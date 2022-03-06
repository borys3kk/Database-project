import csv
import random
import datetime

f = open('company.csv', 'w')
randData = open('randomdataCompany.csv', 'r')
reader = csv.reader(randData, delimiter=';')
writer = csv.writer(f, delimiter=';')
header = ['IdCompany', 'Name', 'Nip', 'Address', 'PostCode', 'City', 'Country','Email', 'Phone']
headerReader = reader.__next__()

writer.writerow(header)
# Companys: 20
for i in range(1, 21):
	string_readed = reader.__next__()
	#print(string_readed)
	string = [i, string_readed[0], string_readed[1], string_readed[2], string_readed[3], string_readed[4], string_readed[5], string_readed[6], string_readed[7]]
	writer.writerow(string)

f.close()
randData.close();