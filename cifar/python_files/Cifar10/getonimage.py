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
      self.fc1 = nn.Linear(4*4*64, 50,bias=False) # I/p image size is 32*32, after 3 MaxPooling layers it reduces to 4*4 and 64 because our last conv layer has 64 outputs. Output nodes is 500
      # self.dropout1 = nn.Dropout(0.5)
      self.fc2 = nn.Linear(50, 10,bias=False) # output nodes are 10 because our dataset have 10 different categories
    def forward(self, x):
      x = F.relu(self.conv1(x)) #Apply relu to each output of conv layer.
      x = F.max_pool2d(x, 2, 2) # Max pooling layer with kernal of 2 and stride of 2
      x = F.relu(self.conv2(x))
      x = F.max_pool2d(x, 2, 2)
      x = F.relu(self.conv3(x))
      # x = F.max_pool2d(x, 2, 2)
      #x.size=(1,64,4,4)
      x = x.view(-1, 4*4*64) # flatten our images to 1D to input it to the fully connected layers
      x = F.relu(self.fc1(x))
      # x = self.dropout1(x) # Applying dropout b/t layers which exchange highest parameters. This is a good practice
      x = self.fc2(x)
      return x

model = LeNet().to(device) 
#loading the model
model.load_state_dict(torch.load('./model_fc1_outputChannel_50.pt'))
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

decimal = 14 #decimal point of the data stored in COE

# print(inputs_buffer[0]*2**decimal)

output = model(inputs_buffer[2])
print(output)

output2 = model(inputs_buffer[2]*2**decimal)
print(output2)


# ————————————————
# 版权声明：本文为CSDN博主「shangyj17」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
# 原文链接：https://blog.csdn.net/qq_17753903/article/details/88931612
def dec2bin(dec_num, bit_wide=20):
    _, bin_num_abs = bin(dec_num).split('b')
    if len(bin_num_abs) > bit_wide:
        raise ValueError           # 数值超出bit_wide长度所能表示的范围
    else:
        if dec_num >= 0:
            bin_num = bin_num_abs.rjust(bit_wide, '0')
        else:
            _, bin_num = bin(2**bit_wide + dec_num).split('b')
    return bin_num

def bin2dec(bin_string):
  dec_num = 0
  for i in range(len(bin_string)):
    if(bin_string[len(bin_string)-i-1]=='1'):
      dec_num += 2**i
  return dec_num


#start writing COE
file = open("one_image_bin.bin","wb")
#first get the one picture data
#CONV1 input: starting address = 2
#size: 32*32*3
inputs_buffer[200] = torch.round(inputs_buffer[200]*2**decimal)

print(int(inputs_buffer[200][0][0][0][0].item()))
print(dec2bin(int(inputs_buffer[200][0][0][0][0].item())))
print(bin2dec(dec2bin(int(inputs_buffer[200][0][0][0][0].item()))))





# #one image
# # torch.size([batch_size, channels, height(rows), width(cols)])
# for ii in range(inputs_buffer[200].size()[1]):
#       for ir in range(inputs_buffer[200].size()[2]):
#             for ic in range(inputs_buffer[200].size()[3]):
#                   file.write("0b"+dec2bin(int(inputs_buffer[200][0][ii][ir][ic].item()))+", ")
#                   file.write('\n')

# #one image, in dec format
# # torch.size([batch_size, channels, height(rows), width(cols)])
# for ii in range(inputs_buffer[200].size()[1]):
#       for ir in range(inputs_buffer[200].size()[2]):
#             for ic in range(inputs_buffer[200].size()[3]):
#                   file.write(str(bin2dec(dec2bin(int(inputs_buffer[200][0][ii][ir][ic].item()))))+", ")
#                   file.write('\n')

#one image, in binary format
# torch.size([batch_size, channels, height(rows), width(cols)])
for ii in range(inputs_buffer[200].size()[1]):
      for ir in range(inputs_buffer[200].size()[2]):
            for ic in range(inputs_buffer[200].size()[3]):
                  file.write(bin2dec(dec2bin(int(inputs_buffer[200][0][ii][ir][ic].item()))).to_bytes(3,'little'))






