import torch
import torch.nn.functional as F
from torchvision import datasets,transforms
from torch import nn
import matplotlib.pyplot as plt
import numpy as np
import copy
from collections import namedtuple
import torch
import torch.nn as nn

criterion = nn.CrossEntropyLoss() 

QTensor = namedtuple('QTensor', ['tensor', 'scale', 'zero_point'])

def calcScaleZeroPoint(min_val, max_val,num_bits=8):
  # Calc Scale and zero point of next 
  qmin = 0.
  qmax = 2.**num_bits - 1.

  scale = (max_val - min_val) / (qmax - qmin)

  initial_zero_point = qmin - min_val / scale
  
  zero_point = 0
  if initial_zero_point < qmin:
      zero_point = qmin
  elif initial_zero_point > qmax:
      zero_point = qmax
  else:
      zero_point = initial_zero_point

  zero_point = int(zero_point)

  return scale, zero_point

def quantize_tensor(x, num_bits=8, min_val=None, max_val=None):
    
    if not min_val and not max_val: 
      min_val, max_val = x.min(), x.max()

    qmin = 0.
    qmax = 2.**num_bits - 1.

    scale, zero_point = calcScaleZeroPoint(min_val, max_val, num_bits)
    q_x = zero_point + x / scale
    q_x.clamp_(qmin, qmax).round_()
    q_x = q_x.round().byte()
    
    return QTensor(tensor=q_x, scale=scale, zero_point=zero_point)

def dequantize_tensor(q_x):
    return q_x.scale * (q_x.tensor.float() - q_x.zero_point)


def quantizeLayer(x, layer, stat, scale_x, zp_x):
  # for both conv and linear layers

  # cache old values
  W = layer.weight.data
  print(W)
  # B = layer.bias.data

  # quantise weights, activations are already quantised
  w = quantize_tensor(layer.weight.data) 
  # b = quantize_tensor(layer.bias.data)
  print(w)

  layer.weight.data = w.tensor.float()
  # layer.bias.data = b.tensor.float()

  # This is Quantisation Artihmetic
  scale_w = w.scale
  zp_w = w.zero_point
  # scale_b = b.scale
  # zp_b = b.zero_point
  
  scale_next, zero_point_next = calcScaleZeroPoint(min_val=stat['min'], max_val=stat['max'])

  # Preparing input by shifting
  X = x.float() - zp_x
  layer.weight.data = scale_x * scale_w*(layer.weight.data - zp_w)
  # layer.bias.data = scale_b*(layer.bias.data + zp_b)

  # All int computation
  x = (layer(X)/ scale_next) + zero_point_next 
  
  # Perform relu too
  x = F.relu(x)

  # Reset weights for next forward pass
  layer.weight.data = W
  # layer.bias.data = B
  
  return x, scale_next, zero_point_next

# Get Min and max of x tensor, and stores it
def updateStats(x, stats, key):
  max_val, _ = torch.max(x, dim=1)
  min_val, _ = torch.min(x, dim=1)
  
  
  if key not in stats:
    stats[key] = {"max": max_val.sum(), "min": min_val.sum(), "total": 1}
  else:
    stats[key]['max'] += max_val.sum().item()
    stats[key]['min'] += min_val.sum().item()
    stats[key]['total'] += 1
  
  return stats

# Reworked Forward Pass to access activation Stats through updateStats function
def gatherActivationStats(model, x, stats):

  stats = updateStats(x.clone().view(x.shape[0], -1), stats, 'conv1')
  
  x = F.relu(model.conv1(x))

  x = F.max_pool2d(x, 2, 2)
  
  stats = updateStats(x.clone().view(x.shape[0], -1), stats, 'conv2')
  
  x = F.relu(model.conv2(x))

  x = F.max_pool2d(x, 2, 2)

  stats = updateStats(x.clone().view(x.shape[0], -1), stats, 'conv3')
  
  x = F.relu(model.conv3(x))

  x = x.view(-1, 4*4*64)
  
  stats = updateStats(x, stats, 'fc1')

  x = F.relu(model.fc1(x))
  
  stats = updateStats(x, stats, 'fc2')

  x = model.fc2(x)

  return stats

# Entry function to get stats of all functions.
def gatherStats(model, test_loader):
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    
    model.eval()
    test_loss = 0
    correct = 0
    stats = {}
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            stats = gatherActivationStats(model, data, stats)
    
    final_stats = {}
    for key, value in stats.items():
      final_stats[key] = { "max" : value["max"] / value["total"], "min" : value["min"] / value["total"] }
    return final_stats

def quantForward(model, x, stats):
  
  # Quantise before inputting into incoming layers
  x = quantize_tensor(x, min_val=stats['conv1']['min'], max_val=stats['conv1']['max'])

  x, scale_next, zero_point_next = quantizeLayer(x.tensor, model.conv1, stats['conv2'], x.scale, x.zero_point)

  x = F.max_pool2d(x, 2, 2)
  
  x, scale_next, zero_point_next = quantizeLayer(x, model.conv2, stats['conv3'], scale_next, zero_point_next)

  x = F.max_pool2d(x, 2, 2)

  x, scale_next, zero_point_next = quantizeLayer(x, model.conv3, stats['fc1'], scale_next, zero_point_next)

  x = x.view(-1, 4*4*64)

  x, scale_next, zero_point_next = quantizeLayer(x, model.fc1, stats['fc2'], scale_next, zero_point_next)
  
  # Back to dequant for final layer
  x = dequantize_tensor(QTensor(tensor=x, scale=scale_next, zero_point=zero_point_next))
   
  x = model.fc2(x)

  return F.log_softmax(x, dim=1)

def testQuant(model, test_loader, quant=False, stats=None):
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            if quant:
              output = quantForward(model, data, stats)
            else:
              output = model(data)
            # test_loss += F.nll_loss(output, target, reduction='sum').item() # sum up batch loss
            # pred = output.argmax(dim=1, keepdim=True) # get the index of the max log-probability
            test_loss += criterion(output, target).item()
            _, pred = torch.max(output, 1)
            # correct += pred.eq(target.view_as(pred)).sum().item()
            correct += torch.sum(pred == target.data)

    test_loss /= len(test_loader.dataset)

    print('\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
        test_loss, correct, len(test_loader.dataset),
        100. * correct / len(test_loader.dataset)))


device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

class LeNet(nn.Module):
    def __init__(self):
      super().__init__()
      self.conv1 = nn.Conv2d(3, 16, 3, 1, padding=0,bias=False) # input is color image, hence 3 i/p channels. 16 filters, kernal size is tuned to 3 to avoid overfitting, stride is 1 , padding is 1 extract all edge features.
      self.conv2 = nn.Conv2d(16, 32, 4, 1, padding=0,bias=False) # We double the feature maps for every conv layer as in pratice it is really good.
      self.conv3 = nn.Conv2d(32, 64, 3, 1, padding=0,bias=False)
      self.fc1 = nn.Linear(4*4*64, 500,bias=False) # I/p image size is 32*32, after 3 MaxPooling layers it reduces to 4*4 and 64 because our last conv layer has 64 outputs. Output nodes is 500
      # self.dropout1 = nn.Dropout(0.5)
      self.fc2 = nn.Linear(500, 10,bias=False) # output nodes are 10 because our dataset have 10 different categories
    def forward(self, x):
      x = F.relu(self.conv1(x)) #Apply relu to each output of conv layer.
      x = F.max_pool2d(x, 2, 2) # Max pooling layer with kernal of 2 and stride of 2
      x = F.relu(self.conv2(x))
      x = F.max_pool2d(x, 2, 2)
      x = F.relu(self.conv3(x))
      # x = F.max_pool2d(x, 2, 2)
      x = x.view(-1, 4*4*64) # flatten our images to 1D to input it to the fully connected layers
      x = F.relu(self.fc1(x))
      # x = self.dropout1(x) # Applying dropout b/t layers which exchange highest parameters. This is a good practice
      x = self.fc2(x)
      return x

model = LeNet().to(device) # run our model on cuda GPU for faster results

model.load_state_dict(torch.load('./model.pt'))
model.eval()


q_model = copy.deepcopy(model)

kwargs = {'num_workers': 1, 'pin_memory': True}

transform = transforms.Compose([transforms.Resize((32,32)),
                               transforms.ToTensor(),
                               transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
                               ])
validation_dataset = datasets.CIFAR10(root='./data', train=False, download=True, transform=transform)
validation_loader = torch.utils.data.DataLoader(validation_dataset, batch_size = 64, shuffle=False)

testQuant(q_model, validation_loader, quant=False)

stats = gatherStats(q_model, validation_loader)
print(stats)

testQuant(q_model, validation_loader, quant=True, stats=stats)

print(q_model.state_dict()['conv1.weight'])

