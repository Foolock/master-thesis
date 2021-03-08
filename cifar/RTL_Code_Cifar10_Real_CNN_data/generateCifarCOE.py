import torch
import torch.nn.functional as F
from torchvision import datasets,transforms
from torch import nn
import matplotlib.pyplot as plt
import numpy as np

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

model = LeNet().to(device) 
#loading the model
model.load_state_dict(torch.load('./model.pt'))
model.eval()
#loading the input picture
transform = transforms.Compose([transforms.Resize((32,32)),
                               transforms.ToTensor(),
                               transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
                               ])
validation_dataset = datasets.CIFAR10(root='./data', train=False, download=True, transform=transform)
validation_loader = torch.utils.data.DataLoader(validation_dataset, batch_size = 1, shuffle=False)

inputs_buffer = []
for inputs, labels in validation_loader:
      inputs_buffer.append(inputs)

output = model(inputs_buffer[0])
print(output)

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

decimal = 12 #decimal point of the data stored in COE

#start writing COE
file = open("cifar10.coe","w")
file.write("memory_initialization_radix=2;\n")
file.write("memory_initialization_vector=0000000000000000 \n") #for read mode

#for write mode
file.write("0000000000000000 ")
file.write('\n')

#first get the one picture data
#CONV1 input: starting address = 2
#size: 32*32*3
inputs_buffer[0] = torch.round(inputs_buffer[0]*2**decimal)


# torch.size([batch_size, channels, height(rows), width(cols)])
for ii in range(inputs_buffer[0].size()[1]):
      for ir in range(inputs_buffer[0].size()[2]):
            for ic in range(inputs_buffer[0].size()[3]):
                  file.write(dec2bin(int(inputs_buffer[0][0][ii][ir][ic].item()))+" ")
                  file.write('\n')

#then write the weight
#weight  [io][ii][ir][ic]
#CONV1 weight: starting address = 32*32*3+2-1+1 = 3074
# print(model.state_dict()['conv1.weight'].size())

for io in range(model.state_dict()['conv1.weight'].size()[0]):
      for ii in range(model.state_dict()['conv1.weight'].size()[1]):
            for ir in range(model.state_dict()['conv1.weight'].size()[2]):
                  for ic in range(model.state_dict()['conv1.weight'].size()[3]):
                        file.write(dec2bin(int(torch.round(model.state_dict()['conv1.weight'][io][ii][ir][ic]*2**decimal).item()))+" ")
                        file.write('\n')

#CONV1 output & MAXPOOLING1 input: starting address = 3074+3*3*3*16 = 3506
#CONV1 output has 30*30*16 = 14400
for ii in range(16):
      for ir in range(30):
            for ic in range(30):
                  file.write("0000000000000000 ")
                  file.write('\n')
#MAXPOOLING1 output & CONV2 input: starting address = 3506+14400 = 17906
#MAXPOOLING1 output & CONV2 input has 15*15*16 = 3600
for ii in range(16):
      for ir in range(15):
            for ic in range(15):
                  file.write("0000000000000000 ")
                  file.write('\n')

#CONV2 weight: starting address = 17906+3600 = 21506
#size: 4*4*16*32
# print(model.state_dict()['conv2.weight'].size())
for io in range(model.state_dict()['conv2.weight'].size()[0]):
      for ii in range(model.state_dict()['conv2.weight'].size()[1]):
            for ir in range(model.state_dict()['conv2.weight'].size()[2]):
                  for ic in range(model.state_dict()['conv2.weight'].size()[3]):
                        file.write(dec2bin(int(torch.round(model.state_dict()['conv2.weight'][io][ii][ir][ic]*2**decimal).item()))+" ")
                        file.write('\n')

#CONV2 output & MAXPOOLING2 input: starting address = 21506+4*4*16*32 = 29698
#CONV2 output has 12*12*32 = 4608
for ii in range(32):
      for ir in range(12):
            for ic in range(12):
                  file.write("0000000000000000 ")
                  file.write('\n')
#MAXPOOLING2 output & CONV3 input:starting address: 29698+4608 = 34306
#MAXPOOLING2 output & CONV3 input has 6*6*32 = 1152
for ii in range(32):
      for ir in range(6):
            for ic in range(6):
                  file.write("0000000000000000 ")
                  file.write('\n')

#CONV3 weight: starting address: 34306+1152 = 35458
#size: 3*3*32*64 = 18432
# print(model.state_dict()['conv3.weight'].size())
for io in range(model.state_dict()['conv3.weight'].size()[0]):
      for ii in range(model.state_dict()['conv3.weight'].size()[1]):
            for ir in range(model.state_dict()['conv3.weight'].size()[2]):
                  for ic in range(model.state_dict()['conv3.weight'].size()[3]):
                        file.write(dec2bin(int(torch.round(model.state_dict()['conv3.weight'][io][ii][ir][ic]*2**decimal).item()))+" ")
                        file.write('\n')

#CONV3 output & FC1 input: starting address = 35458+18432 = 53890
#CONV3 output has 4*4*64 = 1024
for ii in range(64):
      for ir in range(4):
            for ic in range(4):
                  file.write("0000000000000000 ")
                  file.write('\n')

#FC1 weight: starting address = 53890+1024 = 54914
#size: 4*4*64*500 = 512000
# print(model.state_dict()['fc1.weight'].size())
for io in range(model.state_dict()['fc1.weight'].size()[0]):
      for i_irc in range(model.state_dict()['fc1.weight'].size()[1]):
            file.write(dec2bin(int(torch.round(model.state_dict()['fc1.weight'][io][i_irc]*2**decimal).item()))+" ")
            file.write('\n')

#FC1 output & FC2 input: starting address = 54914+512000 = 566914
#FC1 output has 1*1*500 = 500
for ii in range(500):
      for ir in range(1):
            for ic in range(1):
                  file.write("0000000000000000 ")
                  file.write('\n')

#FC2 weight: starting address = 566914+500 = 567414
#size = 1*1*500*10 = 5000
# print(model.state_dict()['fc2.weight'].size())
for io in range(model.state_dict()['fc2.weight'].size()[0]):
      for i_irc in range(model.state_dict()['fc2.weight'].size()[1]):
            file.write(dec2bin(int(torch.round(model.state_dict()['fc2.weight'][io][i_irc]*2**decimal).item()))+" ")
            file.write('\n')

#FC2 output: starting address = 567414+5000 = 572414







