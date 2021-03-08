file = open("firstlayer.coe","w")
file.write("memory_initialization_radix=16;\n")
file.write("memory_initialization_vector=00 \n")

file.write("00 ")
file.write("\n")

#write input 
#address starting at 2
data = 1
for ir in range(28):
	if(ir%4 == 0):
		for ic in range(28):
			if(ic%4 == 0):
				if(data == 5):
					data = 1
				file.write(str(data)+"0 ")
				file.write("\n")
				data += 1
			else:
				file.write("00 ")
				file.write("\n")
		data = 1
	else:
		for ic in range(28):
			file.write("00 ")
			file.write("\n")

#write some margin for input and weight address
for i in range(20):
	file.write("00 ")
	file.write("\n")

#write weight address
#address start at 28*28+20 = 804, 804+2 = 806
for io in range(4):
	for ikr in range(4):
		if(ikr == 0):
			for ikc in range(4):
				if(ikc == 0):
					file.write("10 ")
					file.write("\n")
				else:
					file.write("00 ")
					file.write("\n")
		else:
			for ikc in range(4):
				file.write("00 ")
				file.write("\n")

#write some margin
for i in range(131):
	file.write("00 ")
	file.write("\n")


for i in range(1000):
	file.write("00 ")
	file.write("\n")
# #2nd input data statr at 1001
# data = 1
# for ii in range(4):
# 	for ir in range(13):
# 		if(ir%2 == 0):
# 			for ic in range(13):
# 				if(ic%2 == 0):
# 					if(data == 5):
# 						data = 1
# 					file.write(str(data)+"0 ")
# 					file.write("\n")
# 					data += 1
# 				else:
# 					file.write("00 ")
# 					file.write("\n")
# 			data = 1
# 		else:
# 			for ic in range(13):
# 				file.write("00 ")
# 				file.write("\n")
# #write some margin
# for i in range(324):
# 	file.write("00 ")
# 	file.write("\n")




#2nd weight address start at 2001
for io in range(4):
	for ii in range(4):
		if(ii == 0 or ii == 3):
			for ikr in range(5):
				if(ikr == 0):
					for ikc in range(5):
						if(ikc == 0):
							file.write("10 ")
							file.write("\n")
						else:
							file.write("00 ")
							file.write("\n")
				else:
					for ikc in range(5):
						file.write("00 ")
						file.write("\n")
		else:
			for ikr in range(5):
				for ikc in range(5):
						file.write("00 ")
						file.write("\n")

#write some margin
for i in range(100):
	file.write("00 ")
	file.write("\n")

#3rd input data start at 2501	
for i in range(100):
	file.write("00 ")
	file.write("\n")
# data = 2
# for ii in range(4):
# 	for ir in range(5):
# 		for ic in range(5):
# 			if(data > 8):
# 				data = 2
# 			file.write(str(data)+"0 ")
# 			file.write("\n")
# 			data += 2
# 		data = 2

#3rd weight start at 2601
for io in range(10):
	for ii in range(4):
		if(ii == 0):
			for ikr in range(5):
				if(ikr == 0):
					for ikc in range(5):
						if(ikc == 0):
							file.write("10 ")
							file.write("\n")
						else:
							file.write("00 ")
							file.write("\n")
				else:
					for ikc in range(5):
						file.write("00 ")
						file.write("\n")
		else:
			for ikr in range(5):
				for ikc in range(5):
						file.write("00 ")
						file.write("\n")

for io in range(10):
	for ii in range(4):
		if(ii == 0):
			for ikr in range(5):
				if(ikr == 0):
					for ikc in range(5):
						if(ikc == 1):
							file.write("10 ")
							file.write("\n")
						else:
							file.write("00 ")
							file.write("\n")
				else:
					for ikc in range(5):
						file.write("00 ")
						file.write("\n")
		else:
			for ikr in range(5):
				for ikc in range(5):
						file.write("00 ")
						file.write("\n")

for io in range(10):
	for ii in range(4):
		if(ii == 0):
			for ikr in range(5):
				if(ikr == 0):
					for ikc in range(5):
						if(ikc == 2):
							file.write("10 ")
							file.write("\n")
						else:
							file.write("00 ")
							file.write("\n")
				else:
					for ikc in range(5):
						file.write("00 ")
						file.write("\n")
		else:
			for ikr in range(5):
				for ikc in range(5):
						file.write("00 ")
						file.write("\n")

for io in range(10):
	for ii in range(4):
		if(ii == 0):
			for ikr in range(5):
				if(ikr == 0):
					for ikc in range(5):
						if(ikc == 3):
							file.write("10 ")
							file.write("\n")
						else:
							file.write("00 ")
							file.write("\n")
				else:
					for ikc in range(5):
						file.write("00 ")
						file.write("\n")
		else:
			for ikr in range(5):
				for ikc in range(5):
						file.write("00 ")
						file.write("\n")

# file.write("4th input start ")
# file.write("\n")
#4th input data start at 6601
#write some margin

for i in range(100):
	file.write("00 ")
	file.write("\n")

#4th weight data start at 6701
for i in range(40):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(10):
	file.write("00 ")
	file.write("\n")
for i in range(30):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(20):
	file.write("00 ")
	file.write("\n")
for i in range(20):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(30):
	file.write("00 ")
	file.write("\n")
for i in range(10):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(40):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(40):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(30):
	file.write("00 ")
	file.write("\n")
for i in range(10):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(20):
	file.write("00 ")
	file.write("\n")
for i in range(20):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(10):
	file.write("00 ")
	file.write("\n")
for i in range(30):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")

for i in range(40):
	if(i == 0):
		file.write("10 ")
		file.write("\n")
	else:
		file.write("00 ")
		file.write("\n")



file.write("end ")
file.write("\n")












