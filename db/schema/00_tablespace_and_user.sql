-- Dedicated tablespace for this project's data
CREATE TABLESPACE elo_insights_data
    DATAFILE '<ORACLE_DATA_DIR>\elo_insights_data01.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 50M MAXSIZE 2G;

-- Dedicated user, creates all objects for this project
CREATE USER elo_insights IDENTIFIED BY "<SET_YOUR_OWN_PASSWORD>"
    DEFAULT TABLESPACE elo_insights_data
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON elo_insights_data;

-- Minimum privileges required to build and run the schema
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO elo_insights;

-- Required later, once PKG_INGESTION and PKG_ANALYTICS are added
GRANT CREATE PROCEDURE TO elo_insights;