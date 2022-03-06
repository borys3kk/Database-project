CREATE FUNCTION FGetMenuProductsByDay
(
    @Date date
)
RETURNS TABLE AS RETURN
(
    SELECT m.IdMenu AS 'IdMenu',
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
    WHERE m.Day = @Date
)
GO

CREATE FUNCTION FGetProductsByCategory
(
    @IdCategory int
)
RETURNS TABLE AS RETURN
(
    SELECT
        p.IdProduct AS 'IdProduct',
        p.Name AS 'ProductName',
        p.Description AS 'ProductDescription',
        c.Name AS 'CategoryName',
        c.Description AS 'CategoryDescription',
        p.Active AS 'ProductActive'
    FROM Product p
    LEFT JOIN Category c ON (c.IdCategory = p.IdProduct)
    WHERE c.IdCategory = @IdCategory
)
GO

CREATE FUNCTION FGetEmployeesByCompany
(
    @IdCompany int
)
RETURNS TABLE AS RETURN
(
    SELECT
        ce.FirstName AS 'FirstName',
        ce.LastName AS 'LastName',
        ce.Email AS 'Email',
        ce.Phone AS 'Phone'
    FROM CompanyEmployee ce
    WHERE ce.IdCompany = @IdCompany
)
GO

CREATE FUNCTION FGetCompanyInvoices
(
    @ComapnyId int
)
RETURNS TABLE AS RETURN
(
    SELECT
        I.Url AS 'InvoiceUrl',
        I.IssueDate AS 'DateOfInvoice',
        O.IdOrder AS 'IdOrder',
        O.IdCompany AS 'IdCompany'
    FROM Invoice I
    INNER JOIN InvoiceDetail ID ON I.IdInvoice = ID.IdInvoice
    INNER JOIN [Order] O ON O.IdOrder = ID.IdOrder
    WHERE IdCompany = @ComapnyId
)
GO

CREATE FUNCTION FGetCustomerInvoices
(
    @CustomerId int
)
RETURNS TABLE AS RETURN
(
        SELECT
            I.Url AS 'InvoiceUrl',
            I.IssueDate AS 'DateOfInvoice',
            O.IdOrder AS 'IdOrder',
            O.IdCustomer AS 'IdCustomer'
        FROM Invoice I
        INNER JOIN InvoiceDetail ID ON I.IdInvoice = ID.IdInvoice
        INNER JOIN [Order] O ON O.IdOrder = ID.IdOrder
        WHERE O.IdCustomer = @CustomerId
)
GO

CREATE FUNCTION FGetInvoiceOfOrder
(
    @OrderId int
)
RETURNS TABLE AS RETURN
(
    SELECT
        I.Url AS 'InvoiceUrl',
        I.IssueDate AS 'DateOfInvoice'
    FROM Invoice I
    INNER JOIN InvoiceDetail ID ON I.IdInvoice = ID.IdInvoice
    WHERE ID.IdOrder = @OrderId
)
GO


CREATE FUNCTION FGetValueByConfiguratedVariable
(
    @VariableName nchar(64)
)
RETURNS INT AS
BEGIN
    DECLARE @returnValue INT;
    SELECT @returnValue =
    (
        SELECT
            C.Value
        FROM Configuration C
        WHERE C.Name = @VariableName
    );
    RETURN @returnValue;
END

CREATE FUNCTION FGetDiscountByCustomer
(
    @CustomerID int
)
RETURNS TABLE AS RETURN
(
    SELECT
        CD.Discount AS 'CustomerDiscount',
        CD.Active AS 'DiscountStatus',
        CD.BeginDate AS 'DiscountBeginDate',
        CD.EndDate AS 'DiscountEndDate'
    FROM CustomerDiscount CD
    WHERE IdCustomer = @CustomerID
)
GO


CREATE FUNCTION FOrderDetail
(
    @IdOrder int
)
RETURNS TABLE AS RETURN
(
    select o.IdOrder, p.Name,od.Quantity, md.Price, o.Discount,o.CreateDate, o.PickupDate, dbo.FOrderValue(o.IdOrder) as 'OrderValue'
    from [Order] o
    inner join OrderDetail od
    on o.IdOrder = od.IdOrder
    inner join MenuDetail md
    on od.IdMenuDetail = md.IdMenuDetail
    inner join Product p
    on md.IdProduct = p.IdProduct
    WHERE o.IdOrder = @IdOrder
)


CREATE FUNCTION FOrderByClient
(
    @IdCustomer int = NULL,
    @IdCompany int = NULL
)
RETURNS TABLE AS RETURN
(
    select o.IdOrder,
        CASE
        WHEN @IdCompany IS NULL THEN @IdCustomer
        ELSE @IdCompany
    END AS 'CustomerID',
    CASE
        WHEN IdCompany IS NULL THEN 'Private Customer'
        ELSE 'Company'
    END AS 'Company or private customer'
    FROM [Order] o where @IdCustomer = o.IdCustomer or @IdCompany = o.IdCompany
)


create function FOrderValue(@Order_ID INT)
returns float
    as
    begin
    return (
        select (sum(md1.Price * od1.Quantity) *
            (100 - (select top 1 Discount from [Order]
                o where o.IdOrder = o1.IdOrder))) / 100
            from [Order] o1
            inner join OrderDetail od1
            on o1.IdOrder = od1.IdOrder
            inner join MenuDetail md1
            on od1.IdMenuDetail = md1.IdMenuDetail
            where o1.IdOrder = @Order_ID
            group by o1.IdOrder
        )
    end
