import csv
import random
import datetime

f = open('customerDiscount.csv', 'w')

writer = csv.writer(f, delimiter=';')
header = ['IdCustomerDiscount', 'IdCustomer', 'Discount', 'Active', 'BeginDate', 'EndDate']
writer.writerow(header)

for i in range(1, 71):
	format_string = "%Y-%m-%d %H:%M:%S"
	#two_hours = datetime.timedelta(years=+100)
	date_string = datetime.datetime(year=random.randint(2021,2022), month=random.randint(1, 12), day=random.randint(1, 28), hour=random.randint(10,21), minute=random.randint(0, 59), second=0)
	date_string2 = datetime.datetime(year=9999, month=12, day=31, hour=23, minute=59, second=59)
	string = [i, i, 3, random.randint(0,1) , date_string.strftime(format_string), date_string2]
	writer.writerow(string)

for i in range(71,100):
	j = 500 + i
	format_string = "%Y-%m-%d %H:%M:%S"
	two_hours = datetime.timedelta(days=+7)
	date_string = datetime.datetime(year=random.randint(2021,2022), month=random.randint(1, 12), day=random.randint(1, 28), hour=random.randint(10,21), minute=random.randint(0, 59), second=0)
	string = [j, i, 5, random.randint(0,1), date_string.strftime(format_string), (date_string + two_hours).strftime(format_string)]
	writer.writerow(string)

f.close()
