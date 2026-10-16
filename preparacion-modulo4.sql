-- =====================================================================
-- Proyecto Retail - Módulo 4
-- Preparación de la base para las consultas multicapa
-- Base de datos: retail_project (creada en la pre-entrega anterior)
-- Ejecutar UNA vez antes de pre-entrega-modulo4.sql.
-- Es seguro volver a ejecutarlo: no duplica tablas, columnas ni datos.
-- =====================================================================
-- Por qué hace falta:
--   1. La consigna pide unir ventas, productos y categorias, pero en el
--      esquema anterior la categoría era un texto dentro de productos.
--      Se crea la tabla categorias y se enlaza con productos mediante
--      una FOREIGN KEY (id_categoria).
--   2. Todos los clientes cargados ya tenían compras, así que la
--      consulta "Clientes sin compras" no devolvería nada. Se agregan
--      dos clientes recién registrados que aún no compran.
--   3. Con una sola venta por cliente no hay un "producto más comprado".
--      Se agregan ventas de mayo a septiembre de 2026 para tener
--      historial de compras repetidas.
-- =====================================================================

BEGIN;

-- 1. Tabla categorias
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria  SERIAL       PRIMARY KEY,
    nombre        VARCHAR(50)  NOT NULL UNIQUE,
    descripcion   VARCHAR(150)
);

INSERT INTO categorias (nombre, descripcion) VALUES
    ('Electrónica', 'Accesorios y periféricos tecnológicos'),
    ('Hogar',       'Muebles e iluminación para casa y oficina'),
    ('Papelería',   'Útiles de escritorio y oficina')
ON CONFLICT (nombre) DO NOTHING;

-- 2. Enlace productos -> categorias
ALTER TABLE productos
    ADD COLUMN IF NOT EXISTS id_categoria INT REFERENCES categorias (id_categoria);

-- Se asigna la categoría a cada producto a partir del texto que ya tenía.
UPDATE productos p
SET id_categoria = cat.id_categoria
FROM categorias cat
WHERE cat.nombre = p.categoria
  AND p.id_categoria IS NULL;

-- 3. Clientes registrados que todavía no compran
INSERT INTO clientes (nombre, email, telefono, ciudad, edad, fecha_registro) VALUES
    ('Valentina Torres', 'valentina.torres@correo.com', '3014445566', 'Pereira',  27, '2026-08-19'),
    ('Andrés Castaño',   'andres.castano@correo.com',   NULL,         'Manizales', 38, '2026-09-10')
ON CONFLICT (email) DO NOTHING;

-- 4. Historial de ventas adicional (mayo a septiembre de 2026)
--    precio_unitario es el precio vigente al momento de la venta.
--    NOT EXISTS evita duplicar una venta si el script se ejecuta de nuevo.
INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
SELECT n.id_cliente, n.id_producto, n.cantidad, n.precio_unitario, n.fecha_venta
FROM (VALUES
    (1, 1,  1, 132000.00, TIMESTAMP '2026-05-10 12:30:00'),
    (2, 6, 10,   9500.00, TIMESTAMP '2026-05-18 08:45:00'),
    (3, 5,  1,  75000.00, TIMESTAMP '2026-06-03 17:10:00'),
    (4, 3,  1,  60500.00, TIMESTAMP '2026-06-25 10:00:00'),
    (5, 1,  1, 132000.00, TIMESTAMP '2026-07-05 19:20:00'),
    (1, 1,  1, 132000.00, TIMESTAMP '2026-07-22 15:00:00'),
    (1, 6,  3,   9500.00, TIMESTAMP '2026-08-15 09:30:00'),
    (4, 3,  1,  60500.00, TIMESTAMP '2026-08-30 11:40:00'),
    (2, 6,  4,   9500.00, TIMESTAMP '2026-09-02 14:15:00'),
    (3, 6,  8,   9500.00, TIMESTAMP '2026-09-20 16:50:00')
) AS n (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
WHERE NOT EXISTS (
    SELECT 1
    FROM ventas v
    WHERE v.id_cliente  = n.id_cliente
      AND v.id_producto = n.id_producto
      AND v.fecha_venta = n.fecha_venta
);

COMMIT;
