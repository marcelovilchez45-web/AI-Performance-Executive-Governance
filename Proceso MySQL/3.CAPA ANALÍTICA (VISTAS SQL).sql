/* ================================================================
   PROYECTO: BI AGENTIC AI LEADERSHIP
   FASE 3: CAPA ANALÍTICA (VISTAS SQL)
   ESTRATEGIA: Capa Semántica Virtual para Power BI
   ================================================================
*/

USE bi_agentic_ai;

-- 1. LIMPIEZA DE VISTAS PREVIAS (Para evitar errores de duplicidad)
DROP VIEW IF EXISTS vw_detalle_performance_agentes;
DROP VIEW IF EXISTS vw_kpi_madurez_ia;
DROP VIEW IF EXISTS vw_segmentacion_autonomia_confianza;
DROP VIEW IF EXISTS vw_analisis_cumplimiento_exito;

-- ================================================================
-- 2. VISTA GRANULAR (Nivel Detalle)
-- Propósito: Fuente principal para tablas y drill-down. 
-- Une Hechos con todas las Dimensiones en un solo objeto plano.
-- ================================================================

CREATE VIEW vw_detalle_performance_agentes AS
SELECT 
    f.record_id AS ID_Registro,
    i.industry_name AS Industria,
    i.organization_size AS Tamano_Organizacion,
    l.leadership_function AS Funcion_Liderazgo,
    l.ai_maturity_level AS Madurez_IA,
    a.agent_type AS Tipo_Agente,
    a.use_case_area AS Area_Uso,
    a.agent_autonomy_level AS Nivel_Autonomia,
    a.decision_making_type AS Tipo_Decision,
    a.task_complexity_level AS Complejidad_Tarea,
    s.human_oversight_level AS Supervision_Humana,
    s.explainability_level AS Explicabilidad,
    s.data_privacy_compliance AS Privacidad_Datos,
    s.integration_level AS Nivel_Integracion,
    s.adoption_success_level AS Exito_Adopcion,
    -- Métricas
    f.context_awareness_score AS Score_Contexto,
    f.task_success_rate AS Tasa_Exito,
    f.response_time_seconds AS Tiempo_Respuesta_Seg,
    f.productivity_improvement_percent AS Mejora_Productividad_Pct,
    f.leadership_trust_score AS Score_Confianza_Lider
FROM fact_agent_performance f
JOIN dim_industry i ON f.dim_industry_id = i.dim_industry_id
JOIN dim_leadership l ON f.dim_leadership_id = l.dim_leadership_id
JOIN dim_agent a ON f.dim_agent_id = a.dim_agent_id
JOIN dim_strategy s ON f.dim_strategy_id = s.dim_strategy_id;

-- ================================================================
-- 3. VISTA AGREGADA (Nivel Ejecutivo)
-- Propósito: Resumen por Madurez de IA e Industria. 
-- Optimiza el rendimiento de gráficos de alto nivel.
-- ================================================================

CREATE VIEW vw_kpi_madurez_ia AS
SELECT 
    l.ai_maturity_level AS Madurez_IA,
    i.industry_name AS Industria,
    COUNT(f.fact_id) AS Total_Implementaciones,
    ROUND(AVG(f.task_success_rate), 2) AS Promedio_Exito,
    ROUND(AVG(f.productivity_improvement_percent), 2) AS Promedio_Mejora_Prod,
    ROUND(AVG(f.leadership_trust_score), 2) AS Promedio_Confianza
FROM fact_agent_performance f
JOIN dim_leadership l ON f.dim_leadership_id = l.dim_leadership_id
JOIN dim_industry i ON f.dim_industry_id = i.dim_industry_id
GROUP BY l.ai_maturity_level, i.industry_name;

-- ================================================================
-- 4. VISTA DE SEGMENTACIÓN (Nivel Operativo)
-- Propósito: Analizar la relación entre Autonomía y Confianza.
-- ================================================================

CREATE VIEW vw_segmentacion_autonomia_confianza AS
SELECT 
    a.agent_autonomy_level AS Autonomia,
    a.decision_making_type AS Toma_Decision,
    COUNT(*) AS Cantidad_Casos,
    ROUND(AVG(f.leadership_trust_score), 2) AS Confianza_Promedio,
    ROUND(AVG(f.response_time_seconds), 2) AS Tiempo_Promedio_Seg
FROM fact_agent_performance f
JOIN dim_agent a ON f.dim_agent_id = a.dim_agent_id
GROUP BY a.agent_autonomy_level, a.decision_making_type;

-- ================================================================
-- 5. VISTA DE CUMPLIMIENTO (Nivel Riesgo)
-- Propósito: Evaluar el éxito de adopción según privacidad y supervisión.
-- ================================================================

CREATE VIEW vw_analisis_cumplimiento_exito AS
SELECT 
    s.data_privacy_compliance AS Cumplimiento_Privacidad,
    s.human_oversight_level AS Supervision,
    s.adoption_success_level AS Exito,
    COUNT(*) AS Frecuencia
FROM fact_agent_performance f
JOIN dim_strategy s ON f.dim_strategy_id = s.dim_strategy_id
GROUP BY s.data_privacy_compliance, s.human_oversight_level, s.adoption_success_level;

-- ================================================================
-- 6. VALIDACIÓN FINAL
-- ================================================================

-- Comprobar que la vista granular tiene los mismos registros que la tabla de hechos
SELECT 
    'Validación Granularidad' AS Test,
    (SELECT COUNT(*) FROM fact_agent_performance) AS Total_Fact,
    (SELECT COUNT(*) FROM vw_detalle_performance_agentes) AS Total_Vista,
    CASE 
        WHEN (SELECT COUNT(*) FROM fact_agent_performance) = (SELECT COUNT(*) FROM vw_detalle_performance_agentes) 
        THEN 'OK: Consistente' 
        ELSE 'ERROR: Salto de registros' 
    END AS Resultado;

-- Muestra rápida de los datos listos para Power BI
SELECT * FROM vw_kpi_madurez_ia ORDER BY Promedio_Exito DESC;