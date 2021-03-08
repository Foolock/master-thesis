import torch
import torch.nn.functional as F
from torchvision import datasets,transforms
from torch import nn
import matplotlib.pyplot as plt
import numpy as np

conv1 = nn.Conv2d(3, 16, 3, 1, padding=0)
conv2 = nn.Conv2d(16, 32, 4, 1, padding=0)
conv3 = nn.Conv2d(32, 64, 3, 1, padding=0)

input = torch.randn([1,3,32,32]) #batch size, channel, width, height
output = conv1(input)
output = F.max_pool2d(output,2, 2)
output = conv2(output)
output = F.max_pool2d(output,2, 2)
output = conv3(output)

print(input.size())
print(output.size())