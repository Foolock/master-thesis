file = open("vgg.coe","w")
file.write("memory_initialization_radix=16;\n")
file.write("memory_initialization_vector=00 \n") #for read mode

#for write mode
file.write("00 ")
file.write('\n')

#first layer input
#starting address: 2
data = 1
for ii in range(3):
	for ir in range(32):
		if(ir%4 == 0):
			for ic in range(32):
				if(ic%4 == 0):
					if(data == 5):
						data = 1
					file.write(str(data)+"0 ")
					file.write('\n')
					data += 1
				else:
					file.write("00 ")
					file.write('\n')
		else:
			for ic in range(32):
				file.write("00 ")
				file.write('\n')

#first layer weight 
#starting address: 32*32*3+2-1+1 = 3074
for io in range(16):
	for ii in range(3):
		if(ii == 0):
			for ir in range(3):
				if(ir == 0):
					for ic in range(3):
						if(ic == 0):
							file.write("10 ")
							file.write('\n')
						else:
							file.write("00 ")
							file.write('\n')
				else:
					for ic in range(3):
						file.write("00 ")
						file.write('\n')
		else:
			for ir in range(3):
				for ic in range(3):
					file.write("00 ")
					file.write('\n')

#second layer input
#starting in address: 3072+3*3*3*16+2-1+1=3506


		

