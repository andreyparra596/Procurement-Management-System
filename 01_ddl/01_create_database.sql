/* ============================================================================
   Project: Strategic Procurement Value Intelligence Hub
   File: 01_create_database.sql
   Author: Andrey Parra
   Date: 2026-05-08
   ============================================================================ */

USE [master];
GO


IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ProcurementDW')
BEGIN
    CREATE DATABASE [ProcurementDW];
    PRINT 'Completado: Base de datos creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'Base de datos ya existe.';
END
GO


BEGIN TRY

    IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ProcurementDW')
    BEGIN
        ALTER DATABASE [ProcurementDW] SET RECOVERY SIMPLE WITH NO_WAIT;
        PRINT 'Configurado: Recovery Model = SIMPLE';
        
        ALTER DATABASE [ProcurementDW] SET AUTO_SHRINK OFF WITH NO_WAIT;
        PRINT 'Configurado: AUTO_SHRINK = OFF';
    END
    
END TRY
BEGIN CATCH
    PRINT 'ERROR en configuración de 01_create_database.sql: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

