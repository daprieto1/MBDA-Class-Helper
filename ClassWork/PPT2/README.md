# Parcial Primer Tercio — MYSD G02 — S11 2026-01

## Grúas Nacionales S.A.S — Facturación y Pagos

---

## (30%) Modelo Relacional Mini

### Leyenda de Claves

<table>
  <tr>
    <td><span style="border-bottom: 3px solid red; padding-bottom: 2px">&nbsp;atributo&nbsp;</span></td>
    <td><b>Primaria</b></td>
  </tr>
  <tr>
    <td><span style="border-bottom: 3px dashed blue; padding-bottom: 2px">&nbsp;atributo&nbsp;</span></td>
    <td><b>Única</b></td>
  </tr>
  <tr>
    <td><span style="border-bottom: 3px solid green; padding-bottom: 2px">&nbsp;atributo&nbsp;</span></td>
    <td><b>Foránea</b></td>
  </tr>
  <tr>
    <td><span style="color: red; border-bottom: 3px solid green; padding-bottom: 2px">&nbsp;atributo&nbsp;</span></td>
    <td><b>Primaria + Foránea</b></td>
  </tr>
  <tr>
    <td><span style="color: orange; font-weight: bold; font-size: 18px">&nbsp;!&nbsp;</span></td>
    <td><b>Puede no conocerse</b></td>
  </tr>
</table>

### Leyenda de CRUDs

| Color | CRUD |
|:-----:|------|
| 🔴 | Registrar Cliente |
| 🔵 | Registrar Vehículo |
| 🟢 | Registrar Conductor |
| 🟡 | Registrar Servicio |
| 🟣 | Registrar Facturación |
| 🟠 | Registrar Pago |

---

### Modelo

<div style="font-family: 'Courier New', Courier, monospace; font-size: 15px; line-height: 2.8;">

<!-- ═══════════════════ CRUD: Registrar Cliente ═══════════════════ -->

<p>🔴 <b>Clientes</b>(<span style="border-bottom: 3px solid red">id</span>, nombre)</p>

<p>🔴 <b>Privados</b>(<span style="color: red; border-bottom: 3px solid green">cliente</span>, actividadEconomica)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ cliente → Clientes(id)</p>

<p>🔴 <b>Publicos</b>(<span style="color: red; border-bottom: 3px solid green">cliente</span>, tipo, numeroTributario)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ cliente → Clientes(id)</p>

<!-- ═══════════════════ CRUD: Registrar Vehículo ═══════════════════ -->

<p>🔵 <b>Vehiculos</b>(<span style="border-bottom: 3px solid red">id</span>, <span style="border-bottom: 3px dashed blue">placa</span>, categoria, <span style="border-bottom: 3px solid green">cliente</span>, <span style="border-bottom: 3px solid green">condTipoDoc</span><span style="color: orange; font-weight: bold"> !</span>, <span style="border-bottom: 3px solid green">condNumDoc</span><span style="color: orange; font-weight: bold"> !</span>)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ cliente → Clientes(id)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ (condTipoDoc, condNumDoc) → Conductores(tipoDoc, numeroDocumento)</p>

<!-- ═══════════════════ CRUD: Registrar Conductor ═══════════════════ -->

<p>🟢 <b>Conductores</b>(<span style="border-bottom: 3px solid red">tipoDoc</span>, <span style="border-bottom: 3px solid red">numeroDocumento</span>)</p>

<p>🟢 <b>Licencias</b>(<span style="color: red; border-bottom: 3px solid green">condTipoDoc</span>, <span style="color: red; border-bottom: 3px solid green">condNumDoc</span>, <span style="border-bottom: 3px solid red">fechaExpedicion</span>, fechaVencimiento)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ (condTipoDoc, condNumDoc) → Conductores(tipoDoc, numeroDocumento)</p>

<!-- ═══════════════════ CRUD: Registrar Servicio ═══════════════════ -->

<p>🟡 <b>Servicios</b>(<span style="border-bottom: 3px solid red">idServicio</span>, fechaSolicitud, fechaCancelacion<span style="color: orange; font-weight: bold"> !</span>, fechaFinalizacion<span style="color: orange; font-weight: bold"> !</span>, estado, distanciaTotal, <span style="border-bottom: 3px solid green">cliente</span>, <span style="border-bottom: 3px solid green">condTipoDoc</span>, <span style="border-bottom: 3px solid green">condNumDoc</span>, <span style="border-bottom: 3px solid green">facturacion</span><span style="color: orange; font-weight: bold"> !</span>)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ cliente → Clientes(id)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ (condTipoDoc, condNumDoc) → Conductores(tipoDoc, numeroDocumento)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ facturacion → Facturaciones(id)</p>

<p>🟡 <b>Novedades</b>(<span style="color: red; border-bottom: 3px solid green">servicio</span>, <span style="border-bottom: 3px solid red">fecha</span>, <span style="border-bottom: 3px solid red">titulo</span>)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ servicio → Servicios(idServicio)</p>

<!-- ═══════════════════ CRUD: Registrar Facturación ═══════════════════ -->

<p>🟣 <b>Facturaciones</b>(<span style="border-bottom: 3px solid red">id</span>, <span style="border-bottom: 3px dashed blue">numero</span>, fechaEmision, montoTotal, impuestos, fechaLimitePago, estado, saldoPendiente<span style="color: orange; font-weight: bold"> !</span>)</p>

<p>🟣 <b>Convenios</b>(<span style="border-bottom: 3px solid red">id</span>, porcentaje, motivo)</p>

<p>🟣 <b>FacturacionesConvenios</b>(<span style="color: red; border-bottom: 3px solid green">facturacion</span>, <span style="color: red; border-bottom: 3px solid green">convenio</span>)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ facturacion → Facturaciones(id)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ convenio → Convenios(id)</p>

<!-- ═══════════════════ CRUD: Registrar Pago ═══════════════════ -->

<p>🟠 <b>Pagos</b>(<span style="border-bottom: 3px solid red">id</span>, <span style="border-bottom: 3px dashed blue">referencia</span>, fecha, monto, metodoPago, estado, <span style="border-bottom: 3px solid green">facturacion</span>)</p>
<p style="margin-left: 40px; font-size: 12px; color: green">↳ facturacion → Facturaciones(id)</p>

</div>

---

### Notas de Transformación

| Patrón aplicado | Detalle |
|----------------|---------|
| **Conceptos como tablas** | Cada concepto del modelo conceptual se convierte en una tabla |
| **Identificador de objetos** | Se asigna PK a cada tabla; Convenios recibe PK surrogado (no tiene `<<I>>` en el conceptual) |
| **Relaciones como tablas** | M:N Facturaciones–Convenios → tabla de cruce `FacturacionesConvenios`; relaciones 1:N → FK en el lado muchos |
| **Herencia** | Cliente (superclase) + Privados/Publicos (subclases) con PK compartido como FK — patrón tabla por clase |
| **Atributo multivaluado** | `titulo[*]` de Novedad se aplana en la PK: (servicio, fecha, titulo) |
| **Composición** | Licencia es parte de Conductor → PK de Conductor forma parte de PK de Licencia |
| **Nullable** | `fechaCancelacion` y `fechaFinalizacion` en Servicios son nullable (restricción 2 del parcial implica que fechaCancelacion es nula cuando estado ≠ cancelado); `facturacion` en Servicios es nullable (relación 0..1); `condTipoDoc/condNumDoc` en Vehiculos nullable (relación 0..1 con Conductor) |

---

## (20%) Integridad Declarativa — SQL Estándar

### Resumen de Mecanismos

| # | Restricción | Mecanismo | Nivel |
|---|------------|-----------|-------|
| 1 | Estado de factura solo valores válidos | Definición de dominio (`CREATE DOMAIN`) | Atributo |
| 2 | fechaCancelacion coherente con estado del servicio | Condición de tupla (`CHECK`) | Tupla |
| 3 | fechaLimitePago ≥ fecha del servicio | Aserción general (`CREATE ASSERTION`) | Base de datos |
| 4 | Referencia de pago no repetida | Clave única (`UNIQUE`) | Tabla |

### Implementación

#### 1. El estado de la factura sólo puede ser: solicitado, aprobado, pendiente, vencida, o anulada

**Mecanismo:** Definición de dominio (restricción de atributo)

> Restringe los valores válidos de un atributo a nivel de dominio. Se aplica a cualquier columna que use este tipo.

```sql
CREATE DOMAIN TEstadoFactura AS VARCHAR(20)
    CHECK (VALUE IN ('solicitado', 'aprobado', 'pendiente', 'vencida', 'anulada'));
```

#### 2. Si un servicio se encuentra en estado cancelado, debe tener registrada una fecha de cancelación; si no está en estado cancelado, la fecha de cancelación debe ser nula

**Mecanismo:** Condición de tupla (restricción de tupla)

> Involucra dos atributos de la misma tupla (`estado` y `fechaCancelacion`), por lo tanto requiere un CHECK a nivel de tupla.

```sql
ALTER TABLE SERVICIOS ADD CONSTRAINT CK_SERVICIOS_CANCELACION
    CHECK (
        (estado = 'cancelado' AND fechaCancelacion IS NOT NULL)
        OR
        (estado <> 'cancelado' AND fechaCancelacion IS NULL)
    );
```

#### 3. La fecha límite de pago de una factura debe ser igual o posterior a la fecha del servicio al que pertenece

**Mecanismo:** Aserción general (restricción de base de datos)

> Involucra atributos de dos tablas diferentes (`FACTURACIONES.fechaLimitePago` y `SERVICIOS.fechaSolicitud`), por lo tanto requiere una aserción que valide la condición a nivel de base de datos.

```sql
CREATE ASSERTION CK_FECHA_LIMITE_SERVICIO
    CHECK (NOT EXISTS (
        SELECT 1
        FROM SERVICIOS S
        INNER JOIN FACTURACIONES F ON S.facturacion = F.id
        WHERE F.fechaLimitePago < S.fechaSolicitud
    ));
```

#### 4. La referencia de un pago no puede ser repetida

**Mecanismo:** Clave única (restricción de tabla)

> La unicidad de un atributo se garantiza con una clave única (`UNIQUE`). Ya está reflejada en el modelo mini como UK.

```sql
ALTER TABLE PAGOS ADD CONSTRAINT UK_PAGOS_REFERENCIA
    UNIQUE (referencia);
```

---

## (20%) Integridad Procedimental — Diseño

> **SOLO DISEÑO — NO IMPLEMENTAR.**
> CRUD: **Registrar FACTURACIÓN**

---

### Adicionar

#### A1. Auto-generar datos de factura

> Al registrar una factura, el número debe ser generado automáticamente, la fecha de emisión debe ser la actual, y el estado inicial debe ser 'pendiente'.

| Aspecto | Detalle |
|---------|---------|
| **Disparador** | `tg_facturaciones_ins` |
| **Tabla** | `FACTURACIONES` |
| **Evento** | `INSERT` |
| **Momento** | `BEFORE` |
| **Granularidad** | `FOR EACH ROW` |
| **Condición** | — |

**Acciones:**
1. Calcular `NEW.numero` como `MAX(numero) + 1` de `FACTURACIONES` (o siguiente valor de secuencia)
2. Asignar `NEW.fechaEmision = CURRENT_DATE`
3. Asignar `NEW.estado = 'pendiente'`
4. Asignar `NEW.saldoPendiente = NEW.montoTotal + NEW.impuestos`
5. `RETURN NEW`

---

#### A2. Validar vinculación de servicio a factura

> Una factura solo puede generarse si los servicios están en estado 'Finalizado', no han sido facturados anteriormente, y el cliente asociado no está 'Inactivo' ni 'Suspendido'.

| Aspecto | Detalle |
|---------|---------|
| **Disparador** | `tg_servicios_upd_facturacion` |
| **Tabla** | `SERVICIOS` |
| **Evento** | `UPDATE OF facturacion` |
| **Momento** | `BEFORE` |
| **Granularidad** | `FOR EACH ROW` |
| **Condición** | `WHEN (NEW.facturacion IS NOT NULL)` |

**Acciones:**
1. Si `NEW.estado <> 'Finalizado'` → `RAISE EXCEPTION` *"Solo se pueden facturar servicios finalizados"*
2. Si `OLD.facturacion IS NOT NULL` → `RAISE EXCEPTION` *"El servicio ya fue facturado anteriormente"*
3. Consultar el estado del cliente asociado (`NEW.cliente` → `CLIENTES`). Si el estado del cliente es `'Inactivo'` o `'Suspendido'` → `RAISE EXCEPTION` *"No se puede facturar a un cliente inactivo o suspendido"*
4. `RETURN NEW`

> **Nota:** Las tres reglas de "Adicionar" sobre validación de servicios se verifican en esta tabla porque la relación Servicio–Facturación se materializa mediante el FK `facturacion` en `SERVICIOS`. Al momento de INSERT en `FACTURACIONES` aún no hay servicios vinculados; la validación ocurre cuando se actualizan los servicios para asignarles la factura.

---

### Modificar

#### M1. Impedir modificación de factura anulada y auto-vencimiento

> Una factura con estado 'anulada' no puede modificarse. Además, si la fecha actual supera la fecha límite de pago y aún hay saldo pendiente, el estado debe cambiar automáticamente a 'vencida'.

| Aspecto | Detalle |
|---------|---------|
| **Disparador** | `tg_facturaciones_upd` |
| **Tabla** | `FACTURACIONES` |
| **Evento** | `UPDATE` |
| **Momento** | `BEFORE` |
| **Granularidad** | `FOR EACH ROW` |
| **Condición** | — |

**Acciones:**
1. Si `OLD.estado = 'anulada'` → `RAISE EXCEPTION` *"No se puede modificar una factura anulada"*
2. Si `CURRENT_DATE > NEW.fechaLimitePago` y `NEW.saldoPendiente > 0` → Asignar `NEW.estado = 'vencida'`
3. `RETURN NEW`

> **Nota:** La regla de vencimiento se evalúa en cada UPDATE de la factura. Cuando otros disparadores (M2, o triggers del CRUD Registrar Pago) modifican el `saldoPendiente`, esa actualización también dispara este trigger, verificando automáticamente la condición de vencimiento.

---

#### M2. Actualizar saldo pendiente al registrar convenio

> El saldo pendiente de la factura debe actualizarse automáticamente cada vez que se registre un nuevo convenio asociado a ella.

| Aspecto | Detalle |
|---------|---------|
| **Disparador** | `tg_facturacionesconvenios_ins` |
| **Tabla** | `FACTURACIONESCONVENIOS` |
| **Evento** | `INSERT` |
| **Momento** | `AFTER` |
| **Granularidad** | `FOR EACH ROW` |
| **Condición** | — |

**Acciones:**
1. Obtener el `porcentaje` del convenio desde `CONVENIOS` usando `NEW.convenio`
2. Actualizar `FACTURACIONES` → `saldoPendiente = saldoPendiente - (montoTotal * porcentaje / 100)` donde `id = NEW.facturacion`
3. *(La actualización anterior dispara `tg_facturaciones_upd` (M1), que verifica automáticamente si la factura debe pasar a estado 'vencida')*

---

### Eliminar

#### E1. Impedir eliminación de factura no pendiente

> Una factura no puede eliminarse si su estado es diferente a 'pendiente'.

| Aspecto | Detalle |
|---------|---------|
| **Disparador** | `tg_facturaciones_del` |
| **Tabla** | `FACTURACIONES` |
| **Evento** | `DELETE` |
| **Momento** | `BEFORE` |
| **Granularidad** | `FOR EACH ROW` |
| **Condición** | `WHEN (OLD.estado <> 'pendiente')` |

**Acciones:**
1. `RAISE EXCEPTION` *"Solo se pueden eliminar facturas en estado pendiente"*
2. *(Si la condición WHEN no se cumple, es decir estado = 'pendiente', el DELETE procede normalmente)*

---

### Resumen de Disparadores

| # | Disparador | Tabla | Evento | Momento | Propósito |
|---|-----------|-------|--------|---------|-----------|
| A1 | `tg_facturaciones_ins` | FACTURACIONES | INSERT | BEFORE | Auto-generar numero, fechaEmision, estado, saldoPendiente |
| A2 | `tg_servicios_upd_facturacion` | SERVICIOS | UPDATE OF facturacion | BEFORE | Validar estado servicio, no re-facturar, cliente activo |
| M1 | `tg_facturaciones_upd` | FACTURACIONES | UPDATE | BEFORE | Bloquear si anulada; auto-vencimiento |
| M2 | `tg_facturacionesconvenios_ins` | FACTURACIONESCONVENIOS | INSERT | AFTER | Recalcular saldoPendiente con descuento del convenio |
| E1 | `tg_facturaciones_del` | FACTURACIONES | DELETE | BEFORE | Impedir eliminación si estado ≠ 'pendiente' |

### Cadena de Disparadores

```
INSERT FacturacionesConvenios
  └─ (M2) AFTER INSERT → UPDATE Facturaciones.saldoPendiente
       └─ (M1) BEFORE UPDATE → verifica anulada + auto-vencimiento
```

---

## BONO (+0.2) — Mejoras al Modelo Conceptual Extendido

### 1. Agregar `estado` a Cliente

El modelo conceptual NO incluye un atributo `estado` en `Cliente`, pero las reglas de negocio de Facturación exigen validar que el cliente no esté `'Inactivo'` o `'Suspendido'`. Sin este atributo, la regla es imposible de implementar.

**Mejora:** Agregar `estado : TEstadoCliente` a la clase `Cliente`.

### 2. Marcar `fechaCancelacion` y `fechaFinalizacion` como opcionales `[0..1]`

La restricción 2 del parcial establece que `fechaCancelacion` es nula cuando el servicio no está cancelado. Lo mismo aplica para `fechaFinalizacion` (nula hasta que el servicio finalice). Sin embargo, el modelo conceptual las muestra sin `[0..1]`, lo que implica que son obligatorias — una contradicción con las reglas de negocio.

**Mejora:** Cambiar a `fechaCancelacion : Fecha[0..1]` y `fechaFinalizacion : Fecha[0..1]`.

### 3. Agregar `<<I>>` a Conductor, Licencia, Novedad y Convenios

Estas cuatro clases carecen de identificador explícito `<<I>>`:

- **Conductor**: `(tipoDoc, numeroDocumento)` es su clave natural compuesta, pero no está marcada.
- **Licencia**: depende de Conductor y `fechaExpedicion` — falta marcar la composición.
- **Novedad**: no tiene identificador claro; combinado con `titulo[*]` (multivaluado), dificulta la transformación relacional.
- **Convenios**: obligó a inventar un PK surrogado en el modelo relacional porque no tiene ningún atributo identificador.

**Mejora:** Marcar `<<I>>` en Conductor `(tipoDoc + numeroDocumento)`, agregar `<<I>>` surrogado a Convenios, y definir la composición explícita para Licencia y Novedad.

### 4. Marcar `<<U>>` en `referencia` de Pago

La restricción 4 del parcial exige que la referencia de pago sea única, pero el modelo conceptual no la marca con `<<U>>`. Esto es una regla de negocio implícita que debería ser visible en el diagrama.

**Mejora:** Cambiar a `<<U>> referencia : Cadena(100)`.

### 5. Agregar relación directa Servicio — Vehículo

Actualmente, el vehículo usado en un servicio solo se infiere indirectamente: `Servicio → Conductor → Vehículo`. Pero como un Conductor puede manejar múltiples vehículos (`* — 0..1`), no se puede saber cuál vehículo se usó en un servicio específico.

**Mejora:** Agregar una relación `Utiliza` entre `Servicio` y `Vehiculo` (`* — 1`) para registrar explícitamente qué vehículo/grúa se utilizó en cada servicio.

### 6. `distanciaTotal` debería ser opcional `[0..1]`

Un servicio recién solicitado (estado `'solicitado'`) no tiene distancia calculada aún. Forzar `distanciaTotal` como obligatorio impide crear el servicio sin conocer este dato.

**Mejora:** Cambiar a `distanciaTotal : Numero(10,2)[0..1]`.
