CREATE TRIGGER TAssignDiscountR1 ON [Order] AFTER INSERT AS
BEGIN
    DECLARE @IdCustomer INT;
    DECLARE @TotalPrice MONEY;
    DECLARE @R1 INT;
    DECLARE @Z1 INT;
    DECLARE @K1 INT;
    SET @IdCustomer = (SELECT i.IdCustomer FROM inserted i)
    SET @TotalPrice = (SELECT i.TotalPrice FROM inserted i)
    SET @Z1 = (SELECT c.Value FROM Configuration c WHERE c.Name = 'Z1')
    SET @K1 = (SELECT c.Value FROM Configuration c WHERE c.Name = 'K1')
    SET @R1 = (SELECT c.Value FROM Configuration c WHERE c.Name = 'R1')
    IF (@IdCustomer IS NULL)
    BEGIN
        RETURN
    END
    IF (SELECT DISTINCT 1 FROM CustomerDiscount cd WHERE cd.IdCustomer = @IdCustomer AND cd.Discount = @R1) IS NOT NULL
    BEGIN
        RETURN
    END
    IF (SELECT DISTINCT 1 FROM [Order] o WHERE o.IdCustomer = @IdCustomer AND o.TotalPrice >= @K1 GROUP BY @IdCustomer HAVING COUNT(*) >= @Z1) IS NULL
    BEGIN
        RETURN
    END
    INSERT INTO CustomerDiscount VALUES (@IdCustomer, @R1, 1, GETDATE(), '9999-12-31 23:59:59.000')
END

CREATE TRIGGER TAssignDiscountR2 ON [Order] AFTER INSERT AS
BEGIN
    DECLARE @IdCustomer INT;
    DECLARE @TotalPaid MONEY;
    DECLARE @R2 INT;
    DECLARE @D1 INT;
    DECLARE @K2 INT;
    SET @IdCustomer = (SELECT i.IdCustomer FROM inserted i)
    SET @D1 = (SELECT c.Value FROM Configuration c WHERE c.Name = 'D1')
    SET @K2 = (SELECT c.Value FROM Configuration c WHERE c.Name = 'K2')
    SET @R2 = (SELECT c.Value FROM Configuration c WHERE c.Name = 'R2')
    IF (@IdCustomer IS NULL)
    BEGIN
        RETURN
    END
    SET @TotalPaid = (SELECT c.TotalPaid FROM Customer c WHERE c.IdCustomer = @IdCustomer)
    IF (@TotalPaid >= @K2)
    BEGIN
        INSERT INTO CustomerDiscount VALUES (@IdCustomer, @R2, 1, GETDATE(), DATEADD(day, @D1, GETDATE()))
        UPDATE Customer SET TotalPaid = @TotalPaid - @K2 WHERE IdCustomer = @IdCustomer
    END
END


CREATE TRIGGER TCheckMenu on MenuDetail AFTER INSERT
AS
BEGIN
    DECLARE @ActualMenuCountDistinct INT;
    DECLARE @MenuCount INT;
    SET @ActualMenuCountDistinct =
        (SELECT COUNT(*) FROM (SELECT IdProduct FROM MenuDetail INNER JOIN
            Menu M ON MenuDetail.IdMenu = M.IdMenu WHERE Day = GETDATE()
    EXCEPT
        SELECT IdProduct FROM MenuDetail INNER JOIN Menu M ON M.IdMenu = MenuDetail.IdMenu
        WHERE Day = convert(varchar(15),DATEADD(DAY,-14,GETDATE()),110)) x)
    SET @MenuCount =
        (SELECT count(*) / 2 FROM MenuDetail INNER JOIN
            Menu M ON MenuDetail.IdMenu = M.IdMenu WHERE Day = CONVERT(VARCHAR(15),GETDATE(),110))
    IF @ActualMenuCountDistinct < @MenuCount
        BEGIN
            RAISERROR('Add some products to the menu so it is more different than the one from 2 weeks ago ;)',-1,-1)
        END
END
