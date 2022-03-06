CREATE VIEW VCompanyReservation AS
SELECT
    r.IdReservation AS 'IdReservation',
    rs.Name AS 'ReservationStatus',
    r.IdOrder AS 'IdOrder',
    r.Amount AS 'Amount',
    ce.FirstName AS 'EmployeeFirstName',
    ce.LastName AS 'EmployeeLastName',
    co.Name AS 'CompanyName',
    co.Nip AS 'CompanyNip',
    r.BeginDate AS 'BeginDate',
    r.EndDate AS 'EndDate'
FROM Reservation r
LEFT JOIN ReservationStatus rs ON (rs.IdReservationStatus = r.IdReservationStatus)
LEFT JOIN ReservationCompanyEmployee rce ON (rce.IdReservation = r.IdReservation)
LEFT JOIN Company co ON (co.IdCompany = r.IdCompany)
LEFT JOIN CompanyEmployee ce ON (ce.IdCompanyEmployee = rce.IdCompanyEmployee)
WHERE r.IdCompany IS NOT NULL


CREATE VIEW VFutureReservation AS
SELECT
    r.IdReservation,
    CASE
        WHEN r.IdCompany IS NULL THEN 'Customer'
        ELSE 'Company'
    END AS 'ReservationFor',
    rs.Name AS 'ReservationStatus',
    r.IdOrder,
    r.Amount,
    r.BeginDate,
    r.EndDate
FROM Reservation r
LEFT JOIN Customer cu ON (cu.IdCustomer = r.IdCustomer)
LEFT JOIN Company co ON (co.IdCompany = r.IdCompany)
LEFT JOIN ReservationStatus rs ON (rs.IdReservationStatus = r.IdReservationStatus)
WHERE r.BeginDate >= GETDATE()


CREATE VIEW VCompletedReservation AS
SELECT
    r.IdReservation,
    CASE
        WHEN r.IdCompany IS NULL THEN 'Customer'
        ELSE 'Company'
    END AS 'ReservationFor',
    rs.Name AS 'ReservationStatus',
    r.IdOrder,
    r.Amount,
    r.BeginDate,
    r.EndDate
FROM Reservation r
LEFT JOIN Customer cu ON (cu.IdCustomer = r.IdCustomer)
LEFT JOIN Company co ON (co.IdCompany = r.IdCompany)
LEFT JOIN ReservationStatus rs ON (rs.IdReservationStatus = r.IdReservationStatus)
WHERE r.IdReservationStatus = 1 AND r.EndDate <= GETDATE()

CREATE VIEW VReservationStatisticsLastWeek AS
SELECT
    DATEPART(WEEKDAY, x.BeginDate),
    x.ReservationFor,
    AVG(x.Amount) AS 'AverageAmount',
    COUNT(CASE WHEN x.IdReservationStatus = 1 THEN 1 END) AS 'Accepted',
    COUNT(*) AS 'Total'
FROM (
    SELECT
        r.IdReservation,
        CASE
            WHEN r.IdCompany IS NULL THEN 'Customer'
            ELSE 'Company'
        END AS 'ReservationFor',
        r.IdReservationStatus,
        rs.Name AS 'ReservationStatus',
        r.Amount,
        r.IdOrder,
        r.BeginDate
    FROM Reservation r
    LEFT JOIN Customer cu ON (cu.IdCustomer = r.IdCustomer)
    LEFT JOIN Company co ON (co.IdCompany = r.IdCompany)
    LEFT JOIN ReservationStatus rs ON (rs.IdReservationStatus = r.IdReservationStatus)
) x
WHERE (x.BeginDate >= DATEADD(day, -7, GETDATE()) AND x.BeginDate <= GETDATE())
GROUP BY DATEPART(WEEKDAY, x.BeginDate), x.ReservationFor


CREATE VIEW VReservationStatisticsLastMonth AS
SELECT
    YEAR(x.BeginDate) AS 'Year',
    MONTH(x.BeginDate) AS 'Month',
    x.ReservationFor,
    AVG(x.Amount) AS 'AverageAmount',
    COUNT(CASE WHEN x.IdReservationStatus = 1 THEN 1 END) AS 'Accepted',
    COUNT(*) AS 'Total'
FROM (
    SELECT
        r.IdReservation,
        CASE
            WHEN r.IdCompany IS NULL THEN 'Customer'
            ELSE 'Company'
        END AS 'ReservationFor',
        r.IdReservationStatus,
        rs.Name AS 'ReservationStatus',
        r.Amount,
        r.IdOrder,
        r.BeginDate
    FROM Reservation r
    LEFT JOIN Customer cu ON (cu.IdCustomer = r.IdCustomer)
    LEFT JOIN Company co ON (co.IdCompany = r.IdCompany)
    LEFT JOIN ReservationStatus rs ON (rs.IdReservationStatus = r.IdReservationStatus)
) x
GROUP BY YEAR(x.BeginDate), MONTH(x.BeginDate), x.ReservationFor
HAVING YEAR(x.BeginDate) = YEAR(GETDATE()) AND MONTH(x.BeginDate) = MONTH(GETDATE())


CREATE VIEW VReservationStatisticsLastYear AS
SELECT
    MONTH(x.BeginDate) AS 'Month',
    x.ReservationFor,
    AVG(x.Amount) AS 'AverageAmount',
    COUNT(CASE WHEN x.IdReservationStatus = 1 THEN 1 END) AS 'Accepted',
    COUNT(*) AS 'Total'
FROM (
    SELECT
        r.IdReservation,
        CASE
            WHEN r.IdCompany IS NULL THEN 'Customer'
            ELSE 'Company'
        END AS 'ReservationFor',
        r.IdReservationStatus,
        rs.Name AS 'ReservationStatus',
        r.Amount,
        r.IdOrder,
        r.BeginDate
    FROM Reservation r
    LEFT JOIN Customer cu ON (cu.IdCustomer = r.IdCustomer)
    LEFT JOIN Company co ON (co.IdCompany = r.IdCompany)
    LEFT JOIN ReservationStatus rs ON (rs.IdReservationStatus = r.IdReservationStatus)
) x
WHERE YEAR(x.BeginDate) = YEAR(GETDATE())
GROUP BY MONTH(x.BeginDate), x.ReservationFor


CREATE VIEW VProduct AS
SELECT
    p.IdProduct AS 'IdProduct',
    p.Name AS 'ProductName',
    p.Description AS 'ProductDescription',
    c.Name AS 'CategoryName',
    c.Description AS 'CategoryDescription',
    p.Active AS 'ProductActive'
FROM Product p
LEFT JOIN Category c ON (c.IdCategory = p.IdProduct)


CREATE VIEW VCustomer AS
SELECT
    c.IdCustomer,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone,
    c.TotalPaid,
    o.Sum AS 'OrderSum',
    o.Count AS 'OrderCount',
    r.Count AS 'ReservationCount'
FROM Customer c
LEFT JOIN (
   SELECT
        o.IdCustomer,
        SUM(o.TotalPrice - (o.Discount / 100 * o.TotalPrice)) AS 'Sum',
        COUNT(*) AS 'Count'
    FROM [Order] o
    WHERE o.IdCustomer IS NOT NULL
    GROUP BY o.IdCustomer
) o ON (o.IdCustomer = c.IdCustomer)
LEFT JOIN (
    SELECT
        r.IdCustomer,
        COUNT(*) AS 'Count'
    FROM Reservation r
    WHERE r.IdCustomer IS NOT NULL
    GROUP BY r.IdCustomer
) r ON (r.IdCustomer = c.IdCustomer)


CREATE VIEW VMenu AS
SELECT
    m.IdMenu AS 'IdMenu',
    m.Day AS 'Day',
    p.Name AS 'ProductName',
    p.Description AS 'ProductDescription',
    c.Name AS 'CategoryName',
    md.Price AS 'ProductPrice',
    p.Active AS 'ProductActive'
FROM Menu m
LEFT JOIN MenuDetail md ON (md.IdMenu = m.IdMenu)
LEFT JOIN Product p ON (p.IdProduct = md.IdProduct)
LEFT JOIN Category c ON (c.IdCategory = p.IdCategory)

CREATE VIEW VSavedCompanies AS
SELECT
    c.IdCompany AS "IdCompany",
    c.Name AS "Company Name",
    c.Nip AS "Company Nip",
    c.Address AS "Company Address",
    c.PostCode AS "Company Postcode",
    c.City AS "Company City",
    c.Country AS "Company Country",
    c.Email AS "Company Email",
    c.Phone AS "Company Phone Number"
FROM Company c;

CREATE VIEW VCompanyEmployees AS
SELECT
    CE.IdCompanyEmployee AS "IdCompanyEmployee",
    CE.FirstName AS "First Name of Employee",
    CE.LastName AS "Last Name of Employee",
    CE.Email AS "Employee Email",
    CE.Phone AS "Employee Phone Number",
    C.Name AS "Company Name",
    C.Nip AS "Company Nip"
FROM CompanyEmployee CE
INNER JOIN Company C ON CE.IdCompany = C.IdCompany;

CREATE VIEW VCustomersDiscounts AS
SELECT
    CD.IdCustomerDiscount AS "IdCustomerDiscount",
    CD.Discount AS "Customer Discount",
    CD.Active AS "Discount Status",
    CD.BeginDate AS "Discount Begin Date",
    CD.EndDate AS "Discount End Date",
    C.FirstName AS "Customer First Name",
    C.LastName AS "Customer Last Name",
    C.TotalPaid AS "Customer Bill"
FROM CustomerDiscount CD
INNER JOIN Customer C ON CD.IdCustomer = C.IdCustomer;

CREATE VIEW VConfigurationVariables AS
SELECT
    C.Name as "Variable Name",
    C.Value AS "Variable value"
FROM Configuration C;

CREATE VIEW VAvailableTables AS
SELECT
    T.IdTable AS "IdTable",
    T.Capacity AS "Amount of seats"
FROM [Table] T
WHERE T.IdTable NOT IN
      (
          SELECT DISTINCT TB.IdTable
          FROM TableBusy TB
          INNER JOIN [Table] T ON T.IdTable = TB.IdTable
          INNER JOIN Reservation R2 ON R2.IdReservation = TB.IdReservation
          WHERE (
                            R2.IdReservationStatus != 2 AND
                            TB.Active != 'false' AND
                            TB.BeginDate <= GETDATE() AND
                            TB.EndDate >= GETDATE()
                    )
      );

CREATE VIEW VBusyTable AS
SELECT DISTINCT
    TB.IdTable AS "IdTable",
    TB.Active AS "Table Status",
    TB.BeginDate AS "Begin of Table Reservation",
    TB.EndDate AS "End of Table Reservation",
    T.Capacity AS "Amount of Seats",
    R2.IdReservation AS "IdReservation",
    R2.IdCustomer AS "IdCustomer",
    R2.IdCompany AS "IdCompany",
    R2.IdOrder AS "IdOrder",
    RS.Name AS "Status of Reservation",
    R2.Amount AS "Reservation Amount"
FROM TableBusy TB
INNER JOIN [Table] T ON T.IdTable = TB.IdTable
INNER JOIN Reservation R2 ON R2.IdReservation = TB.IdReservation
INNER JOIN ReservationStatus RS ON R2.IdReservationStatus = RS.IdReservationStatus
WHERE (
        R2.IdReservationStatus != 2 AND
        TB.Active != 'false' AND
        TB.BeginDate <= GETDATE() AND
        TB.EndDate >= GETDATE()
      );

CREATE VIEW VInvoicesCustomers AS
SELECT
    I.IdInvoice AS "IdInvoice",
    I.Url AS "Address of Invoice",
    I.IssueDate AS "Issue Date of Invoice",
    C.FirstName AS "Customer First Name",
    C.LastName AS "Customer Last Name",
    C.Email AS "Customer Email",
    O.TotalPrice AS "Order Bill"
FROM Invoice I
INNER JOIN InvoiceDetail ID ON I.IdInvoice = ID.IdInvoice
INNER JOIN [Order] O ON O.IdOrder = ID.IdOrder
INNER JOIN Customer C ON O.IdCustomer = C.IdCustomer
WHERE (
        O.IdCustomer IS NOT NULL AND
        O.IdCompany IS NULL
      );

CREATE VIEW VInvoicesCompanies AS
SELECT
    I.IdInvoice AS "IdInvoice",
    I.Url AS "Address of Invoice",
    I.IssueDate AS "Issue Date of Invoice",
    C.Name AS "Company Name",
    C.Nip AS "Company Nip",
    C.Email AS "Company Email",
    O.TotalPrice AS "Order Bill"
FROM Invoice I
INNER JOIN InvoiceDetail ID ON I.IdInvoice = ID.IdInvoice
INNER JOIN [Order] O ON O.IdOrder = ID.IdOrder
INNER JOIN Company C ON O.IdCompany = C.IdCompany
WHERE (
        O.IdCustomer IS NULL AND
        O.IdCompany IS NOT NULL
      );

CREATE VIEW VInvoices AS
SELECT
    I.IdInvoice AS "IdInvoice",
    I.Url AS "Address of Invoice",
    I.IssueDate AS "Issue Date of Invoice",
    O.IdCompany AS "CompanyID",
    O.IdCustomer AS "CustomerID",
    O.TotalPrice AS "Order Bill"
FROM Invoice I
INNER JOIN InvoiceDetail ID ON I.IdInvoice = ID.IdInvoice
INNER JOIN [Order] O ON O.IdOrder = ID.IdOrder;

CREATE VIEW VCustomersDiscountsLastMonth AS
SELECT
    CD.IdCustomerDiscount AS "IdCustomerDiscount",
    CD.Discount AS "Customer Discount",
    CD.Active AS "Discount Status",
    CD.BeginDate AS "Discount Begin Date",
    CD.EndDate AS "Discount End Date",
    C.FirstName AS "Customer First Name",
    C.LastName AS "Customer Last Name",
    C.TotalPaid AS "Customer Bill"
FROM CustomerDiscount CD
INNER JOIN Customer C ON CD.IdCustomer = C.IdCustomer
WHERE (
        CD.BeginDate <= GETDATE() AND
        (DATEDIFF(MONTH,CD.BeginDate, GETDATE()) < 1)
      );

CREATE VIEW VCustomersDiscountsLastWeek AS
SELECT
    CD.IdCustomerDiscount AS "IdCustomerDiscount",
    CD.Discount AS "Customer Discount",
    CD.Active AS "Discount Status",
    CD.BeginDate AS "Discount Begin Date",
    CD.EndDate AS "Discount End Date",
    C.FirstName AS "Customer First Name",
    C.LastName AS "Customer Last Name",
    C.TotalPaid AS "Customer Bill"
FROM CustomerDiscount CD
INNER JOIN Customer C ON CD.IdCustomer = C.IdCustomer
WHERE (
        CD.BeginDate <= GETDATE() AND
        (DATEDIFF(WEEK,CD.BeginDate, GETDATE()) < 1)
      );

CREATE VIEW VTableMonth AS
SELECT DISTINCT
    TB.IdTable AS "IdTable",
    TB.Active AS "Table Status",
    TB.BeginDate AS "Begin of Table Reservation",
    TB.EndDate AS "End of Table Reservation",
    T.Capacity AS "Amount of Seats",
    R2.IdReservation AS "IdReservation",
    R2.IdCustomer AS "IdCustomer",
    R2.IdCompany AS "IdCompany",
    R2.IdOrder AS "IdOrder",
    RS.Name AS "Status of Reservation",
    R2.Amount AS "Reservation Amount"
FROM TableBusy TB
INNER JOIN [Table] T ON T.IdTable = TB.IdTable
INNER JOIN Reservation R2 ON R2.IdReservation = TB.IdReservation
INNER JOIN ReservationStatus RS ON R2.IdReservationStatus = RS.IdReservationStatus
WHERE (
        TB.BeginDate <= GETDATE() AND
        (DATEDIFF(MONTH ,TB.BeginDate, GETDATE()) < 1)
      );

CREATE VIEW VTableWeek AS
SELECT DISTINCT
    TB.IdTable AS "IdTable",
    TB.Active AS "Table Status",
    TB.BeginDate AS "Begin of Table Reservation",
    TB.EndDate AS "End of Table Reservation",
    T.Capacity AS "Amount of Seats",
    R2.IdReservation AS "IdReservation",
    R2.IdCustomer AS "IdCustomer",
    R2.IdCompany AS "IdCompany",
    R2.IdOrder AS "IdOrder",
    RS.Name AS "Status of Reservation",
    R2.Amount AS "Reservation Amount"
FROM TableBusy TB
INNER JOIN [Table] T ON T.IdTable = TB.IdTable
INNER JOIN Reservation R2 ON R2.IdReservation = TB.IdReservation
INNER JOIN ReservationStatus RS ON R2.IdReservationStatus = RS.IdReservationStatus
WHERE (
        TB.BeginDate <= GETDATE() AND
        (DATEDIFF(WEEK ,TB.BeginDate, GETDATE()) < 1)
      );
      

CREATE VIEW  VOrdersDetails AS
select o.IdOrder, p.Name,od.Quantity, md.Price, o.Discount,o.CreateDate, o.PickupDate, dbo.FOrderValue(o.IdOrder) as 'OrderValue'
    from [Order] o
    inner join OrderDetail od
    on o.IdOrder = od.IdOrder
    inner join MenuDetail md
    on od.IdMenuDetail = md.IdMenuDetail
    inner join Product p
    on md.IdProduct = p.IdProduct


CREATE VIEW VCompletedOrders as
SELECT IdOrder FROM [Order]
    WHERE PickupDate < getdate()
    AND Active = 0


CREATE VIEW VOrdersByCustomer as
select IdOrder,
    CASE
        WHEN IdCompany IS NULL THEN IdCustomer
        ELSE IdCompany
    END AS 'CustomerID',
    CASE
        WHEN IdCompany IS NULL THEN 'Private Customer'
        ELSE 'Company'
    END AS 'Company or private customer'
    FROM [Order]



CREATE VIEW VOrderStatisticsLastWeek AS
SELECT
    YEAR(x.CreateDate) AS 'YEAR',
    DATEPART(WEEK,X.CreateDate) AS 'WEEK',
    x.OrderFor,
    AVG(x.TotalPrice) AS 'AveragePrice',
    COUNT(CASE WHEN x.Active = 0 THEN 0 END) AS 'Completed',
    COUNT(*) AS 'Total',
    (
    SELECT TOP 1 p.Name FROM [Order] o1
        LEFT JOIN OrderDetail od1
            ON o1.IdOrder = od1.IdOrder
            LEFT JOIN MenuDetail md1
            ON od1.IdMenuDetail = md1.IdMenuDetail
            LEFT JOIN Product p
            ON md1.IdProduct = p.IdProduct
            WHERE DATEPART(WEEK,GETDATE()) = DATEPART(WEEK,X.CreateDate) AND YEAR(o1.CreateDate) = YEAR(x.CreateDate)
            GROUP BY p.Name
            ORDER BY COUNT(*) DESC
    ) AS 'TopProduct'
    FROM (
        SELECT
            o.IdOrder,
        CASE
            WHEN o.IdCompany IS NULL THEN 'Customer'
            ELSE 'Company'
        END AS 'OrderFor',
        o.Active,
        o.CreateDate,
        o.TotalPrice
        FROM [Order] o
        LEFT JOIN OrderDetail od
        ON o.IdOrder = od.IdOrder
             ) x
    GROUP BY YEAR(x.CreateDate), DATEPART(WEEK,X.CreateDate), x.OrderFor
    HAVING YEAR(x.CreateDate) = YEAR(GETDATE()) AND DATEPART(WEEK,GETDATE()) = DATEPART(WEEK,X.CreateDate)


CREATE VIEW VFutureOrders AS
SELECT IdOrder
FROM [Order]
WHERE Active = 1 AND PickupDate > GETDATE()


CREATE VIEW VMenuStatisticsLastWeek AS
SELECT p.Name, m.Day,
    (
    SELECT COUNT(*) FROM [Order] o1
        LEFT JOIN OrderDetail od1
            ON o1.IdOrder = od1.IdOrder
            LEFT JOIN MenuDetail md1
            ON od1.IdMenuDetail = md1.IdMenuDetail
            LEFT JOIN Product p1
            ON md1.IdProduct = p1.IdProduct
            WHERE DATEPART(DAYOFYEAR ,o1.CreateDate) = DATEPART(DAYOFYEAR, m.Day) AND YEAR(o1.CreateDate) = YEAR(M.Day) AND
                  p1.Name = p.Name
    ) AS 'HowManyTimesOrdered'
    FROM Product p
    INNER JOIN MenuDetail md on p.IdProduct = md.IdProduct
    INNER JOIN Menu M on md.IdMenu = m.IdMenu
    WHERE DATEPART(WEEK, GETDATE()) = DATEPART(WEEK, m.Day) AND YEAR(GETDATE()) = YEAR(m.Day)
    GROUP BY M.Day, p.Name


CREATE VIEW VMenuStatisticsLastMonth AS
SELECT p.Name, m.Day,
    (
    SELECT COUNT(*) FROM [Order] o1
        LEFT JOIN OrderDetail od1
            ON o1.IdOrder = od1.IdOrder
            LEFT JOIN MenuDetail md1
            ON od1.IdMenuDetail = md1.IdMenuDetail
            LEFT JOIN Product p1
            ON md1.IdProduct = p1.IdProduct
            WHERE DATEPART(DAYOFYEAR ,o1.CreateDate) = DATEPART(DAYOFYEAR, m.Day) AND YEAR(o1.CreateDate) = YEAR(M.Day) AND
                  p1.Name = p.Name
    ) AS 'HowManyTimesOrdered'
    FROM Product p
    INNER JOIN MenuDetail md on p.IdProduct = md.IdProduct
    INNER JOIN Menu M on md.IdMenu = m.IdMenu
    WHERE MONTH(GETDATE()) = MONTH(m.Day) AND YEAR(GETDATE()) = YEAR(m.Day)
    GROUP BY p.Name, M.Day


CREATE VIEW VOrderStatisticsLastMonth AS
SELECT
    YEAR(x.CreateDate) AS 'YEAR',
    MONTH(x.CreateDate) AS 'MONTH',
    x.OrderFor,
    AVG(x.TotalPrice) AS 'AveragePrice',
    COUNT(CASE WHEN x.Active = 0 THEN 0 END) AS 'Completed',
    COUNT(*) AS 'Total',
    (
    SELECT TOP 1 p.Name FROM [Order] o1
        LEFT JOIN OrderDetail od1
            ON o1.IdOrder = od1.IdOrder
            LEFT JOIN MenuDetail md1
            ON od1.IdMenuDetail = md1.IdMenuDetail
            LEFT JOIN Product p
            ON md1.IdProduct = p.IdProduct
            WHERE MONTH(o1.CreateDate) = MONTH(x.CreateDate) AND YEAR(o1.CreateDate) = YEAR(x.CreateDate)
            GROUP BY p.Name
            ORDER BY COUNT(*) DESC
    ) AS 'TopProduct'
    FROM (
        SELECT
            o.IdOrder,
        CASE
            WHEN o.IdCompany IS NULL THEN 'Customer'
            ELSE 'Company'
        END AS 'OrderFor',
        o.Active,
        o.CreateDate,
        o.TotalPrice
        FROM [Order] o
        LEFT JOIN OrderDetail od
        ON o.IdOrder = od.IdOrder
             ) x
    GROUP BY YEAR(x.CreateDate), MONTH(x.CreateDate), x.OrderFor
    HAVING YEAR(x.CreateDate) = YEAR(GETDATE()) AND MONTH(x.CreateDate) = MONTH(GETDATE())


CREATE VIEW VOrderStatisticsLastYear AS
SELECT
    MONTH(x.CreateDate) AS 'MONTH',
    x.OrderFor,
    AVG(x.TotalPrice) AS 'AveragePrice',
    COUNT(CASE WHEN x.Active = 0 THEN 0 END) AS 'Completed',
    COUNT(*) AS 'Total',
    (
    SELECT TOP 1 p.Name FROM [Order] o1
        LEFT JOIN OrderDetail od1
            ON o1.IdOrder = od1.IdOrder
            LEFT JOIN MenuDetail md1
            ON od1.IdMenuDetail = md1.IdMenuDetail
            LEFT JOIN Product p
            ON md1.IdProduct = p.IdProduct
            WHERE MONTH(o1.CreateDate) = MONTH(x.CreateDate) AND YEAR(o1.CreateDate) = 2021
            GROUP BY p.Name
            ORDER BY COUNT(*) DESC
    ) AS 'TopProduct'
    FROM (
        SELECT
            o.IdOrder,
        CASE
            WHEN o.IdCompany IS NULL THEN 'Customer'
            ELSE 'Company'
        END AS 'OrderFor',
        o.Active,
        o.CreateDate,
        o.TotalPrice
        FROM [Order] o
        LEFT JOIN OrderDetail od
        ON o.IdOrder = od.IdOrder
             ) x
    WHERE YEAR(x.CreateDate) = 2021
    GROUP BY MONTH(x.CreateDate), x.OrderFor
