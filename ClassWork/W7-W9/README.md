# Modelo Relacional — Ventas
### Material para clase — Semanas 7-9: Del modelo conceptual al codigo

> **Fuente:** Caso "Ventas" (MYSD-TT2-2026-02.pdf). Se trabaja el diseño logico,
> construccion basica (tablas, claves), restricciones declarativas y restricciones
> procedimentales (disparadores) del sistema de ventas.

---

## 1. Diagrama Logico (Modelo Relacional)

### Leyenda

| Simbolo | Significado |
|---------|-------------|
| <ins>**atributo**</ins> | Clave primaria (PK) |
| <ins>atributo</ins> | Clave unica (UK) |
| *atributo* | Clave foranea (FK) |
| `!` | Puede no conocerse (NULL) |
| `/` | Atributo derivado (no se almacena) |

### Modelo relacional (notacion compacta)

**GC Clientes**

```
Clientes(tid, nid, nombre, correo!, tidr!, nidr!)
Telefonos(tid, nid, telefono)
```

| Tabla | PK | UK | FK |
|-------|----|----|-----|
| Clientes | (tid, nid) | correo | (tidr, nidr) → Clientes(tid, nid) |
| Telefonos | (tid, nid, telefono) | | (tid, nid) → Clientes(tid, nid) `ON DELETE CASCADE` |

**GC Facturas**

```
Facturas(numero, fecha, tid, nid)
LineasFactura(factura, linea, bien, cantidad, precioVenta)
```

| Tabla | PK | UK | FK |
|-------|----|----|-----|
| Facturas | (numero) | | (tid, nid) → Clientes(tid, nid) |
| LineasFactura | (factura, linea) | | factura → Facturas(numero), bien → Bienes(codigo) |

**GC Bienes**

```
Bienes(codigo, nombre, precioVenta)
Servicios(codigo, manoDeObra)
Productos(codigo, existencias, precioCompra)
Insumos(servicio, producto, unidades)
```

| Tabla | PK | UK | FK |
|-------|----|----|-----|
| Bienes | (codigo) | | |
| Servicios | (codigo) | | codigo → Bienes(codigo) `ON DELETE CASCADE` |
| Productos | (codigo) | | codigo → Bienes(codigo) `ON DELETE CASCADE` |
| Insumos | (servicio, producto) | | servicio → Servicios(codigo) `ON DELETE CASCADE`, producto → Productos(codigo) `ON DELETE CASCADE` |

> **Total: 8 tablas.**
> La herencia Bien → {Servicio, Producto} usa 3 tablas con atributos especificos en las subclases.
> La relacion de composicion Factura ◆→ LineaFactura se representa con FK en LineasFactura.
> La relacion Recomienda (auto-asociacion) se almacena con FK (tidr, nidr) en la misma tabla Clientes.
> La relacion multivaluada telefonos se lleva a la tabla Telefonos.
> La clase asociativa Utiliza se convierte en la tabla Insumos.

### Diagrama ER (visual)

```mermaid
erDiagram
    CLIENTES ||--o{ TELEFONOS : "tiene"
    CLIENTES ||--o{ FACTURAS : "es dueno de"
    CLIENTES }o--o| CLIENTES : "recomienda"
    FACTURAS ||--|{ LINEAS_FACTURA : "contiene"
    BIENES ||--o{ LINEAS_FACTURA : "es de"
    BIENES ||--o| SERVICIOS : "herencia"
    BIENES ||--o| PRODUCTOS : "herencia"
    SERVICIOS ||--o{ INSUMOS : "utiliza"
    PRODUCTOS ||--o{ INSUMOS : "insumo de"

    CLIENTES {
        VARCHAR_2 tid PK
        NUMERIC_15 nid PK
        VARCHAR_20 nombre
        VARCHAR_50 correo UK "nullable"
        VARCHAR_2 tidr FK "nullable"
        NUMERIC_15 nidr FK "nullable"
    }
    TELEFONOS {
        VARCHAR_2 tid PK_FK
        NUMERIC_15 nid PK_FK
        VARCHAR_10 telefono PK
    }
    FACTURAS {
        SERIAL numero PK
        DATE fecha
        VARCHAR_2 tid FK
        NUMERIC_15 nid FK
    }
    LINEAS_FACTURA {
        INTEGER factura PK_FK
        INTEGER linea PK
        VARCHAR_5 bien FK
        INTEGER cantidad
        MONEDA precioVenta
    }
    BIENES {
        VARCHAR_5 codigo PK
        VARCHAR_10 nombre
        MONEDA precioVenta
    }
    SERVICIOS {
        VARCHAR_5 codigo PK_FK
        MONEDA manoDeObra
    }
    PRODUCTOS {
        VARCHAR_5 codigo PK_FK
        INTEGER existencias
        MONEDA precioCompra
    }
    INSUMOS {
        VARCHAR_5 servicio PK_FK
        VARCHAR_5 producto PK_FK
        INTEGER unidades
    }
```

---

## 2. Construccion Basica

### 2.1 Creacion de tablas

```sql
-- =============================================
-- GC: CLIENTES
-- =============================================

CREATE TABLE CLIENTES (
    tid VARCHAR(2) NOT NULL,
    nid NUMERIC(15) NOT NULL,
    nombre VARCHAR(20) NOT NULL,
    correo VARCHAR(50),
    tidr VARCHAR(2),
    nidr NUMERIC(15)
);

CREATE TABLE TELEFONOS (
    tid VARCHAR(2) NOT NULL,
    nid NUMERIC(15) NOT NULL,
    telefono VARCHAR(10) NOT NULL
);

-- =============================================
-- GC: FACTURAS
-- =============================================

CREATE TABLE FACTURAS (
    numero SERIAL NOT NULL,
    fecha DATE NOT NULL,
    tid VARCHAR(2) NOT NULL,
    nid NUMERIC(15) NOT NULL
);

CREATE TABLE LINEAS_FACTURA (
    factura INTEGER NOT NULL,
    linea INTEGER NOT NULL,
    bien VARCHAR(5) NOT NULL,
    cantidad INTEGER NOT NULL,
    precioVenta NUMERIC(10,2) NOT NULL
);

-- =============================================
-- GC: BIENES
-- =============================================

CREATE TABLE BIENES (
    codigo VARCHAR(5) NOT NULL,
    nombre VARCHAR(10) NOT NULL,
    precioVenta NUMERIC(10,2) NOT NULL
);

CREATE TABLE SERVICIOS (
    codigo VARCHAR(5) NOT NULL,
    manoDeObra NUMERIC(10,2) NOT NULL
);

CREATE TABLE PRODUCTOS (
    codigo VARCHAR(5) NOT NULL,
    existencias INTEGER NOT NULL DEFAULT 0,
    precioCompra NUMERIC(10,2) NOT NULL
);

CREATE TABLE INSUMOS (
    servicio VARCHAR(5) NOT NULL,
    producto VARCHAR(5) NOT NULL,
    unidades INTEGER NOT NULL
);
```

### 2.2 Claves primarias (PK_)

```sql
-- GC Clientes
ALTER TABLE CLIENTES ADD CONSTRAINT PK_CLIENTES
    PRIMARY KEY (tid, nid);

ALTER TABLE TELEFONOS ADD CONSTRAINT PK_TELEFONOS
    PRIMARY KEY (tid, nid, telefono);

-- GC Facturas
ALTER TABLE FACTURAS ADD CONSTRAINT PK_FACTURAS
    PRIMARY KEY (numero);

ALTER TABLE LINEAS_FACTURA ADD CONSTRAINT PK_LINEAS_FACTURA
    PRIMARY KEY (factura, linea);

-- GC Bienes
ALTER TABLE BIENES ADD CONSTRAINT PK_BIENES
    PRIMARY KEY (codigo);

ALTER TABLE SERVICIOS ADD CONSTRAINT PK_SERVICIOS
    PRIMARY KEY (codigo);

ALTER TABLE PRODUCTOS ADD CONSTRAINT PK_PRODUCTOS
    PRIMARY KEY (codigo);

ALTER TABLE INSUMOS ADD CONSTRAINT PK_INSUMOS
    PRIMARY KEY (servicio, producto);
```

### 2.3 Claves unicas (UK_)

```sql
ALTER TABLE CLIENTES ADD CONSTRAINT UK_CLIENTES_CORREO
    UNIQUE (correo);
```

### 2.4 Claves foraneas (FK_)

```sql
-- GC Clientes
ALTER TABLE CLIENTES ADD CONSTRAINT FK_CLIENTES_CLIENTES
    FOREIGN KEY (tidr, nidr) REFERENCES CLIENTES (tid, nid)
    ON DELETE SET NULL;

ALTER TABLE TELEFONOS ADD CONSTRAINT FK_TELEFONOS_CLIENTES
    FOREIGN KEY (tid, nid) REFERENCES CLIENTES (tid, nid)
    ON DELETE CASCADE;

-- GC Facturas
ALTER TABLE FACTURAS ADD CONSTRAINT FK_FACTURAS_CLIENTES
    FOREIGN KEY (tid, nid) REFERENCES CLIENTES (tid, nid);

ALTER TABLE LINEAS_FACTURA ADD CONSTRAINT FK_LINEAS_FACTURA_FACTURAS
    FOREIGN KEY (factura) REFERENCES FACTURAS (numero);

ALTER TABLE LINEAS_FACTURA ADD CONSTRAINT FK_LINEAS_FACTURA_BIENES
    FOREIGN KEY (bien) REFERENCES BIENES (codigo);

-- GC Bienes (herencia)
ALTER TABLE SERVICIOS ADD CONSTRAINT FK_SERVICIOS_BIENES
    FOREIGN KEY (codigo) REFERENCES BIENES (codigo)
    ON DELETE CASCADE;

ALTER TABLE PRODUCTOS ADD CONSTRAINT FK_PRODUCTOS_BIENES
    FOREIGN KEY (codigo) REFERENCES BIENES (codigo)
    ON DELETE CASCADE;

ALTER TABLE INSUMOS ADD CONSTRAINT FK_INSUMOS_SERVICIOS
    FOREIGN KEY (servicio) REFERENCES SERVICIOS (codigo)
    ON DELETE CASCADE;

ALTER TABLE INSUMOS ADD CONSTRAINT FK_INSUMOS_PRODUCTOS
    FOREIGN KEY (producto) REFERENCES PRODUCTOS (codigo)
    ON DELETE CASCADE;
```

---

## 3. Restricciones Declarativas

### 3.1 Mantener Bien

**1. Dominio Moneda: positivo, 8 enteros + 2 decimales, decimales solo 00, 25 o 50**

```sql
CREATE DOMAIN MONEDA AS NUMERIC(10,2)
    CHECK (VALUE > 0 AND MOD(VALUE, 1) IN (0, 0.25, 0.50));
```

> Si se usa el dominio MONEDA, las columnas precioVenta (BIENES), manoDeObra (SERVICIOS),
> precioCompra (PRODUCTOS) y precioVenta (LINEAS_FACTURA) se definirian con ese tipo.
> Alternativamente, se puede usar CHECK directamente sobre cada columna.

**2. La herencia debe ser exclusiva (un bien es servicio O producto, nunca ambos)**

```sql
-- Opcion A: Asercion (estandar SQL, no soportado en PostgreSQL)
CREATE ASSERTION AS_BIENES_HERENCIA_EXCLUSIVA
    CHECK (NOT EXISTS (
        SELECT s.codigo FROM SERVICIOS s
        INNER JOIN PRODUCTOS p ON s.codigo = p.codigo
    ));

-- Opcion B: Discriminador en la tabla padre (implementable en PostgreSQL)
ALTER TABLE BIENES ADD tipo CHAR(1) NOT NULL;
ALTER TABLE BIENES ADD CONSTRAINT CK_BIENES_TIPO
    CHECK (tipo IN ('S', 'P'));
ALTER TABLE BIENES ADD CONSTRAINT UK_BIENES_CODIGO_TIPO
    UNIQUE (codigo, tipo);

-- Luego en cada subtabla, agregar columna tipo con valor fijo:
ALTER TABLE SERVICIOS ADD tipo CHAR(1) NOT NULL DEFAULT 'S';
ALTER TABLE SERVICIOS ADD CONSTRAINT CK_SERVICIOS_TIPO CHECK (tipo = 'S');
ALTER TABLE SERVICIOS DROP CONSTRAINT FK_SERVICIOS_BIENES;
ALTER TABLE SERVICIOS ADD CONSTRAINT FK_SERVICIOS_BIENES
    FOREIGN KEY (codigo, tipo) REFERENCES BIENES (codigo, tipo)
    ON DELETE CASCADE;

ALTER TABLE PRODUCTOS ADD tipo CHAR(1) NOT NULL DEFAULT 'P';
ALTER TABLE PRODUCTOS ADD CONSTRAINT CK_PRODUCTOS_TIPO CHECK (tipo = 'P');
ALTER TABLE PRODUCTOS DROP CONSTRAINT FK_PRODUCTOS_BIENES;
ALTER TABLE PRODUCTOS ADD CONSTRAINT FK_PRODUCTOS_BIENES
    FOREIGN KEY (codigo, tipo) REFERENCES BIENES (codigo, tipo)
    ON DELETE CASCADE;
```

**3. La herencia debe ser completa (todo bien debe ser servicio o producto)**

```sql
-- Asercion (estandar SQL, no soportado en PostgreSQL)
CREATE ASSERTION AS_BIENES_HERENCIA_COMPLETA
    CHECK (NOT EXISTS (
        SELECT b.codigo FROM BIENES b
        WHERE b.codigo NOT IN (SELECT codigo FROM SERVICIOS)
          AND b.codigo NOT IN (SELECT codigo FROM PRODUCTOS)
    ));

-- En PostgreSQL: requiere disparador (ver seccion 4)
```

**4. Precio de venta de productos >= 110% del precio de compra**

```sql
-- Asercion (estandar SQL)
CREATE ASSERTION AS_PRODUCTOS_MARGEN
    CHECK (NOT EXISTS (
        SELECT 1 FROM PRODUCTOS p
        INNER JOIN BIENES b ON p.codigo = b.codigo
        WHERE b.precioVenta < p.precioCompra * 1.10
    ));

-- En PostgreSQL: requiere disparador (ver seccion 4)
```

**5. Precio de venta de servicios >= 120% de su costo**

> /costo = manoDeObra + SUM(precioCompra_producto × unidades_insumo)

```sql
-- Asercion (estandar SQL)
CREATE ASSERTION AS_SERVICIOS_MARGEN
    CHECK (NOT EXISTS (
        SELECT 1 FROM SERVICIOS s
        INNER JOIN BIENES b ON s.codigo = b.codigo
        WHERE b.precioVenta < (
            s.manoDeObra + COALESCE((
                SELECT SUM(bp.precioVenta * i.unidades)
                FROM INSUMOS i
                INNER JOIN BIENES bp ON i.producto = bp.codigo
                WHERE i.servicio = s.codigo
            ), 0)
        ) * 1.20
    ));

-- En PostgreSQL: requiere disparador (ver seccion 4)
```

### 3.2 Mantener Cliente

**1. TipoId solo puede ser CC, CE o NT**

```sql
ALTER TABLE CLIENTES ADD CONSTRAINT CK_CLIENTES_TID
    CHECK (tid IN ('CC', 'CE', 'NT'));
```

**2. Un cliente debe tener minimo un telefono (ver DC: 1..*)**

```sql
-- Asercion (estandar SQL)
CREATE ASSERTION AS_CLIENTES_MIN_TELEFONO
    CHECK (NOT EXISTS (
        SELECT c.tid, c.nid FROM CLIENTES c
        WHERE NOT EXISTS (
            SELECT 1 FROM TELEFONOS t
            WHERE t.tid = c.tid AND t.nid = c.nid
        )
    ));

-- En PostgreSQL: requiere disparador (ver seccion 4)
```

**3. El nombre debe tener minimo 10 caracteres**

```sql
ALTER TABLE CLIENTES ADD CONSTRAINT CK_CLIENTES_NOMBRE_MIN
    CHECK (LENGTH(nombre) >= 10);
```

**4. El correo debe tener maximo un @ y un .**

```sql
ALTER TABLE CLIENTES ADD CONSTRAINT CK_CLIENTES_CORREO_FORMATO
    CHECK (
        correo IS NULL
        OR (
            LENGTH(correo) - LENGTH(REPLACE(correo, '@', '')) <= 1
            AND LENGTH(correo) - LENGTH(REPLACE(correo, '.', '')) <= 1
        )
    );
```

**5. Un cliente no se puede autorrecomendar**

```sql
ALTER TABLE CLIENTES ADD CONSTRAINT CK_CLIENTES_NO_AUTORRECOMENDAR
    CHECK (NOT (tidr = tid AND nidr = nid));
```

> Si `tidr` o `nidr` es NULL, la expresion evalua a NULL (no FALSE), por lo que el CHECK se cumple.

### 3.3 Registrar Factura

**1. El numero de la factura debe ser consecutivo iniciando en 1**

```sql
-- Se usa SERIAL en la definicion de la tabla (secuencia automatica)
-- Si se requiere control explicito:
CREATE SEQUENCE SEQ_FACTURAS_NUMERO START WITH 1 INCREMENT BY 1;
```

**2. El numero de la factura se asigna cuando se realiza**

> Se implementa con disparador BEFORE INSERT (ver seccion 4.3.1).

**3. Las facturas deben tener minimo una linea de factura (ver DC: 1..*)**

```sql
-- Asercion (estandar SQL)
CREATE ASSERTION AS_FACTURAS_MIN_LINEA
    CHECK (NOT EXISTS (
        SELECT f.numero FROM FACTURAS f
        WHERE NOT EXISTS (
            SELECT 1 FROM LINEAS_FACTURA lf
            WHERE lf.factura = f.numero
        )
    ));

-- En PostgreSQL: requiere disparador (ver seccion 4)
```

**4. Los precios de venta de los bienes nunca deben disminuir**

```sql
-- Condicion de tupla (BEFORE UPDATE trigger en PostgreSQL)
-- Conceptualmente:
-- CHECK (NEW.precioVenta >= OLD.precioVenta)
-- En PostgreSQL: requiere disparador (ver seccion 4)
```

**5. Los precios de venta no pueden ser menores al precio actual de venta del bien**

```sql
-- En LINEAS_FACTURA, precioVenta >= Bienes.precioVenta correspondiente
-- Restriccion cruzada entre tablas: requiere disparador
-- Se resuelve en el disparador de insercion de lineas (seccion 4.3.2)
-- que copia automaticamente el precio actual del bien.
```

---

## 4. Restricciones Procedimentales (Disparadores)

### 4.1 Mantener Bien

#### 4.1.1 Eliminar bienes solo si no tienen facturas asociadas ni son parte de un servicio

> Actualmente, para eliminar un bien se debe cumplir:
> - No estar referenciado en LINEAS_FACTURA (FK)
> - Si es un servicio: no tener insumos, y eliminar de SERVICIOS (CASCADE) y BIENES
> - Si es un producto: no estar en INSUMOS, no estar en LINEAS_FACTURA

```sql
CREATE OR REPLACE FUNCTION fun_tg_bienes_del() RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que no tenga facturas asociadas
    IF EXISTS (SELECT 1 FROM LINEAS_FACTURA WHERE bien = OLD.codigo) THEN
        RAISE EXCEPTION 'No se puede eliminar el bien %. Tiene facturas asociadas.', OLD.codigo;
    END IF;

    -- Si es un producto, verificar que no sea insumo de un servicio
    IF EXISTS (SELECT 1 FROM INSUMOS WHERE producto = OLD.codigo) THEN
        RAISE EXCEPTION 'No se puede eliminar el bien %. Es insumo de un servicio.', OLD.codigo;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_bienes_del
    BEFORE DELETE ON BIENES
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_bienes_del();
```

#### 4.1.2 Auto-generar codigo a partir del nombre si no se asigna

```sql
CREATE OR REPLACE FUNCTION fun_tg_bienes_ins_codigo() RETURNS TRIGGER AS $$
DECLARE
    candidato VARCHAR(5);
    largo INTEGER;
BEGIN
    IF NEW.codigo IS NULL OR NEW.codigo = '' THEN
        -- Tomar las primeras letras del nombre
        largo := LEAST(LENGTH(NEW.nombre), 5);
        WHILE largo > 0 LOOP
            candidato := UPPER(SUBSTRING(NEW.nombre FROM 1 FOR largo));
            IF NOT EXISTS (SELECT 1 FROM BIENES WHERE codigo = candidato) THEN
                NEW.codigo := candidato;
                RETURN NEW;
            END IF;
            largo := largo - 1;
        END LOOP;
        RAISE EXCEPTION 'No se pudo generar un codigo unico para el bien %', NEW.nombre;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_bienes_ins_codigo
    BEFORE INSERT ON BIENES
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_bienes_ins_codigo();
```

#### 4.1.3 En un servicio, el costo total de productos no debe superar la mano de obra

> **Acciones que modifican el costo de productos:** INSERT/UPDATE/DELETE en INSUMOS,
> UPDATE de precioCompra en PRODUCTOS.
>
> **Acciones que modifican la mano de obra:** UPDATE de manoDeObra en SERVICIOS.

```sql
-- Funcion auxiliar para validar el margen de un servicio
CREATE OR REPLACE FUNCTION validar_costo_servicio(p_servicio VARCHAR) RETURNS VOID AS $$
DECLARE
    v_mano_de_obra NUMERIC(10,2);
    v_costo_productos NUMERIC(10,2);
BEGIN
    SELECT s.manoDeObra INTO v_mano_de_obra
    FROM SERVICIOS s WHERE s.codigo = p_servicio;

    SELECT COALESCE(SUM(b.precioVenta * i.unidades), 0) INTO v_costo_productos
    FROM INSUMOS i
    INNER JOIN BIENES b ON i.producto = b.codigo
    WHERE i.servicio = p_servicio;

    IF v_costo_productos > v_mano_de_obra THEN
        RAISE EXCEPTION 'El costo de productos (%) supera la mano de obra (%) del servicio %',
            v_costo_productos, v_mano_de_obra, p_servicio;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Disparador en INSUMOS
CREATE OR REPLACE FUNCTION fun_tg_insumos_validar() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM validar_costo_servicio(OLD.servicio);
        RETURN OLD;
    ELSE
        PERFORM validar_costo_servicio(NEW.servicio);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_insumos_validar
    AFTER INSERT OR UPDATE OR DELETE ON INSUMOS
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_insumos_validar();

-- Disparador en SERVICIOS (al modificar manoDeObra)
CREATE OR REPLACE FUNCTION fun_tg_servicios_validar_mano() RETURNS TRIGGER AS $$
BEGIN
    PERFORM validar_costo_servicio(NEW.codigo);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_servicios_validar_mano
    AFTER UPDATE OF manoDeObra ON SERVICIOS
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_servicios_validar_mano();
```

### 4.2 Mantener Cliente

#### 4.2.1 Eliminar clientes solo si no tienen facturas asociadas

> Actualmente, la FK de FACTURAS hacia CLIENTES impide eliminar un cliente con facturas (RESTRICT por defecto).
> Ademas, TELEFONOS se elimina en cascada (ON DELETE CASCADE).
> El disparador hace explicita la regla de negocio con un mensaje claro.

```sql
CREATE OR REPLACE FUNCTION fun_tg_clientes_del() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM FACTURAS WHERE tid = OLD.tid AND nid = OLD.nid) THEN
        RAISE EXCEPTION 'No se puede eliminar el cliente (%, %). Tiene facturas asociadas.',
            OLD.tid, OLD.nid;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes_del
    BEFORE DELETE ON CLIENTES
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_clientes_del();
```

#### 4.2.2 Auto-asignar correo nid@vendemos.com.co si no se indica

```sql
CREATE OR REPLACE FUNCTION fun_tg_clientes_ins_correo() RETURNS TRIGGER AS $$
DECLARE
    correo_generado VARCHAR(50);
BEGIN
    IF NEW.correo IS NULL THEN
        correo_generado := NEW.nid || '@vendemos.com.co';
        -- Asignar solo si no esta en uso
        IF NOT EXISTS (SELECT 1 FROM CLIENTES WHERE correo = correo_generado) THEN
            NEW.correo := correo_generado;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes_ins_correo
    BEFORE INSERT ON CLIENTES
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_clientes_ins_correo();
```

#### 4.2.3 No permitir modificar datos de identificacion (tid, nid)

```sql
CREATE OR REPLACE FUNCTION fun_tg_clientes_upd_id() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tid != OLD.tid OR NEW.nid != OLD.nid THEN
        RAISE EXCEPTION 'No esta permitido modificar los datos de identificacion del cliente (tid, nid).';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_clientes_upd_id
    BEFORE UPDATE ON CLIENTES
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_clientes_upd_id();
```

### 4.3 Registrar Factura

#### 4.3.1 Crear encabezado de factura con datos minimos

> **Datos minimos:** tid, nid (el cliente).
> **Se calculan automaticamente:** numero (siguiente consecutivo), fecha (fecha actual).

```sql
CREATE OR REPLACE FUNCTION fun_tg_facturas_ins() RETURNS TRIGGER AS $$
BEGIN
    -- Asignar numero consecutivo
    SELECT COALESCE(MAX(numero), 0) + 1 INTO NEW.numero FROM FACTURAS;
    -- Asignar fecha actual
    NEW.fecha := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturas_ins
    BEFORE INSERT ON FACTURAS
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_facturas_ins();
```

#### 4.3.2 Adicionar linea de factura con datos minimos

> **Datos minimos:** factura, bien, cantidad.
> **Se calculan automaticamente:** linea (siguiente para esa factura), precioVenta (precio actual del bien).
> **Mantener consistencia:** disminuir existencias de productos segun corresponda.

```sql
CREATE OR REPLACE FUNCTION fun_tg_lineas_factura_ins() RETURNS TRIGGER AS $$
DECLARE
    insumo RECORD;
BEGIN
    -- Asignar numero de linea consecutivo dentro de la factura
    SELECT COUNT(*) + 1 INTO NEW.linea
    FROM LINEAS_FACTURA
    WHERE factura = NEW.factura;

    -- Asignar precio de venta actual del bien
    SELECT precioVenta INTO NEW.precioVenta
    FROM BIENES
    WHERE codigo = NEW.bien;

    -- Si es un producto: disminuir existencias
    UPDATE PRODUCTOS
    SET existencias = existencias - NEW.cantidad
    WHERE codigo = NEW.bien;

    -- Si es un servicio: disminuir existencias de los productos insumo
    FOR insumo IN SELECT * FROM INSUMOS WHERE servicio = NEW.bien LOOP
        UPDATE PRODUCTOS
        SET existencias = existencias - insumo.unidades * NEW.cantidad
        WHERE codigo = insumo.producto;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_lineas_factura_ins
    BEFORE INSERT ON LINEAS_FACTURA
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_lineas_factura_ins();
```

#### 4.3.3 No permitir eliminar ni modificar facturas ni lineas

```sql
-- Facturas: no eliminar ni modificar
CREATE OR REPLACE FUNCTION fun_tg_facturas_proteger() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'No se pueden eliminar facturas. Es un registrar.';
    ELSIF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'No se pueden modificar facturas. Es un registrar.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_facturas_proteger
    BEFORE DELETE OR UPDATE ON FACTURAS
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_facturas_proteger();

-- Lineas de factura: no eliminar ni modificar
CREATE OR REPLACE FUNCTION fun_tg_lineas_factura_proteger() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'No se pueden eliminar lineas de factura. Es un registrar.';
    ELSIF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'No se pueden modificar lineas de factura. Es un registrar.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_lineas_factura_proteger
    BEFORE DELETE OR UPDATE ON LINEAS_FACTURA
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_lineas_factura_proteger();
```

### 4.4 Disparadores adicionales (de restricciones declarativas no soportadas)

#### 4.4.1 Precios de venta de bienes nunca deben disminuir

```sql
CREATE OR REPLACE FUNCTION fun_tg_bienes_upd_precio() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.precioVenta < OLD.precioVenta THEN
        RAISE EXCEPTION 'El precio de venta del bien % no puede disminuir (% -> %).',
            OLD.codigo, OLD.precioVenta, NEW.precioVenta;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_bienes_upd_precio
    BEFORE UPDATE OF precioVenta ON BIENES
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_bienes_upd_precio();
```

#### 4.4.2 Precio de venta de productos >= 110% del precio de compra

```sql
CREATE OR REPLACE FUNCTION fun_tg_productos_margen() RETURNS TRIGGER AS $$
DECLARE
    v_precio_venta NUMERIC(10,2);
BEGIN
    SELECT precioVenta INTO v_precio_venta FROM BIENES WHERE codigo = NEW.codigo;
    IF v_precio_venta < NEW.precioCompra * 1.10 THEN
        RAISE EXCEPTION 'El precio de venta (%) debe ser al menos 110%% del precio de compra (%) para el producto %.',
            v_precio_venta, NEW.precioCompra, NEW.codigo;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_productos_margen
    AFTER INSERT OR UPDATE OF precioCompra ON PRODUCTOS
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_productos_margen();
```

#### 4.4.3 Precio de venta de servicios >= 120% de su costo

```sql
CREATE OR REPLACE FUNCTION fun_tg_servicios_margen() RETURNS TRIGGER AS $$
DECLARE
    v_precio_venta NUMERIC(10,2);
    v_costo NUMERIC(10,2);
BEGIN
    SELECT precioVenta INTO v_precio_venta FROM BIENES WHERE codigo = NEW.codigo;
    SELECT NEW.manoDeObra + COALESCE(SUM(b.precioVenta * i.unidades), 0)
    INTO v_costo
    FROM INSUMOS i
    INNER JOIN BIENES b ON i.producto = b.codigo
    WHERE i.servicio = NEW.codigo;

    IF v_precio_venta < v_costo * 1.20 THEN
        RAISE EXCEPTION 'El precio de venta (%) debe ser al menos 120%% del costo (%) para el servicio %.',
            v_precio_venta, v_costo, NEW.codigo;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_servicios_margen
    AFTER INSERT OR UPDATE ON SERVICIOS
    FOR EACH ROW
    EXECUTE FUNCTION fun_tg_servicios_margen();
```

---

## Sugerencias para clase

1. **Diagrama logico:** Hacer el ejercicio de marcar sobre el diagrama conceptual impreso: donde van las tablas (con nombre en plural), donde van las FK, y cual patron de herencia se usa.

2. **Construccion basica:** Implementar un GC por grupo de estudiantes. Luego comparar y discutir convenciones de nombres (PK_tabla, UK_tabla_atributo, FK_tablaBase_tablaReferenciada).

3. **Restricciones declarativas:** Clasificar cada restriccion en el nivel correspondiente:
   - **Dominio** (atributo): CREATE DOMAIN, tipos de dato
   - **Tupla** (fila): ALTER TABLE ADD CONSTRAINT CHECK
   - **Tabla/BD** (cruzada): CREATE ASSERTION (teorico) → disparador (practico)

4. **Disparadores:** Seguir el patron de la clase:
   - Identificar: ¿Que tabla? ¿Que evento (INSERT/DELETE/UPDATE)? ¿Que momento (BEFORE/AFTER)? ¿Cuantas veces (FOR EACH ROW)?
   - Implementar la funcion, luego el disparador.
   - Probar con datos: INSERT que active cada caso.
