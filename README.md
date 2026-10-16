# Proyecto Retail en PostgreSQL

Proyecto del curso de SQL. Base de datos `retail_project` con clientes, productos, categorías y ventas.

## Archivos

| Archivo | Entrega | Descripción |
|---|---|---|
| `retail_project.sql` | Pre-entrega 2 | Crea la base, las tablas con sus restricciones y los datos iniciales |
| `preparacion-modulo4.sql` | Módulo 4 | Agrega la tabla `categorias`, dos clientes sin compras e historial de ventas |
| `pre-entrega-modulo4.sql` | Módulo 4 | Las 3 consultas multicapa de análisis de negocio |

## Consultas del módulo 4

| # | Consulta | Pregunta de negocio | Técnicas |
|---|---|---|---|
| 1 | Rentabilidad por categoría | ¿Qué categorías superan $500.000 en ingresos? | `JOIN` de 3 tablas, `SUM`, `GROUP BY`, `HAVING` |
| 2 | Clientes sin compras | ¿Qué clientes registrados aún no compran? | `LEFT JOIN`, `COUNT`, `HAVING`, `COALESCE` |
| 3 | Top de compras por cliente | ¿Cuál es el producto favorito de cada cliente y cuándo compró por última vez? | `JOIN` de 3 tablas, `GROUP BY`, `ROW_NUMBER`, CTE |

Cada consulta tiene en el script un comentario con el problema de negocio que resuelve.

## Cómo ejecutarlo

Requisito: PostgreSQL 12 o superior. Ejecuta los archivos en este orden:

```bash
psql -U postgres -f retail_project.sql
psql -U postgres -d retail_project -f preparacion-modulo4.sql
psql -U postgres -d retail_project -f pre-entrega-modulo4.sql
```

En pgAdmin o DBeaver, abre cada archivo en una ventana de consultas conectada a `retail_project` y ejecútalo en el mismo orden.

`preparacion-modulo4.sql` se puede ejecutar más de una vez sin duplicar tablas, columnas ni datos.

## Resultado esperado

| Consulta | Filas |
|---|---|
| 1. Rentabilidad por categoría | 2 (Electrónica y Hogar; Papelería vende muchas unidades pero no supera el umbral) |
| 2. Clientes sin compras | 2 (Valentina Torres y Andrés Castaño) |
| 3. Top de compras por cliente | 5 (un producto favorito por cada cliente con compras) |
