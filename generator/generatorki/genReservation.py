import csv
import random
import datetime

f = open('reservation.csv', 'w')

writer = csv.writer(f, delimiter=';')
header = ['IdReservation', 'IdCustomer', 'IdCompany', 'IdOrder', 'IdReservationStatus', 'Amount', 'BeginDate', 'EndDate']
writer.writerow(header)
# Klienci indywidualni w ilości 500
for i in range(1, 501):
	format_string = "%Y-%m-%d %H:%M:%S"
	two_hours = datetime.timedelta(hours=+random.randint(1,3))
	date_string = datetime.datetime(year=random.randint(2021,2022), month=random.randint(1, 12), day=random.randint(1, 28), hour=random.randint(10,21), minute=random.randint(0, 59), second=0)
	string = [i, (i-1)%100+1, 'NULL', i, random.randint(0,2), random.randint(2, 5), date_string.strftime(format_string), (date_string + two_hours).strftime(format_string)]
	writer.writerow(string)
# Na firmę imiennie, gdzie w każdej rezerwacji jest 11 osób: amount = 11 w ilości: 250
for i in range(1,251):
	j = 500 + i
	format_string = "%Y-%m-%d %H:%M:%S"
	two_hours = datetime.timedelta(hours=+random.randint(1,3))
	date_string = datetime.datetime(year=random.randint(2021,2022), month=random.randint(1, 12), day=random.randint(1, 28), hour=random.randint(10,21), minute=random.randint(0, 59), second=0)
	string = [j, 'NULL', (j-1)%20+1, j, random.randint(0,2), 11, date_string.strftime(format_string), (date_string + two_hours).strftime(format_string)]
	writer.writerow(string)

# Na firmę w ilości 250
for i in range(1,251):
	j = 750 + i
	format_string = "%Y-%m-%d %H:%M:%S"
	two_hours = datetime.timedelta(hours=+random.randint(1,3))
	date_string = datetime.datetime(year=random.randint(2021,2022), month=random.randint(1, 12), day=random.randint(1, 28), hour=random.randint(10,21), minute=random.randint(0, 59), second=0)
	string = [j, 'NULL', (j-1)%20+1, j, random.randint(0,2), random.randint(2, 30), date_string.strftime(format_string), (date_string + two_hours).strftime(format_string)]
	writer.writerow(string)

f.close()
