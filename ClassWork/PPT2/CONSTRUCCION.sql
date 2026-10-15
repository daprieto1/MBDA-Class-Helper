-- ============================================================================
-- ESCUELA COLOMBIANA DE INGENIERIA
-- MODELOS Y SERVICIOS DE DATOS - MYSD G02
-- PARCIAL PRIMER TERCIO — S11 2026-01
-- Gruas Nacionales S.A.S — Facturacion y Pagos
--
-- (30%) CONSTRUCCION — SQL Oracle
-- Estudiante: Diego Alfonso
-- ============================================================================


-- ============================================================================
-- PARTE 1: Estructuras de tablas
-- Sin restricciones de integridad externa.
-- SOLO restricciones propias de la definicion de tablas:
--   columnas, tipos de dato, NOT NULL, PRIMARY KEY
-- ============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~ CRUD: Registrar Cliente ~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Clientes (
    id              NUMBER(10)      NOT NULL,
    nombre          VARCHAR2(100)   NOT NULL,
    CONSTRAINT PK_Clientes PRIMARY KEY (id)
);

CREATE TABLE Privados (
    cliente             NUMBER(10)      NOT NULL,
    actividadEconomica  VARCHAR2(10)    NOT NULL,
    CONSTRAINT PK_Privados PRIMARY KEY (cliente)
);

CREATE TABLE Publicos (
    cliente             NUMBER(10)      NOT NULL,
    tipo                NUMBER(10)      NOT NULL,
    numeroTributario    VARCHAR2(10)    NOT NULL,
    CONSTRAINT PK_Publicos PRIMARY KEY (cliente)
);


-- ~~~~~~~~~~~~~~~~~~~~~~~ CRUD: Registrar Vehiculo ~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Vehiculos (
    id              NUMBER(10)      NOT NULL,
    placa           VARCHAR2(7)     NOT NULL,
    categoria       VARCHAR2(21)    NOT NULL,
    cliente         NUMBER(10)      NOT NULL,
    condTipoDoc     VARCHAR2(2),
    condNumDoc      NUMBER(10),
    CONSTRAINT PK_Vehiculos PRIMARY KEY (id)
);


-- ~~~~~~~~~~~~~~~~~~~~~~~ CRUD: Registrar Conductor ~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Conductores (
    tipoDoc             VARCHAR2(2)     NOT NULL,
    numeroDocumento     NUMBER(10)      NOT NULL,
    CONSTRAINT PK_Conductores PRIMARY KEY (tipoDoc, numeroDocumento)
);

CREATE TABLE Licencias (
    condTipoDoc         VARCHAR2(2)     NOT NULL,
    condNumDoc          NUMBER(10)      NOT NULL,
    fechaExpedicion     DATE            NOT NULL,
    fechaVencimiento    DATE            NOT NULL,
    CONSTRAINT PK_Licencias PRIMARY KEY (condTipoDoc, condNumDoc, fechaExpedicion)
);


-- ~~~~~~~~~~~~~~~~~~~~~~~ CRUD: Registrar Servicio ~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Servicios (
    idServicio          NUMBER(10)      NOT NULL,
    fechaSolicitud      DATE            NOT NULL,
    fechaCancelacion    DATE,
    fechaFinalizacion   DATE,
    estado              VARCHAR2(20)    NOT NULL,
    distanciaTotal      NUMBER(10,2),
    cliente             NUMBER(10)      NOT NULL,
    condTipoDoc         VARCHAR2(2)     NOT NULL,
    condNumDoc          NUMBER(10)      NOT NULL,
    facturacion         NUMBER(10),
    CONSTRAINT PK_Servicios PRIMARY KEY (idServicio)
);

CREATE TABLE Novedades (
    servicio    NUMBER(10)      NOT NULL,
    fecha       DATE            NOT NULL,
    titulo      VARCHAR2(200)   NOT NULL,
    CONSTRAINT PK_Novedades PRIMARY KEY (servicio, fecha, titulo)
);


-- ~~~~~~~~~~~~~~~~~~~~~ CRUD: Registrar Facturacion ~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Facturaciones (
    id              NUMBER(10)      NOT NULL,
    numero          NUMBER(10)      NOT NULL,
    fechaEmision    DATE            NOT NULL,
    montoTotal      NUMBER(15,2)    NOT NULL,
    impuestos       NUMBER(15,2)    NOT NULL,
    fechaLimitePago DATE            NOT NULL,
    estado          VARCHAR2(20)    NOT NULL,
    saldoPendiente  NUMBER(15,2),
    CONSTRAINT PK_Facturaciones PRIMARY KEY (id)
);

CREATE TABLE Convenios (
    id          NUMBER(10)      NOT NULL,
    porcentaje  NUMBER(2)       NOT NULL,
    motivo      VARCHAR2(100)   NOT NULL,
    CONSTRAINT PK_Convenios PRIMARY KEY (id)
);

CREATE TABLE FacturacionesConvenios (
    facturacion NUMBER(10)      NOT NULL,
    convenio    NUMBER(10)      NOT NULL,
    CONSTRAINT PK_FactConvenios PRIMARY KEY (facturacion, convenio)
);


-- ~~~~~~~~~~~~~~~~~~~~~~~~~ CRUD: Registrar Pago ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE Pagos (
    id          NUMBER(10)      NOT NULL,
    referencia  VARCHAR2(100)   NOT NULL,
    fecha       DATE            NOT NULL,
    monto       NUMBER(15,2)    NOT NULL,
    metodoPago  VARCHAR2(14)    NOT NULL,
    estado      VARCHAR2(20)    NOT NULL,
    facturacion NUMBER(10)      NOT NULL,
    CONSTRAINT PK_Pagos PRIMARY KEY (id)
);


-- ============================================================================
-- PARTE 2: Integridad declarativa
-- CRUD: Registrar Servicio (tablas: Servicios, Novedades)
-- Unicamente las restricciones de ese CRUD y las necesarias para ellas.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- Claves foraneas: Servicios
-- ----------------------------------------------------------------------------

-- Servicio pertenece a un Cliente (Solicita: Cliente 1 — * Servicio)
ALTER TABLE Servicios ADD CONSTRAINT FK_Servicios_Clientes
    FOREIGN KEY (cliente) REFERENCES Clientes(id);

-- Servicio es realizado por un Conductor (Realiza: Conductor 1 — * Servicio)
ALTER TABLE Servicios ADD CONSTRAINT FK_Servicios_Conductores
    FOREIGN KEY (condTipoDoc, condNumDoc)
    REFERENCES Conductores(tipoDoc, numeroDocumento);

-- Servicio puede pertenecer a una Facturacion (Genera: Servicio 1..* — 0..1 Facturacion)
ALTER TABLE Servicios ADD CONSTRAINT FK_Servicios_Facturaciones
    FOREIGN KEY (facturacion) REFERENCES Facturaciones(id);


-- ----------------------------------------------------------------------------
-- Claves foraneas: Novedades
-- ----------------------------------------------------------------------------

-- Novedad pertenece a un Servicio (Tiene: Servicio 1 — * Novedad)
-- ON DELETE CASCADE: al eliminar un servicio, se eliminan sus novedades
ALTER TABLE Novedades ADD CONSTRAINT FK_Novedades_Servicios
    FOREIGN KEY (servicio) REFERENCES Servicios(idServicio)
    ON DELETE CASCADE;


-- ----------------------------------------------------------------------------
-- CHECK: coherencia estado - fechaCancelacion (Restriccion 2 del parcial)
-- Si estado = 'cancelado' → fechaCancelacion NOT NULL
-- Si estado <> 'cancelado' → fechaCancelacion IS NULL
-- ----------------------------------------------------------------------------

ALTER TABLE Servicios ADD CONSTRAINT CK_Servicios_Cancelacion
    CHECK (
        (estado = 'cancelado' AND fechaCancelacion IS NOT NULL)
        OR
        (estado <> 'cancelado' AND fechaCancelacion IS NULL)
    );


-- ============================================================================
-- PARTE 3: Integridad procedimental
-- CRUD: Registrar Servicio
-- Disparadores en Oracle PL/SQL
-- ============================================================================


-- Secuencia para auto-generar idServicio
CREATE SEQUENCE seq_Servicios START WITH 1 INCREMENT BY 1 NOCACHE;


-- ----------------------------------------------------------------------------
-- Ad: Adicionar Servicio — auto-generar datos
-- ----------------------------------------------------------------------------
-- Tabla:        Servicios
-- Evento:       INSERT
-- Momento:      BEFORE
-- Granularidad: FOR EACH ROW
--
-- Acciones:
--   1. Asignar idServicio desde secuencia (evita mutating table)
--   2. Asignar fechaSolicitud = SYSDATE
--   3. Asignar estado = 'solicitado'
--   4. Limpiar fechaCancelacion y fechaFinalizacion
-- ----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER tg_Servicios_ins
BEFORE INSERT ON Servicios
FOR EACH ROW
BEGIN
    :NEW.idServicio       := seq_Servicios.NEXTVAL;
    :NEW.fechaSolicitud   := SYSDATE;
    :NEW.estado           := 'solicitado';
    :NEW.fechaCancelacion := NULL;
    :NEW.fechaFinalizacion := NULL;
END;
/


-- ----------------------------------------------------------------------------
-- Mo: Modificar Servicio — auto-gestion de fechas segun cambio de estado
-- ----------------------------------------------------------------------------
-- Tabla:        Servicios
-- Evento:       UPDATE
-- Momento:      BEFORE
-- Granularidad: FOR EACH ROW
--
-- Acciones:
--   1. Si cambia a 'cancelado' → auto-asignar fechaCancelacion = SYSDATE
--   2. Si deja de ser 'cancelado' → limpiar fechaCancelacion (cumple CK)
--   3. Si cambia a 'finalizado' → auto-asignar fechaFinalizacion = SYSDATE
-- ----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER tg_Servicios_upd
BEFORE UPDATE ON Servicios
FOR EACH ROW
BEGIN
    -- Si cambia a cancelado: registrar fecha de cancelacion
    IF :NEW.estado = 'cancelado' AND :OLD.estado <> 'cancelado' THEN
        :NEW.fechaCancelacion := SYSDATE;
    END IF;

    -- Si deja de ser cancelado: limpiar fechaCancelacion
    -- (cumplir CK_Servicios_Cancelacion)
    IF :NEW.estado <> 'cancelado' THEN
        :NEW.fechaCancelacion := NULL;
    END IF;

    -- Si cambia a finalizado: registrar fecha de finalizacion
    IF :NEW.estado = 'finalizado' AND :OLD.estado <> 'finalizado' THEN
        :NEW.fechaFinalizacion := SYSDATE;
    END IF;
END;
/


-- ----------------------------------------------------------------------------
-- El: Eliminar Servicio — impedir si ya fue facturado
-- ----------------------------------------------------------------------------
-- Tabla:        Servicios
-- Evento:       DELETE
-- Momento:      BEFORE
-- Granularidad: FOR EACH ROW
--
-- Acciones:
--   1. Si facturacion IS NOT NULL → RAISE_APPLICATION_ERROR
-- ----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER tg_Servicios_del
BEFORE DELETE ON Servicios
FOR EACH ROW
BEGIN
    IF :OLD.facturacion IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001,
            'No se puede eliminar un servicio que ya ha sido facturado.');
    END IF;
END;
/


-- ----------------------------------------------------------------------------
-- Ad: Adicionar Novedad — validar que el servicio este activo
-- ----------------------------------------------------------------------------
-- Tabla:        Novedades
-- Evento:       INSERT
-- Momento:      BEFORE
-- Granularidad: FOR EACH ROW
--
-- Acciones:
--   1. Consultar estado del servicio (tabla SERVICIOS, sin mutating table)
--   2. Si estado IN ('cancelado','finalizado') → RAISE_APPLICATION_ERROR
-- ----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER tg_Novedades_ins
BEFORE INSERT ON Novedades
FOR EACH ROW
DECLARE
    v_estado VARCHAR2(20);
BEGIN
    SELECT estado INTO v_estado
    FROM Servicios
    WHERE idServicio = :NEW.servicio;

    IF v_estado IN ('cancelado', 'finalizado') THEN
        RAISE_APPLICATION_ERROR(-20002,
            'No se pueden agregar novedades a un servicio cancelado o finalizado.');
    END IF;
END;
/


-- ============================================================================
-- RESUMEN DE DISPARADORES — CRUD Registrar Servicio
-- ============================================================================
--
-- +-----+---------------------+-----------+----------+--------+--------------+
-- | #   | Disparador          | Tabla     | Evento   |Momento | Proposito    |
-- +-----+---------------------+-----------+----------+--------+--------------+
-- | Ad  | tg_Servicios_ins    | Servicios | INSERT   | BEFORE | Automatizar  |
-- | Mo  | tg_Servicios_upd    | Servicios | UPDATE   | BEFORE | Automatizar  |
-- | El  | tg_Servicios_del    | Servicios | DELETE   | BEFORE | Evitar       |
-- | Ad  | tg_Novedades_ins    | Novedades | INSERT   | BEFORE | Evitar       |
-- +-----+---------------------+-----------+----------+--------+--------------+
--
-- Patron comun: TODOS son BEFORE + FOR EACH ROW
--   Evitar acciones no deseadas:   verificar → RAISE_APPLICATION_ERROR
--   Automatizar acciones deseadas: calcular  → asignar a :NEW → continuar
-- ============================================================================
