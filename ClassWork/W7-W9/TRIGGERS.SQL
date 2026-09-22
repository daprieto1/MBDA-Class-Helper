-- ============================================================================
-- MYSD-MBDA S09: Integridad Procedimental — Disparadores
-- Caso: Envios (Date) + Caso: Ventas
-- PostgreSQL / plpgsql
-- ============================================================================
--
-- Un disparador (trigger) es un SUBPROGRAMA que se ejecuta:
--   - en MOMENTOS especificos     → BEFORE | INSTEAD OF | AFTER
--   - asociado a EVENTOS          → INSERT | DELETE | UPDATE [OF columna]
--   - sobre una TABLA             → ON nombre_tabla
--   - una o mas VECES             → FOR EACH ROW
--   - si se cumple una CONDICION  → WHEN (condicion)
--
-- Estructura de la funcion:
--   CREATE OR REPLACE FUNCTION nombre() RETURNS TRIGGER AS $$
--   DECLARE
--       -- variables
--   BEGIN
--       -- instrucciones
--       RETURN {NEW | OLD | NULL};
--   END;
--   $$ LANGUAGE plpgsql;
--
-- Estructura del disparador:
--   CREATE OR REPLACE TRIGGER nombre
--       {BEFORE | INSTEAD OF | AFTER}
--       {INSERT | DELETE | UPDATE [OF columna]}
--       ON tabla
--       [FOR EACH ROW] [WHEN (condicion)]
--       EXECUTE FUNCTION nombre_funcion();
--
-- Recordar:
--   - NEW: fila nueva (disponible en INSERT y UPDATE)
--   - OLD: fila anterior (disponible en UPDATE y DELETE)
--   - BEFORE + RETURN NULL = cancela la operacion
--   - BEFORE + RETURN NEW = permite/modifica la operacion
--   - TG_OP: operacion que disparo el trigger ('INSERT','UPDATE','DELETE')
--
-- Para que sirven los disparadores?
--   1. Implementar reglas de integridad
--      - Evitando acciones no deseadas
--      - Automatizando acciones deseadas
--   2. Mover logica de aplicacion a datos
--      - Centralizando acciones
--      - Aumentando la eficiencia
-- ============================================================================


-- ============================================================================
-- PARTE 1: ESQUEMA BASE — CASO ENVIOS
-- ============================================================================
-- Modelo conceptual:
--   Vendedor(v#, nombre, estado, ciudad)  1 ──Corresponde──> * Envio
--   Parte(p#, parte, color, peso, precio) 1 ──Corresponde──> * Envio
--   Envio(numero, cant, precio)
--
-- Modelo relacional:
--   Vendedores(v#, nombre, estado, ciudad)
--   Partes(p#, parte, color, peso, precio)
--   Envios(numero, cant, precio, parte, vendedor)
-- ============================================================================

DROP TABLE IF EXISTS envios CASCADE;
DROP TABLE IF EXISTS partes CASCADE;
DROP TABLE IF EXISTS vendedores CASCADE;

CREATE TABLE vendedores (
    v       VARCHAR(5)  NOT NULL,
    nombre  VARCHAR(20) NOT NULL,
    estado  INTEGER     NOT NULL,
    ciudad  VARCHAR(10) NOT NULL
);

CREATE TABLE partes (
    p       VARCHAR(5)  NOT NULL,
    parte   VARCHAR(20) NOT NULL,
    color   VARCHAR(10) NOT NULL,
    peso    INTEGER     NOT NULL,
    precio  INTEGER     NOT NULL
);

CREATE TABLE envios (
    numero   SERIAL      NOT NULL,
    cant     INTEGER     NOT NULL,
    precio   INTEGER     NOT NULL,
    parte    VARCHAR(5)  NOT NULL,
    vendedor VARCHAR(5)  NOT NULL
);

-- Claves primarias
ALTER TABLE vendedores ADD CONSTRAINT PK_VENDEDORES PRIMARY KEY (v);
ALTER TABLE partes     ADD CONSTRAINT PK_PARTES     PRIMARY KEY (p);
ALTER TABLE envios     ADD CONSTRAINT PK_ENVIOS     PRIMARY KEY (numero);

-- Claves foraneas con acciones referenciales
-- Propuesta de clase:
--   1. Dejar borrar una parte. Al borrarla se borran sus envios.         → ON DELETE CASCADE
--   2. Dejar borrar vendedores. Al borrarlo queda en desconocido.        → ON DELETE SET NULL
--      (requeriria que vendedor sea nullable; aqui usamos CASCADE para demo)
--   3. Dejar modificar el codigo de una parte. Propagar el cambio.       → ON UPDATE CASCADE
ALTER TABLE envios ADD CONSTRAINT FK_ENVIOS_PARTES
    FOREIGN KEY (parte) REFERENCES partes (p)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE envios ADD CONSTRAINT FK_ENVIOS_VENDEDORES
    FOREIGN KEY (vendedor) REFERENCES vendedores (v)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


-- ============================================================================
-- DATOS DE PRUEBA — CASO ENVIOS
-- ============================================================================

INSERT INTO vendedores VALUES ('V1', 'Smith',  20, 'Londres');
INSERT INTO vendedores VALUES ('V2', 'Jones',  10, 'Paris');
INSERT INTO vendedores VALUES ('V3', 'Blake',  30, 'Paris');
INSERT INTO vendedores VALUES ('V4', 'Clark',  20, 'Londres');
INSERT INTO vendedores VALUES ('V5', 'Adams',  30, 'Atenas');

INSERT INTO partes VALUES ('P1', 'tuerca',    'rojo',  12, 100);
INSERT INTO partes VALUES ('P2', 'perno',     'verde', 17, 150);
INSERT INTO partes VALUES ('P3', 'tornillo',  'azul',  17, 100);
INSERT INTO partes VALUES ('P4', 'tornillo',  'rojo',  14, 400);
INSERT INTO partes VALUES ('P5', 'leva',      'azul',  12, 700);
INSERT INTO partes VALUES ('P6', 'engranaje', 'rojo',  19, 100);

INSERT INTO envios (cant, precio, parte, vendedor) VALUES (25,  100, 'P1', 'V1');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (200, 150, 'P2', 'V1');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (400, 100, 'P3', 'V1');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (200, 100, 'P1', 'V2');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (100, 100, 'P3', 'V2');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (300, 400, 'P4', 'V2');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (100, 100, 'P1', 'V3');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (200, 100, 'P3', 'V3');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (400, 400, 'P4', 'V4');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (100, 700, 'P5', 'V4');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (200, 150, 'P2', 'V4');
INSERT INTO envios (cant, precio, parte, vendedor) VALUES (400, 100, 'P1', 'V4');


-- ============================================================================
-- PARTE 2: DISPARADORES — CASO ENVIOS
-- ============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2.1  Mo: Actualizar el color de una parte
--      Regla: los colores 'amarilla', 'azul' y 'rojo' NO se pueden cambiar.
--             Si el nuevo color ya tiene 30 o mas partes, asignar 'generico'.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE (seguimiento incremental):
--   1. Que pasa si queremos cambiar el color de una parte rojo a verde?
--      Por que? → No se debe permitir (rojo es color protegido)
--   2. Que pasa si queremos cambiar naranja a verde? Es la primera verde.
--      Por que? → Se permite (naranja no es protegido, hay < 30 verdes)
--   3. Que pasa si queremos cambiar rosada a verde? Ya hay 30 verdes.
--      Por que? → Se reasigna a 'generico' (limite alcanzado)
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    partes
--   Evento:   UPDATE OF color
--   Momento:  BEFORE  (necesitamos modificar NEW antes de que se escriba)
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_partes_upd_color() RETURNS TRIGGER AS $$
DECLARE
    veces INTEGER;
BEGIN
    -- Si el color actual es protegido, NO permitir el cambio (mantener el viejo)
    IF OLD.color IN ('amarilla', 'azul', 'rojo') THEN
        NEW.color := OLD.color;
    ELSE
        -- Si NO es protegido, verificar cuantas partes ya tienen el nuevo color
        SELECT COUNT(*) INTO veces FROM partes WHERE color = NEW.color;
        IF (veces >= 30) THEN
            -- Si hay 30 o mas, reasignar a 'generico'
            NEW.color := 'generico';
        END IF;
    END IF;
    -- RETURN NEW: permite la operacion (con el valor posiblemente modificado)
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_partes_upd_color
    BEFORE UPDATE OF color ON partes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_partes_upd_color();

-- PRUEBAS:
-- 1. Intentar cambiar P1 (rojo) a verde → debe quedarse en rojo
--    UPDATE partes SET color = 'verde' WHERE p = 'P1';
--    SELECT * FROM partes WHERE p = 'P1';  -- color sigue siendo 'rojo'
--
-- 2. Intentar cambiar P2 (verde) a naranja → se permite (no es protegido, < 30)
--    UPDATE partes SET color = 'naranja' WHERE p = 'P2';
--    SELECT * FROM partes WHERE p = 'P2';  -- color = 'naranja'


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2.2  Ad: Adicionar un envio con datos minimos
--      Regla: al insertar un envio solo se necesita: vendedor, parte, cant.
--             El sistema calcula: numero (consecutivo) y precio (de la parte).
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   1. Instruccion actual para adicionar un nuevo envio de 25 partes de P1
--      del proveedor V1?
--      → INSERT INTO envios VALUES (13, 25, 100, 'P1', 'V1');
--        Problema: el usuario necesita saber el numero y el precio
--
--   2. Instruccion deseada con datos minimos? Que puede calcular el sistema?
--      → INSERT INTO envios (cant, parte, vendedor) VALUES (25, 'P1', 'V1');
--        El sistema calcula: numero (MAX+1) y precio (de partes)
--
--   3. Como lograrlo? → Disparador BEFORE INSERT
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    envios
--   Evento:   INSERT
--   Momento:  BEFORE  (necesitamos asignar valores en NEW antes de insertar)
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_envios_ins() RETURNS TRIGGER AS $$
BEGIN
    -- Calcular el siguiente numero consecutivo
    SELECT COALESCE(MAX(numero), 0) + 1 INTO NEW.numero FROM envios;

    -- Obtener el precio actual de la parte
    SELECT precio INTO NEW.precio FROM partes WHERE p = NEW.parte;

    -- RETURN NEW: permite la insercion con los valores calculados
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_envios_ins
    BEFORE INSERT ON envios
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_envios_ins();

-- PRUEBAS (seguimiento):
-- Insertar con datos minimos: 25 partes de P1 del proveedor V1
--   INSERT INTO envios (cant, parte, vendedor) VALUES (25, 'P1', 'V1');
--   SELECT * FROM envios ORDER BY numero DESC LIMIT 1;
--   → numero = 13 (o el siguiente), precio = 100 (precio de P1)
--
-- Insertar con una parte cara:
--   INSERT INTO envios (cant, parte, vendedor) VALUES (10, 'P5', 'V3');
--   SELECT * FROM envios ORDER BY numero DESC LIMIT 1;
--   → precio = 700 (precio de P5)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2.3  Mo: El precio de una parte no debe bajar
--      Regla: al actualizar el precio, si el nuevo es menor, mantener el viejo.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   1. Instruccion para subir el precio de todas las partes a 100:
--      → UPDATE partes SET precio = 100;
--
--   2. Que pasa? → Las partes con precio > 100 (P2=150, P4=400, P5=700)
--      pierden valor. Los precios BAJAN.
--
--   3. Que deseariamos que pasara? → Que los precios nunca bajen.
--      Solo se actualicen los que suben o se mantienen.
--
--   4. Como lograrlo? → Disparador BEFORE UPDATE OF precio
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    partes
--   Evento:   UPDATE OF precio
--   Momento:  BEFORE  (necesitamos interceptar y corregir NEW)
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_partes_upd_precio() RETURNS TRIGGER AS $$
BEGIN
    -- Si el nuevo precio es menor que el actual, mantener el viejo
    IF NEW.precio < OLD.precio THEN
        NEW.precio := OLD.precio;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_partes_upd_precio
    BEFORE UPDATE OF precio ON partes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_partes_upd_precio();

-- PRUEBAS (seguimiento):
-- Subir todos los precios a 100:
--   SELECT p, precio FROM partes ORDER BY p;
--   UPDATE partes SET precio = 100;
--   SELECT p, precio FROM partes ORDER BY p;
--   → P1=100(=), P2=150(no bajo), P3=100(=), P4=400(no bajo), P5=700(no bajo), P6=100(=)
--
-- Subir todos los precios a 500:
--   UPDATE partes SET precio = 500;
--   SELECT p, precio FROM partes ORDER BY p;
--   → P1=500(subio), P2=500(subio), P3=500(subio), P4=500(subio), P5=700(no bajo), P6=500(subio)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2.4  El: No se deben poder eliminar los envios
--      Regla: la eliminacion de envios esta prohibida. Lanzar excepcion.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   1. Instruccion para eliminar los envios de 'P4':
--      → DELETE FROM envios WHERE parte = 'P4';
--
--   2. Que pasa? → Se eliminan (2 envios de P4 desaparecen)
--
--   3. Que deseariamos que pasara? → Que NO se puedan eliminar.
--      Lanzar un error explicativo.
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    envios
--   Evento:   DELETE
--   Momento:  BEFORE  (interceptar antes de que se borre)
--   Veces:    FOR EACH ROW
--
-- Excepciones:
--   - Del sistema: SELECT INTO puede lanzar too_many_rows (P0003)
--   - Personalizadas: RAISE EXCEPTION USING MESSAGE='...', ERRCODE='A0001';
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_envios_del() RETURNS TRIGGER AS $$
BEGIN
    -- Lanzar una excepcion personalizada: no se pueden eliminar envios
    RAISE EXCEPTION 'No se pueden eliminar los envios.'
        USING ERRCODE = 'A0001';

    -- Nunca se llega aqui, pero por convencion:
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_envios_del
    BEFORE DELETE ON envios
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_envios_del();

-- PRUEBAS (seguimiento):
-- Intentar eliminar envios de P4:
--   DELETE FROM envios WHERE parte = 'P4';
--   → ERROR: No se pueden eliminar los envios. (SQLSTATE A0001)
--
-- Verificar que no se elimino nada:
--   SELECT COUNT(*) FROM envios WHERE parte = 'P4';  → 2 (siguen ahi)


-- ============================================================================
-- PARTE 3: CASO VENTAS — ESQUEMA MINIMO PARA DISPARADOR
-- ============================================================================
-- Modelo relacional (resumido):
--   Clientes(tid, nid, nombre, correo!, tidr!, nidr!)
--   Telefonos(tid, nid, telefono)
--   Facturas(numero, fecha, tid, nid)
--   LineasFactura(factura, linea, bien, cantidad, precioVenta)
--   Bienes(codigo, nombre, precioVenta)
--   Servicios(codigo, manoDeObra)
--   Productos(codigo, existencias, precioCompra)
--   Insumos(servicio, producto, unidades)
-- ============================================================================

DROP TABLE IF EXISTS lineas_factura CASCADE;
DROP TABLE IF EXISTS insumos CASCADE;
DROP TABLE IF EXISTS servicios CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS bienes CASCADE;
DROP TABLE IF EXISTS facturas CASCADE;
DROP TABLE IF EXISTS telefonos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

CREATE TABLE clientes (
    tid    VARCHAR(2)  NOT NULL,
    nid    NUMERIC(15) NOT NULL,
    nombre VARCHAR(20) NOT NULL,
    correo VARCHAR(50),
    tidr   VARCHAR(2),
    nidr   NUMERIC(15)
);

CREATE TABLE telefonos (
    tid      VARCHAR(2)  NOT NULL,
    nid      NUMERIC(15) NOT NULL,
    telefono VARCHAR(10) NOT NULL
);

CREATE TABLE bienes (
    codigo      VARCHAR(5)    NOT NULL,
    nombre      VARCHAR(10)   NOT NULL,
    precioventa NUMERIC(10,2) NOT NULL
);

CREATE TABLE servicios (
    codigo     VARCHAR(5)    NOT NULL,
    manodeobra NUMERIC(10,2) NOT NULL
);

CREATE TABLE productos (
    codigo      VARCHAR(5)    NOT NULL,
    existencias INTEGER       NOT NULL DEFAULT 0,
    preciocompra NUMERIC(10,2) NOT NULL
);

CREATE TABLE insumos (
    servicio VARCHAR(5) NOT NULL,
    producto VARCHAR(5) NOT NULL,
    unidades INTEGER    NOT NULL
);

CREATE TABLE facturas (
    numero INTEGER     NOT NULL,
    fecha  DATE        NOT NULL,
    tid    VARCHAR(2)  NOT NULL,
    nid    NUMERIC(15) NOT NULL
);

CREATE TABLE lineas_factura (
    factura     INTEGER       NOT NULL,
    linea       INTEGER       NOT NULL,
    bien        VARCHAR(5)    NOT NULL,
    cantidad    INTEGER       NOT NULL,
    precioventa NUMERIC(10,2) NOT NULL
);

-- Claves primarias
ALTER TABLE clientes       ADD CONSTRAINT PK_CLIENTES       PRIMARY KEY (tid, nid);
ALTER TABLE telefonos      ADD CONSTRAINT PK_TELEFONOS      PRIMARY KEY (tid, nid, telefono);
ALTER TABLE bienes         ADD CONSTRAINT PK_BIENES         PRIMARY KEY (codigo);
ALTER TABLE servicios      ADD CONSTRAINT PK_SERVICIOS      PRIMARY KEY (codigo);
ALTER TABLE productos      ADD CONSTRAINT PK_PRODUCTOS      PRIMARY KEY (codigo);
ALTER TABLE insumos        ADD CONSTRAINT PK_INSUMOS        PRIMARY KEY (servicio, producto);
ALTER TABLE facturas       ADD CONSTRAINT PK_FACTURAS       PRIMARY KEY (numero);
ALTER TABLE lineas_factura ADD CONSTRAINT PK_LINEAS_FACTURA PRIMARY KEY (factura, linea);

-- Claves unicas
ALTER TABLE clientes ADD CONSTRAINT UK_CLIENTES_CORREO UNIQUE (correo);

-- Claves foraneas
ALTER TABLE clientes ADD CONSTRAINT FK_CLIENTES_CLIENTES
    FOREIGN KEY (tidr, nidr) REFERENCES clientes (tid, nid);

ALTER TABLE telefonos ADD CONSTRAINT FK_TELEFONOS_CLIENTES
    FOREIGN KEY (tid, nid) REFERENCES clientes (tid, nid) ON DELETE CASCADE;

ALTER TABLE facturas ADD CONSTRAINT FK_FACTURAS_CLIENTES
    FOREIGN KEY (tid, nid) REFERENCES clientes (tid, nid);

ALTER TABLE lineas_factura ADD CONSTRAINT FK_LINEAS_FACTURA_FACTURAS
    FOREIGN KEY (factura) REFERENCES facturas (numero);

ALTER TABLE lineas_factura ADD CONSTRAINT FK_LINEAS_FACTURA_BIENES
    FOREIGN KEY (bien) REFERENCES bienes (codigo);

ALTER TABLE servicios ADD CONSTRAINT FK_SERVICIOS_BIENES
    FOREIGN KEY (codigo) REFERENCES bienes (codigo) ON DELETE CASCADE;

ALTER TABLE productos ADD CONSTRAINT FK_PRODUCTOS_BIENES
    FOREIGN KEY (codigo) REFERENCES bienes (codigo) ON DELETE CASCADE;

ALTER TABLE insumos ADD CONSTRAINT FK_INSUMOS_SERVICIOS
    FOREIGN KEY (servicio) REFERENCES servicios (codigo) ON DELETE CASCADE;

ALTER TABLE insumos ADD CONSTRAINT FK_INSUMOS_PRODUCTOS
    FOREIGN KEY (producto) REFERENCES productos (codigo) ON DELETE CASCADE;


-- ============================================================================
-- DATOS DE PRUEBA — CASO VENTAS
-- ============================================================================

-- Clientes
INSERT INTO clientes VALUES ('CC', 1234567890, 'Juan Perez L.', 'juan@mail.co', NULL, NULL);
INSERT INTO clientes VALUES ('CC', 9876543210, 'Maria Garcia R.', 'maria@mail.co', 'CC', 1234567890);
INSERT INTO clientes VALUES ('CE', 1111111111, 'Carlos Lopez M.', NULL, NULL, NULL);

-- Telefonos
INSERT INTO telefonos VALUES ('CC', 1234567890, '3101234567');
INSERT INTO telefonos VALUES ('CC', 1234567890, '3207654321');
INSERT INTO telefonos VALUES ('CC', 9876543210, '3159999999');
INSERT INTO telefonos VALUES ('CE', 1111111111, '3001112222');

-- Bienes (productos)
INSERT INTO bienes VALUES ('PR001', 'Laptop',    1500000.00);
INSERT INTO bienes VALUES ('PR002', 'Mouse',     50000.00);
INSERT INTO bienes VALUES ('PR003', 'Teclado',   80000.00);
INSERT INTO bienes VALUES ('PR004', 'Monitor',   800000.00);

-- Bienes (servicios)
INSERT INTO bienes VALUES ('SV001', 'Mant. PC',  200000.00);

-- Productos
INSERT INTO productos VALUES ('PR001', 10, 1200000.00);
INSERT INTO productos VALUES ('PR002', 50, 30000.00);
INSERT INTO productos VALUES ('PR003', 30, 50000.00);
INSERT INTO productos VALUES ('PR004', 15, 600000.00);

-- Servicios
INSERT INTO servicios VALUES ('SV001', 120000.00);

-- Insumos (el servicio SV001 usa productos)
INSERT INTO insumos VALUES ('SV001', 'PR002', 1);   -- 1 mouse por servicio
INSERT INTO insumos VALUES ('SV001', 'PR003', 1);   -- 1 teclado por servicio

-- Factura de ejemplo (creada manualmente para poder probar lineas)
INSERT INTO facturas VALUES (1, CURRENT_DATE, 'CC', 1234567890);


-- ============================================================================
-- PARTE 4: DISPARADORES — CASO VENTAS
-- ============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.1  Ad: Adicionar una linea de factura con datos minimos
--      Regla: al insertar una linea solo se necesita: factura, bien, cantidad.
--             El sistema calcula: linea (consecutivo) y precioventa (del bien).
--             Ademas mantiene consistencia:
--               - Si es un producto: disminuir sus existencias
--               - Si es un servicio: disminuir existencias de sus insumos
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE (del diagrama conceptual):
--   Al adicionar una linea de factura se debe:
--     - Almacenar el precio de venta actual del bien
--     - Disminuir las existencias de los productos
--
--   Disparador asociado a cual tabla?   → lineas_factura
--   Que tipo de disparador?
--     Evento:   INSERT
--     Momento:  BEFORE  (necesitamos calcular valores en NEW)
--     Veces:    FOR EACH ROW
--
-- ANALISIS DETALLADO:
--   Datos minimos:  factura, bien, cantidad
--   Se calcula:     linea = COUNT(*)+1 dentro de esa factura
--                   precioventa = bienes.precioventa del bien
--   Consistencia:   Si el bien es un producto → restar existencias
--                   Si el bien es un servicio → restar existencias de cada insumo
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_lineas_factura_ins() RETURNS TRIGGER AS $$
DECLARE
    insumo RECORD;
BEGIN
    -- 1. Asignar numero de linea consecutivo dentro de la factura
    SELECT COUNT(*) + 1 INTO NEW.linea
    FROM lineas_factura
    WHERE factura = NEW.factura;

    -- 2. Obtener el precio de venta actual del bien
    SELECT precioventa INTO NEW.precioventa
    FROM bienes
    WHERE codigo = NEW.bien;

    -- 3. Si es un producto: disminuir existencias directamente
    UPDATE productos
    SET existencias = existencias - NEW.cantidad
    WHERE codigo = NEW.bien;

    -- 4. Si es un servicio: disminuir existencias de cada producto insumo
    FOR insumo IN SELECT * FROM insumos WHERE servicio = NEW.bien LOOP
        UPDATE productos
        SET existencias = existencias - insumo.unidades * NEW.cantidad
        WHERE codigo = insumo.producto;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_lineas_factura_ins
    BEFORE INSERT ON lineas_factura
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_lineas_factura_ins();

-- PRUEBAS (seguimiento):
--
-- Verificar existencias antes:
--   SELECT codigo, existencias FROM productos ORDER BY codigo;
--   → PR001=10, PR002=50, PR003=30, PR004=15
--
-- Insertar linea de un PRODUCTO (2 Laptops):
--   INSERT INTO lineas_factura (factura, bien, cantidad) VALUES (1, 'PR001', 2);
--   SELECT * FROM lineas_factura WHERE factura = 1;
--   → linea=1, precioventa=1500000.00 (copiado de bienes)
--   SELECT existencias FROM productos WHERE codigo = 'PR001';
--   → 8 (era 10, se restaron 2)
--
-- Insertar linea de un SERVICIO (1 Mantenimiento):
--   INSERT INTO lineas_factura (factura, bien, cantidad) VALUES (1, 'SV001', 1);
--   SELECT * FROM lineas_factura WHERE factura = 1;
--   → linea=2 (consecutivo), precioventa=200000.00
--   SELECT codigo, existencias FROM productos WHERE codigo IN ('PR002','PR003');
--   → PR002=49 (era 50, se resto 1 mouse), PR003=29 (era 30, se resto 1 teclado)
--
-- Insertar otra linea de producto (5 Monitores):
--   INSERT INTO lineas_factura (factura, bien, cantidad) VALUES (1, 'PR004', 5);
--   SELECT * FROM lineas_factura WHERE factura = 1 ORDER BY linea;
--   → linea=3, precioventa=800000.00
--   SELECT existencias FROM productos WHERE codigo = 'PR004';
--   → 10 (era 15, se restaron 5)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.2  Ad: Crear encabezado de factura con datos minimos
--      Regla: al insertar una factura solo se necesita: tid, nid (el cliente).
--             El sistema calcula: numero (consecutivo) y fecha (hoy).
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   Cuales son los datos minimos para crear el encabezado de una factura?
--     → tid, nid (identificacion del cliente)
--   Como se definen los otros?
--     → numero = MAX(numero)+1 (consecutivo)
--     → fecha  = CURRENT_DATE  (fecha actual)
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    facturas
--   Evento:   INSERT
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_facturas_ins() RETURNS TRIGGER AS $$
BEGIN
    -- Asignar numero consecutivo
    SELECT COALESCE(MAX(numero), 0) + 1 INTO NEW.numero FROM facturas;

    -- Asignar fecha actual
    NEW.fecha := CURRENT_DATE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturas_ins
    BEFORE INSERT ON facturas
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_facturas_ins();

-- PRUEBAS:
--   INSERT INTO facturas (tid, nid) VALUES ('CC', 9876543210);
--   SELECT * FROM facturas ORDER BY numero DESC LIMIT 1;
--   → numero=2, fecha=hoy, tid='CC', nid=9876543210


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.3  El/Mo: No se pueden eliminar ni modificar facturas ni sus lineas
--      Regla: Las facturas son un REGISTRAR. No se permite DELETE ni UPDATE.
--             Lanzar excepcion indicando que no es posible.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   Es un "registrar": una vez creada la factura, no se puede tocar.
--   Ni las facturas, ni sus detalles, se deben poder eliminar ni modificar.
--
-- ANALISIS DEL DISPARADOR:
--   Tablas:   facturas, lineas_factura
--   Evento:   DELETE, UPDATE
--   Momento:  BEFORE  (interceptar y rechazar)
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Proteger FACTURAS
CREATE OR REPLACE FUNCTION fun_tg_facturas_proteger() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'No se pueden % facturas. Es un registrar.',
        LOWER(TG_OP)  -- 'delete' o 'update' segun la operacion
        USING ERRCODE = 'A0002';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturas_proteger
    BEFORE DELETE OR UPDATE ON facturas
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_facturas_proteger();

-- Proteger LINEAS_FACTURA
CREATE OR REPLACE FUNCTION fun_tg_lineas_factura_proteger() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'No se pueden % lineas de factura. Es un registrar.',
        LOWER(TG_OP)
        USING ERRCODE = 'A0003';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_lineas_factura_proteger
    BEFORE DELETE OR UPDATE ON lineas_factura
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_lineas_factura_proteger();

-- PRUEBAS:
--   DELETE FROM facturas WHERE numero = 1;
--   → ERROR: No se pueden delete facturas. Es un registrar. (A0002)
--
--   UPDATE facturas SET fecha = '2020-01-01' WHERE numero = 1;
--   → ERROR: No se pueden update facturas. Es un registrar. (A0002)
--
--   DELETE FROM lineas_factura WHERE factura = 1 AND linea = 1;
--   → ERROR: No se pueden delete lineas de factura. Es un registrar. (A0003)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.4  El: Eliminar clientes solo si no tienen facturas
--      Regla: un cliente solo se puede borrar si no tiene facturas asociadas.
--             Los telefonos se eliminan en cascada (FK ON DELETE CASCADE).
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   Actualmente, que condiciones se deben cumplir para eliminar un cliente?
--     → La FK de facturas hacia clientes ya impide borrarlo (RESTRICT).
--     → Pero podemos dar un mensaje mas claro con un disparador.
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    clientes
--   Evento:   DELETE
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_clientes_del() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM facturas WHERE tid = OLD.tid AND nid = OLD.nid) THEN
        RAISE EXCEPTION 'No se puede eliminar el cliente (%, %). Tiene facturas asociadas.',
            OLD.tid, OLD.nid
            USING ERRCODE = 'A0004';
    END IF;
    -- Si no tiene facturas, permitir la eliminacion
    -- (los telefonos se borran en cascada por la FK)
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes_del
    BEFORE DELETE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_clientes_del();

-- PRUEBAS:
--   DELETE FROM clientes WHERE tid = 'CC' AND nid = 1234567890;
--   → ERROR: Tiene facturas asociadas (A0004)
--
--   DELETE FROM clientes WHERE tid = 'CE' AND nid = 1111111111;
--   → OK (no tiene facturas, se borra cliente y sus telefonos en cascada)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.5  Ad: Auto-asignar correo si no se indica al crear un cliente
--      Regla: si correo es NULL, intentar asignar nid@vendemos.com.co
--             solo si ese correo no esta ya en uso.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    clientes
--   Evento:   INSERT
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_clientes_ins_correo() RETURNS TRIGGER AS $$
DECLARE
    correo_generado VARCHAR(50);
BEGIN
    IF NEW.correo IS NULL THEN
        correo_generado := NEW.nid || '@vendemos.com.co';
        -- Solo asignar si no esta en uso por otro cliente
        IF NOT EXISTS (SELECT 1 FROM clientes WHERE correo = correo_generado) THEN
            NEW.correo := correo_generado;
        END IF;
        -- Si ya esta en uso, el correo queda NULL
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes_ins_correo
    BEFORE INSERT ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_clientes_ins_correo();

-- PRUEBAS:
--   INSERT INTO clientes (tid, nid, nombre) VALUES ('NT', 5555555555, 'Empresa XYZ S.A.');
--   SELECT correo FROM clientes WHERE nid = 5555555555;
--   → '5555555555@vendemos.com.co' (auto-generado)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.6  Mo: No permitir modificar datos de identificacion de clientes
--      Regla: tid y nid son inmutables una vez creado el cliente.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    clientes
--   Evento:   UPDATE
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_clientes_upd_id() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tid != OLD.tid OR NEW.nid != OLD.nid THEN
        RAISE EXCEPTION 'No se pueden modificar los datos de identificacion (tid, nid) de un cliente.'
            USING ERRCODE = 'A0005';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes_upd_id
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_clientes_upd_id();

-- PRUEBAS:
--   UPDATE clientes SET nid = 9999999999 WHERE tid = 'CC' AND nid = 1234567890;
--   → ERROR: No se pueden modificar los datos de identificacion (A0005)
--
--   UPDATE clientes SET nombre = 'Juan P. Lopez' WHERE tid = 'CC' AND nid = 1234567890;
--   → OK (no modifica tid ni nid)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.7  Mo: Los precios de venta de los bienes nunca deben disminuir
--      Regla: al actualizar precioventa, si el nuevo es menor, rechazar.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    bienes
--   Evento:   UPDATE OF precioventa
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_bienes_upd_precio() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.precioventa < OLD.precioventa THEN
        RAISE EXCEPTION 'El precio de venta del bien % no puede disminuir (% -> %).',
            OLD.codigo, OLD.precioventa, NEW.precioventa
            USING ERRCODE = 'A0006';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_bienes_upd_precio
    BEFORE UPDATE OF precioventa ON bienes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_bienes_upd_precio();

-- PRUEBAS:
--   UPDATE bienes SET precioventa = 1000000.00 WHERE codigo = 'PR001';
--   → ERROR: no puede disminuir (1500000.00 -> 1000000.00) (A0006)
--
--   UPDATE bienes SET precioventa = 2000000.00 WHERE codigo = 'PR001';
--   → OK (subio)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.8  El: Eliminar bienes solo si no tienen facturas ni son insumo
--      Regla: un bien solo se puede borrar si:
--        - No esta referenciado en lineas_factura
--        - No es producto insumo de un servicio
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- PREGUNTAS PARA CLASE:
--   Actualmente, que condiciones se deben cumplir para eliminar un bien?
--     → No estar en lineas_factura (FK RESTRICT)
--     → Servicios/Productos se borran en cascada desde bienes (FK CASCADE)
--     → Insumos se borran en cascada desde servicios/productos (FK CASCADE)
--   Pero hay un caso problematico: un producto que es insumo de un servicio
--   deberia bloquearse aunque tecnicamente la FK permitiria la cascada.
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    bienes
--   Evento:   DELETE
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_bienes_del() RETURNS TRIGGER AS $$
BEGIN
    -- No se puede eliminar si tiene facturas asociadas
    IF EXISTS (SELECT 1 FROM lineas_factura WHERE bien = OLD.codigo) THEN
        RAISE EXCEPTION 'No se puede eliminar el bien %. Tiene facturas asociadas.',
            OLD.codigo USING ERRCODE = 'A0007';
    END IF;

    -- No se puede eliminar si es insumo de un servicio
    IF EXISTS (SELECT 1 FROM insumos WHERE producto = OLD.codigo) THEN
        RAISE EXCEPTION 'No se puede eliminar el bien %. Es insumo de un servicio.',
            OLD.codigo USING ERRCODE = 'A0007';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_bienes_del
    BEFORE DELETE ON bienes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_bienes_del();

-- PRUEBAS:
--   DELETE FROM bienes WHERE codigo = 'PR002';
--   → ERROR: Es insumo de un servicio (PR002 es insumo de SV001)
--
--   DELETE FROM bienes WHERE codigo = 'PR004';
--   → OK (no tiene facturas ni es insumo)


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4.9  Ad: Auto-generar codigo de bien si no se asigna
--      Regla: si el codigo es NULL o vacio, generar uno a partir de las
--             primeras letras del nombre (hasta 5 caracteres).
--             Si ya existe, probar con menos letras.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
-- ANALISIS DEL DISPARADOR:
--   Tabla:    bienes
--   Evento:   INSERT
--   Momento:  BEFORE
--   Veces:    FOR EACH ROW
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE FUNCTION fun_tg_bienes_ins_codigo() RETURNS TRIGGER AS $$
DECLARE
    candidato VARCHAR(5);
    largo INTEGER;
BEGIN
    IF NEW.codigo IS NULL OR NEW.codigo = '' THEN
        largo := LEAST(LENGTH(NEW.nombre), 5);
        WHILE largo > 0 LOOP
            candidato := UPPER(SUBSTRING(NEW.nombre FROM 1 FOR largo));
            IF NOT EXISTS (SELECT 1 FROM bienes WHERE codigo = candidato) THEN
                NEW.codigo := candidato;
                RETURN NEW;
            END IF;
            largo := largo - 1;
        END LOOP;
        RAISE EXCEPTION 'No se pudo generar un codigo unico para el bien "%".',
            NEW.nombre USING ERRCODE = 'A0008';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_bienes_ins_codigo
    BEFORE INSERT ON bienes
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_bienes_ins_codigo();

-- PRUEBAS:
--   INSERT INTO bienes (nombre, precioventa) VALUES ('Cable HDMI', 25000.00);
--   SELECT * FROM bienes WHERE nombre = 'Cable HDMI';
--   → codigo = 'CABLE' (primeras 5 letras en mayuscula)


-- ============================================================================
-- RESUMEN DE DISPARADORES
-- ============================================================================
--
-- CASO ENVIOS (ejemplos de clase):
-- ┌────┬──────────────────────┬───────────┬──────────┬────────┬─────────────┐
-- │ #  │ Disparador           │ Tabla     │ Evento   │Momento │ Proposito   │
-- ├────┼──────────────────────┼───────────┼──────────┼────────┼─────────────┤
-- │2.1 │tg_partes_upd_color   │ partes    │ UPD color│ BEFORE │ Evitar      │
-- │2.2 │tg_envios_ins         │ envios    │ INSERT   │ BEFORE │ Automatizar │
-- │2.3 │tg_partes_upd_precio  │ partes    │ UPD prec.│ BEFORE │ Evitar      │
-- │2.4 │tg_envios_del         │ envios    │ DELETE   │ BEFORE │ Evitar      │
-- └────┴──────────────────────┴───────────┴──────────┴────────┴─────────────┘
--
-- CASO VENTAS (trabajo):
-- ┌────┬──────────────────────────────┬────────────────┬──────────┬────────┬─────────────┐
-- │ #  │ Disparador                   │ Tabla          │ Evento   │Momento │ Proposito   │
-- ├────┼──────────────────────────────┼────────────────┼──────────┼────────┼─────────────┤
-- │4.1 │tg_lineas_factura_ins         │ lineas_factura │ INSERT   │ BEFORE │ Automatizar │
-- │4.2 │tg_facturas_ins               │ facturas       │ INSERT   │ BEFORE │ Automatizar │
-- │4.3 │tg_facturas_proteger          │ facturas       │ DEL/UPD  │ BEFORE │ Evitar      │
-- │    │tg_lineas_factura_proteger    │ lineas_factura │ DEL/UPD  │ BEFORE │ Evitar      │
-- │4.4 │tg_clientes_del              │ clientes       │ DELETE   │ BEFORE │ Evitar      │
-- │4.5 │tg_clientes_ins_correo       │ clientes       │ INSERT   │ BEFORE │ Automatizar │
-- │4.6 │tg_clientes_upd_id           │ clientes       │ UPDATE   │ BEFORE │ Evitar      │
-- │4.7 │tg_bienes_upd_precio         │ bienes         │ UPD prec.│ BEFORE │ Evitar      │
-- │4.8 │tg_bienes_del                │ bienes         │ DELETE   │ BEFORE │ Evitar      │
-- │4.9 │tg_bienes_ins_codigo         │ bienes         │ INSERT   │ BEFORE │ Automatizar │
-- └────┴──────────────────────────────┴────────────────┴──────────┴────────┴─────────────┘
--
-- Patron comun: TODOS son BEFORE + FOR EACH ROW
--   - Evitar acciones no deseadas:  verificar condicion → RAISE EXCEPTION
--   - Automatizar acciones deseadas: calcular valores  → modificar NEW → RETURN NEW
-- ============================================================================
