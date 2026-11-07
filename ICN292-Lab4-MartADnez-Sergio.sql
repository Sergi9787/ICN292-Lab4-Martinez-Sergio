-- id_coleccion-- ICN292 - Laboratorio 4 - Austral Editores
-- Estudiante: Sergio Martínez
-- Archivo: ICN292-Lab4-Martínez-Sergio.sql
-- Motor: MySQL 8. Ejecutar POR BLOQUES para guardar capturas
-- de las consultas 1-6 ANTES de modificar datos en las consultas 7-8.
-- El archivo completo también es ejecutable de principio a fin sobre una base vacía.
-- ATENCION: DROP DATABASE borra la base austral existente.

-- ENTREGABLE 1: RECONSTRUCCION DE LA BASE
DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE austral;

-- Tablas principales
CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    pais VARCHAR(60),
    genero ENUM('Cómic', 'Ensayo', 'Infantil', 'Novela', 'Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Se crea colecciones ANTES que libros, porque libros la referencia.
CREATE TABLE colecciones (
    id_coleccion INT AUTO_INCREMENT,
    titulo VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

CREATE TABLE libros (
    id_libro INT AUTO_INCREMENT,
    id_autor INT NOT NULL,
    id_coleccion INT,
    titulo VARCHAR(120) NOT NULL,
    paginas INT,
    ejemplares_vendidos INT,
    anio INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);

CREATE TABLE pagos (
    id_pago INT AUTO_INCREMENT,
    id_autor INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);
SHOW TABLES;

-- CARGA OFICIAL (el orden de carga determina los ids AUTO_INCREMENT)
INSERT INTO autores (nombre, pais, genero) VALUES
('Elena Pizarro', 'Chile', 'Novela'),
('Harold Finch', 'Inglaterra', 'Ensayo'),
('Rodrigo Bahamonde', 'Chile', 'Poesía'),
('Valentina Correa', 'Argentina', 'Infantil'),
('Nora Keller', 'Estados Unidos', 'Novela'),
('Kenji Arakawa', NULL, 'Cómic');

-- id_coleccion queda en NULL hasta la consulta 9: la carga oficial
-- no incluye colecciones y se asignarán posteriormente a los 12 libros.
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
(1, 'Cielo de Enero', 210, 1500, 2024),
(1, 'Marea Baja', 185, 800, 2023),
(1, 'El Norte', 200, 2200, 2024),
(2, 'Estrellas que Caen', 240, 3000, 2022),
(2, 'Máquinas', 215, 450, 2024),
(3, 'Luz Artificial', 300, 1200, 2024),
(3, 'Ruido Blanco', 280, 600, 2023),
(4, 'El Barrio de Lila', 190, 5000, 2024),
(4, 'Antes del Amanecer', 205, 2700, 2024),
(4, 'La Calle 8', 175, 900, 2023),
(5, 'Flor de Hierro', 195, 4100, 2024),
(5, 'Hora Dorada', 220, 1800, 2022);

-- Validación opcional de carga oficial: 6 autores, 12 libros, 24250 ejemplares
SELECT (SELECT COUNT(*) FROM autores) AS autores,
       COUNT(*) AS libros,
       SUM(ejemplares_vendidos) AS total_ejemplares
FROM libros;

-- ENTREGABLE 2: CONSULTAS 1 A 6 (ANTES DE CAMBIOS)

-- 1. Autores fuera de Chile, incluyendo país desconocido
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre ASC;
-- Explicación para el informe: pais <> 'Chile' excluye los NULL,
-- porque su comparación con 'Chile' produce UNKNOWN (desconocido).

-- 2. Libros entre 190 y 220 páginas, ambos incluidos
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas ASC, titulo ASC;

-- 3. Indicadores del catálogo original, una sola fila
SELECT COUNT(*) AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares,
       AVG(paginas) AS promedio_paginas,
       MIN(anio) AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS mayor_venta_libro
FROM libros;

-- 4. Géneros únicos en orden alfabético
SELECT DISTINCT CAST(genero AS CHAR) AS genero
FROM autores
ORDER BY genero ASC;

-- 5. Autores con más de un libro de 2024
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores AS a
JOIN libros AS l ON l.id_autor = a.id_autor
WHERE l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre ASC;

-- 6. Top 3 de libros 2024 con más de 2000 ejemplares
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC, titulo ASC
LIMIT 3;

-- 7. INSERT, comprobación previa, DELETE y comprobación posterior
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 'Papel Mojado', 260, 50, 2024);

SELECT * FROM libros WHERE titulo = 'Papel Mojado';

DELETE FROM libros
WHERE id_libro = 13;

SELECT * FROM libros WHERE titulo = 'Papel Mojado';

-- 8. Antes, UPDATE, después: guardar las tres capturas requeridas
SELECT titulo, ejemplares_vendidos
FROM libros WHERE titulo = 'Cielo de Enero';

UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE id_libro = 1;

SELECT titulo, ejemplares_vendidos
FROM libros WHERE titulo = 'Cielo de Enero';

-- 9. Datos de prueba: dos colecciones y asignación de los 12 libros
-- Los datos de prueba son propuestos; no son parte de la carga oficial.
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
('Colección Austral Contemporánea', '2024-03-15'),
('Colección Letras y Horizontes', '2023-08-10');

-- Ambos UPDATE asignan una colección a TODOS los 12 libros oficiales.
UPDATE libros
SET id_coleccion = 1
WHERE id_libro IN (1, 3, 5, 8, 9, 11);

UPDATE libros
SET id_coleccion = 2
WHERE id_libro IN (2, 4, 6, 7, 10, 12);

SELECT l.titulo AS libro,
       c.titulo AS coleccion,
       c.fecha_publicacion
FROM libros AS l
JOIN colecciones AS c ON l.id_coleccion = c.id_coleccion
ORDER BY l.id_libro;

-- 10. Datos de prueba y dos sentencias de consulta
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
(1, '2026-10-02', 150000.00),
(1, '2026-10-16', 95000.50),
(3, '2026-10-20', 80000.00),
(4, '2026-10-28', 120000.00);

-- 10a. Detalle de pagos realizados
SELECT a.nombre AS autor, p.fecha_pago, p.monto
FROM pagos AS p
JOIN autores AS a ON p.id_autor = a.id_autor
ORDER BY a.nombre ASC, p.fecha_pago ASC;

-- 10b. Total pagado por autor (autores que recibieron pagos)
SELECT a.nombre AS autor, SUM(p.monto) AS total_pagado
FROM autores AS a
JOIN pagos AS p ON a.id_autor = p.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY a.nombre ASC;

-- Comprobaciones opcionales al final
SELECT COUNT(*) AS libros_sin_coleccion
FROM libros WHERE id_coleccion IS NULL;
SELECT COUNT(*) AS pagos_registrados FROM pagos;
