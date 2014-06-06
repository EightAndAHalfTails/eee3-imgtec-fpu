'''
This program translate ibm test vector files to ieee754 format text files

author: Weng Lio
date: 02/06/2014
'''

import os
num_of_bits = 8


for file in os.listdir("."):
	if file.endswith(".fptest"):
		print("Reading file:", file)
		f = open(file, 'r')
		fout = open(file.replace(".fptest", "_bin.txt", 1), 'w')
		for i, line in enumerate(f):
			if i > 4:					#all fptest files starts after line 4
				parts = line.split()
				num = [];
				if parts[0][0:3] == "b32":
					if parts[2][0] == 'x' or parts[2] == 'i' or parts[2] == "oz":
						num.append(parts[3])
						num.append(parts[4])
					else:
						num.append(parts[2])
						num.append(parts[3])

					if num[1] == "->":
						break
					#translate <sign'1.'mantissa'P'exponent> to IEEE 754 format
					s = [0]*2
					e = [0]*2
					m = [0]*2

					for n in range(0,2):

						if num[n][1:] == "Zero":
							num[n] = num[n][0]+"1.000000P-127"
						elif num[n][1:] == "Inf":
							num[n] = num[n][0]+"1.000000P+128"
						elif num[n][:] == "Q" or num[n][:] == "S":
							num[n] = "+1.000001P+128"

						if num[n][0] == '+':
							s[n] = '0'
						else:
							s[n] = '1'


						exp = str(int(num[n][10:],10)+127)
						#print(exp)
						man = str(num[n][3:9])
						#print(man)

						e[n] = str(bin(int(exp,10))[2:].zfill(8));
						m[n] = str(bin(int(man,16))[2:].zfill(23));

						snum = str(s[n]) + (e[n]) + (m[n])
						fout.write(snum)
						fout.write(" ")

					fout.write('\n')


		f.close()