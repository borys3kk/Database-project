import csv
import random
import datetime

f = open('companyEmployee.csv', 'w')
randData = open('randomdataCustomer.csv', 'r')
reader = csv.reader(randData, delimiter=';')
writer = csv.writer(f, delimiter=';')
header = ['IdCompanyEmployee', 'IdCompany', 'FirstName', 'LastName', 'Email', 'Phone']
headerReader = reader.__next__()

writer.writerow(header)
# Employees:600
for i in range(1, 601):
	string_readed = reader.__next__()
	#print(string_readed)
	string = [i, (i-1)%20+1, string_readed[0], string_readed[1], string_readed[2], string_readed[3]]
	writer.writerow(string)


f.close()
randData.close()
