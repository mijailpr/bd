USE DB_MEDIVALLE;
GO

-- ==============================
-- ELIMINAR TABLAS SI EXISTEN (en orden inverso de dependencias)
-- ==============================

IF OBJECT_ID('T_CERTIFICADO_EMO', 'U') IS NOT NULL DROP TABLE T_CERTIFICADO_EMO;
IF OBJECT_ID('T_ANEXO', 'U') IS NOT NULL DROP TABLE T_ANEXO;
IF OBJECT_ID('T_RESULTADO_EMO', 'U') IS NOT NULL DROP TABLE T_RESULTADO_EMO;
IF OBJECT_ID('T_PERSONA_PROGRAMA', 'U') IS NOT NULL DROP TABLE T_PERSONA_PROGRAMA;
IF OBJECT_ID('T_PROTOCOLO_EMO', 'U') IS NOT NULL DROP TABLE T_PROTOCOLO_EMO;
IF OBJECT_ID('T_PERFIL_TIPO_EMO', 'U') IS NOT NULL DROP TABLE T_PERFIL_TIPO_EMO;
IF OBJECT_ID('T_PERFIL_OCUPACIONAL', 'U') IS NOT NULL DROP TABLE T_PERFIL_OCUPACIONAL;
IF OBJECT_ID('T_PROGRAMA_EMO', 'U') IS NOT NULL DROP TABLE T_PROGRAMA_EMO;
IF OBJECT_ID('T_EXAMEN_MEDICO_OCUPACIONAL', 'U') IS NOT NULL DROP TABLE T_EXAMEN_MEDICO_OCUPACIONAL;
IF OBJECT_ID('T_DOCTOR', 'U') IS NOT NULL DROP TABLE T_DOCTOR;
IF OBJECT_ID('T_SESSION', 'U') IS NOT NULL DROP TABLE T_SESSION;
IF OBJECT_ID('T_USUARIO', 'U') IS NOT NULL DROP TABLE T_USUARIO;
IF OBJECT_ID('T_PERSONA', 'U') IS NOT NULL DROP TABLE T_PERSONA;
IF OBJECT_ID('T_ENTIDAD', 'U') IS NOT NULL DROP TABLE T_ENTIDAD;
IF OBJECT_ID('T_ROL', 'U') IS NOT NULL DROP TABLE T_ROL;
GO

-- ==============================
-- TABLAS MAESTRAS
-- ==============================

CREATE TABLE T_ENTIDAD
(
    Id            INT IDENTITY PRIMARY KEY,
    Nombre        NVARCHAR(150)              NOT NULL,
    Estado        NVARCHAR(20)               NOT NULL,
    FechaAccion   DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL
)
GO

CREATE TABLE T_EXAMEN_MEDICO_OCUPACIONAL
(
    Id            INT IDENTITY PRIMARY KEY,
    Nombre        NVARCHAR(300)              NOT NULL,
    Estado        NVARCHAR(20)               NOT NULL,
    FechaAccion   DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL
)
GO

CREATE TABLE T_PERSONA
(
    Id                  INT IDENTITY PRIMARY KEY,
    Nombres             NVARCHAR(100)              NOT NULL,
    Apellidos           NVARCHAR(100)              NOT NULL,
    TipoDocumento       NVARCHAR(50),
    NDocumentoIdentidad NVARCHAR(20),
    Telefono            NVARCHAR(20),
    Correo              NVARCHAR(100),
    Edad                INT,
    Genero              NVARCHAR(20),
    GrupoSanguineo      NVARCHAR(10),
    Rh                  NVARCHAR(10),
    Estado              NVARCHAR(20)               NOT NULL,
    FechaAccion         DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion       DATETIME DEFAULT GETDATE() NOT NULL
)
GO

CREATE TABLE T_DOCTOR
(
    Id                     INT IDENTITY PRIMARY KEY,
    PersonaId              INT                        NOT NULL
        CONSTRAINT FK_DOCTOR_PERSONA
            REFERENCES T_PERSONA (Id),
    Codigo                 NVARCHAR(100)              NOT NULL
        UNIQUE,
    Especialidad           NVARCHAR(200)              NOT NULL,
    RutaImagenFirma        NVARCHAR(200),
    RutaCertificadoDigital NVARCHAR(200),
    Estado                 NVARCHAR(20)               NOT NULL,
    FechaAccion            DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion          DATETIME DEFAULT GETDATE() NOT NULL
)
GO

CREATE TABLE T_ROL
(
    Id            INT IDENTITY PRIMARY KEY,
    Nombre        NVARCHAR(100)              NOT NULL
        UNIQUE,
    Estado        NVARCHAR(20)               NULL,
    FechaAccion   DATETIME DEFAULT GETDATE() NULL,
    FechaCreacion DATETIME DEFAULT GETDATE() NULL
)
GO

CREATE TABLE T_USUARIO
(
    Id            INT IDENTITY PRIMARY KEY,
    UserName      NVARCHAR(100)              NOT NULL
        UNIQUE,
    Password      NVARCHAR(150)              NOT NULL,
    PersonaId     INT
        CONSTRAINT FK_USUARIO_PERSONA
            REFERENCES T_PERSONA (Id),
    RolId         INT
        CONSTRAINT FK_USUARIO_ROL
            REFERENCES T_ROL (Id),
    Estado        NVARCHAR(20)               NOT NULL,
    FechaAccion   DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL
)
GO

CREATE TABLE T_SESSION
(
    Id              NVARCHAR(100) PRIMARY KEY,           -- GUID de la cookie
    UsuarioId       INT                        NOT NULL
        CONSTRAINT FK_SESSION_USUARIO REFERENCES T_USUARIO (Id),
    Data            NVARCHAR(MAX)              NOT NULL, -- JSON con BEDatosUsuario
    FechaExpiracion DATETIME                   NOT NULL, -- Expira en 15 días
    FechaCreacion   DATETIME DEFAULT GETDATE() NOT NULL,
)
GO

-- Índice para limpiar sesiones expiradas eficientemente
CREATE INDEX IX_SESSION_EXPIRACION ON T_SESSION (FechaExpiracion)
GO

-- Índice para búsqueda por usuario
CREATE INDEX IX_SESSION_USUARIO ON T_SESSION (UsuarioId)
GO

-- ==============================
-- TABLAS DE PROGRAMAS EMO
-- ==============================

CREATE TABLE T_PROGRAMA_EMO
(
    Id            INT IDENTITY PRIMARY KEY,
    Nombre        NVARCHAR(300)              NOT NULL,
    EntidadId     INT                        NOT NULL
        CONSTRAINT FK_PROGRAMA_EMO_ENTIDAD
            REFERENCES T_ENTIDAD (Id),
    Estado        NVARCHAR(20)               NOT NULL,
    FechaAccion   DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL
)
GO

CREATE TABLE T_PERFIL_OCUPACIONAL
(
    Id            INT IDENTITY PRIMARY KEY,
    Nombre        NVARCHAR(200)              NOT NULL,
    ProgramaEMOId INT                        NOT NULL
        CONSTRAINT FK_PERFIL_PROGRAMA
            REFERENCES T_PROGRAMA_EMO (Id),
    Estado        NVARCHAR(20)               NOT NULL,
    FechaAccion   DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE() NOT NULL
)
GO

-- ==============================
-- NUEVA TABLA: T_PERFIL_TIPO_EMO
-- Relaciona Perfiles Ocupacionales con Tipos de EMO
-- ==============================

CREATE TABLE T_PERFIL_TIPO_EMO
(
    Id                  INT IDENTITY PRIMARY KEY,
    PerfilOcupacionalId INT                        NOT NULL
        CONSTRAINT FK_PERFIL_TIPO_PERFIL
            REFERENCES T_PERFIL_OCUPACIONAL (Id),
    TipoEMO             NVARCHAR(150)              NOT NULL,
    Estado              NVARCHAR(20)               NOT NULL,
    FechaAccion         DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion       DATETIME DEFAULT GETDATE() NOT NULL,

    -- Constraint: Un perfil ocupacional solo puede tener un registro activo por TipoEMO
    CONSTRAINT UK_PERFIL_TIPO_EMO UNIQUE (PerfilOcupacionalId, TipoEMO)
)
GO

-- ==============================
-- TABLA: T_PROTOCOLO_EMO (ACTUALIZADA)
-- Ahora referencia a T_PERFIL_TIPO_EMO
-- ==============================

CREATE TABLE T_PROTOCOLO_EMO
(
    Id                        INT IDENTITY PRIMARY KEY,
    PerfilTipoEMOId           INT                        NOT NULL
        CONSTRAINT FK_PROTOCOLO_PERFIL_TIPO
            REFERENCES T_PERFIL_TIPO_EMO (Id),
    ExamenMedicoOcupacionalId INT                        NOT NULL
        CONSTRAINT FK_PROTOCOLO_EXAMEN_MEDICO_OCUPACIONAL
            REFERENCES T_EXAMEN_MEDICO_OCUPACIONAL (Id),
    EsRequerido               BIT      DEFAULT 0         NOT NULL,
    Estado                    NVARCHAR(20)               NOT NULL,
    FechaAccion               DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion             DATETIME DEFAULT GETDATE() NOT NULL,

    -- Constraint: Evitar que el mismo examen se agregue dos veces al mismo perfil+tipo
    CONSTRAINT UK_PERFIL_TIPO_EXAMEN UNIQUE (PerfilTipoEMOId, ExamenMedicoOcupacionalId)
)
GO

-- ==============================
-- TABLA: T_PERSONA_PROGRAMA
-- ==============================

CREATE TABLE T_PERSONA_PROGRAMA
(
    Id              INT IDENTITY PRIMARY KEY,
    PersonaId       INT                        NOT NULL
        CONSTRAINT FK_PERSONA_PROGRAMA_PERSONA
            REFERENCES T_PERSONA (Id),
    ProgramaEMOId   INT                        NOT NULL
        CONSTRAINT FK_PERSONA_PROGRAMA_PROGRAMA
            REFERENCES T_PROGRAMA_EMO (Id),
    PerfilTipoEMOId INT                        NULL
        CONSTRAINT FK_PERSONA_PROGRAMA_PERFIL_TIPO
            REFERENCES T_PERFIL_TIPO_EMO (Id),
    Estado          NVARCHAR(20)               NOT NULL,
    FechaAccion     DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion   DATETIME DEFAULT GETDATE() NOT NULL,

    CONSTRAINT UK_PERSONA_PROGRAMA_ACTIVO
        UNIQUE (PersonaId, ProgramaEMOId)
)
GO

-- ==============================
-- TABLA: T_RESULTADO_EMO
-- ==============================

CREATE TABLE T_RESULTADO_EMO
(
    Id                INT IDENTITY PRIMARY KEY,
    PersonaProgramaId INT                        NOT NULL
        CONSTRAINT FK_RESULTADO_PERSONA_PROGRAMA
            REFERENCES T_PERSONA_PROGRAMA (Id),
    ProtocoloEMOId    INT                        NOT NULL
        CONSTRAINT FK_RESULTADO_PROTOCOLO
            REFERENCES T_PROTOCOLO_EMO (Id),
    Realizado         BIT      DEFAULT 0         NOT NULL,
    Estado            NVARCHAR(20)               NOT NULL,
    FechaAccion       DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion     DATETIME DEFAULT GETDATE() NOT NULL,

    CONSTRAINT UK_PERSONA_PROGRAMA_PROTOCOLO
        UNIQUE (PersonaProgramaId, ProtocoloEMOId)
)
GO

-- ==============================
-- TABLA: T_ANEXO
-- ==============================

CREATE TABLE T_ANEXO
(
    Id                INT IDENTITY PRIMARY KEY,
    PersonaProgramaId INT                        NOT NULL
        CONSTRAINT FK_ANEXO_PERSONA_PROGRAMA
            REFERENCES T_PERSONA_PROGRAMA (Id),
    Nombre            NVARCHAR(200)              NOT NULL,
    TipoArchivo       NVARCHAR(100)              NOT NULL,
    RutaArchivo       NVARCHAR(500)              NOT NULL,
    Estado            NVARCHAR(20)               NOT NULL,
    FechaAccion       DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion     DATETIME DEFAULT GETDATE() NOT NULL
)
GO

-- ==============================
-- TABLA: T_CERTIFICADO_EMO
-- ==============================

CREATE TABLE T_CERTIFICADO_EMO
(
    Id                 INT IDENTITY PRIMARY KEY,
    PersonaProgramaId  INT                        NOT NULL
        CONSTRAINT FK_CERTIFICADO_PERSONA_PROGRAMA
            REFERENCES T_PERSONA_PROGRAMA (Id),
    DoctorId           INT
        CONSTRAINT FK_CERTIFICADO_DOCTOR
            REFERENCES T_DOCTOR (Id),
    Codigo             NVARCHAR(50)               NOT NULL
        UNIQUE,
    Password           NVARCHAR(250)              NOT NULL,
    PuestoAlQuePostula NVARCHAR(200),
    PuestoActual       NVARCHAR(200),
    TipoEvaluacion     NVARCHAR(100)              NOT NULL,
    TipoResultado      NVARCHAR(100)              NOT NULL,
    Conclusiones       NVARCHAR(800),
    Observaciones      NVARCHAR(800),
    Restricciones      NVARCHAR(800),
    FechaEvaluacion    DATETIME,
    FechaCaducidad     DATETIME,
    RutaArchivoPDF     NVARCHAR(500)              NOT NULL,
    NombreArchivo      NVARCHAR(200)              NOT NULL,
    FechaGeneracion    DATETIME DEFAULT GETDATE() NOT NULL,
    TamanoArchivo      BIGINT,
    Estado             NVARCHAR(20)               NOT NULL,
    FechaAccion        DATETIME DEFAULT GETDATE() NOT NULL,
    FechaCreacion      DATETIME DEFAULT GETDATE() NOT NULL,

    CONSTRAINT UK_PERSONA_PROGRAMA_CERTIFICADO
        UNIQUE (PersonaProgramaId)
)
GO

-- ==============================
-- ÍNDICES ADICIONALES PARA MEJORAR RENDIMIENTO
-- ==============================

CREATE INDEX IX_PERSONA_PROGRAMA_PERSONA ON T_PERSONA_PROGRAMA (PersonaId)
GO

CREATE INDEX IX_PERSONA_PROGRAMA_PROGRAMA ON T_PERSONA_PROGRAMA (ProgramaEMOId)
GO

CREATE INDEX IX_PERSONA_PROGRAMA_PERFIL_TIPO ON T_PERSONA_PROGRAMA (PerfilTipoEMOId)
GO

CREATE INDEX IX_RESULTADO_PERSONA_PROGRAMA ON T_RESULTADO_EMO (PersonaProgramaId)
GO

CREATE INDEX IX_PERSONA_DNI ON T_PERSONA (NDocumentoIdentidad)
GO

CREATE INDEX IX_PROTOCOLO_PERFIL_TIPO ON T_PROTOCOLO_EMO (PerfilTipoEMOId)
GO

CREATE INDEX IX_PROTOCOLO_EXAMEN ON T_PROTOCOLO_EMO (ExamenMedicoOcupacionalId)
GO

CREATE INDEX IX_PERFIL_TIPO_PERFIL ON T_PERFIL_TIPO_EMO (PerfilOcupacionalId)
GO

CREATE UNIQUE INDEX IX_USUARIO_USERNAME ON T_USUARIO (UserName)
    WHERE Estado = '1';
GO

PRINT 'Base de datos creada exitosamente con la nueva estructura T_PERFIL_TIPO_EMO';
GO



-- =============================================
-- REGION: ÍNDICES OPTIMIZADOS PARA S_SEL_PERSONAS_PROGRAMAS_CERTIFICADOS
-- =============================================

-- 1. T_PERSONA_PROGRAMA
IF NOT EXISTS (SELECT *
               FROM sys.indexes
               WHERE name = 'IX_PP_Programa_Activo_Covering'
                 AND object_id = OBJECT_ID('T_PERSONA_PROGRAMA'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_PP_Programa_Activo_Covering
            ON T_PERSONA_PROGRAMA (ProgramaEMOId, Estado)
            INCLUDE (PersonaId, PerfilTipoEMOId)
            WHERE Estado = '1';
        PRINT 'Índice creado: IX_PP_Programa_Activo_Covering';
    END

-- 2. T_CERTIFICADO_EMO
IF NOT EXISTS (SELECT *
               FROM sys.indexes
               WHERE name = 'IX_CE_PersonaPrograma_Fechas_Codigo'
                 AND object_id = OBJECT_ID('T_CERTIFICADO_EMO'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_CE_PersonaPrograma_Fechas_Codigo
            ON T_CERTIFICADO_EMO (PersonaProgramaId)
            INCLUDE (Id, DoctorId, Codigo, Estado, RutaArchivoPDF, FechaCaducidad, FechaEvaluacion, TipoEvaluacion,
                     TipoResultado, PuestoAlQuePostula, PuestoActual)
            WHERE Estado = '1';
        PRINT 'Índice creado: IX_CE_PersonaPrograma_Fechas_Codigo';
    END

-- 3. T_RESULTADO_EMO
IF NOT EXISTS (SELECT *
               FROM sys.indexes
               WHERE name = 'IX_RE_Persona_Protocolo_Realizado'
                 AND object_id = OBJECT_ID('T_RESULTADO_EMO'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_RE_Persona_Protocolo_Realizado
            ON T_RESULTADO_EMO (PersonaProgramaId, ProtocoloEMOId)
            INCLUDE (Estado, Realizado)
            WHERE Estado = '1';
        PRINT 'Índice creado: IX_RE_Persona_Protocolo_Realizado';
    END

-- 4. T_PROTOCOLO_EMO (opcional pero recomendado)
IF NOT EXISTS (SELECT *
               FROM sys.indexes
               WHERE name = 'IX_PRO_Perfil_Requerido'
                 AND object_id = OBJECT_ID('T_PROTOCOLO_EMO'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_PRO_Perfil_Requerido
            ON T_PROTOCOLO_EMO (PerfilTipoEMOId)
            INCLUDE (EsRequerido)
            WHERE Estado = '1' AND EsRequerido = 1;
        PRINT 'Índice creado: IX_PRO_Perfil_Requerido';
    END

