Markdown
# ✈️ Automatización de Conciliación Operador Turístico- Sitema en MYSQL

Este proyecto desarrolla una solución eficiente y automatizada mediante **SQL (MySQL)** para resolver uno de los problemas más comunes y tediosos en la administración de agencias de viajes: la conciliación de cuentas entre los reportes de los operadores turísticos externos y los registros internos del sistema de gestión ERP.

## 📌 El Problema de Negocio

La conciliación manual en la industria del turismo presenta complejidades específicas que dificultan los cruces de datos tradicionales:
1. **Múltiples reservas agrupadas:** El sistema interno suele consolidar varias reservas o cupones en una sola celda separados por comas (ej. `130-2595119,130-2595120`), rompiendo la relación 1 a 1 clásica de un `JOIN`.
2. **Discrepancias en cadenas de texto:** Los nombres de los pasajeros o clientes varían formalmente entre lo cargado por el operador y lo registrado internamente, lo que impide cruces directos exactos.
3. **Volumen de transacciones:** El procesamiento manual de archivos extensos de facturación genera cuellos de botella mensuales y margen de error humano.

## 🛠️ La Solución Técnica (Arquitectura del Script)

El script SQL implementa un flujo de datos robusto estructurado en tres capas (*Staging*, *Normalización* y *Resolución*):

### 1. Capa de Staging (Estructura de Datos)
Se definen tablas base (`listsistema` y `listoperador`) tipificadas para absorber las planillas CSV provenientes de los sistemas de origen, aislando el esquema de caracteres especiales molestos mediante un mapeo limpio de columnas.

### 2. Capa de Normalización
Para resolver las celdas multi-reserva de Aptour, el script utiliza un **generador dinámico de filas** basado en un `CROSS JOIN` matemático y funciones de extracción de subcadenas (`SUBSTRING_INDEX`). 

Esto "desarma" automáticamente las listas separadas por comas en registros independientes:


### 3. Capa de Resolución (Reglas de Negocio Coalesce)
Para determinar el Estado de la conciliación y encontrar el ID correspondiente del sistema interno sin duplicar filas del operador, el reporte final ejecuta un cruce con cascada de prioridades:

Prioridad 1: Coincidencia exacta por identificador de reserva (N_de_Reserva = DETALLE_INDIVIDUAL).

Prioridad 2 (Match Difuso): Búsqueda cruzada de similitud de cadenas en los nombres de los clientes utilizando la función LIKE CONCAT('%', ... ,'%') en ambos sentidos si la prioridad 1 resultó nula.

Prioridad 3: Espacio vacío si no se detectaron ocurrencias en el sistema para posterior auditoría manual.

## 🚀 Instrucciones de Uso
Clonar el repositorio y abrir el script en MySQL Workbench.

Ejecutar la creación del esquema y las tablas base de staging.

Importar tus archivos CSV correspondientes utilizando el asistente de importación o sentencias LOAD DATA LOCAL INFILE asegurando la coherencia de los delimitadores.

Correr los bloques de normalización y cruzado. El script está optimizado para cumplir con modos estrictos como ONLY_FULL_GROUP_BY mediante el uso estratégico de funciones agregadoras (MAX).

Exportar la tabla reporte_conciliado_final de regreso a formato de hoja de cálculo (CSV/Excel) para su análisis o presentación corporativa.
