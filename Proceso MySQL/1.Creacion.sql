
CREATE DATABASE IF NOT EXISTS bi_agentic_ai;
USE bi_agentic_ai;

DROP TABLE IF EXISTS stg_agentic_ai_leadership;

CREATE TABLE stg_agentic_ai_leadership (
    Record_ID VARCHAR(50),
    Industry VARCHAR(100),
    Organization_Size VARCHAR(50),
    Leadership_Function VARCHAR(100),
    AI_Maturity_Level VARCHAR(50),
    Agent_Type VARCHAR(100),
    Use_Case_Area VARCHAR(100),
    Agent_Autonomy_Level VARCHAR(50),
    Decision_Making_Type VARCHAR(50),
    Context_Awareness_Score DECIMAL(10,2),
    Task_Complexity_Level VARCHAR(50),
    Human_Oversight_Level VARCHAR(50),
    Explainability_Level VARCHAR(50),
    Data_Privacy_Compliance VARCHAR(10),
    Integration_Level VARCHAR(100),
    Task_Success_Rate DECIMAL(10,2),
    Response_Time_Seconds DECIMAL(10,2),
    Productivity_Improvement_Percent DECIMAL(10,2),
    Leadership_Trust_Score DECIMAL(10,2),
    Adoption_Success_Level VARCHAR(50),
    PRIMARY KEY (Record_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Carga de Datos

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/AgenticAI_Leadership_Dataset_v1.csv' 
INTO TABLE stg_agentic_ai_leadership 
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ','  
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' -- Cambio aquí para compatibilidad total con CSV de Windows
IGNORE 1 LINES 
(Record_ID, Industry, Organization_Size, Leadership_Function, AI_Maturity_Level,   
 Agent_Type, Use_Case_Area, Agent_Autonomy_Level, Decision_Making_Type,   
 Context_Awareness_Score, Task_Complexity_Level, Human_Oversight_Level,   
 Explainability_Level, Data_Privacy_Compliance, Integration_Level,   
 Task_Success_Rate, Response_Time_Seconds, Productivity_Improvement_Percent,   
 Leadership_Trust_Score, Adoption_Success_Level);
 
 SET GLOBAL local_infile = 1;
 
 -- Verificaciones de Datos:
 
 -- 1. ¿Cargaron todos los registros? (Deberían ser 5498 según el snippet)
SELECT COUNT(*) as total_registros FROM stg_agentic_ai_leadership;

-- 2. ¿Hay duplicados en el ID principal?
SELECT Record_ID, COUNT(*) 
FROM stg_agentic_ai_leadership 
GROUP BY Record_ID 
HAVING COUNT(*) > 1;

-- 3. ¿Hay nulos críticos en las métricas?
SELECT 
    SUM(CASE WHEN Task_Success_Rate IS NULL THEN 1 ELSE 0 END) AS null_success,
    SUM(CASE WHEN Leadership_Trust_Score IS NULL THEN 1 ELSE 0 END) AS null_trust
FROM stg_agentic_ai_leadership;

-- 4. Verificación de outliers en scores (Rango esperado 0-100)
SELECT MIN(Context_Awareness_Score), MAX(Context_Awareness_Score) 
FROM stg_agentic_ai_leadership;

