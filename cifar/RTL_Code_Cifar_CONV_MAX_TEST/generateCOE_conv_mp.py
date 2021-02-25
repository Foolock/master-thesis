file = open("conv_mp_test.coe","w")
file.write("memory_initialization_radix=16;\n")
file.write("memory_initialization_vector=00 \n") #for read mode

#for write mode
file.write("00 ")
file.write('\n')

#first layer input
#starting address: 2
#input size = 15*15*3
data = 1
for ii in range(3):
	for ir in range(15):
		if(ir%2 == 0):
			for ic in range(15):
				if(ic%2 == 0):
					if(data == 5):
						data = 1
					file.write(str(data)+"0 ")
					file.write('\n')
					data += 1
				else:
					file.write("00 ")
					file.write('\n')
		else:
			for ic in range(15):
				file.write("00 ")
				file.write('\n')

#weight start at 15*15*3 + 2 -1 +1 = 677
for io in range(8):
	for ii in range(3):
		if(ii == 0):
			for ir in range(4):
				if(ir == 0):
					for ic in range(4):
						if(ic == 0):
							file.write("10 ")
							file.write('\n')
						else:
							file.write("00 ")
							file.write('\n')
				else:
					for ic in range(4):
						file.write("00 ")
						file.write('\n')
		else:
			for ir in range(4):
				for ic in range(4):
					file.write("00 ")
					file.write('\n')




#CONV1 output start at 15*15*3+2+4*4*3*8-1+1 = 1061
#there will be 12*12*8 = 1152
for ii in range(8):
	for ir in range(12):
		for ic in range(12):
			file.write("00 ")
			file.write('\n')
#so the output address for MAXPOOLING is 1061+1152 = 2213

#CONV2 input: 6*6*8 = 288
for ii in range(8):
	for ir in range(6):
		for ic in range(6):
			file.write("00 ")
			file.write('\n')

#CONV2 weight start at 2213+288 = 2501
for io in range(16):
	for ii in range(8):
		if(ii == 0 or ii == 7):
			for ir in range(4):
				if(ir == 0):
					for ic in range(4):
						if(ic == 0):
							file.write("10 ")
							file.write('\n')
						else:
							file.write("00 ")
							file.write('\n')
				else:
					for ic in range(4):
						file.write("00 ")
						file.write('\n')
		else:
			for ir in range(4):
				for ic in range(4):
					file.write("00 ")
					file.write('\n')












