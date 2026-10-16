-- =====================================================================
-- Proyecto Retail - Pre-entrega Módulo 4
-- Consultas multicapa para análisis de negocio
-- Base de datos: retail_project
-- Requisito: haber ejecutado preparacion-modulo4.sql
-- =====================================================================
-- Alias usados en todo el script:
--   v   = ventas      p = productos
--   cat = categorias  c = clientes
-- =====================================================================


-- ---------------------------------------------------------------------
-- CONSULTA 1. RENTABILIDAD POR CATEGORÍA
-- ---------------------------------------------------------------------
-- Problema de negocio:
--   La tienda necesita saber qué categorías generan más dinero para
--   decidir dónde concentrar inventario, espacio en vitrina y
--   presupuesto de campañas. Ver solo las unidades engaña: una
--   categoría puede vender muchas unidades baratas y aportar poco
--   ingreso.
--
-- Umbral definido en $500.000 de ingreso total porque es el monto a
-- partir del cual una categoría justifica inversión dedicada (reposición
-- prioritaria y pauta propia) en el período analizado; por debajo de
-- ese valor se gestiona con reposición estándar.
--
-- El ingreso se calcula con v.precio_unitario (precio cobrado en cada
-- venta) y no con p.precio (precio actual del catálogo), porque los
-- precios cambian con el tiempo y el ingreso real es el que se cobró.
-- El filtro va en HAVING porque se aplica sobre un resultado agregado
-- (SUM); en WHERE generaría error.
SELECT
    cat.nombre                          AS categoria,
    SUM(v.cantidad)                     AS unidades_vendidas,
    SUM(v.cantidad * v.precio_unitario) AS ingreso_total
FROM ventas v
INNER JOIN productos  p   ON p.id_producto    = v.id_producto
INNER JOIN categorias cat ON cat.id_categoria = p.id_categoria
GROUP BY cat.nombre
HAVING SUM(v.cantidad * v.precio_unitario) > 500000
ORDER BY ingreso_total DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 2. CLIENTES SIN COMPRAS
-- ---------------------------------------------------------------------
-- Problema de negocio:
--   Un cliente registrado que nunca compra representa un costo de
--   adquisición sin retorno. Identificarlos permite al equipo de
--   marketing lanzar una campaña de activación (por ejemplo, un cupón
--   de primera compra), priorizando a quienes llevan más días
--   registrados sin comprar.
--
-- LEFT JOIN conserva a todos los clientes aunque no tengan ventas; en
-- esos casos las columnas de ventas llegan en NULL. COALESCE convierte
-- el total comprado en 0 y el teléfono ausente en un texto legible para
-- el equipo que hará el contacto. El filtro sobre COUNT va en HAVING.
SELECT
    c.id_cliente,
    c.nombre                                         AS cliente,
    c.email,
    COALESCE(c.telefono, 'Sin teléfono')             AS telefono,
    c.ciudad,
    c.fecha_registro,
    CURRENT_DATE - c.fecha_registro                  AS dias_registrado,
    COUNT(v.id_venta)                                AS compras_realizadas,
    COALESCE(SUM(v.cantidad * v.precio_unitario), 0) AS total_comprado
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.email, c.telefono, c.ciudad, c.fecha_registro
HAVING COUNT(v.id_venta) = 0
ORDER BY c.fecha_registro ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 3. TOP DE COMPRAS POR CLIENTE
-- ---------------------------------------------------------------------
-- Problema de negocio:
--   Para personalizar ofertas y recordatorios de recompra, la tienda
--   necesita conocer el producto favorito de cada cliente (el que más
--   veces compró) y cuándo fue su última transacción. Un cliente con
--   un favorito claro y varias semanas sin comprar es candidato a un
--   recordatorio con ese producto.
--
-- Paso 1 (compras): une clientes, ventas y productos y cuenta cuántas
--   veces compró cada cliente cada producto (GROUP BY cliente-producto).
-- Paso 2 (ranking): ROW_NUMBER numera los productos de cada cliente de
--   mayor a menor número de compras. Si hay empate, gana el producto con
--   más unidades y, si sigue el empate, el comprado más recientemente.
--   MAX(...) OVER obtiene la última transacción del cliente con
--   cualquier producto, no solo con su favorito.
-- Paso 3: se queda con la posición 1 de cada cliente.
WITH compras AS (
    SELECT
        c.id_cliente,
        c.nombre           AS cliente,
        p.id_producto,
        p.nombre           AS producto,
        COUNT(v.id_venta)  AS veces_comprado,
        SUM(v.cantidad)    AS unidades_compradas,
        MAX(v.fecha_venta) AS ultima_compra_producto
    FROM clientes c
    INNER JOIN ventas    v ON v.id_cliente  = c.id_cliente
    INNER JOIN productos p ON p.id_producto = v.id_producto
    GROUP BY c.id_cliente, c.nombre, p.id_producto, p.nombre
),
ranking AS (
    SELECT
        co.cliente,
        co.producto,
        co.veces_comprado,
        co.unidades_compradas,
        MAX(co.ultima_compra_producto) OVER (PARTITION BY co.id_cliente) AS ultima_transaccion,
        ROW_NUMBER() OVER (
            PARTITION BY co.id_cliente
            ORDER BY co.veces_comprado DESC,
                     co.unidades_compradas DESC,
                     co.ultima_compra_producto DESC
        ) AS posicion
    FROM compras co
)
SELECT
    r.cliente,
    r.producto           AS producto_mas_comprado,
    r.veces_comprado,
    r.unidades_compradas,
    r.ultima_transaccion
FROM ranking r
WHERE r.posicion = 1
ORDER BY r.ultima_transaccion DESC;
