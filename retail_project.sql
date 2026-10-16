-- =====================================================================
-- Proyecto Retail - Pre-entrega 2
-- Tablas principales con restricciones y datos iniciales
-- Motor: PostgreSQL
-- Ejecución: psql -U postgres -f retail_project.sql
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. BASE DE DATOS
-- ---------------------------------------------------------------------
-- CREATE DATABASE no puede ir dentro de una transacción, por eso va
-- primero y por separado. \c es un comando de psql que conecta a la
-- base recién creada para que las tablas queden dentro de ella.
CREATE DATABASE retail_project;

\c retail_project


-- ---------------------------------------------------------------------
-- 1. DDL - ESTRUCTURA DE TABLAS
-- ---------------------------------------------------------------------
-- Permite volver a ejecutar el script desde cero. Se borra primero
-- ventas porque depende de las otras dos tablas.
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

-- 1.1 clientes
CREATE TABLE clientes (
    id_cliente      SERIAL       PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    ciudad          VARCHAR(80),
    edad            INT          CHECK (edad >= 18),            -- CHECK 1
    fecha_registro  DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- 1.2 productos
CREATE TABLE productos (
    id_producto  SERIAL        PRIMARY KEY,
    nombre       VARCHAR(100)  NOT NULL,
    categoria    VARCHAR(50)   NOT NULL,
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),     -- CHECK 2
    stock        INT           NOT NULL DEFAULT 0
                               CHECK (stock >= 0)               -- CHECK 3
);

-- 1.3 ventas (se crea al final: sus FOREIGN KEY apuntan a las dos
--     tablas anteriores, que ya deben existir)
CREATE TABLE ventas (
    id_venta         SERIAL        PRIMARY KEY,
    id_cliente       INT           NOT NULL,
    id_producto      INT           NOT NULL,
    cantidad         INT           NOT NULL
                                   CHECK (cantidad > 0),        -- CHECK 4
    precio_unitario  DECIMAL(10,2) NOT NULL
                                   CHECK (precio_unitario > 0), -- CHECK 5
    fecha_venta      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (id_cliente)  REFERENCES clientes (id_cliente),
    CONSTRAINT fk_ventas_producto
        FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
);


-- ---------------------------------------------------------------------
-- 2. DML - CARGA INICIAL DENTRO DE UNA TRANSACCIÓN
-- ---------------------------------------------------------------------
-- Si algún INSERT falla, no se confirma ninguno: la carga queda
-- completa o no queda.
BEGIN;

INSERT INTO clientes (nombre, email, telefono, ciudad, edad, fecha_registro) VALUES
    ('Ana Gómez',      'ana.gomez@correo.com',      '3001234567', 'Bogotá',       29, '2026-01-15'),
    ('Luis Martínez',  'luis.martinez@correo.com',  '3109876543', 'Medellín',     41, '2026-02-03'),
    ('Carla Ríos',     'carla.rios@correo.com',     NULL,         'Cali',         35, '2026-02-20'),
    ('Jorge Peña',     'jorge.pena@correo.com',     '3205551122', 'Armenia',      52, '2026-03-08'),
    ('Sofía Herrera',  'sofia.herrera@correo.com',  '3157778899', 'Barranquilla', 23, '2026-03-27');

INSERT INTO productos (nombre, categoria, precio, stock) VALUES
    ('Audífonos inalámbricos', 'Electrónica', 120000.00,  40),
    ('Teclado mecánico',       'Electrónica', 210000.00,  25),
    ('Mouse óptico',           'Electrónica',  55000.00,  60),
    ('Silla ergonómica',       'Hogar',       480000.00,  10),
    ('Lámpara de escritorio',  'Hogar',        75000.00,  30),
    ('Cuaderno argollado',     'Papelería',     9500.00, 200);

INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1, 1, 1, 120000.00, '2026-04-02 10:15:00'),
    (2, 2, 1, 210000.00, '2026-04-03 16:40:00'),
    (3, 6, 5,   9500.00, '2026-04-05 09:05:00'),
    (4, 4, 1, 480000.00, '2026-04-08 14:20:00'),
    (5, 3, 2,  55000.00, '2026-04-10 11:30:00'),
    (1, 5, 1,  75000.00, '2026-04-12 18:00:00'),
    (2, 6, 1,   9500.00, '2026-04-12 18:05:00');  -- venta de prueba (se elimina en el punto 4)

COMMIT;


-- ---------------------------------------------------------------------
-- 3. UPDATE MASIVO DE PRECIOS (con WHERE)
-- ---------------------------------------------------------------------
-- Aumento del 10 % a todos los productos de la categoría 'Electrónica'.

-- Verificación previa: filas que se van a modificar
SELECT id_producto, nombre, categoria, precio
FROM productos
WHERE categoria = 'Electrónica';

UPDATE productos
SET precio = ROUND(precio * 1.10, 2)
WHERE categoria = 'Electrónica';

-- Verificación posterior
SELECT id_producto, nombre, categoria, precio
FROM productos
WHERE categoria = 'Electrónica';


-- ---------------------------------------------------------------------
-- 4. DELETE DE UN REGISTRO DE PRUEBA (con WHERE)
-- ---------------------------------------------------------------------
-- Se elimina la venta de prueba, identificada por su clave primaria.

-- Verificación previa: fila que se va a eliminar
SELECT *
FROM ventas
WHERE id_venta = 7;

DELETE FROM ventas
WHERE id_venta = 7;


-- ---------------------------------------------------------------------
-- 5. ESTADO FINAL
-- ---------------------------------------------------------------------
SELECT * FROM clientes  ORDER BY id_cliente;
SELECT * FROM productos ORDER BY id_producto;
SELECT * FROM ventas    ORDER BY id_venta;
