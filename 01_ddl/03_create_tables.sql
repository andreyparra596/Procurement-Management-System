/* ==================================================================
Project: Strategic Procurement Value Intelligence Hub
File: 03_create_tables.sql
Author: Andrey Parra
Date: 2026-05-08
================================================================== */

USE ProcurementDW;
GO

BEGIN TRY
    BEGIN TRAN;


    /***********************
     * 1. RAW - 3 tablas
     ***********************/
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Vendor' AND schema_id = SCHEMA_ID('raw'))
    BEGIN
        CREATE TABLE raw.Vendor (
            VendorKey INT IDENTITY(1,1) NOT NULL,
            VendorID INT NOT NULL,
            VendorName NVARCHAR(255) NOT NULL,
            VendorCountry NVARCHAR(100) NULL,
            VendorCategory NVARCHAR(100) NULL,
            SourceRowHash BINARY(32) NOT NULL,
            LoadDate DATETIME2(7) NOT NULL CONSTRAINT DF_rawVendor_LoadDate DEFAULT (SYSUTCDATETIME()),
            CONSTRAINT PK_rawVendor PRIMARY KEY CLUSTERED (VendorKey ASC)
        );
        PRINT 'Completado: Tabla raw.Vendor creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla raw.Vendor ya existe.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PurchaseOrder' AND schema_id = SCHEMA_ID('raw'))
    BEGIN
        CREATE TABLE raw.PurchaseOrder (
            PORawKey INT IDENTITY(1,1) NOT NULL,
            PO_ID INT NOT NULL,
            VendorID INT NULL,
            MaterialID NVARCHAR(50) NULL,
            OrderDate DATE NULL,
            Quantity DECIMAL(18,4) NULL,
            UnitPrice DECIMAL(18,4) NULL,
            TotalAmount AS (Quantity * UnitPrice) PERSISTED,
            LoadDate DATETIME2(7) NOT NULL CONSTRAINT DF_rawPO_LoadDate DEFAULT (SYSUTCDATETIME()),
            CONSTRAINT PK_rawPO PRIMARY KEY CLUSTERED (PORawKey ASC)
        );
        PRINT 'Completado: Tabla raw.PurchaseOrder creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla raw.PurchaseOrder ya existe.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Material' AND schema_id = SCHEMA_ID('raw'))
    BEGIN
        CREATE TABLE raw.Material (
            MaterialKey INT IDENTITY(1,1) NOT NULL,
            MaterialID NVARCHAR(50) NOT NULL,
            MaterialName NVARCHAR(255) NULL,
            Category NVARCHAR(100) NULL,
            SubCategory NVARCHAR(100) NULL,
            UnitOfMeasure NVARCHAR(20) NULL,
            LoadDate DATETIME2(7) NOT NULL CONSTRAINT DF_rawMaterial_LoadDate DEFAULT (SYSUTCDATETIME()),
            CONSTRAINT PK_rawMaterial PRIMARY KEY CLUSTERED (MaterialKey ASC)
        );
        PRINT 'Completado: Tabla raw.Material creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla raw.Material ya existe.';
    END


    /***********************
     * 2. CURATED - 4 tablas
     ***********************/
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DimDate' AND schema_id = SCHEMA_ID('curated'))
    BEGIN
        CREATE TABLE curated.DimDate (
            DateKey INT NOT NULL,
            FullDate DATE NOT NULL,
            Year SMALLINT NOT NULL,
            Quarter TINYINT NOT NULL,
            Month TINYINT NOT NULL,
            MonthName NVARCHAR(20) NOT NULL,
            Day TINYINT NOT NULL,
            DayOfWeek TINYINT NOT NULL,
            DayName NVARCHAR(20) NOT NULL,
            IsWeekend BIT NOT NULL,
            IsHoliday BIT NOT NULL CONSTRAINT DF_DimDate_IsHoliday DEFAULT 0,
            FiscalYear SMALLINT NOT NULL,
            FiscalQuarter TINYINT NOT NULL,
            CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (DateKey ASC)
        );
        PRINT 'Completado: Tabla curated.DimDate creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla curated.DimDate ya existe.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DimVendor' AND schema_id = SCHEMA_ID('curated'))
    BEGIN
        CREATE TABLE curated.DimVendor (
            VendorKey INT IDENTITY(1,1) NOT NULL,
            VendorID INT NOT NULL,
            VendorName NVARCHAR(255) NOT NULL,
            VendorCountry NVARCHAR(100) NULL,
            VendorCategory NVARCHAR(100) NULL,
            IsActive BIT NOT NULL CONSTRAINT DF_DimVendor_IsActive DEFAULT 1,
            ValidFrom DATETIME2(7) NOT NULL CONSTRAINT DF_DimVendor_ValidFrom DEFAULT (SYSUTCDATETIME()),
            ValidTo DATETIME2(7) NOT NULL CONSTRAINT DF_DimVendor_ValidTo DEFAULT ('9999-12-31'),
            IsCurrent BIT NOT NULL CONSTRAINT DF_DimVendor_IsCurrent DEFAULT 1,
            CONSTRAINT PK_DimVendor PRIMARY KEY CLUSTERED (VendorKey ASC),
            CONSTRAINT UQ_DimVendor_VendorID_Current UNIQUE (VendorID, IsCurrent)
        );
        PRINT 'Completado: Tabla curated.DimVendor creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla curated.DimVendor ya existe.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DimMaterial' AND schema_id = SCHEMA_ID('curated'))
    BEGIN
        CREATE TABLE curated.DimMaterial (
            MaterialKey INT IDENTITY(1,1) NOT NULL,
            MaterialID NVARCHAR(50) NOT NULL,
            MaterialName NVARCHAR(255) NULL,
            Category NVARCHAR(100) NULL,
            SubCategory NVARCHAR(100) NULL,
            UnitOfMeasure NVARCHAR(20) NULL,
            EffectiveDate DATE NOT NULL CONSTRAINT DF_DimMaterial_EffDate DEFAULT ('1900-01-01'),
            EndDate DATE NOT NULL CONSTRAINT DF_DimMaterial_EndDate DEFAULT ('9999-12-31'),
            IsCurrent BIT NOT NULL CONSTRAINT DF_DimMaterial_IsCurrent DEFAULT 1,
            CONSTRAINT PK_DimMaterial PRIMARY KEY CLUSTERED (MaterialKey ASC),
            CONSTRAINT UQ_DimMaterial_MaterialID_Current UNIQUE (MaterialID, IsCurrent)
        );
        PRINT 'Completado: Tabla curated.DimMaterial creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla curated.DimMaterial ya existe.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FactPurchaseOrder' AND schema_id = SCHEMA_ID('curated'))
    BEGIN
        CREATE TABLE curated.FactPurchaseOrder (
            PurchaseOrderKey BIGINT IDENTITY(1,1) NOT NULL,
            PO_Number NVARCHAR(50) NOT NULL,
            VendorKey INT NOT NULL,
            MaterialKey INT NOT NULL,
            PO_DateKey INT NOT NULL,
            PO_Amount DECIMAL(19,4) NOT NULL,
            Currency NCHAR(3) NOT NULL CONSTRAINT DF_FactPO_Currency DEFAULT ('USD'),
            PO_Status NVARCHAR(50) NOT NULL,
            CreatedDateUTC DATETIME2(7) NOT NULL CONSTRAINT DF_FactPO_CreatedDate DEFAULT (SYSUTCDATETIME()),
            CreatedBy NVARCHAR(128) NOT NULL CONSTRAINT DF_FactPO_CreatedBy DEFAULT (SUSER_SNAME()),
            CONSTRAINT PK_FactPurchaseOrder PRIMARY KEY CLUSTERED (PurchaseOrderKey ASC),
            CONSTRAINT CHK_FactPO_Amount CHECK (PO_Amount >= 0)
        );
        PRINT 'Completado: Tabla curated.FactPurchaseOrder creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla curated.FactPurchaseOrder ya existe.';
    END



    /***********************
     * 3. GOVERNANCE - 1 tabla
     ***********************/
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ETL_AuditLog' AND schema_id = SCHEMA_ID('governance'))
    BEGIN
        CREATE TABLE governance.ETL_AuditLog (
            AuditKey BIGINT IDENTITY(1,1) NOT NULL,
            PackageName NVARCHAR(255) NOT NULL,
            TableName NVARCHAR(255) NOT NULL,
            StartTime DATETIME2(7) NOT NULL CONSTRAINT DF_ETL_AuditLog_StartTime DEFAULT (SYSUTCDATETIME()),
            EndTime DATETIME2(7) NULL,
            RowsInserted INT NULL,
            RowsUpdated INT NULL,
            RowsDeleted INT NULL,
            Status NVARCHAR(50) NOT NULL CONSTRAINT DF_ETL_AuditLog_Status DEFAULT ('Running'),
            ErrorMessage NVARCHAR(MAX) NULL,
            UserName NVARCHAR(128) NOT NULL CONSTRAINT DF_ETL_AuditLog_UserName DEFAULT (SUSER_SNAME()),
            CONSTRAINT PK_ETL_AuditLog PRIMARY KEY CLUSTERED (AuditKey ASC)
        );
        PRINT 'Completado: Tabla governance.ETL_AuditLog creada.';
    END
    ELSE
    BEGIN
        PRINT 'Tabla governance.ETL_AuditLog ya existe.';
    END

    COMMIT TRAN;

    PRINT 'Proceso completado. 7 tablas verificadas.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO