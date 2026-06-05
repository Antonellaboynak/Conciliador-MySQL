CREATE SCHEMA IF NOT EXISTS conciliacion_operador_sistema;
USE conciliacion_operador_sistema;

-- Tabla base para el informe de sistema
DROP TABLE IF EXISTS listsistema;
CREATE TABLE listsistema (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    ID_RES VARCHAR(50),
    NOM_CLI VARCHAR(100),
    DETALLE VARCHAR(100),
    VENTA VARCHAR(50),
    COSTO VARCHAR(50)
);

-- Tabla base para el informe del operador
DROP TABLE IF EXISTS listoperador;
CREATE TABLE listoperador (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    Entidad_Legal VARCHAR(50),
    N_Factura VARCHAR(50),
    FechaDoc VARCHAR(50),
    FechaVto VARCHAR(50),
    FLlegada VARCHAR(50),
    FSalida VARCHAR(50),
    SuRef VARCHAR(50),
    Destino VARCHAR(50),
    N_de_Reserva VARCHAR(50),
    Cliente VARCHAR(100),
    Hotel VARCHAR(50),
    N_Pax VARCHAR(50),
    Importe VARCHAR(50),
    Moneda VARCHAR(50),
    Estado VARCHAR(50) -- Queda en principio vacia
);

SELECT *
FROM listoperador ;

SELECT *
FROM listsistema;

-- Tabla listsistema normalizada
DROP TABLE IF EXISTS listsistema_normalizada;
CREATE TABLE listsistema_normalizada AS
SELECT 
    s.ID_RES,
    s.NOM_CLI,
    -- Corte del texto entre comas y se quitan espacios residuales
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(s.DETALLE, ',', n.n), ',', -1)) AS DETALLE_INDIVIDUAL
FROM listsistema s
CROSS JOIN (
    -- Generador dinámico de filas
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 
    UNION ALL SELECT 9 UNION ALL SELECT 10
) n
-- Crea filas según la cantidad real de comas (+1) detectadas
WHERE n.n <= CHAR_LENGTH(s.DETALLE) - CHAR_LENGTH(REPLACE(s.DETALLE, ',', '')) + 1
  AND s.DETALLE IS NOT NULL 
  AND s.DETALLE != '';
  
SELECT * 
FROM listsistema_normalizada ;

-- Tabla de reporte conciliado
DROP TABLE IF EXISTS reporte_conciliado_final;
CREATE TABLE reporte_conciliado_final AS
SELECT 
    lo.Entidad_Legal,
    lo.N_Factura,
    lo.FechaDoc,
    lo.FechaVto,
    lo.FLlegada,
    lo.FSalida,
    lo.SuRef,
    lo.Destino,
    lo.N_de_Reserva,
    lo.Cliente,
    lo.Hotel,
    lo.N_Pax,
    lo.Importe,
    lo.Moneda,
    COALESCE(
        REPLACE(CAST(CAST(MAX(match_reserva.ID_RES) AS UNSIGNED) AS CHAR), ' ', ''), 
        REPLACE(CAST(CAST(MAX(match_nombre.ID_RES)  AS UNSIGNED) AS CHAR), ' ', ''), 
        ''
    ) AS Estado
FROM listoperador lo
-- Cruzamos contra la tabla normalizada (Prioridad 1: Reserva exacta)
LEFT JOIN listsistema_normalizada match_reserva 
    ON lo.N_de_Reserva = match_reserva.DETALLE_INDIVIDUAL
    AND (lo.N_de_Reserva IS NOT NULL AND lo.N_de_Reserva != '')
-- Cruzamos contra la tabla normalizada (Prioridad 2: Coincidencia cruzada de nombres)
LEFT JOIN listsistema_normalizada match_nombre 
    ON match_reserva.ID_RES IS NULL -- Optimización: Solo busca por nombre si falló la reserva
    AND (lo.Cliente IS NOT NULL AND match_nombre.NOM_CLI IS NOT NULL)
    AND (lo.Cliente LIKE CONCAT('%', TRIM(match_nombre.NOM_CLI), '%') 
         OR match_nombre.NOM_CLI LIKE CONCAT('%', TRIM(lo.Cliente), '%'))
GROUP BY lo.id_auditoria;         
         
SELECT *
FROM reporte_conciliado_final;