file = open("cifar10.coe","w")
file.write("memory_initialization_radix=16;\n")
file.write("memory_initialization_vector=00 \n") #for read mode

#for write mode
file.write("00 ")
file.write('\n')

#CONV1 input: starting address = 2
#size: 32*32*3
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

#CONV1 weight: starting address = 32*32*3+2-1+1 = 3074
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

#CONV1 output & MAXPOOLING1 input: starting address = 3074+3*3*3*16 = 3506
#CONV1 output has 30*30*16 = 14400
for ii in range(16):
	for ir in range(30):
		for ic in range(30):
			file.write("00 ")
			file.write('\n')
#MAXPOOLING1 output & CONV2 input: starting address = 3506+14400 = 17906
#MAXPOOLING1 output & CONV2 input has 15*15*16 = 3600
for ii in range(16):
	for ir in range(15):
		for ic in range(15):
			file.write("00 ")
			file.write('\n')

#CONV2 weight: starting address = 17906+3600 = 21506
#size: 4*4*16*32
for io in range(32):
	for ii in range(16):
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

#CONV2 output & MAXPOOLING2 input: starting address = 21506+4*4*16*32 = 29698
#CONV2 output has 12*12*32 = 4608
for ii in range(32):
	for ir in range(12):
		for ic in range(12):
			file.write("00 ")
			file.write('\n')
#MAXPOOLING2 output & CONV3 input:starting address: 29698+4608 = 34306
#MAXPOOLING2 output & CONV3 input has 6*6*32 = 1152
for ii in range(32):
	for ir in range(6):
		for ic in range(6):
			file.write("00 ")
			file.write('\n')

#CONV3 weight: starting address: 34306+1152 = 35458
#size: 3*3*32*64 = 18432
for io in range(64):
	for ii in range(32):
		if(ii == 0 or ii == 31):
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

#CONV3 output & FC1 input: starting address = 35458+18432 = 53890
#CONV3 output has 4*4*64 = 1024
for ii in range(64):
	for ir in range(4):
		for ic in range(4):
			file.write("00 ")
			file.write('\n')

#FC1 weight: starting address = 53890+1024 = 54914
#size: 4*4*64*500 = 512000
for io in range(100):
	for ii in range(64):
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


for io in range(100):
	for ii in range(64):
		if(ii == 1): 
			for ir in range(4):
				if(ir == 0):
					for ic in range(4):
						if(ic == 1):
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

for io in range(100):
	for ii in range(64):
		if(ii == 2): 
			for ir in range(4):
				if(ir == 0):
					for ic in range(4):
						if(ic == 2):
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

for io in range(100):
	for ii in range(64):
		if(ii == 3): 
			for ir in range(4):
				if(ir == 0):
					for ic in range(4):
						if(ic == 3):
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


for io in range(100):
	for ii in range(64):
		if(ii == 4): 
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


#FC1 output & FC2 input: starting address = 54914+512000 = 566914
#FC1 output has 1*1*500 = 500
for ii in range(500):
	for ir in range(1):
		for ic in range(1):
			file.write("00 ")
			file.write('\n')

#FC2 weight: starting address = 566914+500 = 567414
#size = 1*1*500*10 = 5000
for ii in range(500):
	if(ii == 0):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 100):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 200):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 300):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 400):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 400):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 300):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 200):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 100):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

for ii in range(500):
	if(ii == 0):
		for ir in range(1):
			for ic in range(1):
				file.write("10 ")
				file.write('\n')
	else:
		for ir in range(1):
			for ic in range(1):
				file.write("00 ")
				file.write('\n')

#FC2 output: starting address = 567414+5000 = 572414




