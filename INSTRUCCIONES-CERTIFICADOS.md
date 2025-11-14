# INSTRUCCIONES COMPLETAS PARA GENERACIÓN DE CERTIFICADOS EMO

**Versión:** 3.0 - Lógica Completa con 3 Tipos y Variabilidad Total
**Fecha:** 2025-01-14
**Script:** `4. Insertar Certificados.sql`

---

## 📋 RESUMEN EJECUTIVO

Este documento define la lógica completa para generar certificados EMO con **máxima variabilidad** que simula un entorno real de trabajo.

### Distribución General:
- **10%** - TIPO 0: Sin certificado (colaboradores nuevos o sin proceso iniciado)
- **40%** - TIPO 1: Certificado SIN PDF (variabilidad en datos y exámenes)
- **50%** - TIPO 2: Certificado CON PDF (datos completos + exámenes completos + validaciones)

---

## 🎯 TIPO 0: SIN CERTIFICADO (10%)

### Características:
- ❌ NO se crea registro en `T_CERTIFICADO_EMO`
- ❌ NO se registran exámenes en `T_RESULTADO_EMO`
- 💡 El colaborador existe en `T_PERSONA_PROGRAMA` pero nunca inició su proceso EMO

### Implementación:
```sql
-- Random 0-100
IF @RandomTipo < 10
BEGIN
    -- Skip - No hacer nada, continuar al siguiente colaborador
    CONTINUE;
END
```

---

## 📄 TIPO 1: CERTIFICADO SIN PDF (40%)

Certificados en proceso, con datos completos pero diferentes niveles de exámenes realizados.

**REGLA IMPORTANTE:** TODOS los certificados Tipo 1 tienen datos completos. La diferencia está SOLO en el porcentaje de exámenes realizados.

### Sub-Tipos (Distribución dentro del 40%):

#### **1A - Datos Completos + Sin Exámenes (25% del Tipo 1 = 10% total)**

**Campos completos:**
```sql
- Todos los datos del certificado (ver sección "Generación de Datos Completos")
- DoctorId: ✅ Asignado aleatoriamente
- TipoEvaluacion: ✅ Generado aleatoriamente
- TipoResultado: ✅ Generado aleatoriamente
- Puestos: ✅ UNO de dos (PuestoAlQuePostula O PuestoActual)
- Observaciones: ⚪ 60% probabilidad
- Conclusiones: ⚪ 70% probabilidad
- Restricciones: ⚪ Condicional según resultado
- Fechas: ✅ FechaEvaluacion y FechaCaducidad
```

**Exámenes:**
- ❌ 0% de exámenes realizados

**PDF:**
- ❌ RutaArchivoPDF = vacío/NULL

---

#### **1B - Datos Completos + Exámenes Parciales Bajo (25% del Tipo 1 = 10% total)**

**Campos completos:**
```sql
- Todos los datos del certificado (ver sección "Generación de Datos Completos")
- Fechas: ✅ FechaEvaluacion y FechaCaducidad
```

**Exámenes:**
- ⚠️ PARCIALES BAJO: 20-40% aleatorio de los exámenes requeridos

**PDF:**
- ❌ RutaArchivoPDF = vacío/NULL

---

#### **1C - Datos Completos + Exámenes Parciales Medio (25% del Tipo 1 = 10% total)**

**Campos completos:**
```sql
- Todos los datos del certificado (ver sección "Generación de Datos Completos")
- Fechas: ✅ FechaEvaluacion y FechaCaducidad
```

**Exámenes:**
- ⚠️ PARCIALES MEDIO: 50-70% aleatorio de los exámenes requeridos

**PDF:**
- ❌ RutaArchivoPDF = vacío/NULL

---

#### **1D - Datos Completos + Todos los Exámenes (25% del Tipo 1 = 10% total)**

**Campos completos:**
```sql
- Todos los datos del certificado (ver sección "Generación de Datos Completos")
- Fechas: ✅ FechaEvaluacion y FechaCaducidad
```

**Exámenes:**
- ✅ TODOS los exámenes realizados (100%)

**PDF:**
- ❌ RutaArchivoPDF = vacío/NULL (NO SE GENERA PDF)

---

## ✅ TIPO 2: CERTIFICADO CON PDF (50%)

Certificados completos con validaciones obligatorias.

### Características:

**Datos:**
- ✅ Todos los campos completos (OBLIGATORIO)
- ✅ Fechas completas (OBLIGATORIO)

**Exámenes:**
- ✅ TODOS los exámenes realizados (OBLIGATORIO - 100%)

**PDF:**
- ✅ RutaArchivoPDF: `certificados/{personaprogramaid}/certificado.pdf`
- ✅ Validaciones antes de generar PDF

**Estados por Fechas:**
- 60% → Vigente (>60 días restantes)
- 20% → Por vencer (0-60 días restantes)
- 20% → Vencido (fecha ya pasó)

---

## 🎲 GENERACIÓN DE DATOS COMPLETOS

Para TIPO 1 (sub-tipos B, C, D) y TIPO 2.

### Campos Obligatorios:

#### 1. Puestos (OBLIGATORIO uno de dos, NUNCA ambos)

```sql
-- Random 0-1
IF @RandomPuesto = 0
BEGIN
    @p_PuestoAlQuePostula = @NombrePerfil  -- El perfil asignado
    @p_PuestoActual = NULL
END
ELSE
BEGIN
    @p_PuestoActual = @NombrePerfil
    @p_PuestoAlQuePostula = NULL
END
```

**IMPORTANTE:** Uno de los dos DEBE tener valor, el otro DEBE ser NULL.

---

#### 2. TipoEvaluacion (OBLIGATORIO)

```sql
Random 0-100:
├─ < 40 (40%) → 'examenPreocupacional'
├─ 40-85 (45%) → 'examenOcupacionalAnual'
├─ 85-95 (10%) → 'examenOcupacionalDeRetiro'
└─ >= 95 (5%) → 'otros'
```

---

#### 3. TipoResultado (OBLIGATORIO)

```sql
Random 0-100:
├─ < 80 (80%) → 'apto'
├─ 80-95 (15%) → 'aptoConRestricciones'
├─ 95-99 (4%) → 'noApto'
└─ >= 99 (1%) → 'noAplica'
```

---

#### 4. Restricciones (CONDICIONAL)

```sql
IF TipoResultado = 'aptoConRestricciones':
    → OBLIGATORIO: Seleccionar una restricción aleatoria:
       - 'No cargar peso mayor a 20kg'
       - 'No trabajar en alturas'
       - 'Uso obligatorio de lentes correctivos'
       - 'Evitar exposición prolongada a ruidos fuertes'

ELSE IF TipoResultado = 'noApto':
    → OBLIGATORIO: 'No apto para el puesto evaluado'

ELSE:
    → Random (20% tiene restricción, 80% NULL)
```

---

#### 5. Observaciones (OPCIONAL - 60%)

```sql
Random 0-100:
├─ < 60 (60%) → Seleccionar una observación:
│                - 'Sin observaciones'
│                - 'Evaluación satisfactoria'
│                - 'Mantener hábitos saludables'
│                - 'Requiere evaluación adicional'
│
└─ >= 60 (40%) → NULL
```

---

#### 6. Conclusiones (OPCIONAL - 70%)

```sql
Random 0-100:
├─ < 70 (70%) → Generar según resultado:
│                - Si apto: 'Apto para el puesto de {NombrePerfil}'
│                - Si aptoConRestricciones: 'Apto con restricciones para el puesto de {NombrePerfil}'
│                - Si noApto: 'No apto para el puesto de {NombrePerfil}'
│
└─ >= 70 (30%) → NULL
```

---

#### 7. DoctorId (OBLIGATORIO)

```sql
-- Seleccionar doctor aleatorio de la tabla temporal @Doctores
SELECT TOP 1 @DoctorId = DoctorId
FROM @Doctores
ORDER BY NEWID();
```

---

#### 8. Código y Password (SIEMPRE OBLIGATORIOS)

```sql
-- Código único secuencial
@CodigoCertificado = 'EMO-' + CAST(@AnioActual AS VARCHAR) + '-' + RIGHT('000000' + CAST(@CodigoSecuencial AS VARCHAR), 6)
-- Ejemplo: EMO-2025-000001

-- Password = DNI de la persona
@Password = @DNI
```

---

## 📅 GENERACIÓN DE FECHAS

**Regla fija:** `FechaCaducidad = FechaEvaluacion + 2 años (730 días)`

### Para TIPO 1 (con datos completos):

```sql
-- Fechas recientes variadas
@DiasAtras = Random 0-365  -- Último año
@FechaEvaluacion = GETDATE() - @DiasAtras días
@FechaCaducidad = @FechaEvaluacion + 730 días
```

### Para TIPO 2 (con PDF):

La fecha de evaluación varía para generar diferentes estados:

#### **Estado: VENCIDO (20%)**
```sql
-- Para que esté vencido: FechaEvaluacion + 730 días < HOY
@DiasAtras = 731-1095  -- Vencido hace 1 día hasta 1 año
@FechaEvaluacion = GETDATE() - @DiasAtras
@FechaCaducidad = @FechaEvaluacion + 730 días
-- Resultado: FechaCaducidad < HOY (ya venció)
```

#### **Estado: POR VENCER (20%)**
```sql
-- Para que le queden 0-60 días
@DiasAtras = 670-730  -- Evaluación hace 670-730 días
@FechaEvaluacion = GETDATE() - @DiasAtras
@FechaCaducidad = @FechaEvaluacion + 730 días
-- Resultado: Faltan 0-60 días para vencer
```

#### **Estado: VIGENTE (60%)**
```sql
-- Para que le queden más de 60 días
@DiasAtras = 0-669  -- Evaluación hace 0-669 días
@FechaEvaluacion = GETDATE() - @DiasAtras
@FechaCaducidad = @FechaEvaluacion + 730 días
-- Resultado: Faltan más de 60 días
```

---

## 🧬 DATOS DE PERSONA (Opcionales pero recomendados)

Estos datos se pueden actualizar al crear el certificado:

### Genero:
```sql
Random 0-1:
├─ 0 (50%) → 'M'
└─ 1 (50%) → 'F'
```

### RH:
```sql
Random 0-100:
├─ < 85 (85%) → 'Positivo'
└─ >= 85 (15%) → 'Negativo'
```

### GrupoSanguineo:
```sql
Random 0-100:
├─ < 45 (45%) → 'O'
├─ 45-80 (35%) → 'A'
├─ 80-95 (15%) → 'B'
└─ >= 95 (5%) → 'AB'
```

**NOTA:** NO usar valor '--' (es valor inválido en la BD)

---

## ✔️ VALIDACIONES OBLIGATORIAS PARA PDF

Antes de generar PDF (TIPO 2), validar:

### 1. Datos del Certificado Completos

```sql
IF @DoctorId IS NULL OR @CodigoCertificado IS NULL OR
   @TipoResultado IS NULL OR @FechaEvaluacion IS NULL OR
   @FechaCaducidad IS NULL
BEGIN
    -- NO generar PDF
    -- Mostrar advertencia
END
```

### 2. TODOS los Exámenes Realizados

```sql
-- Contar exámenes requeridos
SELECT @ExamenesRequeridos = COUNT(*)
FROM T_PROTOCOLO_EMO PRO
WHERE PRO.PerfilTipoEMOId = @PerfilTipoEMOId
  AND PRO.EsRequerido = 1
  AND PRO.Estado = '1';

-- Contar exámenes realizados
SELECT @ExamenesRealizados = COUNT(*)
FROM T_RESULTADO_EMO RE
INNER JOIN T_PROTOCOLO_EMO PRO ON RE.ProtocoloEMOId = PRO.Id
WHERE RE.PersonaProgramaId = @PersonaProgramaId
  AND RE.Realizado = 1
  AND RE.Estado = '1'
  AND PRO.EsRequerido = 1;

-- Validar
IF @ExamenesRequeridos > @ExamenesRealizados
BEGIN
    -- NO generar PDF
    -- Mostrar cuántos faltan
END
```

### 3. Generar PDF Solo si Pasa Validaciones

```sql
IF @PuedeGenerarPDF = 1
BEGIN
    DECLARE @RutaPDF NVARCHAR(500);
    SET @RutaPDF = 'certificados/' + CAST(@PersonaProgramaId AS VARCHAR) + '/certificado.pdf';

    EXEC S_UPD_GUARDAR_PDF_CERTIFICADO
        @p_PersonaProgramaId = @PersonaProgramaId,
        @p_RutaArchivoPDF = @RutaPDF;
END
```

---

## 🔄 FLUJO COMPLETO DE GENERACIÓN

```
Para cada colaborador en T_PERSONA_PROGRAMA:
│
├─ 1. Generar Random 0-100
│  │
│  ├─ < 10 (10%) → TIPO 0: Skip (Continue)
│  │
│  ├─ 10-50 (40%) → TIPO 1: SIN PDF
│  │                        │
│  │                        ├─ Generar Random sub-tipo 0-100:
│  │                        │  ├─ < 25 → 1A: Completo + 0% exámenes
│  │                        │  │         - Generar datos completos
│  │                        │  │         - Insertar certificado
│  │                        │  │         - NO insertar exámenes (0%)
│  │                        │  │
│  │                        │  ├─ 25-50 → 1B: Completo + 20-40% exámenes
│  │                        │  │         - Generar datos completos
│  │                        │  │         - Insertar certificado
│  │                        │  │         - Insertar 20-40% exámenes
│  │                        │  │
│  │                        │  ├─ 50-75 → 1C: Completo + 50-70% exámenes
│  │                        │  │         - Generar datos completos
│  │                        │  │         - Insertar certificado
│  │                        │  │         - Insertar 50-70% exámenes
│  │                        │  │
│  │                        │  └─ >= 75 → 1D: Completo + 100% exámenes
│  │                        │            - Generar datos completos
│  │                        │            - Insertar certificado
│  │                        │            - Insertar TODOS exámenes (100%)
│  │                        │
│  │                        └─ Incrementar @ContadorSinPDF
│  │
│  └─ >= 50 (50%) → TIPO 2: CON PDF
│                             │
│                             ├─ Generar datos completos
│                             ├─ Generar fechas (según estado deseado)
│                             ├─ Insertar certificado
│                             ├─ Insertar TODOS exámenes (obligatorio 100%)
│                             ├─ Validar datos + exámenes
│                             ├─ SI pasa validación:
│                             │  └─ Guardar PDF
│                             └─ Incrementar contadores
```

---

## 📊 CONTADORES Y REPORTES

### Contadores a Mantener:

```sql
DECLARE @ContadorSinCertificado INT = 0;  -- Tipo 0
DECLARE @ContadorDatosMinimos INT = 0;    -- Tipo 1A: Completo + 0% exámenes
DECLARE @ContadorSinExamenes INT = 0;     -- Tipo 1B: Completo + 20-40% exámenes
DECLARE @ContadorParcial INT = 0;         -- Tipo 1C: Completo + 50-70% exámenes
DECLARE @ContadorCompletoSinPDF INT = 0;  -- Tipo 1D: Completo + 100% exámenes
DECLARE @ContadorConPDF INT = 0;          -- Tipo 2: Con PDF
DECLARE @ContadorVigente INT = 0;         -- Tipo 2 vigente
DECLARE @ContadorPorVencer INT = 0;       -- Tipo 2 por vencer
DECLARE @ContadorVencido INT = 0;         -- Tipo 2 vencido
```

### Reporte Final:

```
--- DISTRIBUCIÓN GENERAL ---
Total colaboradores: 100
Sin certificado (Tipo 0): 10 (10%)

--- CERTIFICADOS SIN PDF (Tipo 1) ---
Total sin PDF: 40 (40%)
  - 1A (Completo + 0% exámenes): 10 (25%)
  - 1B (Completo + 20-40% exámenes): 10 (25%)
  - 1C (Completo + 50-70% exámenes): 10 (25%)
  - 1D (Completo + 100% exámenes): 10 (25%)

--- CERTIFICADOS CON PDF (Tipo 2) ---
Total con PDF: 50 (50%)
  - Vigente (>60 días): 30 (60%)
  - Por vencer (0-60 días): 10 (20%)
  - Vencido: 10 (20%)
```

---

## 📝 PROCEDIMIENTOS ALMACENADOS UTILIZADOS

### 1. S_INS_UPD_CERTIFICADO_EMO

Inserta o actualiza certificado EMO.

**Parámetros principales:**
```sql
@p_Id INT = NULL,                      -- NULL para INSERT
@p_PersonaProgramaId INT,              -- REQUERIDO
@p_DoctorId INT = NULL,
@p_Codigo NVARCHAR(50) = NULL,
@p_Password NVARCHAR(250) = NULL,
@p_PuestoAlQuePostula NVARCHAR(200) = NULL,
@p_PuestoActual NVARCHAR(200) = NULL,
@p_TipoEvaluacion NVARCHAR(100) = NULL,
@p_TipoResultado NVARCHAR(100) = NULL,
@p_Observaciones NVARCHAR(800) = NULL,
@p_Conclusiones NVARCHAR(800) = NULL,
@p_Restricciones NVARCHAR(800) = NULL,
@p_FechaEvaluacion DATETIME = NULL,
@p_FechaCaducidad DATETIME = NULL
```

**Retorna:** 1 = éxito, -1 = error

---

### 2. S_INS_UPD_RESULTADO_EXAMEN

Marca un examen como realizado.

**Parámetros:**
```sql
@p_PersonaProgramaId INT,
@p_ProtocoloEMOId INT,
@p_Realizado BIT                       -- 1 = realizado
```

**Retorna:**
- 1 = insertado
- 2 = actualizado
- -1/-2/-3 = error

---

### 3. S_UPD_GUARDAR_PDF_CERTIFICADO

Guarda la ruta del PDF generado.

**Parámetros:**
```sql
@p_PersonaProgramaId INT,
@p_RutaArchivoPDF NVARCHAR(500)       -- certificados/{id}/certificado.pdf
```

**Retorna:** 1 = éxito, 0 = no encontrado, -1 = error

---

## ⚠️ NOTAS IMPORTANTES

1. **Estado = '1':** Todos los registros se crean con `Estado = '1'` (activo). El estado NO se refiere a vigente/vencido, sino a si el registro existe o fue eliminado.

2. **Estados Vigente/Por vencer/Vencido:** Se calculan dinámicamente basados en `FechaCaducidad`, NO se almacenan.

3. **Uno de dos puestos:** NUNCA ambos puestos simultáneamente. Siempre uno NULL y otro con valor.

4. **Restricciones:** Solo obligatorio para 'aptoConRestricciones' y 'noApto'.

5. **RutaArchivoPDF:** Usar formato simple sin dominio: `certificados/{personaprogramaid}/certificado.pdf`

6. **Validaciones:** Las validaciones son un "safety check". El script debe generar intencionalmente los datos completos cuando va a crear PDF.

---

**Documento actualizado:** 2025-01-14
**Versión:** 3.0 - Lógica completa con 3 tipos y máxima variabilidad
**Autor:** Sistema MediValle
