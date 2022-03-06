import csv
import random
import datetime

f = open('reservationCompanyEmployee.csv', 'w')

writer = csv.writer(f, delimiter=';')
header = ['IdReservationCompanyEmployee', 'IdReservation', 'IdCompanyEmployee']
writer.writerow(header)

# Na firmę imiennie, gdzie w każdej rezerwacji jest 11 osób: amount = 11 w ilości: 250
cnt = 1
for i in range(1,276):
    """
    arr = []
    for k in range(0,11):
        arr.append(random.randint(1, 601))
        for l in range(len(arr)-2, -1):
            if arr[l] == arr[len(arr)-1]:
                k -= 1
    """
    """
    if i == 275:
        cnt += 1 
        writer.writerow([cnt, 775,350])   
    else:
        """
    for k in range(0, 10):
        j = 500 + i
        string = [cnt, j, (cnt-1)%600+1]
        cnt += 1
        writer.writerow(string)

# Na firmę w ilości 250
for i in range(776,1001):
    j = 775 + i
    string = [cnt, i, i-775]
    cnt += 1
    writer.writerow(string)

f.close()
