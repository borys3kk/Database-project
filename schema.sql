create table Category
(
    IdCategory  int    IDENTITY (1 ,1)  not null
        constraint Category_pk
            primary key nonclustered,
    Name        nvarchar(256) not null,
    Description nvarchar(max)
)
go

create unique index Category_IdCategory_uindex
    on Category (IdCategory)
go

create table Company
(
    IdCompany int     IDENTITY (1 ,1)      not null
        constraint Company_pk
            primary key nonclustered,
    Name      nvarchar(256) not null,
    Nip       nvarchar(128) not null,
    Address   nvarchar(128) not null,
    PostCode  nvarchar(16)  not null,
    City      nvarchar(128) not null,
    Country   nvarchar(128) not null,
    Email     nvarchar(256) not null,
    Phone     nvarchar(128) not null
)
go

create unique index Company_IdCompany_uindex
    on Company (IdCompany)
go

create unique index Company_Nip_uindex
    on Company (Nip)
go

create unique index Company_Email_uindex
    on Company (Email)
go

create unique index Company_Phone_uindex
    on Company (Phone)
go

create table CompanyEmployee
(
    IdCompanyEmployee int      IDENTITY (1 ,1)     not null,
    IdCompany         int           not null
        constraint CompanyEmployee_Company_IdCompany_fk
            references Company,
    FirstName         nvarchar(128) not null,
    LastName          nvarchar(128) not null,
    Email             nvarchar(128) not null,
    Phone             nvarchar(128) not null
)
go

create unique index CompanyEmployee_IdCompanyEmployee_uindex
    on CompanyEmployee (IdCompanyEmployee)
go

create table Configuration
(
    Name  nchar(64) not null
        constraint Configuration_pk
            primary key nonclustered,
    Value int       not null
)
go

create unique index Configuration_Name_uindex
    on Configuration (Name)
go

create table Customer
(
    IdCustomer int     IDENTITY (1 ,1)      not null
        constraint Customer_pk
            primary key nonclustered,
    FirstName  nvarchar(128) not null,
    LastName   nvarchar(128) not null,
    Email      nvarchar(256) not null,
    Phone      nvarchar(256) not null,
    TotalPaid  money         not null
)
go

create unique index Customer_IdCustomer_uindex
    on Customer (IdCustomer)
go

create unique index Customer_Email_uindex
    on Customer (Email)
go

create unique index Customer_Phone_uindex
    on Customer (Phone)
go

create table CustomerDiscount
(
    IdCustomerDiscount int   IDENTITY (1 ,1)   not null
        constraint CustomerDiscount_pk
            primary key nonclustered,
    IdCustomer         int      not null
        constraint CustomerDiscount_Customer_IdCustomer_fk
            references Customer,
    Discount           int      not null,
    Active             bit      not null,
    BeginDate          datetime not null,
    EndDate            datetime not null
)
go

create unique index CustomerDiscount_IdCustomerDiscount_uindex
    on CustomerDiscount (IdCustomerDiscount)
go

create table Invoice
(
    IdInvoice int      IDENTITY (1 ,1)     not null
        constraint Invoice_pk
            primary key nonclustered,
    Url       nvarchar(256) not null,
    IssueDate datetime      not null
)
go

create unique index Invoice_IdInvoice_uindex
    on Invoice (IdInvoice)
go

create table Menu
(
    IdMenu int  IDENTITY (1 ,1) not null
        constraint Menu_pk
            primary key nonclustered,
    Day    date not null
)
go

create unique index Menu_IdMenu_uindex
    on Menu (IdMenu)
go

create table [Order]
(
    IdOrder    int  IDENTITY (1 ,1)    not null
        constraint Order_pk
            primary key nonclustered,
    IdCustomer int
        constraint Order_Customer_IdCustomer_fk
            references Customer,
    IdCompany  int
        constraint Order_Company_IdCompany_fk
            references Company,
    TotalPrice money    not null,
    Discount   int      not null,
    Takeaway   bit      not null,
    Prepaid    bit      not null,
    Active     bit      not null,
    PickupDate datetime not null,
    CreateDate datetime not null
)
go

create table InvoiceDetail
(
    IdInvoiceDetail int IDENTITY (1 ,1) not null
        constraint InvoiceDetail_pk
            primary key nonclustered,
    IdInvoice       int not null
        constraint InvoiceDetail_Invoice_IdInvoice_fk
            references Invoice,
    IdOrder         int not null
        constraint InvoiceDetail_Order_IdOrder_fk
            references [Order]
)
go

create unique index InvoiceDetail_IdInvoiceDetail_uindex
    on InvoiceDetail (IdInvoiceDetail)
go

create unique index Order_IdOrder_uindex
    on [Order] (IdOrder)
go

create table Product
(
    IdProduct   int     IDENTITY (1 ,1)      not null
        constraint Product_pk
            primary key nonclustered,
    IdCategory  int           not null
        constraint Product_Category_IdCategory_fk
            references Category,
    Name        nvarchar(256) not null,
    Description nvarchar(max),
    Active      bit           not null
)
go

create table MenuDetail
(
    IdMenuDetail int IDENTITY (1 ,1)  not null
        constraint MenuDetail_pk
            primary key nonclustered,
    IdMenu       int   not null
        constraint MenuDetail_Menu_IdMenu_fk
            references Menu
            on update cascade on delete cascade,
    IdProduct    int   not null
        constraint MenuDetail_Product_IdProduct_fk
            references Product,
    Price        money not null
)
go

create unique index MenuDetail_IdMenuDetail_uindex
    on MenuDetail (IdMenuDetail)
go

create table OrderDetail
(
    IdOrderDetail int   IDENTITY (1 ,1)   not null
        constraint OrderDetail_pk
            primary key nonclustered,
    IdOrder       int      not null
        constraint OrderDetail_Order_IdOrder_fk
            references [Order]
            on update cascade on delete cascade,
    IdMenuDetail  int      not null
        constraint OrderDetail_MenuDetail_IdMenuDetail_fk
            references MenuDetail,
    Quantity      smallint not null
)
go

create unique index OrderDetail_IdOrderDetail_uindex
    on OrderDetail (IdOrderDetail)
go

create unique index Product_IdProduct_uindex
    on Product (IdProduct)
go

create table ReservationStatus
(
    IdReservationStatus int  IDENTITY (1 ,1)         not null
        constraint ReservationStatus_pk
            primary key nonclustered,
    Name                nvarchar(256) not null
)
go

create table Reservation
(
    IdReservation       int  IDENTITY (1 ,1)    not null
        constraint Reservation_pk
            primary key nonclustered,
    IdCustomer          int
        constraint Reservation_Customer_IdCustomer_fk
            references Customer,
    IdCompany           int
        constraint Reservation_Company_IdCompany_fk
            references Company,
    IdOrder             int
        constraint Reservation_Order_IdOrder_fk
            references [Order],
    IdReservationStatus int      not null
        constraint Reservation_ReservationStatus_IdReservationStatus_fk
            references ReservationStatus,
    Amount              smallint not null,
    BeginDate           datetime not null,
    EndDate             datetime not null
)
go

create unique index Reservation_IdReservation_uindex
    on Reservation (IdReservation)
go

create table ReservationCompanyEmployee
(
    IdReservationCompanyEmployee int IDENTITY (1 ,1) not null
        constraint ReservationCompanyEmployee_pk
            primary key nonclustered,
    IdReservation                int not null
        constraint ReservationCompanyEmployee_Reservation_IdReservation_fk
            references Reservation,
    IdCompanyEmployee            int not null
        constraint ReservationCompanyEmployee_CompanyEmployee_IdCompanyEmployee_fk
            references CompanyEmployee (IdCompanyEmployee)
)
go

create unique index ReservationCompanyEmployee_IdReservationCompanyEmployee_uindex
    on ReservationCompanyEmployee (IdReservationCompanyEmployee)
go

create unique index ReservationStatus_IdReservationStatus_uindex
    on ReservationStatus (IdReservationStatus)
go

create unique index ReservationStatus_Name_uindex
    on ReservationStatus (Name)
go

create table [Table]
(
    IdTable  int   IDENTITY (1 ,1)   not null
        constraint Table_pk
            primary key nonclustered,
    Capacity smallint not null
)
go

create unique index Table_IdTable_uindex
    on [Table] (IdTable)
go

create table TableBusy
(
    IdTableBusy   int   IDENTITY (1 ,1)   not null
        constraint TableBusy_pk
            primary key nonclustered,
    IdTable       int      not null
        constraint TableBusy_Table_IdTable_fk
            references [Table],
    IdReservation int
        constraint TableBusy_Reservation_IdReservation_fk
            references Reservation,
    Active        bit      not null,
    BeginDate     datetime not null,
    EndDate       datetime not null
)
go

create unique index TableBusy_IdTableBusy_uindex
    on TableBusy (IdTableBusy)
go
