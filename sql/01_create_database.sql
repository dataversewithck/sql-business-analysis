/*
Project: SQL Business Analysis
Platform: SQL Server / T-SQL

Run this script in SSMS using a login that can create databases.
*/

IF DB_ID('SQLBusinessAnalysis') IS NULL
BEGIN
    CREATE DATABASE SQLBusinessAnalysis;
END;
GO

USE SQLBusinessAnalysis;
GO
