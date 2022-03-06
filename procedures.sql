CREATE PROCEDURE PCreateProductCategory
(
    @Name nvarchar(256),
    @Description nvarchar(max)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (SELECT * FROM Category WHERE Name = @Name) BEGIN ; THROW 52000, 'Category with given name already exists.', 1 END
        INSERT INTO Category (Name, Description) VALUES (@Name, @Description)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create the category. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PUpdateProductCategory
(
    @IdCategory int,
    @Name nvarchar(256),
    @Description nvarchar(max)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Category WHERE IdCategory = @IdCategory) BEGIN ; THROW 52000, 'Category with given id does not exist.', 1 END
        UPDATE Category SET Name = @Name, Description = @Description WHERE IdCategory = @IdCategory
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot update the category. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PCreateProduct
(
    @IdCategory int,
    @Name nvarchar(256),
    @Description nvarchar(max),
    @Active bit
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (SELECT * FROM Product WHERE Name = @Name) BEGIN ; THROW 52000, 'Product with given name already exists.', 1 END
        INSERT INTO Product (IdCategory, Name, Description, Active) VALUES (@IdCategory, @Name, @Description, @Active)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create the product. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PUpdateProduct
(
    @IdProduct int,
    @IdCategory int,
    @Name nvarchar(256),
    @Description nvarchar(max),
    @Active bit
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Product WHERE IdProduct = @IdProduct) BEGIN ; THROW 52000, 'Product with given id does not exist.', 1 END
        UPDATE Product SET IdCategory = @IdCategory, Name = @Name, Description = @Description, Active = @Active WHERE IdProduct = @IdProduct
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot update the product. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PUpdateProductStatus
(
    @IdProduct int,
    @Active bit
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Product WHERE IdProduct = @IdProduct) BEGIN ; THROW 52000, 'Product with given id does not exist.', 1 END
        UPDATE Product SET Active = @Active WHERE IdProduct = @IdProduct
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot update the product. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PCreateTable
(
    @Capacity int
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        INSERT INTO [Table] (Capacity) VALUES (@Capacity)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create the table. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PUpdateTableCapacity
(
    @IdTable int,
    @Capacity int
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM [Table] WHERE IdTable = @IdTable) BEGIN ; THROW 52000, 'Table with given id does not exist.', 1 END
        UPDATE [Table] SET Capacity = @Capacity WHERE IdTable = @IdTable
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot update the table. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PMarkTableBusy
(
    @IdTable int,
    @BeginDate datetime,
    @EndDate datetime
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (
            SELECT * FROM TableBusy WHERE IdTable = @IdTable
                                      AND Active = 1
                                      AND BeginDate <= @EndDate
                                      AND EndDate >= @BeginDate
        ) BEGIN ; THROW 52000, 'Table is already busy.', 1 END
        INSERT INTO TableBusy (IdTable, IdReservation, Active, BeginDate, EndDate) VALUES
                              (@IdTable, NULL, 1, @BeginDate, @EndDate)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot occupy the table. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PFreeTable
(
    @IdTable int
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (
            SELECT * FROM TableBusy WHERE IdTable = @IdTable
                                      AND Active = 1
                                      AND BeginDate <= GETDATE()
                                      AND EndDate >= GETDATE()
        ) BEGIN ; THROW 52000, 'Table is already free.', 1 END
        UPDATE TableBusy SET Active = 0 WHERE IdTable = @IdTable AND BeginDate <= GETDATE() AND EndDate >= GETDATE()
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot update the table. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PCreateCompany
(
    @Name nvarchar(256),
    @Nip nvarchar(128),
    @Address nvarchar(128),
    @PostCode nvarchar(16),
    @City nvarchar(128),
    @Country nvarchar(128),
    @Email nvarchar(256),
    @Phone nvarchar(128)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (SELECT * FROM Company WHERE Nip = @Nip) BEGIN ; THROW 52000, 'Company with given nip already exists.', 1 END
        INSERT INTO Company (Name, Nip, Address, PostCode, City, Country, Email, Phone) VALUES
                            (@Name, @Nip, @Address, @PostCode, @City, @Country, @Email, @Phone)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create the company. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PUpdateCompany
(
    @IdCompany int,
    @Name nvarchar(256),
    @Nip nvarchar(128),
    @Address nvarchar(128),
    @PostCode nvarchar(16),
    @City nvarchar(128),
    @Country nvarchar(128),
    @Email nvarchar(256),
    @Phone nvarchar(128)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (SELECT * FROM Company WHERE Nip = @Nip AND IdCompany != @IdCompany) BEGIN ;
        THROW 52000, 'Company with given nip already exists.', 1 END

        IF NOT EXISTS (SELECT * FROM Company WHERE IdCompany = @IdCompany) BEGIN ;
        THROW 52000, 'Company with given id does not exist.', 1 END

        UPDATE Company SET
            Name = @Name,
            Nip = @Nip,
            Address = @Address,
            PostCode = @PostCode,
            City = @City,
            Country = @Country,
            Email = @Email,
            Phone = @Phone
        WHERE IdCompany = @IdCompany
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot update the company. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
GO

CREATE PROCEDURE PAddEmployeeToCompany
(
    @IdCompany INT,
    @NameCompany NVARCHAR(256),
    @FirstName NVARCHAR(128),
    @LastName NVARCHAR(128),
    @Email NVARCHAR(128),
    @Phone NVARCHAR(128)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS
            (
                SELECT *
                FROM CompanyEmployee CE
                WHERE CE.FirstName = @FirstName AND
                    CE.LastName = @LastName AND
                    CE.Email = @Email
            ) BEGIN; THROW 52000, 'Employee already exists.',1 END
        IF NOT EXISTS
            (
                SELECT *
                FROM Company c
                WHERE C.IdCompany = @IdCompany AND
                    C.Name = @NameCompany
            ) BEGIN; THROW 52000, 'Company does not exist in the database.', 1 END
        INSERT INTO CompanyEmployee (IdCompany, FirstName, LastName, Email, Phone) VALUES (@IdCompany, @FirstName, @LastName, @Email, @Phone)
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot add the employee to database. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PUpdateCompanyEmployee
(
    @IdCompanyEmployee INT,
    @IdCompany INT,
    @FirstName NVARCHAR(128),
    @LastName NVARCHAR(128),
    @Email NVARCHAR(128),
    @Phone NVARCHAR(128)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM CompanyEmployee CE WHERE CE.IdCompanyEmployee = @IdCompanyEmployee) BEGIN; THROW 52000, 'Employee does not exist.',1 END
        UPDATE CompanyEmployee SET IdCompany = @IdCompany, FirstName = @FirstName, LastName = @LastName, Email = @Email, Phone = @Phone WHERE IdCompanyEmployee = @IdCompanyEmployee
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot update the employee in database. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PCreateCustomer
(
    @FirstName NVARCHAR(128),
    @LastName NVARCHAR(128),
    @Email NVARCHAR(128),
    @Phone NVARCHAR(128),
    @TotalPaid MONEY
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (SELECT * FROM Customer C WHERE C.FirstName = @FirstName AND C.LastName = @LastName AND C.Email = @Email) BEGIN; THROW 52000, 'Customer already exists.',1 END
        INSERT INTO Customer (FirstName, LastName, Email, Phone, TotalPaid) VALUES (@FirstName, @LastName, @Email, @Phone, @TotalPaid)
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot create the customer. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PUpdateCustomer
(
    @IdCustomer INT,
    @FirstName NVARCHAR(128),
    @LastName NVARCHAR(128),
    @Email NVARCHAR(128),
    @Phone NVARCHAR(128),
    @TotalPaid MONEY
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Customer C WHERE C.IdCustomer = @IdCustomer) BEGIN; THROW 52000, 'Customer does not exist.',1 END
        UPDATE Customer SET FirstName = @FirstName, LastName = @LastName, Email = @Email, Phone = @Phone, TotalPaid = @TotalPaid WHERE IdCustomer = @IdCustomer
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot update the customer. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PCreateTemporaryDiscountForCustomer
(
    @IdCustomer INT,
    @BeginDate DATETIME,
    @EndDate DATETIME
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Customer C WHERE C.IdCustomer = @IdCustomer) BEGIN; THROW 52000, 'Customer does not exists of this id.',1 END
        INSERT INTO CustomerDiscount(IdCustomer, Discount, Active, BeginDate, EndDate)
            VALUES (@IdCustomer, (SELECT [dbo].[FGetValueByConfiguratedVariable]('R2')), 1, @BeginDate, @EndDate)
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot create the discount for customer. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PCreatePermanentDiscountForCustomer
(
    @IdCustomer INT,
    @BeginDate DATETIME
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        DECLARE @Discount INT = (SELECT [dbo].[FGetValueByConfiguratedVariable]('R1'));
        IF NOT EXISTS (SELECT * FROM Customer C WHERE C.IdCustomer = @IdCustomer) BEGIN; THROW 52000, 'Customer does not exists of this id.',1 END
        IF (SELECT Discount FROM CustomerDiscount CD WHERE CD.IdCustomer = @IdCustomer AND CD.EndDate >= '9999-12-31 23:59:59.000') = @Discount BEGIN; THROW 52000, 'Customer has a discount.',1 END
        INSERT INTO CustomerDiscount(IdCustomer, Discount, Active, BeginDate, EndDate)
            VALUES (@IdCustomer, @Discount, 1, @BeginDate, '9999-12-31 23:59:59.000');
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot create the discount for customer. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PUpdateConfigurationValue
(
    @Name  NCHAR(64),
    @Value INT
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Configuration C WHERE C.Name = @Name) BEGIN; THROW 52000, 'Configuration variable does not exists of this name.',1 END
        UPDATE Configuration SET Value = @Value WHERE Name = @Name;
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot update the value. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PUpdateDiscount
(
    @IdCustomerDiscount INT,
    @Discount INT,
    @Active BIT,
    @BeginDate DATETIME,
    @EndDate DATETIME
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM CustomerDiscount CD WHERE CD.IdCustomerDiscount = @IdCustomerDiscount) BEGIN; THROW 52000, 'Discount does not exist.',1 END
        UPDATE CustomerDiscount SET Discount = @Discount, Active = @Active, BeginDate = @BeginDate, EndDate = @EndDate WHERE IdCustomerDiscount = @IdCustomerDiscount;
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot update the discount. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PCreateSingleInvoice
(
    @IdOrder INT,
    @Url NVARCHAR(256)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
    DECLARE @IssueDate DATETIME = GETDATE();
        IF NOT EXISTS (SELECT * FROM [Order] O WHERE O.IdOrder = @IdOrder) BEGIN; THROW 52000, 'Order does not exists of this id.',1 END
        IF EXISTS (SELECT * FROM InvoiceDetail ID WHERE ID.IdOrder = @IdOrder) BEGIN; THROW 52000, 'Invoice exists for this order.',1 END
        INSERT INTO Invoice(url, issuedate) VALUES (@Url, @IssueDate)
        INSERT INTO InvoiceDetail(IdInvoice, IdOrder) VALUES ( (SELECT IdInvoice FROM Invoice I WHERE I.Url = @Url AND I.IssueDate = @IssueDate), @IdOrder)
    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot create the invoice. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PCreateCollectiveInvoiceForCompany
(
    @IdCompany INT,
    @Url NVARCHAR(256)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
    DECLARE @IssueDate DATETIME = GETDATE();
        IF NOT EXISTS (SELECT * FROM [Company] C WHERE C.IdCompany = @IdCompany) BEGIN; THROW 52000, 'Company does not exists of this id.',1 END
        DECLARE @Cursor CURSOR;
        DECLARE @IdOrder INT;
        DECLARE @IdInvoiceVar INT;

        BEGIN
            SET @Cursor = CURSOR FOR
            SELECT IdOrder from FGetCompanyInvoices(@IdCompany)

            OPEN @Cursor
            FETCH NEXT FROM @Cursor
            INTO @IdOrder

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @IdInvoiceVar = (SELECT IdInvoice FROM InvoiceDetail WHERE IdOrder = @IdOrder)
              IF (SELECT Count(IdOrder) FROM InvoiceDetail WHERE IdInvoice = @IdInvoiceVar) > 1 AND (DATEDIFF(MONTH,(SELECT IssueDate FROM Invoice WHERE IdInvoice = @IdInvoiceVar), GETDATE()) < 1)
                BEGIN;
                    CLOSE @Cursor ;
                    DEALLOCATE @Cursor;
                    THROW 52000, 'Company has an collective invoice in last month.',1
                END

              FETCH NEXT FROM @Cursor
              INTO @IdOrder
            END;

            CLOSE @Cursor ;
            DEALLOCATE @Cursor;
        END;

        IF (SELECT COUNT(IdOrder) FROM [Order] O WHERE O.IdCompany = @IdCompany AND IdOrder NOT IN (SELECT IdOrder FROM FGetCompanyInvoices(@IdCompany))) = 0
        BEGIN;
            THROW 52000, 'Company has not got an order without invoice.',1
        END

        INSERT INTO Invoice(url, issuedate) VALUES (@Url, @IssueDate)
        BEGIN
            SET @Cursor = CURSOR FOR
            SELECT IdOrder FROM [Order] O WHERE O.IdCompany = @IdCompany AND IdOrder NOT IN (SELECT IdOrder FROM FGetCompanyInvoices(@IdCompany))

            OPEN @Cursor
            FETCH NEXT FROM @Cursor
            INTO @IdOrder

            WHILE @@FETCH_STATUS = 0
            BEGIN
                INSERT INTO InvoiceDetail(IdInvoice, IdOrder) VALUES ( (SELECT IdInvoice FROM Invoice I WHERE I.Url = @Url AND I.IssueDate = @IssueDate), @IdOrder)
                FETCH NEXT FROM @Cursor
                INTO @IdOrder
            END;

            CLOSE @Cursor ;
            DEALLOCATE @Cursor;
        END;

    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot create the invoice. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PCreateCollectiveInvoiceForCustomer
(
    @IdCustomer INT,
    @Url NVARCHAR(256)
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        DECLARE @IssueDate DATETIME = GETDATE();
        IF NOT EXISTS (SELECT * FROM [Customer] C WHERE C.IdCustomer = @IdCustomer) BEGIN; THROW 52000, 'Customer does not exists of this id.',1 END
        DECLARE @Cursor CURSOR;
        DECLARE @IdOrder INT;
        DECLARE @IdInvoiceVar INT;

        BEGIN
            SET @Cursor = CURSOR FOR
            SELECT IdOrder from FGetCustomerInvoices(@IdCustomer)

            OPEN @Cursor
            FETCH NEXT FROM @Cursor
            INTO @IdOrder

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @IdInvoiceVar = (SELECT IdInvoice FROM InvoiceDetail WHERE IdOrder = @IdOrder)
              IF (SELECT Count(IdOrder) FROM InvoiceDetail WHERE IdInvoice = @IdInvoiceVar) > 1 AND (DATEDIFF(MONTH,(SELECT IssueDate FROM Invoice WHERE IdInvoice = @IdInvoiceVar), GETDATE()) < 1)
                BEGIN;
                    CLOSE @Cursor ;
                    DEALLOCATE @Cursor;
                    THROW 52000, 'Customer has an collective invoice in last month.',1
                END

              FETCH NEXT FROM @Cursor
              INTO @IdOrder
            END;

            CLOSE @Cursor ;
            DEALLOCATE @Cursor;
        END;

        IF (SELECT COUNT(IdOrder) FROM [Order] O WHERE O.IdCustomer = @IdCustomer AND IdOrder NOT IN (SELECT IdOrder FROM FGetCustomerInvoices(@IdCustomer))) = 0
        BEGIN;
            THROW 52000, 'Customer has not got an order without invoice.',1
        END

        INSERT INTO Invoice(url, issuedate) VALUES (@Url, @IssueDate)
        BEGIN
            SET @Cursor = CURSOR FOR
            SELECT IdOrder FROM [Order] O WHERE O.IdCustomer = @IdCustomer AND IdOrder NOT IN (SELECT IdOrder FROM FGetCustomerInvoices(@IdCustomer))

            OPEN @Cursor
            FETCH NEXT FROM @Cursor
            INTO @IdOrder

            WHILE @@FETCH_STATUS = 0
            BEGIN
                INSERT INTO InvoiceDetail(IdInvoice, IdOrder) VALUES ( (SELECT IdInvoice FROM Invoice I WHERE I.Url = @Url AND I.IssueDate = @IssueDate), @IdOrder)
                FETCH NEXT FROM @Cursor
                INTO @IdOrder
            END;

            CLOSE @Cursor ;
            DEALLOCATE @Cursor;
        END;

    END TRY
    BEGIN CATCH
        DECLARE @error NVARCHAR(2048) = 'Cannot create the invoice. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PCreateOrderTakeout
(
    @IdCustomer int = NULL,
    @IdCompany int = NULL,
    @TotalPrice money = NULL,
    @Discount int = 0,
    @Takeaway bit = 1,
    @Prepaid bit = 0,
    @Active bit = 1,
    @PickupDate datetime,
    @CreateDate datetime = NULL
)
AS BEGIN
    SET @CreateDate = GETDATE()
    SET NOCOUNT ON
    BEGIN TRY
        IF @IdCustomer IS NOT NULL and @IdCompany IS NOT NULL BEGIN ; THROW 52000, 'Wrong data for IdCustomer and IdCompany', 1 END
        INSERT INTO [ORDER] (IdCustomer, IdCompany, TotalPrice, Discount, Takeaway, Prepaid, Active, PickupDate, CreateDate)
        VALUES (@IdCustomer, @IdCompany, @TotalPrice, @Discount, @Takeaway, @Prepaid, @Active, @PickupDate, @CreateDate)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create the Order, ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PCreateOrderOnSite
(
    @IdCustomer int = NULL,
    @IdCompany int = NULL,
    @TotalPrice money = 0,
    @Discount int = 0,
    @Takeaway bit = 0,
    @Prepaid bit = 0,
    @Active bit = 1,
    @PickupDate datetime,
    @CreateDate datetime = NULL
)
AS BEGIN
    SET @CreateDate = GETDATE()
    SET NOCOUNT ON
    BEGIN TRY
        IF @IdCustomer IS NOT NULL and @IdCompany IS NOT NULL BEGIN ; THROW 52000, 'Wrong data for IdCustomer and IdCompany', 1 END
        INSERT INTO [ORDER] (IdCustomer, IdCompany, TotalPrice, Discount, Takeaway, Prepaid, Active, PickupDate, CreateDate)
        VALUES (@IdCustomer, @IdCompany, @TotalPrice, @Discount, @Takeaway, @Prepaid, @Active, @PickupDate, @CreateDate)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create the Order, ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PCancelOrderTakeOut
(
    @IdOrder int,
    @Active bit = 0
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM [Order] WHERE IdOrder = @IdOrder) BEGIN ; THROW 52000, 'Order for given IdOrder does not exist.', 1 END
        UPDATE [Order] SET Active = @Active where IdOrder = @IdOrder
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot cancel the Order, ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

CREATE PROCEDURE PAddProductToOrder
(
    @IdOrder int,
    @IdMenuDetail int,
    @Quantity smallint
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(SELECT * FROM [Order] WHERE IdOrder = @IdOrder) BEGIN ; THROW 52000, 'Order with given ID does not exist', 1 END
        IF NOT EXISTS(SELECT * FROM MenuDetail INNER JOIN Menu M on MenuDetail.IdMenu = M.IdMenu WHERE
        Year(M.Day) = YEAR(GETDATE()) AND MONTH(M.Day) = MONTH(GETDATE()) AND DAY(M.Day) = DAY(GETDATE()) AND IdMenuDetail = @IdMenuDetail)
        BEGIN ; THROW 52000, 'Product with given Id is not one the menu right now, choose something else!', 1 END

        IF (DATEPART(DW,GETDATE()) NOT IN (5,6,7)) AND (SELECT P.IdCategory from MenuDetail md inner join Product P on md.IdProduct = P.IdProduct where md.IdMenuDetail = @IdMenuDetail) = 7
        BEGIN ; THROW 52000, 'Cannot order seafood at this time of the week', 1 END

        INSERT INTO OrderDetail (IdOrder, IdMenuDetail, Quantity) VALUES (@IdOrder, @IdMenuDetail, @Quantity)
        DECLARE @total_price INT = (SELECT SUM(Price*Quantity) FROM OrderDetail od INNER JOIN MenuDetail D ON od.IdMenuDetail = D.IdMenuDetail
            INNER JOIN Menu m ON D.IdMenu = m.IdMenu
            WHERE YEAR(M.Day) = YEAR(GETDATE()) AND MONTH(M.Day) = MONTH(GETDATE()) AND DAY(M.Day) = DAY(GETDATE()) AND
            od.IdOrder = @IdOrder
            GROUP BY IdOrder)
        UPDATE [Order]  SET TotalPrice = @total_price where IdOrder = @IdOrder
        IF EXISTS(SELECT * FROM Customer C INNER JOIN [Order] O ON C.IdCustomer = O.IdCustomer WHERE O.IdOrder = @IdOrder) BEGIN ;
        DECLARE @total_paid INT = (SELECT C.TotalPaid FROM Customer C INNER JOIN [Order] O ON C.IdCustomer = O.IdCustomer WHERE O.IdOrder = @IdOrder)
        DECLARE @cu_id INT = (SELECT C.IdCustomer FROM Customer C INNER JOIN [Order] O ON C.IdCustomer = O.IdCustomer WHERE O.IdOrder = @IdOrder)
        UPDATE Customer SET TotalPaid = @total_paid + @total_price WHERE IdCustomer = @cu_id END
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PCreateReservationIndividualClient
(
    @IdCustomer1 int = NULL,
    @IdCompany1 int = NULL,
    @IdReservationStatus bit = 0,
    @Amount smallint,
    @BeginDate datetime = NUll,
    @HowLong int = 2,
    @Discount1 int = 0
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF @IdCustomer1 IS NULL and @IdCompany1 IS NOT NULL BEGIN ; THROW 52000, 'It is a reservation for and individual client, try using one for a Company', 1 END
        DECLARE @End_Date datetime = DATEADD(HOUR,@HowLong, @BeginDate)
        EXEC PCreateOrderOnSite @IdCustomer = @IdCustomer1, @IdCompany = @IdCompany1, @Discount = @Discount1, @CreateDate = @BeginDate, @PickupDate = @End_Date
        INSERT INTO Reservation(IdCustomer, IdCompany, IdOrder, IdReservationStatus, Amount, BeginDate, EndDate)
        VALUES (@IdCustomer1, @IdCompany1, (SELECT TOP 1 IdOrder from [Order] order by IdOrder desc), @IdReservationStatus, @Amount, @BeginDate, @End_Date)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create reservation, ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PCreateReservationCompany
(
    @IdCustomer1 int = NULL,
    @IdCompany1 int = NULL,
    @IdReservationStatus bit = 0,
    @Amount smallint,
    @BeginDate datetime = NUll,
    @HowLong int = 2,
    @Discount1 int = 0,
    @WithOrder bit = 0
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF @IdCustomer1 IS NOT NULL and @IdCompany1 IS NULL BEGIN ; THROW 52000, 'It is a reservation for a Company, try using one for an individual client', 1 END
        DECLARE @End_Date datetime = DATEADD(HOUR,@HowLong, @BeginDate)
        IF @WithOrder = 1 BEGIN ; EXEC PCreateOrderOnSite @IdCustomer = @IdCustomer1, @IdCompany = @IdCompany1, @Discount = @Discount1, @CreateDate = @BeginDate, @PickupDate = @End_Date
        END
        INSERT INTO Reservation(IdCustomer, IdCompany, IdOrder, IdReservationStatus, Amount, BeginDate, EndDate)
        VALUES (@IdCustomer1, @IdCompany1, (SELECT TOP 1 IdOrder from [Order] order by IdOrder desc), @IdReservationStatus, @Amount, @BeginDate, @End_Date)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot create reservation, ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PAcceptReservationWithTables
(
    @IdReservation int
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Reservation WHERE IdReservation = @IdReservation) BEGIN ; THROW 52000,
            'Reservation with given ID does not exist!', 1 END
        IF (SELECT IdReservationStatus from Reservation where @IdReservation = IdReservation) = 1 BEGIN ; THROW 52000
            , 'Reservation has already been accepted!', 1 END
        IF EXISTS (SELECT top 1 IdTable FROM VAvailableTables
        where [Amount of seats] = (SELECT Amount FROM Reservation WHERE IdReservation = @IdReservation))
            BEGIN ;
            DECLARE @TABLE_ID INT = (SELECT top 1 IdTable FROM VAvailableTables
            where [Amount of seats] = (SELECT Amount FROM Reservation WHERE IdReservation = @IdReservation))
            DECLARE @Res_Start datetime = (SELECT BeginDate FROM Reservation WHERE IdReservation = @IdReservation)
            DECLARE @End_Res datetime = (SELECT EndDate FROM Reservation WHERE IdReservation = @IdReservation)
            EXEC PMarkTableBusy @IdTable = @TABLE_ID, @BeginDate = @Res_Start, @EndDate = @End_Res
            UPDATE TableBusy SET IdReservation = @IdReservation WHERE IdTable = @TABLE_ID
        END
        UPDATE Reservation SET IdReservationStatus = 1 where IdReservation = @IdReservation
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot accept reservation. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
select * from [Table] order by capacity desc


CREATE PROCEDURE PRejectReservation
(
    @IdReservation int
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Reservation WHERE IdReservation = @IdReservation) BEGIN ; THROW 52000,
            'Reservation with given ID does not exist!', 1 END
        IF (SELECT IdReservationStatus from Reservation where @IdReservation = IdReservation) = 2 BEGIN ; THROW 52000
            , 'Reservation has already been rejected!', 1 END
        IF (SELECT IdReservationStatus from Reservation where @IdReservation = IdReservation) != 0 BEGIN ; THROW 52000
            , 'Use PCancelReservation to cancel this reservation!', 1 END
        UPDATE Reservation SET IdReservationStatus = 2
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot reject reservation. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END


CREATE PROCEDURE PCancelReservation
(
    @IdReservation int
)
AS BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS (SELECT * FROM Reservation WHERE IdReservation = @IdReservation) BEGIN ; THROW 52000,
            'Reservation with given ID does not exist!', 1 END
        IF (SELECT IdReservationStatus from Reservation where @IdReservation = IdReservation) = 2 BEGIN ; THROW 52000
            , 'Reservation has already been cancelled!', 1 END
        IF (SELECT IdReservationStatus from Reservation where @IdReservation = IdReservation) != 1 BEGIN ; THROW 52000
            , 'Use PRejectReservation to cancel this reservation!', 1 END
        UPDATE Reservation SET IdReservationStatus = 2
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot cancel reservation. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END

DROP PROCEDURE PCREATEMENU


CREATE PROCEDURE PCreateMenu
(
    @Day datetime = NULL,
    @IdProduct int,
    @Price money
)
AS BEGIN
    SET DATEFIRST 1
    SET NOCOUNT ON
    SET @day = GETDATE()
    BEGIN TRY
        IF EXISTS (SELECT md.IdProduct FROM Menu M INNER JOIN MenuDetail MD on M.IdMenu = MD.IdMenu
        WHERE Year(M.Day) = YEAR(GETDATE()) AND MONTH(M.Day) = MONTH(GETDATE()) AND DAY(M.Day) = DAY(GETDATE())
        AND @IdProduct = MD.IdProduct)
        BEGIN ; THROW 52000, 'Product already in the Menu!', 1 END
        IF NOT EXISTS (SELECT * FROM Menu M WHERE Year(M.Day) = YEAR(GETDATE()) and MONTH(M.Day) = MONTH(GETDATE())
        and DAY(M.Day) = DAY(GETDATE()))
        BEGIN ; INSERT INTO Menu (Day) VALUES (@Day) END
        IF NOT EXISTS (SELECT * FROM Product WHERE IdProduct = @IdProduct) BEGIN ;
        THROW 52000, 'Product with given Id does not exist!', 1 END
        INSERT INTO MenuDetail (IdMenu, IdProduct, Price) VALUES ((SELECT TOP 1 IdMenu FROM Menu M WHERE
        YEAR(M.Day) = YEAR(GETDATE()) AND MONTH(M.Day) = MONTH(GETDATE()) AND DAY(M.Day) = DAY(GETDATE())),
        @IdProduct, @Price)
    END TRY
    BEGIN CATCH
        DECLARE @error nvarchar(2048) = 'Cannot add product to the menu. ERROR: ' + ERROR_MESSAGE();
        THROW 52000, @error, 1
    END CATCH
END
