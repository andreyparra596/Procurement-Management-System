/* ============================================================================
   Project: Strategic Procurement Value Intelligence Hub
   File: 02_create_schemas.sql
   Author: Andrey Parra
   Date: 2026-05-07
   ============================================================================ */


USE [master];
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ProcurementDW') DROP DATABASE [ProcurementDW];
GO

CREATE DATABASE [ProcurementDW];
GO

USE [ProcurementDW];
GO

CREATE SCHEMA [raw];
GO
CREATE SCHEMA [staging];
GO
CREATE SCHEMA [curated];
GO
CREATE SCHEMA [analytics];
GO
CREATE SCHEMA [governance];
GO

PRINT 'Completado: Base ProcurementDW y 5 schemas fueron creados';
