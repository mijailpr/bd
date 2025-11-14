# INSTRUCCIONES PARA INSERT-CERTIFICADOS.SQL

## ANÁLISIS PREVIO - ESTRUCTURA REAL

### Procedimientos Disponibles

**Para gestión de certificados:**
- ✅ `S_INS_UPD_CERTIFICADO_EMO` - Insertar/actualizar certificado EMO
- ✅ `S_SEL_EXAMENES_PERSONA_PROGRAMA` - Obtener exámenes del perfil con estado
- ✅ `S_INS_UPD_RESULTADO_EXAMEN` - Marcar exámenes como realizados
- ✅ `S_UPD_GUARDAR_PDF_CERTIFICADO` - Guardar ruta del PDF
- ✅ `S_SEL_DOCTORES` - Lista de doctores disponibles

### Estructura de Tablas REAL

#### T_CERTIFICADO_EMO
```sql
-- Tabla principal para certificados EMO
Campos:
- Id (INT, PK)
- PersonaProgramaId (INT, FK) → Referencia directa a T_PERSONA_PROGRAMA ✅
- DoctorId (INT, FK) → Referencia a T_DOCTOR
- Codigo (NVARCHAR(50)) → Código único del certificado
- Password (NVARCHAR(250)) → Contraseña para acceso al certificado
- PuestoAlQuePostula (NVARCHAR(200)) → Nombre del puesto
- PuestoActual (NVARCHAR(200)) → Puesto actual (puede ser NULL)
- TipoEvaluacion (NVARCHAR(100)) → "INGRESO", "PERIÓDICO", etc.
- TipoResultado (NVARCHAR(100)) → "APTO", "APTO CON RESTRICCIONES", "NO APTO"
- Observaciones (NVARCHAR(800)) → Observaciones médicas
- Conclusiones (NVARCHAR(800)) → Conclusiones del médico
- Restricciones (NVARCHAR(800)) → Restricciones médicas (puede ser NULL)
- FechaEvaluacion (DATETIME) → Fecha en que se realizó la evaluación
- FechaCaducidad (DATETIME) → Fecha de vencimiento (FechaEvaluacion + 2+ años)
- FechaGeneracion (DATETIME) → Fecha en que se generó el PDF
- RutaArchivoPDF (NVARCHAR(500)) → URL del PDF generado (vacío si no generado)
- NombreArchivo (NVARCHAR) → Nombre del archivo PDF
- Estado (CHAR(1)) → '1' = activo, '0' = inactivo
- FechaCreacion (DATETIME)
- FechaAccion (DATETIME)
```

#### T_RESULTADO_EMO
```sql
-- Tabla para marcar exámenes como realizados
Campos:
- Id (INT, PK)
- PersonaProgramaId (INT, FK) → Referencia a T_PERSONA_PROGRAMA
- ProtocoloEMOId (INT, FK) → Referencia a T_PROTOCOLO_EMO
- Realizado (BIT) → 1 = realizado, 0 = pendiente
- Estado (CHAR(1)) → '1' = activo
- FechaCreacion (DATETIME)
- FechaAccion (DATETIME)
```

---

## PROCEDIMIENTOS ALMACENADOS - DOCUMENTACIÓN

### 1. S_INS_UPD_CERTIFICADO_EMO

**Propósito:** Insertar o actualizar certificado EMO con datos básicos (Etapa 1)

**Parámetros:**
```sql
@p_Id INT = NULL,                          -- NULL para INSERT, ID para UPDATE
@p_PersonaProgramaId INT,                  -- REQUERIDO
@p_DoctorId INT = NULL,
@p_Codigo NVARCHAR(50) = NULL,
@p_Password NVARCHAR(250) = NULL,          -- DNI de la persona
@p_PuestoAlQuePostula NVARCHAR(200) = NULL,
@p_PuestoActual NVARCHAR(200) = NULL,
@p_TipoEvaluacion NVARCHAR(100) = NULL,
@p_TipoResultado NVARCHAR(100) = NULL,
@p_Observaciones NVARCHAR(800) = NULL,
@p_Conclusiones NVARCHAR(800) = NULL,
@p_Restricciones NVARCHAR(800) = NULL,
@p_FechaEvaluacion DATETIME = NULL,
@p_FechaCaducidad DATETIME = NULL,
-- Parámetros opcionales para actualizar persona
@p_Nombres NVARCHAR(100) = NULL,
@p_Apellidos NVARCHAR(100) = NULL,
@p_Edad INT = NULL,
@p_Genero NVARCHAR(20) = NULL,
@p_GrupoSanguineo NVARCHAR(10) = NULL,
@p_Rh NVARCHAR(10) = NULL
```

**Retorna:** 1 = éxito, -1 = error

**Notas:**
- Inserta con RutaArchivoPDF = '' (vacío, no NULL)
- Actualiza datos de persona si se proporcionan

---

### 2. S_SEL_EXAMENES_PERSONA_PROGRAMA

**Propósito:** Obtener exámenes requeridos del perfil con estado de realización

**Parámetros:**
```sql
@p_PersonaProgramaId INT
```

**Retorna:** Recordset con:
- ProtocoloEMOId
- ExamenId
- NombreExamen
- EsRequerido
- Realizado (0 o 1)
- Solo exámenes con EsRequerido = 1

---

### 3. S_INS_UPD_RESULTADO_EXAMEN

**Propósito:** Marcar un examen como realizado o pendiente (Etapa 2)

**Parámetros:**
```sql
@p_PersonaProgramaId INT,
@p_ProtocoloEMOId INT,
@p_Realizado BIT                           -- 1 = realizado, 0 = pendiente
```

**Retorna:**
- 1 = insertado
- 2 = actualizado
- 0 = sin cambios
- -1 = error general
- -2 = PersonaPrograma no existe
- -3 = Protocolo no válido

**Validaciones:**
- Valida que PersonaProgramaId existe y está activo
- Valida que ProtocoloEMOId corresponde al PerfilTipoEMO del colaborador
- Evita duplicados (hace UPDATE si ya existe)

---

### 4. S_UPD_GUARDAR_PDF_CERTIFICADO

**Propósito:** Guardar la ruta del PDF generado (Etapa 3)

**Parámetros:**
```sql
@p_PersonaProgramaId INT,
@p_RutaArchivoPDF NVARCHAR(500)
```

**Retorna:** 1 = éxito, 0 = no encontrado, -1 = error

**Acción:**
- Actualiza RutaArchivoPDF
- Actualiza FechaGeneracion = GETDATE()

---

## FLUJO PARA GENERAR CERTIFICADOS

### Requisitos del Usuario

1. **3 ETAPAS:**
   - **Etapa 1 - Datos Básicos**: Usar `S_INS_UPD_CERTIFICADO_EMO` con RutaArchivoPDF vacío
   - **Etapa 2 - Exámenes Realizados**: Usar `S_INS_UPD_RESULTADO_EXAMEN` para cada examen
   - **Etapa 3 - Generación PDF**: Usar `S_UPD_GUARDAR_PDF_CERTIFICADO` solo si todos los exámenes están realizados

2. **VARIABILIDAD:**
   - 20% colaboradores: SOLO Etapa 1 (datos básicos, sin exámenes)
   - 15% colaboradores: Etapa 1 + algunos exámenes (parcial)
   - 25% colaboradores: Etapa 1 + todos exámenes, SIN PDF
   - 40% colaboradores: COMPLETO con PDF (Etapa 1 + 2 + 3)

3. **ESTADOS DEL CERTIFICADO:**
   - **Sin URL**: RutaArchivoPDF = '' (vacío)
   - **Emitido**: RutaArchivoPDF tiene contenido
   - **Vencido**: GETDATE() > FechaCaducidad
   - **Por vencer**: DATEDIFF(DAY, GETDATE(), FechaCaducidad) < 60
   - **Vigente**: DATEDIFF(DAY, GETDATE(), FechaCaducidad) >= 60

4. **REGLAS DE FECHAS:**
   - FechaEvaluacion: 0-180 días atrás (últimos 6 meses)
   - FechaCaducidad: FechaEvaluacion + 2 o 3 años
   - Para certificados vencidos: FechaEvaluacion más antigua

5. **OTROS:**
   - Código único: "EMO-" + AÑO + "-" + NÚMERO (6 dígitos)
   - Password: DNI de la persona
   - Doctor aleatorio por certificado

---

## EJEMPLO DE FLUJO PARA UN COLABORADOR

### Datos del Colaborador de Ejemplo
```
Colaborador: Juan Carlos Pérez López
DNI: 62345678
PersonaProgramaId: 1 (de T_PERSONA_PROGRAMA)
Perfil: Cajero - INGRESO
```

### PASO 1: Obtener Datos del Colaborador

```sql
SELECT
    PP.Id AS PersonaProgramaId,
    P.Nombres,
    P.Apellidos,
    P.NDocumentoIdentidad AS DNI,
    PO.Nombre AS NombrePerfil,
    PTE.TipoEMO
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
WHERE PP.Id = 1;
```

### PASO 2: Obtener Exámenes Requeridos

```sql
EXEC S_SEL_EXAMENES_PERSONA_PROGRAMA @p_PersonaProgramaId = 1;
-- Retorna: 4 exámenes requeridos (ProtocoloEMOIds: 1, 5, 12, 22)
```

### PASO 3: Obtener Doctor Aleatorio

```sql
SELECT TOP 1 Id AS DoctorId
FROM T_DOCTOR
WHERE Estado = 'ACTIVO'
ORDER BY NEWID();
-- Retorna: DoctorId = 1
```

### PASO 4: ETAPA 1 - Insertar Datos Básicos

```sql
-- Generar código único
DECLARE @AnioActual INT = YEAR(GETDATE());
DECLARE @CodigoCertificado NVARCHAR(50) = 'EMO-' + CAST(@AnioActual AS VARCHAR) + '-000001';
DECLARE @Password NVARCHAR(250) = '62345678';  -- DNI

-- Generar fechas
DECLARE @DiasAtras INT = 90;  -- 3 meses atrás
DECLARE @FechaEvaluacion DATETIME = DATEADD(DAY, -@DiasAtras, GETDATE());
DECLARE @FechaCaducidad DATETIME = DATEADD(YEAR, 2, @FechaEvaluacion);

-- Insertar certificado (Etapa 1)
EXEC S_INS_UPD_CERTIFICADO_EMO
    @p_Id = NULL,                                  -- Nuevo certificado
    @p_PersonaProgramaId = 1,
    @p_DoctorId = 1,
    @p_Codigo = @CodigoCertificado,
    @p_Password = @Password,
    @p_PuestoAlQuePostula = 'Cajero',
    @p_PuestoActual = NULL,                        -- INGRESO no tiene puesto actual
    @p_TipoEvaluacion = 'INGRESO',
    @p_TipoResultado = 'APTO',
    @p_Observaciones = 'Sin observaciones',
    @p_Conclusiones = 'Apto para el puesto de Cajero',
    @p_Restricciones = NULL,
    @p_FechaEvaluacion = @FechaEvaluacion,
    @p_FechaCaducidad = @FechaCaducidad;

-- RESULTADO: Certificado con ID 1, SIN PDF (RutaArchivoPDF = '')
```

**Estado después de Etapa 1:**
- ✅ Certificado creado en T_CERTIFICADO_EMO
- ❌ RutaArchivoPDF = '' (vacío)
- ❌ Sin exámenes en T_RESULTADO_EMO
- **Estado:** "Sin URL"

---

### PASO 5: ETAPA 2 - Marcar Exámenes (Opciones)

#### Opción A: PARCIAL (2 de 4 exámenes)

```sql
-- Marcar examen 1 (ProtocoloEMOId = 1)
EXEC S_INS_UPD_RESULTADO_EXAMEN
    @p_PersonaProgramaId = 1,
    @p_ProtocoloEMOId = 1,
    @p_Realizado = 1;

-- Marcar examen 5 (ProtocoloEMOId = 5)
EXEC S_INS_UPD_RESULTADO_EXAMEN
    @p_PersonaProgramaId = 1,
    @p_ProtocoloEMOId = 5,
    @p_Realizado = 1;

-- Exámenes 12 y 22: NO se marcan
```

**Estado:** 2 de 4 exámenes realizados → NO apto para PDF

#### Opción B: COMPLETO (4 de 4 exámenes)

```sql
-- Marcar los 4 exámenes
EXEC S_INS_UPD_RESULTADO_EXAMEN @p_PersonaProgramaId = 1, @p_ProtocoloEMOId = 1, @p_Realizado = 1;
EXEC S_INS_UPD_RESULTADO_EXAMEN @p_PersonaProgramaId = 1, @p_ProtocoloEMOId = 5, @p_Realizado = 1;
EXEC S_INS_UPD_RESULTADO_EXAMEN @p_PersonaProgramaId = 1, @p_ProtocoloEMOId = 12, @p_Realizado = 1;
EXEC S_INS_UPD_RESULTADO_EXAMEN @p_PersonaProgramaId = 1, @p_ProtocoloEMOId = 22, @p_Realizado = 1;
```

**Estado:** 4 de 4 exámenes realizados → LISTO para PDF

---

### PASO 6: ETAPA 3 - Generar PDF (Solo si todos los exámenes están)

```sql
-- Validar que todos los exámenes están realizados
DECLARE @ExamenesRequeridos INT;
DECLARE @ExamenesRealizados INT;

-- Obtener exámenes requeridos del perfil
SELECT @ExamenesRequeridos = COUNT(*)
FROM T_PROTOCOLO_EMO PRO
INNER JOIN T_PERSONA_PROGRAMA PP ON PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId
WHERE PP.Id = 1 AND PRO.EsRequerido = 1 AND PRO.Estado = '1';

-- Obtener exámenes realizados
SELECT @ExamenesRealizados = COUNT(*)
FROM T_RESULTADO_EMO
WHERE PersonaProgramaId = 1 AND Realizado = 1 AND Estado = '1';

-- Si están todos, generar PDF
IF @ExamenesRealizados >= @ExamenesRequeridos
BEGIN
    DECLARE @RutaPDF NVARCHAR(500);
    DECLARE @DNI NVARCHAR(20) = '62345678';

    SET @RutaPDF = 'https://storage.medivalle.com/certificados/EMO-2025-000001_' + @DNI + '.pdf';

    EXEC S_UPD_GUARDAR_PDF_CERTIFICADO
        @p_PersonaProgramaId = 1,
        @p_RutaArchivoPDF = @RutaPDF;
END
```

**Estado después de Etapa 3:**
- ✅ Certificado COMPLETO con PDF
- ✅ RutaArchivoPDF = 'https://...'
- ✅ FechaGeneracion actualizada
- **Estado:** Vigente / Por vencer / Vencido (según FechaCaducidad)

---

## DISTRIBUCIÓN DE VARIABILIDAD

### Sobre 120 Colaboradores (20 por programa × 6 programas):

```
- 24 colaboradores (20%): Solo Etapa 1 (sin exámenes)
- 18 colaboradores (15%): Etapa 1 + 50% de exámenes
- 30 colaboradores (25%): Etapa 1 + 100% exámenes, SIN PDF
- 48 colaboradores (40%): COMPLETO con PDF
```

### Estados de Certificados con PDF (48 colaboradores):

```
- 29 certificados (60%): VIGENTE (vence en 60+ días)
- 12 certificados (25%): POR VENCER (vence en <60 días)
- 7 certificados (15%): VENCIDO (ya caducó)
```

### Datos Variables:

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
- "Sin observaciones"
- "Evaluación satisfactoria"
- "Mantener control de presión arterial"
- "Hidratación adecuada durante jornada"

**Conclusiones:**
- "Apto para el puesto de [NombrePerfil]"
- "Apto con restricciones para el puesto de [NombrePerfil]"
- "No apto para el puesto de [NombrePerfil]"

---

## CONSULTAS DE VALIDACIÓN

### 1. Resumen de certificados por estado

```sql
SELECT
    CASE
        WHEN CERT.RutaArchivoPDF = '' THEN 'Sin URL'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END AS EstadoCertificado,
    COUNT(*) AS Cantidad
FROM T_CERTIFICADO_EMO CERT
WHERE CERT.Estado = '1'
GROUP BY
    CASE
        WHEN CERT.RutaArchivoPDF = '' THEN 'Sin URL'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END
ORDER BY Cantidad DESC;
```

### 2. Detalle de certificados con exámenes

```sql
SELECT
    CERT.Codigo,
    P.Nombres + ' ' + P.Apellidos AS Colaborador,
    PE.Nombre AS Programa,
    PO.Nombre AS Perfil,
    CERT.TipoEvaluacion,
    CERT.TipoResultado,
    (SELECT COUNT(*)
     FROM T_PROTOCOLO_EMO PRO
     WHERE PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId
       AND PRO.EsRequerido = 1 AND PRO.Estado = '1') AS ExamenesRequeridos,
    (SELECT COUNT(*)
     FROM T_RESULTADO_EMO RE
     WHERE RE.PersonaProgramaId = PP.Id
       AND RE.Realizado = 1 AND RE.Estado = '1') AS ExamenesRealizados,
    CASE
        WHEN CERT.RutaArchivoPDF = '' THEN 'Sin PDF'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END AS EstadoCertificado
FROM T_CERTIFICADO_EMO CERT
INNER JOIN T_PERSONA_PROGRAMA PP ON CERT.PersonaProgramaId = PP.Id
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
WHERE CERT.Estado = '1'
ORDER BY EstadoCertificado, P.Apellidos;
```

---

**Documento actualizado:** 2025-01-14
**Versión:** 2.0 - Con procedimientos reales
