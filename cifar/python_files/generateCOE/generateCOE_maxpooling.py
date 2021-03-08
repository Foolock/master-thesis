file = open("CONV2_output.coe","w")
file.write("memory_initialization_radix=16;\n")
file.write("memory_initialization_vector=00 \n") #for read mode

#inaddr
#starting address: 1
data = 1
for ii in range(32):
	for ir in range(12):
		if(ir%2 == 0):
			for ic in range(12):
				if(ic%2 == 0):
					if(data == 5):
						data = 1
					file.write(str(data)+"0 ")
					file.write('\n')
					data += 1
				else:
					file.write("00 ")
					file.write('\n')
			data = 1
		else:
			for ic in range(12):
				file.write("00 ")
				file.write('\n')
		

#outaddr = 5000