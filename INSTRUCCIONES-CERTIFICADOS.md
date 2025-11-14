# INSTRUCCIONES PARA INSERT-CERTIFICADOS.SQL

## ANÁLISIS PREVIO

### Procedimientos Encontrados en procedimientos.sql

**Para gestión de certificados:**
- ❌ NO EXISTE: `S_INS_UPD_EMO_CERTIFICADO` → Debemos crear inserciones directas o el procedimiento
- ❌ NO EXISTE: `S_INS_UPD_RESULTADO_EMO` → Debemos crear inserciones directas o el procedimiento
- ✅ EXISTE: `S_SEL_CERTIFICADO_VALIDAR_ACCESO` → Solo consulta, no inserta

**Para consultas:**
- ✅ `S_SEL_PROTOCOLOS_EMO` → Obtiene exámenes requeridos por perfil y tipo EMO
- ✅ `S_SEL_DOCTORES` → Lista de doctores disponibles
- ✅ `S_SEL_DOCTOR_POR_ID` → Obtiene un doctor específico

### Estructura de Tablas Inferida

Basándose en el procedimiento `S_SEL_CERTIFICADO_VALIDAR_ACCESO` (líneas 535-575 de procedimientos.sql):

#### T_EMO_CERTIFICADO
```sql
-- Tabla principal para certificados EMO
Campos:
- Id (INT, PK)
- Codigo (NVARCHAR(50)) → Código único del certificado
- EMOId (INT, FK) → Referencia a T_EMO
- RutaArchivoPDF (NVARCHAR(500)) → URL del PDF generado (NULL si aún no se generó)
- NombreArchivo (NVARCHAR(300)) → Nombre del archivo PDF
- TipoEvaluacion (NVARCHAR(100)) → Ej: "INGRESO", "PERIÓDICO"
- TipoResultado (NVARCHAR(50)) → Ej: "APTO", "APTO CON RESTRICCIONES", "NO APTO"
- PuestoAlQuePostula (NVARCHAR(200)) → Nombre del puesto
- PuestoActual (NVARCHAR(200)) → Puesto actual (puede ser NULL para ingresos)
- Observaciones (NVARCHAR(MAX)) → Observaciones médicas
- Restricciones (NVARCHAR(MAX)) → Restricciones médicas (puede ser NULL)
- FechaEvaluacion (DATETIME) → Fecha en que se realizó la evaluación
- FechaCaducidad (DATETIME) → Fecha de vencimiento (FechaEvaluacion + 2+ años)
- FechaGeneracion (DATETIME) → Fecha en que se generó el certificado
- Estado (NVARCHAR(20)) → "ACTIVO", "INACTIVO"
- DoctorId (INT, FK) → Referencia a T_DOCTOR (asumo, no visible en SELECT pero lógico)
```

#### T_EMO
```sql
-- Tabla intermedia que conecta colaborador con certificado
Campos:
- Id (INT, PK)
- ColaboradorId (INT, FK) → ⚠️ PROBLEMA: Usa T_COLABORADOR (obsoleto)
  → SOLUCIÓN: Debe usar PersonaProgramaId (FK a T_PERSONA_PROGRAMA)
- FechaCreacion (DATETIME)
- Estado (CHAR(1))
```

#### T_RESULTADO_EMO
```sql
-- Tabla para marcar exámenes como completados
Campos (inferidos):
- Id (INT, PK)
- EMOId (INT, FK) → Referencia a T_EMO
- ExamenMedicoId (INT, FK) → Referencia a T_EXAMEN_MEDICO_OCUPACIONAL
- Completado (BIT) → 1 = marcado con check, 0 = pendiente
- FechaRealizacion (DATETIME) → Fecha en que se realizó el examen
- Resultado (NVARCHAR(MAX)) → Resultado del examen (opcional)
- Estado (CHAR(1))
```

---

## FLUJO PARA GENERAR CERTIFICADOS

### Requisitos del Usuario

1. **3 ETAPAS:**
   - **Etapa 1 - Datos Básicos**: Llenar todos los campos del certificado EXCEPTO RutaArchivoPDF
   - **Etapa 2 - Exámenes Completados**: Marcar exámenes requeridos como completados en T_RESULTADO_EMO
   - **Etapa 3 - Generación de Certificado**: Llenar RutaArchivoPDF solo cuando:
     - Todos los datos básicos están completos (Etapa 1)
     - Todos los exámenes requeridos están marcados como completados (Etapa 2)

2. **VARIABILIDAD:**
   - Algunos colaboradores: SOLO Etapa 1 (datos básicos completos, sin exámenes)
   - Algunos colaboradores: Etapa 1 + algunos exámenes de Etapa 2 (datos completos + exámenes parciales)
   - Algunos colaboradores: Etapa 1 + todos exámenes de Etapa 2 (datos completos + exámenes completos, SIN PDF)
   - Algunos colaboradores: Etapa 1 + Etapa 2 + Etapa 3 (certificado completo CON PDF)

3. **ESTADOS DEL CERTIFICADO:**
   - **Sin URL**: RutaArchivoPDF es NULL
   - **Emitido**: RutaArchivoPDF tiene contenido
   - **Vencido**: GETDATE() > FechaCaducidad
   - **Por vencer**: FechaCaducidad - GETDATE() < 60 días (2 meses)
   - **Vigente**: FechaCaducidad - GETDATE() >= 60 días

4. **REGLAS DE FECHAS:**
   - FechaEvaluacion: Puede ser en el pasado (últimos 6 meses desde GETDATE())
   - FechaCaducidad: Siempre FechaEvaluacion + (2 a 3 años)
   - FechaGeneracion: Fecha en que se "generó" el PDF (puede ser igual o posterior a FechaEvaluacion)

5. **OTROS:**
   - Código de certificado ÚNICO (formato: "EMO-" + AÑO + "-" + NÚMERO)
   - Doctor variado por certificado (seleccionar aleatoriamente de doctores disponibles)

---

## EJEMPLO DE FLUJO PARA UN COLABORADOR

### Datos del Colaborador de Ejemplo
```
Colaborador: Juan Carlos Pérez López
DNI: 62345678
PersonaProgramaId: 1 (obtenido de T_PERSONA_PROGRAMA)
ProgramaEMOId: 1 (Programa Operativo)
PerfilTipoEMOId: 1 (Cajero - INGRESO)
```

### PASO 1: Obtener Información Base

#### 1.1. Obtener datos del colaborador
```sql
SELECT
    PP.Id AS PersonaProgramaId,
    PP.ProgramaEMOId,
    PP.PerfilTipoEMOId,
    P.Id AS PersonaId,
    P.Nombres,
    P.Apellidos,
    P.NDocumentoIdentidad,
    P.Edad,
    P.Genero,
    P.GrupoSanguineo,
    P.Rh,
    PTE.TipoEMO,
    PO.Nombre AS NombrePerfil
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
WHERE PP.Id = 1;  -- PersonaProgramaId del colaborador

-- RESULTADO:
-- PersonaProgramaId: 1
-- Nombres: Juan Carlos
-- Apellidos: Pérez López
-- DNI: 62345678
-- TipoEMO: INGRESO
-- NombrePerfil: Cajero
```

#### 1.2. Obtener exámenes requeridos para el perfil
```sql
-- Usar procedimiento existente
EXEC S_SEL_PROTOCOLOS_EMO
    @p_PerfilOcupacionalId = 1,  -- Cajero (obtenido de PTE.PerfilOcupacionalId)
    @p_TipoEMOId = NULL;  -- O el ID correspondiente a "INGRESO"

-- Alternativa con query directa:
SELECT
    PRO.Id AS ProtocoloId,
    PRO.ExamenMedicoId,
    EM.Nombre AS NombreExamen,
    PRO.EsRequerido
FROM T_PROTOCOLO_EMO PRO
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PRO.PerfilTipoEMOId = PTE.Id
INNER JOIN T_EXAMEN_MEDICO_OCUPACIONAL EM ON PRO.ExamenMedicoId = EM.Id
WHERE PTE.Id = 1  -- PerfilTipoEMOId del colaborador
  AND PRO.EsRequerido = 1  -- Solo exámenes obligatorios
  AND PRO.Estado = '1';

-- RESULTADO (ejemplo):
-- Examen 1: Hemograma Completo
-- Examen 5: Radiografía de Tórax PA
-- Examen 12: Examen Oftalmológico
-- Examen 22: Evaluación Psicológica
-- Total: 4 exámenes requeridos
```

#### 1.3. Obtener un doctor aleatorio
```sql
-- Seleccionar doctor aleatoriamente
SELECT TOP 1
    Id AS DoctorId,
    Nombres + ' ' + Apellidos AS NombreCompleto,
    Codigo AS CodigoCMP,
    Especialidad
FROM T_DOCTOR
WHERE Estado = 'ACTIVO'
ORDER BY NEWID();  -- Ordenar aleatoriamente

-- RESULTADO (ejemplo):
-- DoctorId: 1
-- NombreCompleto: Carlos Eduardo Ramírez García
-- CodigoCMP: CMP12345
-- Especialidad: Medicina Ocupacional
```

### PASO 2: Crear Registro T_EMO

⚠️ **PROBLEMA IDENTIFICADO:** La tabla T_EMO actualmente usa `ColaboradorId` que referencia a T_COLABORADOR (tabla obsoleta según claude.md).

**SOLUCIÓN TEMPORAL:** Usar `PersonaProgramaId` en lugar de `ColaboradorId` si la tabla ya fue actualizada, o crear la relación correcta.

```sql
-- ⚠️ ESTO ASUME QUE T_EMO FUE ACTUALIZADO PARA USAR PersonaProgramaId
INSERT INTO T_EMO (PersonaProgramaId, FechaCreacion, Estado)
VALUES (
    1,           -- PersonaProgramaId del colaborador
    GETDATE(),   -- Fecha de creación
    '1'          -- Estado activo
);

-- Obtener el ID generado
DECLARE @EMOId INT = SCOPE_IDENTITY();
-- RESULTADO: @EMOId = 1
```

### PASO 3: ETAPA 1 - Insertar Datos Básicos del Certificado (SIN PDF)

```sql
-- Generar código único
DECLARE @CodigoCertificado NVARCHAR(50);
DECLARE @AnioActual INT = YEAR(GETDATE());
DECLARE @NumeroSecuencial INT;

-- Obtener siguiente número secuencial
SELECT @NumeroSecuencial = ISNULL(MAX(CAST(RIGHT(Codigo, 6) AS INT)), 0) + 1
FROM T_EMO_CERTIFICADO
WHERE Codigo LIKE 'EMO-' + CAST(@AnioActual AS VARCHAR) + '-%';

SET @CodigoCertificado = 'EMO-' + CAST(@AnioActual AS VARCHAR) + '-' + RIGHT('000000' + CAST(@NumeroSecuencial AS VARCHAR), 6);
-- RESULTADO: @CodigoCertificado = "EMO-2025-000001"

-- Generar fechas
DECLARE @FechaEvaluacion DATETIME;
DECLARE @FechaCaducidad DATETIME;
DECLARE @DiasAtras INT = CAST((RAND() * 180) AS INT);  -- 0 a 6 meses atrás
DECLARE @AniosVigencia INT = 2 + CAST((RAND() * 2) AS INT);  -- 2 o 3 años

SET @FechaEvaluacion = DATEADD(DAY, -@DiasAtras, GETDATE());
SET @FechaCaducidad = DATEADD(YEAR, @AniosVigencia, @FechaEvaluacion);

-- Insertar certificado CON datos básicos, SIN RutaArchivoPDF
INSERT INTO T_EMO_CERTIFICADO (
    Codigo,
    EMOId,
    DoctorId,
    RutaArchivoPDF,        -- ❌ NULL para Etapa 1
    NombreArchivo,         -- ❌ NULL para Etapa 1
    TipoEvaluacion,
    TipoResultado,
    PuestoAlQuePostula,
    PuestoActual,
    Observaciones,
    Restricciones,
    FechaEvaluacion,
    FechaCaducidad,
    FechaGeneracion,       -- ❌ NULL para Etapa 1
    Estado
) VALUES (
    @CodigoCertificado,            -- 'EMO-2025-000001'
    @EMOId,                        -- 1
    1,                             -- DoctorId obtenido aleatoriamente
    NULL,                          -- ❌ SIN PDF EN ETAPA 1
    NULL,                          -- ❌ SIN nombre de archivo
    'INGRESO',                     -- Tipo de evaluación (del perfil)
    'APTO',                        -- Resultado (aleatorio: APTO, APTO CON RESTRICCIONES, NO APTO)
    'Cajero',                      -- Puesto al que postula (NombrePerfil)
    NULL,                          -- Puesto actual (NULL para INGRESO)
    'Sin observaciones',           -- Observaciones (puede variar)
    NULL,                          -- Restricciones (NULL o texto)
    @FechaEvaluacion,              -- Ej: 2024-10-15
    @FechaCaducidad,               -- Ej: 2026-10-15 (2 años después)
    NULL,                          -- ❌ SIN fecha de generación en Etapa 1
    'ACTIVO'                       -- Estado
);

-- RESULTADO: Certificado creado con ID 1, SOLO datos básicos, SIN PDF
```

**ESTADO DESPUÉS DE ETAPA 1:**
- ✅ Registro en T_EMO creado
- ✅ Registro en T_EMO_CERTIFICADO creado con datos básicos
- ❌ RutaArchivoPDF = NULL
- ❌ Sin exámenes marcados en T_RESULTADO_EMO
- **Estado del certificado:** "Sin URL"

---

### PASO 4: ETAPA 2 - Marcar Exámenes como Completados

Esta etapa puede ser:
- **Completa**: Marcar TODOS los exámenes requeridos
- **Parcial**: Marcar solo ALGUNOS exámenes requeridos
- **Omitida**: No marcar ningún examen (quedarse solo en Etapa 1)

#### Ejemplo: Marcar 2 de 4 exámenes como completados (PARCIAL)

```sql
-- Supongamos que el perfil requiere 4 exámenes (IDs: 1, 5, 12, 22)
-- Vamos a marcar solo 2 como completados: 1 y 5

-- Examen 1: Hemograma Completo
INSERT INTO T_RESULTADO_EMO (
    EMOId,
    ExamenMedicoId,
    Completado,
    FechaRealizacion,
    Resultado,
    Estado
) VALUES (
    @EMOId,                        -- 1
    1,                             -- ExamenMedicoId: Hemograma
    1,                             -- ✅ Marcado como completado
    @FechaEvaluacion,              -- Misma fecha de evaluación
    'Normal',                      -- Resultado del examen
    '1'                            -- Estado activo
);

-- Examen 5: Radiografía de Tórax PA
INSERT INTO T_RESULTADO_EMO (
    EMOId,
    ExamenMedicoId,
    Completado,
    FechaRealizacion,
    Resultado,
    Estado
) VALUES (
    @EMOId,                        -- 1
    5,                             -- ExamenMedicoId: Radiografía
    1,                             -- ✅ Marcado como completado
    @FechaEvaluacion,
    'Sin hallazgos patológicos',
    '1'
);

-- Exámenes 12 y 22: NO se insertan registros (quedan pendientes)
```

**ESTADO DESPUÉS DE ETAPA 2 PARCIAL:**
- ✅ 2 de 4 exámenes marcados como completados
- ❌ Certificado AÚN NO puede tener PDF (faltan exámenes)
- **Estado del certificado:** "Sin URL" (porque no tiene todos los exámenes)

#### Ejemplo: Marcar TODOS los exámenes (COMPLETA)

```sql
-- Marcar también los exámenes 12 y 22

INSERT INTO T_RESULTADO_EMO (EMOId, ExamenMedicoId, Completado, FechaRealizacion, Resultado, Estado)
VALUES (@EMOId, 12, 1, @FechaEvaluacion, 'Normal', '1');

INSERT INTO T_RESULTADO_EMO (EMOId, ExamenMedicoId, Completado, FechaRealizacion, Resultado, Estado)
VALUES (@EMOId, 22, 1, @FechaEvaluacion, 'Apto para el cargo', '1');
```

**ESTADO DESPUÉS DE ETAPA 2 COMPLETA:**
- ✅ 4 de 4 exámenes marcados como completados
- ✅ Certificado LISTO para generar PDF
- ❌ Aún no tiene PDF generado
- **Estado del certificado:** "Sin URL" (hasta que se genere el PDF)

---

### PASO 5: ETAPA 3 - Generar Certificado (Asignar PDF)

**CONDICIÓN:** Solo se ejecuta si:
1. Todos los datos básicos están completos (Etapa 1 ✅)
2. Todos los exámenes requeridos están marcados (Etapa 2 ✅)

```sql
-- Validar que todos los exámenes están completos
DECLARE @ExamenesRequeridos INT;
DECLARE @ExamenesCompletados INT;

-- Contar exámenes requeridos
SELECT @ExamenesRequeridos = COUNT(*)
FROM T_PROTOCOLO_EMO PRO
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PRO.PerfilTipoEMOId = PTE.Id
WHERE PTE.Id = 1  -- PerfilTipoEMOId del colaborador
  AND PRO.EsRequerido = 1
  AND PRO.Estado = '1';
-- RESULTADO: @ExamenesRequeridos = 4

-- Contar exámenes completados
SELECT @ExamenesCompletados = COUNT(*)
FROM T_RESULTADO_EMO
WHERE EMOId = @EMOId
  AND Completado = 1
  AND Estado = '1';
-- RESULTADO: @ExamenesCompletados = 4 (si están todos)

-- Si están todos completos, generar PDF
IF @ExamenesCompletados >= @ExamenesRequeridos
BEGIN
    DECLARE @RutaPDF NVARCHAR(500);
    DECLARE @NombreArchivo NVARCHAR(300);
    DECLARE @FechaGeneracion DATETIME = GETDATE();

    SET @NombreArchivo = @CodigoCertificado + '_' + REPLACE(P.NDocumentoIdentidad, ' ', '') + '.pdf';
    SET @RutaPDF = 'https://storage.medivalle.com/certificados/' + @NombreArchivo;
    -- RESULTADO: 'https://storage.medivalle.com/certificados/EMO-2025-000001_62345678.pdf'

    -- Actualizar certificado con PDF
    UPDATE T_EMO_CERTIFICADO
    SET RutaArchivoPDF = @RutaPDF,
        NombreArchivo = @NombreArchivo,
        FechaGeneracion = @FechaGeneracion
    WHERE EMOId = @EMOId;
END
```

**ESTADO DESPUÉS DE ETAPA 3:**
- ✅ Certificado COMPLETO con PDF generado
- ✅ RutaArchivoPDF tiene valor
- ✅ FechaGeneracion registrada
- **Estado del certificado:**
  - Si `GETDATE() > FechaCaducidad`: "Vencido"
  - Si `DATEDIFF(DAY, GETDATE(), FechaCaducidad) < 60`: "Por vencer"
  - Si `DATEDIFF(DAY, GETDATE(), FechaCaducidad) >= 60`: "Vigente"

---

## RESUMEN DE VARIABILIDAD

Para simular datos realistas, aplicar estas distribuciones:

### Distribución de Colaboradores por Etapa

```
TOTAL COLABORADORES: 120 (20 por cada uno de los 6 programas)

Distribución sugerida:
- 20% (24 colaboradores): Solo Etapa 1 (datos básicos, sin exámenes)
- 15% (18 colaboradores): Etapa 1 + exámenes parciales (50% de exámenes)
- 25% (30 colaboradores): Etapa 1 + todos exámenes, SIN PDF (no generado aún)
- 40% (48 colaboradores): Etapa 1 + Etapa 2 + Etapa 3 COMPLETA (con PDF)
```

### Distribución de Estados (solo para los con PDF)

De los 48 colaboradores con PDF (40%):
- 60% (29 colaboradores): Certificado VIGENTE (vence en más de 2 meses)
- 25% (12 colaboradores): Certificado POR VENCER (vence en menos de 2 meses)
- 15% (7 colaboradores): Certificado VENCIDO (ya caducó)

### Variación de Datos

**Tipos de Resultado:**
- 80%: "APTO"
- 15%: "APTO CON RESTRICCIONES"
- 5%: "NO APTO"

**Restricciones (solo para "APTO CON RESTRICCIONES"):**
- "No cargar peso mayor a 20kg"
- "No trabajar en alturas"
- "Uso obligatorio de lentes correctivos"
- "Evitar exposición prolongada a ruidos fuertes"

**Observaciones:**
- 70%: "Sin observaciones" o "Evaluación satisfactoria"
- 20%: Observaciones médicas generales ("Mantener control de presión arterial", "Hidratación adecuada")
- 10%: Observaciones específicas del puesto

**Doctores:**
- Rotar aleatoriamente entre los doctores disponibles en T_DOCTOR

---

## CONSULTAS DE VALIDACIÓN

### 1. Validar certificados creados
```sql
SELECT
    CERT.Codigo,
    P.Nombres + ' ' + P.Apellidos AS Colaborador,
    P.NDocumentoIdentidad AS DNI,
    PE.Nombre AS Programa,
    PO.Nombre AS Perfil,
    CERT.TipoEvaluacion,
    CERT.TipoResultado,
    CERT.FechaEvaluacion,
    CERT.FechaCaducidad,
    CASE
        WHEN CERT.RutaArchivoPDF IS NULL THEN 'Sin URL'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END AS EstadoCertificado,
    (SELECT COUNT(*) FROM T_RESULTADO_EMO WHERE EMOId = EMO.Id AND Completado = 1) AS ExamenesCompletados
FROM T_EMO_CERTIFICADO CERT
INNER JOIN T_EMO EMO ON CERT.EMOId = EMO.Id
INNER JOIN T_PERSONA_PROGRAMA PP ON EMO.PersonaProgramaId = PP.Id
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
ORDER BY CERT.Id;
```

### 2. Validar distribución de estados
```sql
SELECT
    CASE
        WHEN CERT.RutaArchivoPDF IS NULL THEN 'Sin URL'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END AS EstadoCertificado,
    COUNT(*) AS Cantidad
FROM T_EMO_CERTIFICADO CERT
WHERE CERT.Estado = 'ACTIVO'
GROUP BY
    CASE
        WHEN CERT.RutaArchivoPDF IS NULL THEN 'Sin URL'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END
ORDER BY Cantidad DESC;
```

### 3. Validar exámenes por colaborador
```sql
SELECT
    P.Nombres + ' ' + P.Apellidos AS Colaborador,
    CERT.Codigo AS CodigoCertificado,
    (SELECT COUNT(*) FROM T_PROTOCOLO_EMO PRO WHERE PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId AND PRO.EsRequerido = 1) AS ExamenesRequeridos,
    (SELECT COUNT(*) FROM T_RESULTADO_EMO WHERE EMOId = EMO.Id AND Completado = 1) AS ExamenesCompletados,
    CASE
        WHEN (SELECT COUNT(*) FROM T_RESULTADO_EMO WHERE EMOId = EMO.Id AND Completado = 1) >=
             (SELECT COUNT(*) FROM T_PROTOCOLO_EMO PRO WHERE PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId AND PRO.EsRequerido = 1)
        THEN 'COMPLETO'
        WHEN (SELECT COUNT(*) FROM T_RESULTADO_EMO WHERE EMOId = EMO.Id AND Completado = 1) > 0
        THEN 'PARCIAL'
        ELSE 'SIN EXÁMENES'
    END AS EstadoExamenes
FROM T_EMO_CERTIFICADO CERT
INNER JOIN T_EMO EMO ON CERT.EMOId = EMO.Id
INNER JOIN T_PERSONA_PROGRAMA PP ON EMO.PersonaProgramaId = PP.Id
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
ORDER BY EstadoExamenes, P.Apellidos;
```

---

## DECISIONES TÉCNICAS PENDIENTES

⚠️ **IMPORTANTE:** Antes de escribir el código SQL, necesitamos confirmar:

1. **Estructura de T_EMO:**
   - ¿Usa `ColaboradorId` (FK a T_COLABORADOR obsoleto)?
   - ¿O ya fue actualizado a `PersonaProgramaId` (FK a T_PERSONA_PROGRAMA)?
   - **Acción:** Consultar esquema real de la tabla

2. **Nombres exactos de campos:**
   - ¿T_EXAMEN_MEDICO_OCUPACIONAL existe o es T_EXAMEN_MEDICO?
   - Verificar nombres exactos en esquema

3. **Procedimientos:**
   - ¿Crear procedimientos S_INS_UPD_EMO_CERTIFICADO y S_INS_UPD_RESULTADO_EMO?
   - ¿O usar INSERT directo?
   - **Recomendación:** Usar INSERT directo para simplificar el script de datos de prueba

4. **Formato de código de certificado:**
   - ¿"EMO-2025-000001" es correcto?
   - ¿O prefieren otro formato?

---

## PRÓXIMOS PASOS

Una vez validadas las decisiones técnicas pendientes:

1. ✅ Crear script `insert-certificados.sql` con:
   - Cursor para recorrer todos los colaboradores en T_PERSONA_PROGRAMA
   - Lógica de variabilidad (20% solo datos, 15% parcial, 25% completo sin PDF, 40% con PDF)
   - Generación de fechas aleatorias pero realistas
   - Asignación aleatoria de doctores
   - Validación de exámenes requeridos vs completados
   - Resumen final con estadísticas

2. ✅ Actualizar `claude.md` con:
   - Documentación de tablas T_EMO, T_EMO_CERTIFICADO, T_RESULTADO_EMO
   - Flujo de generación de certificados
   - Estados posibles y su lógica

3. ✅ Probar el script y validar resultados

---

**Documento creado:** 2025-01-14
**Versión:** 1.0 - Borrador para revisión
