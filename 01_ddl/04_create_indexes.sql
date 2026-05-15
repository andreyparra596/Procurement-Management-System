USE ProcurementDW;
GO

SET NOCOUNT ON;
PRINT 'Starting index creation...';

BEGIN TRY
    BEGIN TRAN;

    -- DIMVENDOR - Indexes
    IF OBJECT_ID('curated.DimVendor', 'U') IS NOT NULL
    BEGIN
        -- Unique index on business key for MERGE and JOIN performance
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_DimVendor_VendorID_Current' 
                   AND object_id = OBJECT_ID('curated.DimVendor'))
            DROP INDEX IX_DimVendor_VendorID_Current ON curated.DimVendor;
        
        CREATE UNIQUE INDEX IX_DimVendor_VendorID_Current 
        ON curated.DimVendor(VendorID)
        WHERE IsCurrent = 1
        WITH (FILLFACTOR = 90);

        PRINT 'DimVendor indexes created.';
    END

    -- DIMMATERIAL - Indexes
    IF OBJECT_ID('curated.DimMaterial', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_DimMaterial_MaterialID_Current' 
                   AND object_id = OBJECT_ID('curated.DimMaterial'))
            DROP INDEX IX_DimMaterial_MaterialID_Current ON curated.DimMaterial;
        
        CREATE UNIQUE INDEX IX_DimMaterial_MaterialID_Current 
        ON curated.DimMaterial(MaterialID)
        WHERE IsCurrent = 1
        WITH (FILLFACTOR = 90);

        PRINT 'DimMaterial indexes created.';
    END

    -- DIMDATE - Indexes
    IF OBJECT_ID('curated.DimDate', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_DimDate_FullDate' 
                   AND object_id = OBJECT_ID('curated.DimDate'))
            DROP INDEX IX_DimDate_FullDate ON curated.DimDate;
        
        CREATE UNIQUE INDEX IX_DimDate_FullDate 
        ON curated.DimDate(FullDate)
        WITH (FILLFACTOR = 100);

        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_DimDate_DateKey' 
                   AND object_id = OBJECT_ID('curated.DimDate'))
            DROP INDEX IX_DimDate_DateKey ON curated.DimDate;
        
        CREATE NONCLUSTERED INDEX IX_DimDate_DateKey 
        ON curated.DimDate(DateKey)
        WITH (FILLFACTOR = 100);

        PRINT 'DimDate indexes created.';
    END

    -- FACTPURCHASEORDER - Indexes
    IF OBJECT_ID('curated.FactPurchaseOrder', 'U') IS NOT NULL
    BEGIN
        -- Unique index on PO_Number to prevent duplicates
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_Fact_PO_Number' 
                   AND object_id = OBJECT_ID('curated.FactPurchaseOrder'))
            DROP INDEX IX_Fact_PO_Number ON curated.FactPurchaseOrder;
        
        CREATE UNIQUE INDEX IX_Fact_PO_Number 
        ON curated.FactPurchaseOrder(PO_Number)
        WITH (FILLFACTOR = 90);

        -- Non-clustered index on PO_DateKey for time-based queries
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_Fact_PO_DateKey' 
                   AND object_id = OBJECT_ID('curated.FactPurchaseOrder'))
            DROP INDEX IX_Fact_PO_DateKey ON curated.FactPurchaseOrder;
        
        CREATE NONCLUSTERED INDEX IX_Fact_PO_DateKey 
        ON curated.FactPurchaseOrder(PO_DateKey)
        WITH (FILLFACTOR = 90);

        -- Non-clustered index on VendorKey for joins
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_Fact_VendorKey' 
                   AND object_id = OBJECT_ID('curated.FactPurchaseOrder'))
            DROP INDEX IX_Fact_VendorKey ON curated.FactPurchaseOrder;
        
        CREATE NONCLUSTERED INDEX IX_Fact_VendorKey 
        ON curated.FactPurchaseOrder(VendorKey)
        WITH (FILLFACTOR = 90);

        -- Non-clustered index on MaterialKey for joins
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_Fact_MaterialKey' 
                   AND object_id = OBJECT_ID('curated.FactPurchaseOrder'))
            DROP INDEX IX_Fact_MaterialKey ON curated.FactPurchaseOrder;
        
        CREATE NONCLUSTERED INDEX IX_Fact_MaterialKey 
        ON curated.FactPurchaseOrder(MaterialKey)
        WITH (FILLFACTOR = 90);

        PRINT 'FactPurchaseOrder indexes created.';
    END

    -- ETL_AUDITLOG - Indexes
    IF OBJECT_ID('governance.ETL_AuditLog', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'IX_Audit_ProcessDate' 
                   AND object_id = OBJECT_ID('governance.ETL_AuditLog'))
            DROP INDEX IX_Audit_ProcessDate ON governance.ETL_AuditLog;
        
        CREATE NONCLUSTERED INDEX IX_Audit_ProcessDate 
        ON governance.ETL_AuditLog(PackageName, TableName, StartTime DESC)
        WITH (FILLFACTOR = 90);

        PRINT 'AuditLog index created.';
    END

    COMMIT TRAN;
    PRINT 'Index creation completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO