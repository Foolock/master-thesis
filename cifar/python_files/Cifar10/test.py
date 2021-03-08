import torch
import torch.nn.functional as F
from torchvision import datasets,transforms
from torch import nn
import matplotlib.pyplot as plt
import numpy as np

x = torch.randn(3,4,4)
print(x)
x = x.view(-1,3*4*4)
print(x)