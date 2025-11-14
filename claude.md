# Sistema EMO - Base de Datos MediValle

## Descripción General

Sistema de gestión de Exámenes Médicos Ocupacionales (EMO) para instituciones que requieren control de evaluaciones médicas de su personal, incluyendo la gestión de programas, perfiles ocupacionales, protocolos de exámenes y seguimiento de colaboradores.

---

## Estructura de la Base de Datos

### 1. Tablas Principales

#### T_PERSONA
Almacena la información personal de todas las personas en el sistema (doctores, colaboradores, etc.).

**Campos:**
- `Id` (INT, PK): Identificador único
- `Nombres` (NVARCHAR(100)): Nombres de la persona
- `Apellidos` (NVARCHAR(100)): Apellidos de la persona
- `TipoDocumento` (NVARCHAR(50)): Tipo de documento (DNI, CE, etc.)
- `NDocumentoIdentidad` (NVARCHAR(20)): Número de documento (único)
- `Telefono` (NVARCHAR(20)): Teléfono de contacto
- `Correo` (NVARCHAR(100)): Correo electrónico
- `Edad` (INT): Edad de la persona
- `Genero` (NVARCHAR(20)): Género (M/F)
- `GrupoSanguineo` (NVARCHAR(10)): Grupo sanguíneo (A, B, AB, O)
- `Rh` (NVARCHAR(10)): Factor Rh (+, -)
- `Estado` (CHAR(1)): Estado activo/inactivo
- `FechaCreacion` (DATETIME): Fecha de creación
- `FechaAccion` (DATETIME): Fecha de última modificación

**Regla:** El `NDocumentoIdentidad` debe ser único en el sistema.

---

#### T_ENTIDAD
Representa las organizaciones o empresas que utilizan el sistema.

**Campos:**
- `Id` (INT, PK): Identificador único
- `Nombre` (NVARCHAR(150)): Nombre de la entidad
- `Estado` (CHAR(1)): Estado activo/inactivo
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Ejemplo:** Banco de la Nación - Sede Principal, Banco de la Nación - Región Lima

---

#### T_PROGRAMA_EMO
Programas de evaluación médica ocupacional por entidad.

**Campos:**
- `Id` (INT, PK): Identificador único
- `Nombre` (NVARCHAR(300)): Nombre del programa
- `EntidadId` (INT, FK): Referencia a T_ENTIDAD
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Relación:** Un programa pertenece a una entidad
**Ejemplo:** "Programa EMO - Personal Operativo", "Programa EMO - Personal Comercial"

---

#### T_PERFIL_OCUPACIONAL
Define los diferentes puestos o roles laborales dentro de un programa.

**Campos:**
- `Id` (INT, PK): Identificador único
- `Nombre` (NVARCHAR(200)): Nombre del perfil
- `ProgramaEMOId` (INT, FK): Referencia a T_PROGRAMA_EMO
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Regla Importante:** Un perfil ocupacional pertenece a UN SOLO programa
**Ejemplo:** "Cajero", "Oficial de Seguridad", "Operador de Bóveda" (del Programa Operativo)

---

#### T_PERFIL_TIPO_EMO
**Tabla clave** que combina un perfil ocupacional con un tipo de EMO (INGRESO, PERIÓDICO, SALIDA, etc.).

**Campos:**
- `Id` (INT, PK): Identificador único
- `PerfilOcupacionalId` (INT, FK): Referencia a T_PERFIL_OCUPACIONAL
- `TipoEMO` (NVARCHAR(150)): Tipo de examen médico
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Ejemplo:**
- PerfilTipoEMOId=1: Cajero + INGRESO
- PerfilTipoEMOId=2: Cajero + PERIÓDICO
- PerfilTipoEMOId=3: Oficial de Seguridad + INGRESO

**Tipos de EMO comunes:** INGRESO, PERIÓDICO, RETIRO, REINTEGRO

---

#### T_PERSONA_PROGRAMA (Colaboradores/Participantes)
**Tabla principal** que registra a los colaboradores asignados a un programa con su perfil específico.

**Campos:**
- `Id` (INT, PK): Identificador único del participante
- `PersonaId` (INT, FK): Referencia a T_PERSONA
- `ProgramaEMOId` (INT, FK): Referencia a T_PROGRAMA_EMO
- `PerfilTipoEMOId` (INT, FK): Referencia a T_PERFIL_TIPO_EMO
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Reglas de Negocio:**
1. Una persona (DNI único) SOLO puede estar en UN programa (no puede estar en múltiples programas)
2. Una persona NO puede estar DOS VECES en el MISMO programa
3. El `PerfilTipoEMOId` debe pertenecer al mismo programa que `ProgramaEMOId`
4. El perfil ocupacional debe ser del mismo programa

**Ejemplo:**
```
ParticipanteId: 1
PersonaId: 10 (Juan Pérez - DNI: 10000001)
ProgramaEMOId: 1 (Programa Operativo)
PerfilTipoEMOId: 1 (Cajero - INGRESO)
```

---

#### T_EXAMEN_MEDICO_OCUPACIONAL
Catálogo de exámenes médicos disponibles.

**Campos:**
- `Id` (INT, PK): Identificador único
- `Nombre` (NVARCHAR(300)): Nombre del examen
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Ejemplos:**
- Hemograma Completo
- Radiografía de Tórax PA
- Examen Oftalmológico Completo
- Audiometría
- Evaluación Psicológica Ocupacional

---

#### T_PROTOCOLO_EMO
Define qué exámenes son requeridos para cada combinación de Perfil-TipoEMO.

**Campos:**
- `Id` (INT, PK): Identificador único
- `PerfilTipoEMOId` (INT, FK): Referencia a T_PERFIL_TIPO_EMO
- `ExamenMedicoOcupacionalId` (INT, FK): Referencia a T_EXAMEN_MEDICO_OCUPACIONAL
- `EsRequerido` (BIT): Si el examen es obligatorio (1) u opcional (0)
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

**Ejemplo:**
Un "Cajero" en "INGRESO" requiere:
- Hemograma Completo (obligatorio)
- Glucosa en Sangre (obligatorio)
- Radiografía de Tórax PA (obligatorio)
- Examen Oftalmológico (obligatorio)

---

#### T_DOCTOR
Información de los médicos ocupacionales.

**Campos:**
- `Id` (INT, PK): Identificador único
- `PersonaId` (INT, FK): Referencia a T_PERSONA
- `Codigo` (NVARCHAR(50)): Código CMP
- `Especialidad` (NVARCHAR(200)): Especialidad médica
- `RutaImagenFirma` (NVARCHAR(500)): Ruta de imagen de firma
- `RutaCertificadoDigital` (NVARCHAR(500)): Ruta de certificado digital
- `Estado` (CHAR(1))
- `FechaCreacion` (DATETIME)
- `FechaAccion` (DATETIME)

---

## Procedimientos Almacenados

### Gestión de Colaboradores

#### S_INS_UPD_PERSONA_PROGRAMA
**Procedimiento principal** para crear y actualizar colaboradores (participantes en programas EMO).

**Parámetros:**
```sql
@p_ParticipanteId INT = NULL,           -- NULL para crear, ID para editar
@p_Nombres NVARCHAR(100),
@p_Apellidos NVARCHAR(100),
@p_TipoDocumento NVARCHAR(50),
@p_NDocumentoIdentidad NVARCHAR(20),    -- DNI único
@p_Telefono NVARCHAR(20),
@p_Correo NVARCHAR(100),
@p_Edad INT,
@p_Genero NVARCHAR(20),
@p_GrupoSanguineo NVARCHAR(10),
@p_Rh NVARCHAR(10),
@p_ProgramaEMOId INT,                   -- Programa al que se asigna
@p_PerfilTipoEMOId INT                  -- Combinación Perfil+TipoEMO
```

**Lógica:**

**MODO CREACIÓN** (cuando @p_ParticipanteId es NULL):
1. Busca si existe una persona con el DNI proporcionado
2. Si existe, actualiza sus datos personales
3. Si no existe, crea un nuevo registro en T_PERSONA
4. Valida que la persona NO esté ya en ese mismo programa
5. Crea el registro en T_PERSONA_PROGRAMA
6. Retorna 1 si es exitoso, -1 si hay error

**MODO EDICIÓN** (cuando @p_ParticipanteId tiene valor):
1. Obtiene la PersonaId y ProgramaId del participante
2. Actualiza los datos en T_PERSONA (NO actualiza el DNI)
3. Actualiza solo el PerfilTipoEMOId en T_PERSONA_PROGRAMA (NO cambia el programa)
4. Retorna 1 si es exitoso, -1 si hay error

**Uso:**
```sql
-- Crear nuevo colaborador
EXEC S_INS_UPD_PERSONA_PROGRAMA
    NULL,                                    -- Nuevo
    'Juan Carlos',                           -- Nombres
    'Pérez López',                           -- Apellidos
    'DNI',                                   -- Tipo Documento
    '10000001',                              -- DNI único
    NULL,                                    -- Teléfono
    NULL,                                    -- Correo
    28,                                      -- Edad
    'M',                                     -- Género
    'O',                                     -- Grupo Sanguíneo
    '+',                                     -- Rh
    1,                                       -- ProgramaEMOId
    1;                                       -- PerfilTipoEMOId
```

---

### Gestión de Protocolos

#### S_INS_UPD_PROTOCOLO_EMO
Asocia exámenes médicos a combinaciones de Perfil-TipoEMO.

**Parámetros:**
```sql
@p_PerfilOcupacionalId INT,              -- ID del perfil ocupacional
@p_TipoEMO NVARCHAR(150),                -- Tipo de EMO (INGRESO, PERIÓDICO, etc.)
@p_ExamenMedicoOcupacionalId INT,        -- ID del examen médico
@p_EsRequerido BIT = 1                   -- Si es obligatorio
```

**Lógica:**
1. Busca o crea la combinación Perfil-TipoEMO en T_PERFIL_TIPO_EMO
2. Verifica si ya existe el protocolo
3. Si no existe, lo crea en T_PROTOCOLO_EMO
4. Retorna 1 si es exitoso

**Uso:**
```sql
-- Asignar examen a un perfil para tipo INGRESO
EXEC S_INS_UPD_PROTOCOLO_EMO
    @p_PerfilOcupacionalId = 1,              -- Cajero
    @p_TipoEMO = 'INGRESO',
    @p_ExamenMedicoOcupacionalId = 5,        -- Hemograma Completo
    @p_EsRequerido = 1;
```

---

### Otros Procedimientos

- **S_INS_UPD_PERFIL_OCUPACIONAL**: Crear/actualizar perfiles ocupacionales
- **S_INS_UPD_PROGRAMA_EMO**: Crear/actualizar programas EMO
- **S_INS_UDP_ENTIDAD**: Crear/actualizar entidades
- **S_INS_UPD_DOCTOR**: Crear/actualizar doctores
- **S_INS_UPD_EXAMEN_MEDICO**: Crear/actualizar exámenes médicos
- **S_SEL_PERFILES_OCUPACIONAL**: Consultar perfiles por programa
- **S_SEL_PROGRAMAS_EMO**: Consultar programas por entidad
- **S_SEL_PROTOCOLOS_EMO**: Consultar protocolos configurados

---

## Flujo de Configuración del Sistema

### Paso 1: Crear Entidades
```sql
EXEC S_INS_UDP_ENTIDAD NULL, 'Banco de la Nación - Sede Principal';
```

### Paso 2: Crear Programas EMO
```sql
EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Programa EMO - Personal Operativo', 1;
```

### Paso 3: Crear Exámenes Médicos
```sql
EXEC S_INS_UPD_EXAMEN_MEDICO NULL, 'Hemograma Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO NULL, 'Radiografía de Tórax PA';
```

### Paso 4: Crear Perfiles Ocupacionales
```sql
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Cajero', 1;  -- Programa 1
```

### Paso 5: Configurar Protocolos
```sql
EXEC S_INS_UPD_PROTOCOLO_EMO 1, 'INGRESO', 1, 1;  -- Cajero + Hemograma
```

### Paso 6: Registrar Colaboradores
```sql
EXEC S_INS_UPD_PERSONA_PROGRAMA
    NULL, 'Juan', 'Pérez', 'DNI', '10000001', NULL, NULL, 28, 'M', 'O', '+', 1, 1;
```

---

## Reglas de Negocio Importantes

### 1. Unicidad de DNI
- El DNI (`NDocumentoIdentidad`) debe ser único en T_PERSONA
- No pueden existir dos personas con el mismo DNI

### 2. Colaboradores y Programas
- Un colaborador (T_PERSONA_PROGRAMA) pertenece a UN SOLO programa
- NO puede estar registrado dos veces en el mismo programa
- NO puede estar en programas diferentes (solo un registro activo en T_PERSONA_PROGRAMA por persona)

### 3. Perfiles Ocupacionales
- Cada perfil ocupacional pertenece a UN solo programa
- El T_PERFIL_OCUPACIONAL está ligado a un T_PROGRAMA_EMO específico

### 4. Validación de Perfil-Programa
- Al registrar un colaborador en T_PERSONA_PROGRAMA:
  - El `PerfilTipoEMOId` debe corresponder a un perfil del mismo `ProgramaEMOId`
  - Ejemplo: Si ProgramaEMOId=1, el PerfilTipoEMOId debe ser de un perfil del Programa 1

### 5. Tipos de EMO
- Los tipos comunes son: INGRESO, PERIÓDICO, RETIRO, REINTEGRO
- Se pueden agregar tipos personalizados según necesidad

---

## Datos de Prueba

El sistema incluye datos de prueba con:

### 3 Entidades
1. Banco de la Nación - Sede Principal
2. Banco de la Nación - Región Lima
3. Banco de la Nación - Región Norte

### 3 Programas EMO
1. **Programa EMO - Personal Operativo** (4 perfiles)
   - Cajero
   - Oficial de Seguridad
   - Operador de Bóveda
   - Mensajero/Courier

2. **Programa EMO - Personal Comercial y Soporte** (6 perfiles)
   - Asesor de Negocios
   - Ejecutivo de Atención al Cliente
   - Tecnólogo de Información
   - Personal de Call Center
   - Recepcionista
   - Personal de Limpieza

3. **Programa EMO - Personal Administrativo y Gerencial**

### 33 Exámenes Médicos
Incluyendo: Hemograma, Radiografías, Exámenes oftalmológicos, Audiometría, Evaluaciones psicológicas, etc.

### Colaboradores (Cantidad Variable)
- 20 colaboradores por cada programa EMO activo
- DNIs únicos de 8 dígitos con formato realista:
  - Primeros 2 dígitos: aleatorios entre 62 y 73 (rango típico peruano)
  - Siguientes 6 dígitos: aleatorios
- Distribuidos equitativamente entre TODOS los perfiles disponibles de cada programa
- Generación dinámica: el script detecta automáticamente todos los programas y perfiles
- Variedad en datos: nombres, edades (23-40), grupos sanguíneos (O, A, B, AB), géneros (M/F)

---

## Consultas Útiles

### Ver todos los colaboradores de un programa
```sql
SELECT
    PP.Id AS ParticipanteId,
    P.Nombres + ' ' + P.Apellidos AS NombreCompleto,
    P.NDocumentoIdentidad AS DNI,
    PE.Nombre AS Programa,
    PO.Nombre AS Perfil,
    PTE.TipoEMO
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
WHERE PP.Estado = '1'
  AND PE.Id = 1
ORDER BY P.Apellidos, P.Nombres;
```

### Ver protocolos de un perfil específico
```sql
SELECT
    PO.Nombre AS Perfil,
    PTE.TipoEMO,
    EMO.Nombre AS Examen,
    PRO.EsRequerido,
    CASE WHEN PRO.EsRequerido = 1 THEN 'OBLIGATORIO' ELSE 'OPCIONAL' END AS Importancia
FROM T_PROTOCOLO_EMO PRO
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PRO.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_EXAMEN_MEDICO_OCUPACIONAL EMO ON PRO.ExamenMedicoOcupacionalId = EMO.Id
WHERE PO.Id = 1  -- Cajero
  AND PTE.TipoEMO = 'INGRESO'
  AND PRO.Estado = '1'
ORDER BY EMO.Nombre;
```

### Contar colaboradores por programa
```sql
SELECT
    PE.Nombre AS Programa,
    COUNT(PP.Id) AS TotalColaboradores
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
WHERE PP.Estado = '1'
GROUP BY PE.Id, PE.Nombre
ORDER BY PE.Id;
```

---

## Archivos del Sistema

### Scripts SQL
- **tablas.sql**: Definiciones de tablas y datos iniciales básicos
- **procedimientos.sql**: Todos los procedimientos almacenados
- **insertarDatos.sql**: Datos de prueba (entidades, programas, perfiles, exámenes, protocolos)
- **insertarColaboradores.sql**: Inserción dinámica de colaboradores (20 por programa)

### Orden de Ejecución
1. `tablas.sql` - Crear estructura
2. `procedimientos.sql` - Crear procedimientos
3. `insertarDatos.sql` - Cargar datos maestros (programas, perfiles, protocolos)
4. `insertarColaboradores.sql` - Cargar colaboradores (detecta programas automáticamente)

### Características de insertarColaboradores.sql
Este script es **completamente dinámico**:
- Consulta automáticamente TODOS los programas EMO activos
- Para cada programa, detecta TODOS sus perfiles con tipo INGRESO
- Distribuye equitativamente 20 colaboradores entre los perfiles disponibles
- Si un programa no tiene perfiles configurados, lo omite con advertencia
- Genera datos variados (nombres, edades, grupos sanguíneos, géneros)
- **DNIs realistas de 8 dígitos**: Primeros 2 dígitos entre 62-73, resto aleatorio
- Sistema anti-duplicados: verifica que cada DNI sea único
- Incluye resumen detallado al final mostrando distribución por programa y perfil

---

## Notas Importantes

1. **No usar T_COLABORADOR**: Esta tabla está obsoleta. El procedimiento correcto es usar **T_PERSONA_PROGRAMA** con el procedimiento **S_INS_UPD_PERSONA_PROGRAMA**.

2. **PerfilTipoEMOId es clave**: Siempre usar este ID al registrar colaboradores, ya que combina el perfil ocupacional con el tipo de examen.

3. **Validar perfiles**: Antes de asignar un colaborador, verificar que el PerfilTipoEMOId corresponda al ProgramaEMOId.

4. **DNIs únicos**: El sistema valida que no se repitan DNIs en T_PERSONA.

5. **Estados**: Usar '1' para activo y '0' para inactivo en todos los registros.

---

## Contacto y Soporte

Para consultas sobre el sistema, referirse a la documentación técnica o contactar al equipo de desarrollo.

**Versión:** 1.0
**Última actualización:** 2025-01-14
