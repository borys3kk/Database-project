import csv;

header = ['IdReservationStatus', 'Name']
row = [
	[0, 'Waiting'],
	[1, 'Accepted'],
	[2, 'Canceled']
];

f = open('reservationStatus.csv', 'w')
writer = csv.writer(f, delimiter=';')
writer.writerow(header)
writer.writerows(row)
f.close()
