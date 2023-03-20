-- @create_table.sql
spool create_table_fin.log

prompt *************************************************************
prompt ******************** DROP TABLE *****************************
prompt *************************************************************

/*
DROP TABLE Pays;
DROP TABLE Villes;
DROP TABLE Secteurs;
DROP TABLE Investments;
*/

prompt *************************************************************
prompt ******************** CREATE TABLE ***************************
prompt *************************************************************

CREATE TABLE dim_geographique (
    geographique_id NUMBER PRIMARY KEY NOT NULL, -- Ajout de la colonne d'identifiant unique
    country_code VARCHAR2(3),
    state_code VARCHAR2(3),
    region VARCHAR2(100),
    city VARCHAR2(100)
);

CREATE TABLE dim_temps (
    temps_id NUMBER PRIMARY KEY NOT NULL,
    founded_at DATE,
    founded_month DATE,
    founded_quarter VARCHAR2(100),
    founded_year DATE,
    first_funding_at DATE,
    last_funding_at DATE
);

CREATE TABLE dim_startup (
    startup_id NUMBER PRIMARY KEY NOT NULL,
    startup_name VARCHAR2(100),
    url_entreprise VARCHAR2(200),
    market VARCHAR2(100),
    startup_status VARCHAR2(50)
);

CREATE TABLE fait_leve_de_fond (
    geographique_id NUMBER,
    temps_id NUMBER,
    startup_id NUMBER,
    funding_total_usd NUMBER,
    funding_rounds NUMBER,

    FOREIGN KEY (geographique_id) REFERENCES dim_geographique(geographique_id), -- Référence de la clé primaire de dim_geographique
    FOREIGN KEY (temps_id) REFERENCES dim_temps(temps_id), -- Référence de la clé primaire de dim_temps
    FOREIGN KEY (startup_id) REFERENCES dim_startup(startup_id) -- Référence de la clé primaire de dim_startup
);

