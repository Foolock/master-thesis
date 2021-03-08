import torch
import torch.nn.functional as F
from torchvision import datasets,transforms
from torch import nn
import matplotlib.pyplot as plt
import numpy as np

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

check_conv1_output = []

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
      check_conv1_output.append(x)
      x = F.max_pool2d(x, 2, 2) # Max pooling layer with kernal of 2 and stride of 2
      x = F.relu(self.conv2(x))
      x = F.max_pool2d(x, 2, 2)
      x = F.relu(self.conv3(x))
      # x = F.max_pool2d(x, 2, 2)
      x = x.view(-1, 4*4*64) # flatten our images to 1D to input it to the fully connected layers
      # print(x)
      x = F.relu(self.fc1(x))
      # x = self.dropout1(x) # Applying dropout b/t layers which exchange highest parameters. This is a good practice
      # print(x)
      x = self.fc2(x)
      return x

model = LeNet().to(device) # run our model on cuda GPU for faster results

model.load_state_dict(torch.load('./model.pt'))
model.eval()
# Print model's state_dict
# print("Model's state_dict:")
# for param_tensor in model.state_dict():
#     print(param_tensor, "\t", model.state_dict()[param_tensor].size())

#weight  [io][ii][ir][ic]

# print(model.state_dict()['conv1.weight'][15][0][0][1].item())
# print(model.state_dict()['conv1.weight'])


transform_train = transforms.Compose([transforms.Resize((32,32)),  #resises the image so it can be perfect for our model.
                                      transforms.RandomHorizontalFlip(), # FLips the image w.r.t horizontal axis
                                      transforms.RandomRotation(10),     #Rotates the image to a specified angel
                                      transforms.RandomAffine(0, shear=10, scale=(0.8,1.2)), #Performs actions like zooms, change shear angles.
                                      transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2), # Set the color params
                                      transforms.ToTensor(), # comvert the image to tensor so that it can work with torch, and converts the value from [0,255] into [0.0,1.0]
                                      transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)) #Normalize all the images
                               ])
 
 
transform = transforms.Compose([transforms.Resize((32,32)),
                               transforms.ToTensor(),
                               transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
                               ])
training_dataset = datasets.CIFAR10(root='./data', train=True, download=True, transform=transform_train) # Data augmentation is only done on training images
validation_dataset = datasets.CIFAR10(root='./data', train=False, download=True, transform=transform)
 
training_loader = torch.utils.data.DataLoader(training_dataset, batch_size=100, shuffle=True) # Batch size of 100 i.e to work with 100 images at a time
validation_loader = torch.utils.data.DataLoader(validation_dataset, batch_size = 1, shuffle=False)

# inputs_buffer = []
# max_value = 0
# min_value = 0
# for inputs, labels in validation_loader:
#       if(inputs.max()>max_value):
#             max_value = inputs.max()
#       if(inputs.min()<min_value):
#             min_value = inputs.min()

# print(max_value)
# print(min_value)

# print(len(inputs_buffer[0][0][0][0]))

# print(model.state_dict()['fc2.weight'].min())
 
    


# # torch.size([batch_size, channels, height(rows), width(cols)])
# print(inputs_buffer[0].size())

# file = open("cifar10.coe","w")
# file.write("memory_initialization_radix=16;\n")
# file.write("memory_initialization_vector=00 \n") #for read mode

# #for write mode
# file.write("00 ")
# file.write('\n')

# #CONV1 input: starting address = 2
# #size: 32*32*3
# for ii in range(inputs_buffer[0].size()[1]):
#       for ir in range(inputs_buffer[0].size()[2]):
#             for ic in range(inputs_buffer[0].size()[3]):
#                   file.write(str(int(inputs_buffer[0][0][ii][ir][ic].item()*2**5))+' ')
#                   # file.write('\n')
#             file.write('\n')
#       file.write('\n')
#       file.write('\n')

decimal = 12

# print(inputs_buffer[0][0][0][0][0].item())
# print(int(inputs_buffer[0][0][0][0][0].item()*32))
# print(inputs_buffer[0].data)
# print(inputs_buffer[0].data*2**decimal)
# print(torch.round(inputs_buffer[0].data*2**decimal))

# inputs_buffer[0] = torch.round(inputs_buffer[0]*2**decimal)
# print(inputs_buffer[0])


# ————————————————
# 版权声明：本文为CSDN博主「shangyj17」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
# 原文链接：https://blog.csdn.net/qq_17753903/article/details/88931612
def dec2bin(dec_num, bit_wide=16):
    _, bin_num_abs = bin(dec_num).split('b')
    if len(bin_num_abs) > bit_wide:
        raise ValueError           # 数值超出bit_wide长度所能表示的范围
    else:
        if dec_num >= 0:
            bin_num = bin_num_abs.rjust(bit_wide, '0')
        else:
            _, bin_num = bin(2**bit_wide + dec_num).split('b')
    return bin_num

# print(dec2bin(-7))

with torch.no_grad():
      inputs_buffer = []
      for inputs, labels in validation_loader:
            inputs_buffer.append([inputs,labels])
      print(inputs_buffer[0][0][0][0][0][0])
      print(model.state_dict()['conv1.weight'][0][0][0][0])
      output = model(inputs_buffer[0][0])
      print(output)
      _, pred = torch.max(output, 1)
      for i in range(output.size()[1]):
            print(torch.round(output[0][i]*2**decimal))
      print(pred)
      print(inputs_buffer[0][1])
      output2 = torch.zeros(1,10)
      print(output2)
      output2[0][0] = -12927
      output2[0][1] = 26
      output2[0][2] = -9511
      output2[0][3] = 14535
      output2[0][4] = -12422
      output2[0][5] = -367
      output2[0][6] = -11746
      output2[0][7] = -10301
      output2[0][8] = 2574
      output2[0][9] = -16278
      print(output2)
      output2 = output2*2**(-decimal)
      print(output2)
      _, pred2 = torch.max(output, 1)
      print(pred2)

# print(check_conv1_output[0].size())
# print(check_conv1_output[0][0][2][0][0])









