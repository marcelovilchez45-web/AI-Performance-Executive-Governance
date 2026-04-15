/* ================================================================
   PROYECTO: BI AGENTIC AI LEADERSHIP
   FASE 2: MODELADO DIMENSIONAL (STAR SCHEMA) - SCRIPT DEFINITIVO
   ================================================================
*/

USE bi_agentic_ai;

-- 1. LIMPIEZA DE ENTORNO (Fresh Start)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS fact_agent_performance;
DROP TABLE IF EXISTS dim_industry;
DROP TABLE IF EXISTS dim_leadership;
DROP TABLE IF EXISTS dim_agent;
DROP TABLE IF EXISTS dim_strategy;
SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 2. CREACIÓN DE TABLAS DE DIMENSIONES (Claves Sustitutas)
-- ================================================================

CREATE TABLE dim_industry (
    dim_industry_id INT AUTO_INCREMENT PRIMARY KEY,
    industry_name VARCHAR(100),
    organization_size VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE dim_leadership (
    dim_leadership_id INT AUTO_INCREMENT PRIMARY KEY,
    leadership_function VARCHAR(100),
    ai_maturity_level VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE dim_agent (
    dim_agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_type VARCHAR(100),
    use_case_area VARCHAR(100),
    agent_autonomy_level VARCHAR(50),
    decision_making_type VARCHAR(50),
    task_complexity_level VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE dim_strategy (
    dim_strategy_id INT AUTO_INCREMENT PRIMARY KEY,
    human_oversight_level VARCHAR(50),
    explainability_level VARCHAR(50),
    data_privacy_compliance VARCHAR(10),
    integration_level VARCHAR(100),
    adoption_success_level VARCHAR(50)
) ENGINE=InnoDB;

-- ================================================================
-- 3. CREACIÓN DE TABLA DE HECHOS (Métricas e IDs)
-- ================================================================

CREATE TABLE fact_agent_performance (
    fact_id INT AUTO_INCREMENT PRIMARY KEY,
    record_id VARCHAR(50), -- Clave natural para trazabilidad
    dim_industry_id INT,
    dim_leadership_id INT,
    dim_agent_id INT,
    dim_strategy_id INT,
    -- Métricas Numéricas
    context_awareness_score DECIMAL(10,2),
    task_success_rate DECIMAL(10,2),
    response_time_seconds DECIMAL(10,2),
    productivity_improvement_percent DECIMAL(10,2),
    leadership_trust_score DECIMAL(10,2),
    -- Relaciones
    CONSTRAINT fk_industry_perf FOREIGN KEY (dim_industry_id) REFERENCES dim_industry(dim_industry_id),
    CONSTRAINT fk_leadership_perf FOREIGN KEY (dim_leadership_id) REFERENCES dim_leadership(dim_leadership_id),
    CONSTRAINT fk_agent_perf FOREIGN KEY (dim_agent_id) REFERENCES dim_agent(dim_agent_id),
    CONSTRAINT fk_strategy_perf FOREIGN KEY (dim_strategy_id) REFERENCES dim_strategy(dim_strategy_id)
) ENGINE=InnoDB;

-- ================================================================
-- 4. POBLADO DE DIMENSIONES (Usando stg_agentic_ai_leadership)
-- ================================================================

INSERT INTO dim_industry (industry_name, organization_size)
SELECT DISTINCT Industry, Organization_Size 
FROM stg_agentic_ai_leadership;

INSERT INTO dim_leadership (leadership_function, ai_maturity_level)
SELECT DISTINCT Leadership_Function, AI_Maturity_Level 
FROM stg_agentic_ai_leadership;

INSERT INTO dim_agent (agent_type, use_case_area, agent_autonomy_level, decision_making_type, task_complexity_level)
SELECT DISTINCT Agent_Type, Use_Case_Area, Agent_Autonomy_Level, Decision_Making_Type, Task_Complexity_Level 
FROM stg_agentic_ai_leadership;

INSERT INTO dim_strategy (human_oversight_level, explainability_level, data_privacy_compliance, integration_level, adoption_success_level)
SELECT DISTINCT Human_Oversight_Level, Explainability_Level, Data_Privacy_Compliance, Integration_Level, Adoption_Success_Level 
FROM stg_agentic_ai_leadership;

-- ================================================================
-- 5. POBLADO DE TABLA DE HECHOS (Cruces de Integridad)
-- ================================================================

INSERT INTO fact_agent_performance (
    record_id, dim_industry_id, dim_leadership_id, dim_agent_id, dim_strategy_id,
    context_awareness_score, task_success_rate, response_time_seconds, 
    productivity_improvement_percent, leadership_trust_score
)
SELECT 
    s.Record_ID,
    di.dim_industry_id,
    dl.dim_leadership_id,
    da.dim_agent_id,
    ds.dim_strategy_id,
    s.Context_Awareness_Score,
    s.Task_Success_Rate,
    s.Response_Time_Seconds,
    s.Productivity_Improvement_Percent,
    s.Leadership_Trust_Score
FROM stg_agentic_ai_leadership s
JOIN dim_industry di 
    ON s.Industry = di.industry_name AND s.Organization_Size = di.organization_size
JOIN dim_leadership dl 
    ON s.Leadership_Function = dl.leadership_function AND s.AI_Maturity_Level = dl.ai_maturity_level
JOIN dim_agent da 
    ON s.Agent_Type = da.agent_type AND s.Use_Case_Area = da.use_case_area 
    AND s.Agent_Autonomy_Level = da.agent_autonomy_level AND s.Decision_Making_Type = da.decision_making_type
    AND s.Task_Complexity_Level = da.task_complexity_level
JOIN dim_strategy ds 
    ON s.Human_Oversight_Level = ds.human_oversight_level 
    AND s.Explainability_Level = ds.explainability_level AND s.Data_Privacy_Compliance = ds.data_privacy_compliance
    AND s.Integration_Level = ds.integration_level AND s.Adoption_Success_Level = ds.adoption_success_level;

-- ================================================================
-- 6. VALIDACIÓN DE RESULTADOS
-- ================================================================

-- Comprobación de carga completa
SELECT 
    (SELECT COUNT(*) FROM stg_agentic_ai_leadership) as origen_staging,
    (SELECT COUNT(*) FROM fact_agent_performance) as destino_fact,
    CASE 
        WHEN (SELECT COUNT(*) FROM stg_agentic_ai_leadership) = (SELECT COUNT(*) FROM fact_agent_performance) 
        THEN 'ÉXITO: Sincronización completa' 
        ELSE 'ERROR: Discrepancia en el conteo' 
    END AS resultado;