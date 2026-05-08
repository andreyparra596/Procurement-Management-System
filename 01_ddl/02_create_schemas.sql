/* ============================================================================
   Project: Strategic Procurement Value Intelligence Hub
   File: 02_create_schemas.sql
   Author: Andrey Parra
   Date: 2026-05-08
   ============================================================================ */


USE [ProcurementDW];
GO

BEGIN TRY
BEGIN TRAN;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =N'raw')
BEGIN
EXEC('CREATE SCHEMA [raw] AUTHORIZATION [dbo]');
PRINT 'Completado: Schema [raw] creado.';
END
ELSE
BEGIN
PRINT 'Schema [raw] ya existe. ';
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =N'staging')
BEGIN
EXEC('CREATE SCHEMA [staging] AUTHORIZATION [dbo]');
PRINT 'Completado: Schema [staging] creado.';
END
ELSE
BEGIN
PRINT 'Schema [staging] ya existe. ';
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =N'curated')
BEGIN
EXEC('CREATE SCHEMA [curated] AUTHORIZATION [dbo]');
PRINT 'Completado: Schema [curated] creado.';
END
ELSE
BEGIN
PRINT 'Schema [curated] ya existe. ';
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =N'analytics')
BEGIN
EXEC('CREATE SCHEMA [analytics] AUTHORIZATION [dbo]');
PRINT 'Completado: Schema [analytics] creado.';
END
ELSE
BEGIN
PRINT 'Schema [analytics] ya existe. ';
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name =N'governance')
BEGIN
EXEC('CREATE SCHEMA [governance] AUTHORIZATION [dbo]');
PRINT 'Completado: Schema [governance] creado.';
END
ELSE
BEGIN
PRINT 'Schema [governance] ya existe. ';
END

COMMIT TRAN;
PRINT 'Completado: 5 schemas fueron creados con exito o ya estaban creados';

END TRY 
BEGIN CATCH

IF @@TRANCOUNT > 0 ROLLBACK TRAN;
PRINT 'ERROR: no fue posible crear los schemas' + ERROR_MESSAGE();
THROW;
END CATCH
GO


