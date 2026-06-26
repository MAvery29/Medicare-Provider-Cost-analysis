USE Medicare;

CREATE TABLE Provider_Raw (
    Rndrng_NPI                    VARCHAR(20),
    Rndrng_Prvdr_Last_Org_Name    VARCHAR(100),
    Rndrng_Prvdr_First_Name       VARCHAR(50),
    Rndrng_Prvdr_MI               VARCHAR(5),
    Rndrng_Prvdr_Crdntls          VARCHAR(50),
    Rndrng_Prvdr_Ent_Cd           VARCHAR(5),
    Rndrng_Prvdr_St1              VARCHAR(100),
    Rndrng_Prvdr_St2              VARCHAR(100),
    Rndrng_Prvdr_City             VARCHAR(50),
    Rndrng_Prvdr_State_Abrvtn     VARCHAR(5),
    Rndrng_Prvdr_State_FIPS       VARCHAR(10),
    Rndrng_Prvdr_Zip5             VARCHAR(10),
    Rndrng_Prvdr_RUCA             VARCHAR(10),
    Rndrng_Prvdr_RUCA_Desc        VARCHAR(255),
    Rndrng_Prvdr_Cntry            VARCHAR(50),
    Rndrng_Prvdr_Type             VARCHAR(100),
    Rndrng_Prvdr_Mdcr_Prtcptg_Ind VARCHAR(5),
    HCPCS_Cd                      VARCHAR(10),
    HCPCS_Desc                    VARCHAR(500),
    HCPCS_Drug_Ind                VARCHAR(5),
    Place_Of_Srvc                 VARCHAR(5),
    Tot_Benes                     INT,
    Tot_Srvcs                     DECIMAL(10,2),
    Tot_Bene_Day_Srvcs            DECIMAL(10,2),
    Avg_Sbmtd_Chrg                DECIMAL(10,2),
    Avg_Mdcr_Alowd_Amt            DECIMAL(10,2),
    Avg_Mdcr_Pymt_Amt             DECIMAL(10,2),
    Avg_Mdcr_Stdzd_Amt            DECIMAL(10,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MedicareData.csv'
INTO TABLE Provider_Raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*)
FROM Provider_Raw;

SELECT *
FROM Provider_Raw
LIMIT 10;

SELECT 
  SUM(CASE WHEN Rndrng_NPI IS NULL THEN 1 ELSE 0 END) AS null_npi,
  SUM(CASE WHEN Rndrng_Prvdr_Type IS NULL THEN 1 ELSE 0 END) AS null_type,
  SUM(CASE WHEN HCPCS_Desc IS NULL THEN 1 ELSE 0 END) AS null_desc,
  SUM(CASE WHEN Avg_Mdcr_Pymt_Amt IS NULL THEN 1 ELSE 0 END) AS null_payment
FROM Provider_Raw;

SELECT Rndrng_Prvdr_Type, COUNT(*) AS cnt
FROM Provider_Raw
GROUP BY Rndrng_Prvdr_Type
ORDER BY cnt DESC
LIMIT 10;

SELECT Rndrng_Prvdr_State_Abrvtn, COUNT(*) AS cnt
FROM Provider_Raw
GROUP BY Rndrng_Prvdr_State_Abrvtn
ORDER BY cnt DESC;

-- See what these mystery codes are
SELECT 
  Rndrng_Prvdr_State_Abrvtn,
  Rndrng_Prvdr_Cntry,
  COUNT(*) AS cnt
FROM Provider_Raw
WHERE Rndrng_Prvdr_State_Abrvtn IN ('ZZ', 'XX', 'AP', 'AE', 'AA', 'FM', 'AS')
GROUP BY Rndrng_Prvdr_State_Abrvtn, Rndrng_Prvdr_Cntry
ORDER BY cnt DESC;

ALTER TABLE Provider_Raw ADD COLUMN Provider_Location VARCHAR(20);

UPDATE Provider_Raw
SET Provider_Location = CASE
    WHEN Rndrng_Prvdr_State_Abrvtn IN ('AP', 'AE', 'AA') THEN 'MILITARY'
    WHEN Rndrng_Prvdr_State_Abrvtn = 'ZZ' THEN 'FOREIGN'
    WHEN Rndrng_Prvdr_State_Abrvtn = 'XX' THEN 'UNKNOWN'
    ELSE 'DOMESTIC'
END;
-- Starting the cleaning process
CREATE TABLE Provider_Staging (
    Rndrng_NPI                    VARCHAR(20),
    Rndrng_Prvdr_Last_Org_Name    VARCHAR(100),
    Rndrng_Prvdr_First_Name       VARCHAR(50),
    Rndrng_Prvdr_MI               VARCHAR(5),
    Rndrng_Prvdr_Crdntls          VARCHAR(50),
    Rndrng_Prvdr_Ent_Cd           VARCHAR(5),
    Rndrng_Prvdr_St1              VARCHAR(100),
    Rndrng_Prvdr_St2              VARCHAR(100),
    Rndrng_Prvdr_City             VARCHAR(50),
    Rndrng_Prvdr_State_Abrvtn     VARCHAR(5),
    Rndrng_Prvdr_State_FIPS       VARCHAR(10),
    Rndrng_Prvdr_Zip5             VARCHAR(10),
    Rndrng_Prvdr_RUCA             VARCHAR(10),
    Rndrng_Prvdr_RUCA_Desc        VARCHAR(255),
    Rndrng_Prvdr_Cntry            VARCHAR(50),
    Rndrng_Prvdr_Type             VARCHAR(100),
    Rndrng_Prvdr_Mdcr_Prtcptg_Ind VARCHAR(5),
    HCPCS_Cd                      VARCHAR(10),
    HCPCS_Desc                    VARCHAR(500),
    HCPCS_Drug_Ind                VARCHAR(5),
    Place_Of_Srvc                 VARCHAR(5),
    Tot_Benes                     INT,
    Tot_Srvcs                     DECIMAL(10,2),
    Tot_Bene_Day_Srvcs            DECIMAL(10,2),
    Avg_Sbmtd_Chrg                DECIMAL(10,2),
    Avg_Mdcr_Alowd_Amt            DECIMAL(10,2),
    Avg_Mdcr_Pymt_Amt             DECIMAL(10,2),
    Avg_Mdcr_Stdzd_Amt            DECIMAL(10,2),
	Provider_Location             TEXT
);

SET GLOBAL innodb_buffer_pool_size = 2147483648; -- 2GB
SET GLOBAL sort_buffer_size = 67108864;          -- 64MB
SET GLOBAL tmp_table_size = 268435456;           -- 256MB
SET GLOBAL max_heap_table_size = 268435456;      -- 256MB

-- all the states
INSERT INTO Provider_Staging(
    `Rndrng_NPI`, `Rndrng_Prvdr_Last_Org_Name`, `Rndrng_Prvdr_First_Name`, `Rndrng_Prvdr_MI`,
    `Rndrng_Prvdr_Crdntls`, `Rndrng_Prvdr_Ent_Cd`, `Rndrng_Prvdr_St1`, `Rndrng_Prvdr_St2`,
    `Rndrng_Prvdr_City`, `Rndrng_Prvdr_State_Abrvtn`, `Rndrng_Prvdr_State_FIPS`, `Rndrng_Prvdr_Zip5`,
    `Rndrng_Prvdr_RUCA`, `Rndrng_Prvdr_RUCA_Desc`, `Rndrng_Prvdr_Cntry`, `Rndrng_Prvdr_Type`,
    `Rndrng_Prvdr_Mdcr_Prtcptg_Ind`, `HCPCS_Cd`, `HCPCS_Desc`, `HCPCS_Drug_Ind`, `Place_Of_Srvc`,
    `Tot_Benes`, `Tot_Srvcs`, `Tot_Bene_Day_Srvcs`, `Avg_Sbmtd_Chrg`, `Avg_Mdcr_Alowd_Amt`,
    `Avg_Mdcr_Pymt_Amt`, `Avg_Mdcr_Stdzd_Amt`, `Provider_Location`
)
WITH CTE_Duplicate AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY `Rndrng_NPI`, `HCPCS_Cd`
            ORDER BY `Rndrng_NPI`) AS ROW_NUM 
    FROM Provider_Raw
    WHERE `Rndrng_Prvdr_State_Abrvtn` = 'AS'							
)
SELECT 
    `Rndrng_NPI`, `Rndrng_Prvdr_Last_Org_Name`, `Rndrng_Prvdr_First_Name`, `Rndrng_Prvdr_MI`,
    `Rndrng_Prvdr_Crdntls`, `Rndrng_Prvdr_Ent_Cd`, `Rndrng_Prvdr_St1`, `Rndrng_Prvdr_St2`,
    `Rndrng_Prvdr_City`, `Rndrng_Prvdr_State_Abrvtn`, `Rndrng_Prvdr_State_FIPS`, `Rndrng_Prvdr_Zip5`,
    `Rndrng_Prvdr_RUCA`, `Rndrng_Prvdr_RUCA_Desc`, `Rndrng_Prvdr_Cntry`, `Rndrng_Prvdr_Type`,
    `Rndrng_Prvdr_Mdcr_Prtcptg_Ind`, `HCPCS_Cd`, `HCPCS_Desc`, `HCPCS_Drug_Ind`, `Place_Of_Srvc`,
    `Tot_Benes`, `Tot_Srvcs`, `Tot_Bene_Day_Srvcs`, `Avg_Sbmtd_Chrg`, `Avg_Mdcr_Alowd_Amt`,
    `Avg_Mdcr_Pymt_Amt`, `Avg_Mdcr_Stdzd_Amt`, `Provider_Location`
FROM CTE_Duplicate
WHERE ROW_NUM = 1;

SELECT DISTINCT `Rndrng_Prvdr_State_Abrvtn`
FROM Provider_Raw;

-- How many rows were removed?
SELECT 
  (SELECT COUNT(*) FROM Provider_Raw) AS raw_count,
  (SELECT COUNT(*) FROM Provider_Staging) AS clean_count,
  (SELECT COUNT(*) FROM Provider_Raw) - 
  (SELECT COUNT(*) FROM Provider_Staging) AS duplicates_removed;

-- Standardization
SELECT Rndrng_Prvdr_Type, COUNT(*) AS cnt
FROM Provider_Staging
GROUP BY Rndrng_Prvdr_Type
ORDER BY cnt DESC
LIMIT 20;

-- Check participation indicator
SELECT Rndrng_Prvdr_Mdcr_Prtcptg_Ind, COUNT(*) AS cnt
FROM Provider_Staging
GROUP BY Rndrng_Prvdr_Mdcr_Prtcptg_Ind;

SELECT HCPCS_Drug_Ind, COUNT(*) AS cnt
FROM Provider_Staging
GROUP BY HCPCS_Drug_Ind;

SELECT Place_Of_Srvc, COUNT(*) AS cnt
FROM Provider_Staging
GROUP BY Place_Of_Srvc;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_NPI TO Provider_NPI;

ALTER TABLE Provider_Staging 
RENAME COLUMN Rndrng_Prvdr_Last_Org_Name TO Provider_LastName;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_First_Name TO Provider_FirstName;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_MI TO Provider_MiddleInitial;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_Crdntls TO Provider_Credentials;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_Ent_Cd TO Provider_EntityCode;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_St1 TO Address_Line_1;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_St2 TO Address_Line_2;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_City TO City;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_State_Abrvtn TO State;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_State_FIPS TO State_Fips ;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_Zip5 TO ZipCode ;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_RUCA TO RucaCode;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_RUCA_Desc TO RucaDescription;

ALTER TABLE Provider_Staging
RENAME COLUMN Rndrng_Prvdr_Cntry TO Country;

ALTER TABLE Provider_Staging
RENAME COLUMN  Rndrng_Prvdr_Type TO Provider_Speciality;

ALTER TABLE Provider_Staging
RENAME COLUMN  Rndrng_Prvdr_Mdcr_Prtcptg_Ind TO Medicare_Participation;

ALTER TABLE Provider_Staging
RENAME COLUMN HCPCS_Cd TO HCPCS_Code;

ALTER TABLE Provider_Staging
RENAME COLUMN HCPCS_Desc TO HCPCS_Description;

ALTER TABLE Provider_Staging
RENAME COLUMN HCPCS_Drug_Ind TO Drug_Indicator;

ALTER TABLE Provider_Staging
RENAME COLUMN Place_Of_Srvc TO Service_Place;

ALTER TABLE Provider_Staging
RENAME COLUMN Tot_Benes TO Total_Beneficiaries;

ALTER TABLE Provider_Staging
RENAME COLUMN Tot_Srvcs TO Total_Services;

ALTER TABLE Provider_Staging
RENAME COLUMN Tot_Bene_Day_Srvcs TO Total_Beneficiaries_Day_Service;

ALTER TABLE Provider_Staging
RENAME COLUMN Avg_Sbmtd_Chrg TO Average_Submitted_Charge;

ALTER TABLE Provider_Staging
RENAME COLUMN Avg_Mdcr_Alowd_Amt TO Average_Medicare_Allowed_Amount;

ALTER TABLE Provider_Staging
RENAME COLUMN Avg_Mdcr_Pymt_Amt TO Average_Medicare_Payment_Amount;

ALTER TABLE Provider_Staging
RENAME COLUMN Avg_Mdcr_Stdzd_Amt TO Average_Medicare_Standardized_Amount;

DESCRIBE Provider_Staging;

WITH aggregated AS (
    SELECT 
        Provider_NPI,
        Provider_LastName,
        Provider_Speciality,
        State,
        SUM(Average_Medicare_Payment_Amount) AS Total_Payment
    FROM Provider_Staging
    GROUP BY 
        Provider_NPI,
        Provider_LastName,
        Provider_Speciality,
        State
),

ranked AS (
    SELECT *,
        RANK() OVER(
            PARTITION BY State
            ORDER BY Total_Payment DESC
        ) AS State_Rank
    FROM aggregated
)

SELECT *
FROM ranked
WHERE State_Rank <= 5;

WITH specialty_avg AS (
    SELECT 
        Provider_Speciality,
        AVG(Average_Medicare_Payment_Amount) AS National_Avg
    FROM Provider_Staging
    GROUP BY Provider_Speciality
),
provider_avg AS (
    SELECT
        Provider_NPI,
        Provider_LastName,
        Provider_Speciality,
        State,
        AVG(Average_Medicare_Payment_Amount) AS Provider_Avg
    FROM Provider_Staging
    GROUP BY 
        Provider_NPI,
        Provider_LastName,
        Provider_Speciality,
        State
)
SELECT 
    p.*,
    n.National_Avg,
    ROUND(p.Provider_Avg - n.National_Avg, 2) AS Difference
FROM provider_avg p
JOIN specialty_avg n 
    ON p.Provider_Speciality = n.Provider_Speciality
WHERE p.Provider_Avg > n.National_Avg
ORDER BY Difference DESC
LIMIT 20;

SELECT 
    State,
    COUNT(DISTINCT Provider_NPI) AS Total_Providers,
    ROUND(AVG(Average_Medicare_Payment_Amount), 2) AS Avg_Payment,
    ROUND(SUM(Average_Medicare_Payment_Amount), 2) AS Total_Payment
FROM Provider_Staging
GROUP BY State
ORDER BY Total_Payment DESC;

SELECT 
    Provider_Speciality,
    COUNT(DISTINCT Provider_NPI) AS Total_Providers,
    ROUND(AVG(Average_Medicare_Payment_Amount), 2) AS Avg_Payment,
    ROUND(SUM(Average_Medicare_Payment_Amount), 2) AS Total_Payment
FROM Provider_Staging
GROUP BY Provider_Speciality
ORDER BY Total_Payment DESC
LIMIT 20;