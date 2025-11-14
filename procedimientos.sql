--------------------------------------------------
-- Empresa: Desarrollo Empresarial System Strategy S.A.C
-- Autor: Cristhian Lopez
-- Creado: 13/10/2025 19:27:28
-- Propósito: Listar usuarios
--------------------------------------------------
CREATE PROCEDURE [dbo].[S_AC_SEL_USUARIOS]

AS
SET NoCount ON

	SELECT [Id]
		  ,[Usuario]
		  ,[Passwordd]
	FROM [dbo].[T_AC_USUARIOS]

SET NoCount OFF


go

-- =============================================
-- 4. S_DEL_ANEXO
-- Elimina (marca como inactivo) un anexo
-- =============================================
CREATE   PROCEDURE S_DEL_ANEXO
(
    @p_AnexoId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_ANEXO
    SET Estado = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_AnexoId;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

--------------------------------------------------
-- Empresa: Desarrollo Empresarial System Strategy S.A.C.
-- Autor: GitHub Copilot
-- Creado: 10/10/2025 14:30:00
-- Propósito: Eliminar (inactivar) un doctor
--------------------------------------------------
CREATE   PROCEDURE [dbo].[S_DEL_DOCTOR]

@p_DoctorId INT,
@p_UsuarioAccion INT

AS
SET NOCOUNT ON
DECLARE @VALOR INT = 0

    UPDATE T_DOCTOR
    SET Estado = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_DoctorId

    IF @@ROWCOUNT > 0
        SET @VALOR = 1

IF @@ERROR != 0
    SET @VALOR = -1

RETURN @VALOR
SET NOCOUNT OFF
go

CREATE     PROCEDURE S_DEL_ENTIDAD(
    @p_Id INT
) AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_ENTIDAD
    SET Estado      = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_Id;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE   PROCEDURE S_DEL_EXAMEN_MEDICO_OCUPACIONAL(
    @p_Id INT
) AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_EXAMEN_MEDICO_OCUPACIONAL
    SET Estado      = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_Id;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END;
go

CREATE     PROCEDURE S_DEL_PERFIL_OCUPACIONAL(
    @p_Id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_PERFIL_OCUPACIONAL
    SET Estado = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_Id;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE PROCEDURE [dbo].[S_DEL_PERSONA_PROGRAMA]
    @p_ParticipanteId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    -- 5. Eliminar el participante
    UPDATE T_PERSONA_PROGRAMA
    SET Estado = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_ParticipanteId;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE -1 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE     PROCEDURE S_DEL_PROGRAMA_EMO(
    @p_Id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_PROGRAMA_EMO
    SET Estado = '0',
        FechaAccion = GETDATE()
    WHERE Id = @p_Id;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE PROCEDURE S_DEL_PROTOCOLO_EMO(
    @p_ProgramaEMOId INT,
    @p_ProtocoloEMOId INT = NULL,
    @p_PerfilOcupacionalId INT = NULL,
    @p_ExamenMedicoOcupacionalId INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE P
    SET
        P.Estado = '0',
        P.FechaAccion = GETDATE()
    FROM T_PROTOCOLO_EMO P
    INNER JOIN T_PERFIL_OCUPACIONAL PO
        ON PO.Id = P.PerfilOcupacionalId
    WHERE
        PO.ProgramaEMOId = @p_ProgramaEMOId
        AND (@p_ProtocoloEMOId IS NULL OR P.Id = @p_ProtocoloEMOId)
        AND (@p_PerfilOcupacionalId IS NULL OR P.PerfilOcupacionalId = @p_PerfilOcupacionalId)
        AND (@p_ExamenMedicoOcupacionalId IS NULL OR P.ExamenMedicoOcupacionalId = @p_ExamenMedicoOcupacionalId);

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE     PROCEDURE S_INS_UDP_ENTIDAD(
    @p_Id INT = NULL,
    @p_Nombre NVARCHAR(150) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL
    BEGIN

        UPDATE T_ENTIDAD
        SET Nombre      = ISNULL(@p_Nombre, Nombre),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    END
    ELSE
    BEGIN

        INSERT INTO T_ENTIDAD (Nombre, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_Nombre, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

-- =============================================
-- 3. S_INS_UPD_ANEXO
-- Inserta un nuevo anexo o actualiza uno existente
-- basándose en PersonaProgramaId + Nombre
-- =============================================
CREATE PROCEDURE S_INS_UPD_ANEXO
(
    @p_PersonaProgramaId INT,
    @p_Nombre NVARCHAR(200),
    @p_TipoArchivo NVARCHAR(100),
    @p_RutaArchivo NVARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;
    DECLARE @AnexoExistente INT = NULL;

    -- Verificar si existe un anexo con el mismo nombre para esta persona-programa
    SELECT @AnexoExistente = Id
    FROM T_ANEXO
    WHERE PersonaProgramaId = @p_PersonaProgramaId
      AND Nombre = @p_Nombre
      AND Estado = '1';

    IF @AnexoExistente IS NOT NULL
    BEGIN
        -- UPDATE - Reemplazar archivo existente
        UPDATE T_ANEXO
        SET TipoArchivo = @p_TipoArchivo,
            RutaArchivo = @p_RutaArchivo,
            FechaAccion = GETDATE()
        WHERE Id = @AnexoExistente;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END; -- Retorna 1 para indicar actualización
    END
    ELSE
    BEGIN
        -- INSERT - Crear nuevo anexo
        INSERT INTO T_ANEXO (
            PersonaProgramaId,
            Nombre,
            TipoArchivo,
            RutaArchivo,
            Estado,
            FechaAccion,
            FechaCreacion
        )
        VALUES (
            @p_PersonaProgramaId,
            @p_Nombre,
            @p_TipoArchivo,
            @p_RutaArchivo,
            '1',
            GETDATE(),
            GETDATE()
        );

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END; -- Retorna 1 para indicar inserción
    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

-- =============================================
-- S_INS_UPD_CERTIFICADO_EMO
-- Inserta o actualiza información del certificado EMO
-- Incluye actualización de datos de la persona
-- =============================================
CREATE   PROCEDURE S_INS_UPD_CERTIFICADO_EMO
(
    @p_Id INT = NULL,
    @p_PersonaProgramaId INT,

    -- Parámetros del Certificado
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
    @p_FechaCaducidad DATETIME = NULL,

    -- Parámetros de la Persona (opcionales para actualización)
    @p_Nombres NVARCHAR(100) = NULL,
    @p_Apellidos NVARCHAR(100) = NULL,
    @p_Edad INT = NULL,
    @p_Genero NVARCHAR(20) = NULL,
    @p_GrupoSanguineo NVARCHAR(10) = NULL,
    @p_Rh NVARCHAR(10) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;
    DECLARE @PersonaId INT = NULL;

    -- 1. OBTENER PersonaId desde PersonaPrograma
    SELECT @PersonaId = PersonaId
    FROM T_PERSONA_PROGRAMA
    WHERE Id = @p_PersonaProgramaId AND Estado = '1';

    IF @PersonaId IS NULL
    BEGIN
        SET @VALOR = -1;
        RETURN @VALOR;
    END

    -- 2. ACTUALIZAR DATOS DE LA PERSONA (si se proporcionaron)
    IF @p_Nombres IS NOT NULL
       OR @p_Apellidos IS NOT NULL
       OR @p_Edad IS NOT NULL
       OR @p_Genero IS NOT NULL
       OR @p_GrupoSanguineo IS NOT NULL
       OR @p_Rh IS NOT NULL
    BEGIN
        UPDATE T_PERSONA
        SET Nombres = ISNULL(@p_Nombres, Nombres),
            Apellidos = ISNULL(@p_Apellidos, Apellidos),
            Edad = ISNULL(@p_Edad, Edad),
            Genero = ISNULL(@p_Genero, Genero),
            GrupoSanguineo = ISNULL(@p_GrupoSanguineo, GrupoSanguineo),
            Rh = ISNULL(@p_Rh, Rh),
            FechaAccion = GETDATE()
        WHERE Id = @PersonaId;

        IF @@ROWCOUNT > 0
            SET @VALOR = 1;
    END

    -- 3. MANEJAR CERTIFICADO
    IF @p_Id IS NOT NULL
    BEGIN
        -- UPDATE CERTIFICADO
        UPDATE T_CERTIFICADO_EMO
        SET DoctorId = ISNULL(@p_DoctorId, DoctorId),
            Codigo = ISNULL(@p_Codigo, Codigo),
            Password = ISNULL(@p_Password, Password),
            PuestoAlQuePostula = ISNULL(@p_PuestoAlQuePostula, PuestoAlQuePostula),
            PuestoActual = ISNULL(@p_PuestoActual, PuestoActual),
            TipoEvaluacion = ISNULL(@p_TipoEvaluacion, TipoEvaluacion),
            TipoResultado = ISNULL(@p_TipoResultado, TipoResultado),
            Observaciones = @p_Observaciones,
            Conclusiones = @p_Conclusiones,
            Restricciones = @p_Restricciones,
            FechaEvaluacion = ISNULL(@p_FechaEvaluacion, FechaEvaluacion),
            FechaCaducidad = ISNULL(@p_FechaCaducidad, FechaCaducidad),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        IF @@ROWCOUNT > 0
            SET @VALOR = 1;
    END
    ELSE
    BEGIN
        -- INSERT CERTIFICADO
        INSERT INTO T_CERTIFICADO_EMO (
            PersonaProgramaId,
            DoctorId,
            Codigo,
            Password,
            PuestoAlQuePostula,
            PuestoActual,
            TipoEvaluacion,
            TipoResultado,
            Observaciones,
            Conclusiones,
            Restricciones,
            FechaEvaluacion,
            FechaCaducidad,
            RutaArchivoPDF,
            NombreArchivo,
            Estado,
            FechaAccion,
            FechaCreacion
        )
        VALUES (
            @p_PersonaProgramaId,
            @p_DoctorId,
            @p_Codigo,
            @p_Password,
            @p_PuestoAlQuePostula,
            @p_PuestoActual,
            @p_TipoEvaluacion,
            @p_TipoResultado,
            @p_Observaciones,
            @p_Conclusiones,
            @p_Restricciones,
            @p_FechaEvaluacion,
            @p_FechaCaducidad,
            '',
            '',
            '1',
            GETDATE(),
            GETDATE()
        );

        IF @@ROWCOUNT > 0
            SET @VALOR = 1;
    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE   PROCEDURE [dbo].[S_INS_UPD_DOCTOR](
    @p_Id INT = NULL,
    @p_Codigo NVARCHAR(100) = NULL,
    @p_Nombres NVARCHAR(100) = NULL,
    @p_Apellidos NVARCHAR(100) = NULL,
    @p_TipoDocumento NVARCHAR(50) = NULL,
    @p_NDocumentoIdentidad NVARCHAR(20) = NULL,
    @p_Genero NVARCHAR(20) = NULL,
    @p_Especialidad NVARCHAR(200) = NULL,
    @p_RutaImagenFirma NVARCHAR(200) = NULL,
    @p_RutaCertificadoDigital NVARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VALOR INT = 0;
    DECLARE @PERSONAID INT = NULL;

    ----------------------------------------------------------------------
    -- CREAR
    ----------------------------------------------------------------------
    IF @p_Id IS NULL OR @p_Id = 0
        BEGIN
            INSERT INTO T_PERSONA (Nombres, Apellidos, TipoDocumento, NDocumentoIdentidad, Genero, Estado, FechaAccion, FechaCreacion)
            VALUES (@p_Nombres, @p_Apellidos, @p_TipoDocumento, @p_NDocumentoIdentidad, @p_Genero, '1', GETDATE(), GETDATE());

            SET @PERSONAID = SCOPE_IDENTITY();

            INSERT INTO T_DOCTOR (PersonaId, Codigo, Especialidad, RutaImagenFirma, RutaCertificadoDigital, Estado, FechaAccion, FechaCreacion)
            VALUES (@PERSONAID, @p_Codigo, @p_Especialidad, NULLIF(@p_RutaImagenFirma, ''), NULLIF(@p_RutaCertificadoDigital, ''), '1', GETDATE(), GETDATE());

            SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
        END
    ELSE
        BEGIN
            ----------------------------------------------------------------------
            -- EDITAR
            ----------------------------------------------------------------------
            SELECT @PERSONAID = PersonaId
            FROM T_DOCTOR
            WHERE Id = @p_Id AND Estado = '1';

            IF @PERSONAID > 0
                BEGIN
                    UPDATE T_PERSONA
                    SET Nombres = ISNULL(@p_Nombres, Nombres),
                        Apellidos = ISNULL(@p_Apellidos, Apellidos),
                        TipoDocumento = ISNULL(@p_TipoDocumento, TipoDocumento),
                        NDocumentoIdentidad = ISNULL(@p_NDocumentoIdentidad, NDocumentoIdentidad),
                        Genero = ISNULL(@p_Genero, Genero),
                        FechaAccion = GETDATE()
                    WHERE Id = @PERSONAID;

                    UPDATE T_DOCTOR
                    SET Codigo = ISNULL(@p_Codigo, Codigo),
                        Especialidad = ISNULL(@p_Especialidad, Especialidad),
                        RutaImagenFirma = ISNULL(@p_RutaImagenFirma, RutaImagenFirma),
                        RutaCertificadoDigital = ISNULL(@p_RutaCertificadoDigital, RutaCertificadoDigital),
                        FechaAccion = GETDATE()
                    WHERE Id = @p_Id;

                    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
                END
        END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE   PROCEDURE S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL(
    @p_Id INT = NULL,
    @p_Nombre NVARCHAR(300) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL
    BEGIN

        UPDATE T_EXAMEN_MEDICO_OCUPACIONAL
        SET Nombre      = ISNULL(@p_Nombre, Nombre),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    END
    ELSE
    BEGIN

        INSERT INTO T_EXAMEN_MEDICO_OCUPACIONAL (Nombre, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_Nombre, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END;
go

CREATE     PROCEDURE S_INS_UPD_PERFIL_OCUPACIONAL(
    @p_Id INT = NULL,
    @p_Nombre NVARCHAR(200) = NULL,
    @p_ProgramaEMOId INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL AND @p_Id > 0
    BEGIN
        UPDATE T_PERFIL_OCUPACIONAL
        SET Nombre = ISNULL(@p_Nombre, Nombre),
            ProgramaEMOId = ISNULL(@p_ProgramaEMOId, ProgramaEMOId),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END
    ELSE
    BEGIN
        INSERT INTO T_PERFIL_OCUPACIONAL (Nombre, ProgramaEMOId, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_Nombre, @p_ProgramaEMOId, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE PROCEDURE [dbo].[S_INS_UPD_PERSONA]
    @p_PersonaId INT = NULL,
    @p_Nombres NVARCHAR(100) = NULL,
    @p_Apellidos NVARCHAR(100) = NULL,
    @p_TipoDocumento NVARCHAR(50) = NULL,
    @p_NDocumentoIdentidad NVARCHAR(20) = NULL,
    @p_Telefono NVARCHAR(20) = NULL,
    @p_Correo NVARCHAR(100) = NULL,
    @p_Edad INT = NULL,
    @p_Genero NVARCHAR(20) = NULL,
    @p_GrupoSanguineo NVARCHAR(10) = NULL,
    @p_Rh NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VALOR INT = 0;
    DECLARE @PersonaIdExistente INT = NULL;

    -- ==================
    -- MODO CREACIÓN
    -- ==================
    IF @p_PersonaId IS NULL
    BEGIN
        -- Validar DNI obligatorio
        IF @p_NDocumentoIdentidad IS NULL OR @p_NDocumentoIdentidad = ''
        BEGIN
            SET @VALOR = -1; -- DNI requerido
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        -- Verificar si existe persona con ese DNI
        SELECT @PersonaIdExistente = Id
        FROM T_PERSONA
        WHERE NDocumentoIdentidad = @p_NDocumentoIdentidad
          AND Estado = '1';

        -- Validar que el DNI ya esté registrado
        IF @PersonaIdExistente IS NOT NULL
        BEGIN
            SET @VALOR = -2; -- DNI ya existe
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        -- Crear persona
        INSERT INTO T_PERSONA (Nombres, Apellidos, TipoDocumento, NDocumentoIdentidad,
                               Telefono, Correo, Edad, Genero, GrupoSanguineo, Rh,
                               Estado, FechaAccion, FechaCreacion)
        VALUES (ISNULL(@p_Nombres, ''),
                ISNULL(@p_Apellidos, ''),
                @p_TipoDocumento,
                @p_NDocumentoIdentidad,
                @p_Telefono,
                @p_Correo,
                @p_Edad,
                @p_Genero,
                @p_GrupoSanguineo,
                @p_Rh,
                '1',
                GETDATE(),
                GETDATE());

        IF @@ROWCOUNT = 0
        BEGIN
            SET @VALOR = -3; -- Error al insertar
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        SET @VALOR = 1; -- Se creó correctamente
        SET NOCOUNT OFF;
        RETURN @VALOR;
    END
    -- ==================
    -- MODO EDICIÓN
    -- ==================
    ELSE
    BEGIN
        UPDATE T_PERSONA
        SET Nombres        = ISNULL(@p_Nombres, Nombres),
            Apellidos      = ISNULL(@p_Apellidos, Apellidos),
            TipoDocumento  = ISNULL(@p_TipoDocumento, TipoDocumento),
            Telefono       = ISNULL(@p_Telefono, Telefono),
            Correo         = ISNULL(@p_Correo, Correo),
            Edad           = ISNULL(@p_Edad, Edad),
            Genero         = ISNULL(@p_Genero, Genero),
            GrupoSanguineo = ISNULL(@p_GrupoSanguineo, GrupoSanguineo),
            Rh             = ISNULL(@p_Rh, Rh),
            FechaAccion    = GETDATE()
        WHERE Id = @p_PersonaId;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @VALOR = -3; -- Error al actualizar
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        SET @VALOR = 1; -- Actualizado correctamente
        SET NOCOUNT OFF;
        RETURN @VALOR;
    END
END
go

CREATE PROCEDURE [dbo].[S_INS_UPD_PERSONA_PROGRAMA]
    -- Identificadores
    @p_ParticipanteId INT = NULL,
    -- Datos de Persona
    @p_Nombres NVARCHAR(100) = NULL,
    @p_Apellidos NVARCHAR(100) = NULL,
    @p_TipoDocumento NVARCHAR(50) = NULL,
    @p_NDocumentoIdentidad NVARCHAR(20) = NULL,
    @p_Telefono NVARCHAR(20) = NULL,
    @p_Correo NVARCHAR(100) = NULL,
    @p_Edad INT = NULL,
    @p_Genero NVARCHAR(20) = NULL,
    @p_GrupoSanguineo NVARCHAR(10) = NULL,
    @p_Rh NVARCHAR(10) = NULL,
    -- Datos de Participante
    @p_ProgramaEMOId INT = NULL,
    @p_PerfilTipoEMOId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VALOR INT = 0;
    DECLARE @PersonaId INT = NULL;
    DECLARE @PersonaIdExistente INT = NULL;
    DECLARE @ProgramaActual INT = NULL;
    DECLARE @ParticipanteExistente INT = NULL;

    -- ==================
    -- MODO CREACIÓN
    -- ==================
    IF @p_ParticipanteId IS NULL
    BEGIN
        -- VERIFICAR SI YA EXISTE PERSONA CON ESE DNI
        SELECT @PersonaIdExistente = Id
        FROM T_PERSONA
        WHERE NDocumentoIdentidad = @p_NDocumentoIdentidad
          AND Estado = '1';

        -- SI LA PERSONA EXISTE, ACTUALIZAR SUS DATOS
        IF @PersonaIdExistente IS NOT NULL
        BEGIN
            UPDATE T_PERSONA
            SET Nombres = ISNULL(@p_Nombres, Nombres),
                Apellidos = ISNULL(@p_Apellidos, Apellidos),
                TipoDocumento = ISNULL(@p_TipoDocumento, TipoDocumento),
                Telefono = ISNULL(@p_Telefono, Telefono),
                Correo = ISNULL(@p_Correo, Correo),
                Edad = ISNULL(@p_Edad, Edad),
                Genero = ISNULL(@p_Genero, Genero),
                GrupoSanguineo = ISNULL(@p_GrupoSanguineo, GrupoSanguineo),
                Rh = ISNULL(@p_Rh, Rh),
                FechaAccion = GETDATE()
            WHERE Id = @PersonaIdExistente;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @VALOR = -1;
                SET NOCOUNT OFF;
                RETURN @VALOR;
            END

            SET @PersonaId = @PersonaIdExistente;
        END
        -- SI NO EXISTE, CREAR PERSONA
        ELSE
        BEGIN
            INSERT INTO T_PERSONA (
                Nombres, Apellidos, TipoDocumento, NDocumentoIdentidad,
                Telefono, Correo, Edad, Genero, GrupoSanguineo, Rh,
                Estado, FechaAccion, FechaCreacion
            )
            VALUES (
                ISNULL(@p_Nombres, ''),
                ISNULL(@p_Apellidos, ''),
                @p_TipoDocumento,
                @p_NDocumentoIdentidad,
                @p_Telefono,
                @p_Correo,
                @p_Edad,
                @p_Genero,
                @p_GrupoSanguineo,
                @p_Rh,
                '1',
                GETDATE(),
                GETDATE()
            );

            IF @@ROWCOUNT = 0
            BEGIN
                SET @VALOR = -1;
                SET NOCOUNT OFF;
                RETURN @VALOR;
            END

            SET @PersonaId = SCOPE_IDENTITY();
        END

        -- VALIDAR QUE LA PERSONA NO ESTÉ YA EN EL MISMO PROGRAMA
        SELECT @ParticipanteExistente = Id
        FROM T_PERSONA_PROGRAMA
        WHERE PersonaId = @PersonaId
          AND ProgramaEMOId = @p_ProgramaEMOId
          AND Estado = '1';

        IF @ParticipanteExistente IS NOT NULL
        BEGIN
            SET @VALOR = -1;
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        -- CREAR PARTICIPANTE
        INSERT INTO T_PERSONA_PROGRAMA (
            PersonaId, ProgramaEMOId, PerfilTipoEMOId,
            Estado, FechaAccion, FechaCreacion
        )
        VALUES (
            @PersonaId,
            @p_ProgramaEMOId,
            @p_PerfilTipoEMOId,
            '1',
            GETDATE(),
            GETDATE()
        );

        IF @@ROWCOUNT = 0
        BEGIN
            SET @VALOR = -1;
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        SET @VALOR = 1;
        SET NOCOUNT OFF;
        RETURN @VALOR;
    END

    -- ==================
    -- MODO EDICIÓN
    -- ==================
    ELSE
    BEGIN
        -- OBTENER PERSONA Y PROGRAMA DEL PARTICIPANTE
        SELECT @PersonaId = PersonaId, @ProgramaActual = ProgramaEMOId
        FROM T_PERSONA_PROGRAMA
        WHERE Id = @p_ParticipanteId
          AND Estado = '1';

        IF @PersonaId IS NULL OR @ProgramaActual IS NULL
        BEGIN
            SET @VALOR = -1;
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        -- ACTUALIZAR PERSONA (DNI NO SE ACTUALIZA)
        UPDATE T_PERSONA
        SET Nombres = ISNULL(@p_Nombres, Nombres),
            Apellidos = ISNULL(@p_Apellidos, Apellidos),
            TipoDocumento = ISNULL(@p_TipoDocumento, TipoDocumento),
            Telefono = ISNULL(@p_Telefono, Telefono),
            Correo = ISNULL(@p_Correo, Correo),
            Edad = ISNULL(@p_Edad, Edad),
            Genero = ISNULL(@p_Genero, Genero),
            GrupoSanguineo = ISNULL(@p_GrupoSanguineo, GrupoSanguineo),
            Rh = ISNULL(@p_Rh, Rh),
            FechaAccion = GETDATE()
        WHERE Id = @PersonaId;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @VALOR = -1;
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        -- ACTUALIZAR PARTICIPANTE (SOLO PERFIL+TIPO, PROGRAMA NO SE CAMBIA)
        UPDATE T_PERSONA_PROGRAMA
        SET PerfilTipoEMOId = @p_PerfilTipoEMOId,
            FechaAccion = GETDATE()
        WHERE Id = @p_ParticipanteId;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @VALOR = -1;
            SET NOCOUNT OFF;
            RETURN @VALOR;
        END

        SET @VALOR = 1;
        SET NOCOUNT OFF;
        RETURN @VALOR;
    END
END
go

CREATE     PROCEDURE S_INS_UPD_PROGRAMA_EMO(
    @p_Id INT = NULL,
    @p_Nombre NVARCHAR(300) = NULL,
    @p_EntidadId INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL AND @p_Id > 0
    BEGIN
        UPDATE T_PROGRAMA_EMO
        SET Nombre = ISNULL(@p_Nombre, Nombre),
            EntidadId = ISNULL(@p_EntidadId, EntidadId),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END
    ELSE
    BEGIN
        INSERT INTO T_PROGRAMA_EMO (Nombre, EntidadId, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_Nombre, @p_EntidadId, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

-- Procedimiento para Insertar/Actualizar
CREATE PROCEDURE S_INS_UPD_PROGRAMA_EMO_EXAMEN_MEDICO(
    @p_ProgramEMOExamenMedicoId INT = NULL,
    @p_ProgramaEMOId INT = NULL,
    @p_ExamenMedicoId INT = NULL,
    @p_Orden INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_ProgramEMOExamenMedicoId IS NOT NULL AND @p_ProgramEMOExamenMedicoId > 0
    BEGIN
        UPDATE T_PROGRAMA_EMO_EXAMEN_MEDICO
        SET Orden = ISNULL(@p_Orden, Orden),
            FechaAccion = GETDATE()
        WHERE Id = @p_ProgramEMOExamenMedicoId;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END
    ELSE
    BEGIN
        INSERT INTO T_PROGRAMA_EMO_EXAMEN_MEDICO (ProgramaEMOId, ExamenMedicoId, Orden, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_ProgramaEMOId, @p_ExamenMedicoId, @p_Orden, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE  PROCEDURE S_INS_UPD_PROTOCOLO_EMO
(
    @p_PerfilOcupacionalId INT,
    @p_TipoEMO NVARCHAR(150),
    @p_ExamenMedicoOcupacionalId INT,
    @p_EsRequerido BIT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VALOR INT = 1; -- Valor por defecto = éxito
    DECLARE @PerfilTipoEMOId INT = NULL;
    DECLARE @IdExistente INT = NULL;
    DECLARE @TipoEMONormalizado NVARCHAR(150);

    BEGIN TRY

        -- NORMALIZAR TipoEMO
        SET @TipoEMONormalizado = UPPER(LTRIM(RTRIM(@p_TipoEMO)));

        -- Buscar si existe el PerfilTipoEMO activo
        SELECT @PerfilTipoEMOId = Id
        FROM T_PERFIL_TIPO_EMO
        WHERE PerfilOcupacionalId = @p_PerfilOcupacionalId
          AND UPPER(TipoEMO) = @TipoEMONormalizado
          AND Estado = '1';

        IF @PerfilTipoEMOId IS NULL
        BEGIN
            -- Existe desactivado → reactivar
            IF EXISTS (
                SELECT 1 FROM T_PERFIL_TIPO_EMO
                WHERE PerfilOcupacionalId = @p_PerfilOcupacionalId
                  AND UPPER(TipoEMO) = @TipoEMONormalizado
            )
            BEGIN
                UPDATE T_PERFIL_TIPO_EMO
                SET Estado = '1', FechaAccion = GETDATE()
                WHERE PerfilOcupacionalId = @p_PerfilOcupacionalId
                  AND UPPER(TipoEMO) = @TipoEMONormalizado;

                SELECT @PerfilTipoEMOId = Id
                FROM T_PERFIL_TIPO_EMO
                WHERE PerfilOcupacionalId = @p_PerfilOcupacionalId
                  AND UPPER(TipoEMO) = @TipoEMONormalizado;
            END
            ELSE
            BEGIN
                -- Crear nuevo registro
                INSERT INTO T_PERFIL_TIPO_EMO
                (PerfilOcupacionalId, TipoEMO, Estado, FechaAccion, FechaCreacion)
                VALUES
                (@p_PerfilOcupacionalId, @TipoEMONormalizado, '1', GETDATE(), GETDATE());

                SET @PerfilTipoEMOId = SCOPE_IDENTITY();
            END
        END

        -- Buscar si existe el protocolo activo
        SELECT @IdExistente = Id
        FROM T_PROTOCOLO_EMO
        WHERE PerfilTipoEMOId = @PerfilTipoEMOId
          AND ExamenMedicoOcupacionalId = @p_ExamenMedicoOcupacionalId
          AND Estado = '1';

        IF @IdExistente IS NOT NULL
        BEGIN
            -- Actualizar
            UPDATE T_PROTOCOLO_EMO
            SET EsRequerido = ISNULL(@p_EsRequerido, EsRequerido),
                FechaAccion = GETDATE()
            WHERE Id = @IdExistente;
        END
        ELSE
        BEGIN
            -- Existe inactivo → reactivar
            SELECT @IdExistente = Id
            FROM T_PROTOCOLO_EMO
            WHERE PerfilTipoEMOId = @PerfilTipoEMOId
              AND ExamenMedicoOcupacionalId = @p_ExamenMedicoOcupacionalId
              AND Estado = '0';

            IF @IdExistente IS NOT NULL
            BEGIN
                UPDATE T_PROTOCOLO_EMO
                SET EsRequerido = ISNULL(@p_EsRequerido, 1),
                    Estado = '1',
                    FechaAccion = GETDATE()
                WHERE Id = @IdExistente;
            END
            ELSE
            BEGIN
                -- Insertar nuevo
                INSERT INTO T_PROTOCOLO_EMO
                (PerfilTipoEMOId, ExamenMedicoOcupacionalId, EsRequerido, Estado, FechaAccion, FechaCreacion)
                VALUES
                (@PerfilTipoEMOId, @p_ExamenMedicoOcupacionalId, ISNULL(@p_EsRequerido, 1), '1', GETDATE(), GETDATE());
            END
        END

    END TRY
    BEGIN CATCH
        SET @VALOR = -1; -- Error
    END CATCH;

    RETURN @VALOR;
END
go

-- =============================================
-- VERSIÓN MEJORADA con validaciones
-- =============================================
CREATE PROCEDURE S_INS_UPD_RESULTADO_EXAMEN
(
    @p_PersonaProgramaId INT,
    @p_ProtocoloEMOId INT,
    @p_Realizado BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;
    DECLARE @ResultadoId INT;
    DECLARE @CambioRealizado BIT = 0;

    -- 1. VALIDAR que PersonaProgramaId existe y está activo
    IF NOT EXISTS (
        SELECT 1 FROM T_PERSONA_PROGRAMA 
        WHERE Id = @p_PersonaProgramaId AND Estado = '1'
    )
    BEGIN
        SET @VALOR = -2; -- Código: PersonaPrograma no existe o inactivo
        RETURN @VALOR;
    END

    -- 2. VALIDAR que ProtocoloEMOId existe, está activo y corresponde al PerfilTipoEMO correcto
    IF NOT EXISTS (
        SELECT 1 
        FROM T_PROTOCOLO_EMO PRO
        INNER JOIN T_PERSONA_PROGRAMA PP ON PP.PerfilTipoEMOId = PRO.PerfilTipoEMOId
        WHERE PRO.Id = @p_ProtocoloEMOId 
          AND PRO.Estado = '1'
          AND PP.Id = @p_PersonaProgramaId
    )
    BEGIN
        SET @VALOR = -3; -- Código: Protocolo no válido para esta PersonaPrograma
        RETURN @VALOR;
    END

    -- 3. Verificar si ya existe el registro
    SELECT @ResultadoId = Id
    FROM T_RESULTADO_EMO
    WHERE PersonaProgramaId = @p_PersonaProgramaId
      AND ProtocoloEMOId = @p_ProtocoloEMOId
      AND Estado = '1';

    IF @ResultadoId IS NOT NULL
    BEGIN
        -- UPDATE solo si hay cambio real
        UPDATE T_RESULTADO_EMO
        SET Realizado = @p_Realizado,
            FechaAccion = GETDATE()
        WHERE Id = @ResultadoId
          AND Realizado <> @p_Realizado; -- Solo actualiza si cambió

        SET @CambioRealizado = @@ROWCOUNT;
        SET @VALOR = CASE 
            WHEN @CambioRealizado > 0 THEN 2  -- Código: Actualizado
            ELSE 0                             -- Código: Sin cambios
        END;
    END
    ELSE
    BEGIN
        -- INSERT
        INSERT INTO T_RESULTADO_EMO (
            PersonaProgramaId,
            ProtocoloEMOId,
            Realizado,
            Estado,
            FechaAccion,
            FechaCreacion
        )
        VALUES (
            @p_PersonaProgramaId,
            @p_ProtocoloEMOId,
            @p_Realizado,
            '1',
            GETDATE(),
            GETDATE()
        );

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END; -- Código: Insertado
    END

    IF @@ERROR <> 0
        SET @VALOR = -1; -- Código: Error general

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE   PROCEDURE S_INS_UPD_USUARIO
(
    @p_UsuarioId INT = NULL,
    @p_UserName NVARCHAR(100) = NULL,
    @p_Password NVARCHAR(150) = NULL,
    @p_PersonaId INT = NULL,
    @p_RolId INT = NULL
)
AS
BEGIN
    DECLARE  @VALOR INT = 0;

   IF @p_UsuarioId IS NULL OR @p_UsuarioId  = 0
    BEGIN
        INSERT INTO T_USUARIO (
            UserName,
            Password,
            PersonaId,
            RolId,
            Estado,
            FechaCreacion,
            FechaAccion
        )
        VALUES (
            @p_UserName,
            @p_Password,
            @p_PersonaId,
            @p_RolId,
            '1',
            GETDATE(),
            GETDATE()
        );
        IF @@ROWCOUNT > 0
            BEGIN
                SET @VALOR =  1;
            end
    end
    ELSE
    BEGIN
        UPDATE
            T_USUARIO
        SET
            UserName = ISNULL(@p_UserName, UserName),
            Password = ISNULL(@p_Password, Password),
            PersonaId = ISNULL(@p_PersonaId, PersonaId),
            RolId = ISNULL(@p_RolId, RolId),
            FechaAccion = GETDATE()
        WHERE
            Id = @p_UsuarioId
            AND Estado = '1';
    END
END
go

-- =============================================
-- PROCEDIMIENTO 2: LISTAR ANEXOS POR PERSONA PROGRAMA
-- Procedimiento separado para gestionar anexos de forma independiente
-- =============================================
CREATE   PROCEDURE S_SEL_ANEXOS_PERSONA_PROGRAMA
    @p_PersonaProgramaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        A.Id,
        A.PersonaProgramaId,
        A.Nombre,
        A.RutaArchivo,
        A.Estado,
        A.FechaCreacion,
        A.FechaAccion
    FROM T_ANEXO A
    INNER JOIN T_PERSONA_PROGRAMA PP ON A.PersonaProgramaId = PP.Id
    INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
    INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
    WHERE A.PersonaProgramaId = @p_PersonaProgramaId
      AND A.Estado = '1'
    ORDER BY A.FechaCreacion DESC;

    SET NOCOUNT OFF;
END
go

CREATE PROCEDURE [dbo].[S_SEL_CERTIFICADO_VALIDAR_ACCESO]
(
    @p_CodigoCertificado NVARCHAR(50),
    @p_Password NVARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Datos Certificado
        C.Codigo,
        C.RutaArchivoPDF,
        C.TipoEvaluacion,
        C.TipoResultado,
        C.PuestoAlQuePostula,
        C.PuestoActual,
        C.Observaciones,
        C.Restricciones,
        C.FechaEvaluacion,
        C.FechaCaducidad,
        C.FechaGeneracion,
        C.Estado,
        -- Datos Persona
        P.Nombres,
        P.Apellidos,
        P.TipoDocumento,
        P.NDocumentoIdentidad,
        P.Edad,
        P.Genero,
        P.GrupoSanguineo,
        P.Rh,
        -- Datos Doctor
        PD.Nombres AS DoctorNombres,
        PD.Apellidos AS DoctorApellidos,
        D.Especialidad AS DoctorEspecialidad,
        D.Codigo AS DoctorCodigo
    FROM T_CERTIFICADO_EMO C
    INNER JOIN T_PERSONA_PROGRAMA PP ON PP.Id = C.PersonaProgramaId
    INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
    INNER JOIN T_DOCTOR D ON D.Id = C.DoctorId
    INNER JOIN T_PERSONA PD ON D.PersonaId = PD.Id
    WHERE C.Codigo = @p_CodigoCertificado
      AND P.NDocumentoIdentidad = @p_Password
      AND LTRIM(RTRIM(C.RutaArchivoPDF)) <> ''
      AND C.Estado = '1';

    SET NOCOUNT OFF;
END
go

-- Actualizar SP S_SEL_DOCTORES
CREATE PROCEDURE [dbo].[S_SEL_DOCTORES]
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        d.Id,
        d.PersonaId,
        d.Codigo,
        p.Nombres,
        p.Apellidos,
        p.TipoDocumento,
        p.NDocumentoIdentidad,
        p.Genero,
        d.Especialidad,
        d.RutaImagenFirma,
        d.RutaCertificadoDigital,
        d.Estado,
        CASE 
            WHEN p.Nombres IS NOT NULL 
                AND p.Apellidos IS NOT NULL 
                AND p.TipoDocumento IS NOT NULL 
                AND p.NDocumentoIdentidad IS NOT NULL 
                AND d.Codigo IS NOT NULL 
                AND d.Especialidad IS NOT NULL 
            THEN 1 
            ELSE 0 
        END AS DatosCompletos
    FROM T_DOCTOR d
    INNER JOIN T_PERSONA p ON d.PersonaId = p.Id
    WHERE d.Estado = '1' AND p.Estado = '1'
    ORDER BY d.Id DESC
    
    SET NOCOUNT OFF
END
go

CREATE   PROCEDURE [dbo].[S_SEL_DOCTOR_POR_ID]
@p_DoctorId INT
AS
SET NOCOUNT ON

    SELECT
        d.Id,
        d.PersonaId,
        d.Codigo,
        p.Nombres,
        p.Apellidos,
        p.TipoDocumento,
        p.NDocumentoIdentidad,
        d.Especialidad,
        d.Estado,
        d.FechaCreacion,
        d.FechaAccion
    FROM T_DOCTOR d
    INNER JOIN T_PERSONA p ON d.PersonaId = p.Id
    WHERE d.Id = @p_DoctorId

SET NOCOUNT OFF
go

CREATE     PROCEDURE S_SEL_ENTIDADES
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM T_ENTIDAD WHERE Estado = '1' order by Id desc;

    SET NOCOUNT OFF;
END
go

CREATE   PROCEDURE S_SEL_ESTADISTICAS_PROTOCOLO_EMO
    @p_ProgramaId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH CTE_Datos AS (
        SELECT
            PP.ProgramaEMOId,
            PROG.Nombre AS ProgramaNombre,
            PP.Id AS PersonaProgramaId,

            -- Validador 1: Exámenes completos
            CASE
                WHEN PP.PerfilTipoEMOId IS NULL OR PTE.Estado != '1' THEN 0
                WHEN NOT EXISTS (SELECT 1 FROM T_PROTOCOLO_EMO
                                 WHERE PerfilTipoEMOId = PP.PerfilTipoEMOId
                                   AND EsRequerido = 1 AND Estado = '1') THEN 0
                WHEN EXISTS (SELECT 1 FROM T_PROTOCOLO_EMO PRO
                             LEFT JOIN T_RESULTADO_EMO RE
                                   ON PRO.Id = RE.ProtocoloEMOId
                                  AND RE.PersonaProgramaId = PP.Id
                                  AND RE.Estado = '1'
                             WHERE PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId
                               AND PRO.EsRequerido = 1 AND PRO.Estado = '1'
                               AND (RE.Id IS NULL OR RE.Realizado = 0)) THEN 0
                ELSE 1
            END AS ValidadorExamenesCompletos,

            -- Validador 2: Datos del certificado completos
            CASE
                WHEN CE.Id IS NULL OR CE.Estado != '1'
                  OR ISNULL(RTRIM(CE.Codigo), '') = ''
                  OR ISNULL(RTRIM(CE.TipoEvaluacion), '') = ''
                  OR ISNULL(RTRIM(CE.TipoResultado), '') = ''
                  OR CE.FechaEvaluacion IS NULL
                  OR (ISNULL(RTRIM(CE.PuestoAlQuePostula), '') = ''
                      AND ISNULL(RTRIM(CE.PuestoActual), '') = '')
                THEN 0
                ELSE 1
            END AS ValidadorDatosCertificado,

            -- Es finalizado: solo si Estado='1' y tiene PDF
            CASE
                WHEN CE.Estado = '1' AND LEN(ISNULL(CE.RutaArchivoPDF, '')) > 0 THEN 1
                ELSE 0
            END AS EsFinalizado

        FROM T_PERSONA_PROGRAMA PP
        INNER JOIN T_PROGRAMA_EMO PROG ON PP.ProgramaEMOId = PROG.Id
        INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id AND P.Estado = '1'
        LEFT JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
        LEFT JOIN T_CERTIFICADO_EMO CE
               ON PP.Id = CE.PersonaProgramaId
              AND CE.Estado = '1'  -- SOLO CERTIFICADOS ACTIVOS

        WHERE PP.Estado = '1'
          AND (@p_ProgramaId IS NULL OR PP.ProgramaEMOId = @p_ProgramaId)
    ),

    CTE_Estados AS (
        SELECT
            ProgramaEMOId,
            ProgramaNombre,
            CASE
                -- 1. FINALIZADO
                WHEN EsFinalizado = 1 THEN 'finalizado'

                -- 2. PENDIENTE
                WHEN EsFinalizado = 0
                 AND (ValidadorExamenesCompletos = 0 OR ValidadorDatosCertificado = 0)
                    THEN 'pendiente'

                -- 3. EN PROCESO
                ELSE 'en_proceso'
            END AS Estado
        FROM CTE_Datos
    )

    -- RESULTADO FINAL
    SELECT
        ProgramaEMOId,
        ProgramaNombre,
        ISNULL(SUM(CASE WHEN Estado = 'pendiente'   THEN 1 ELSE 0 END), 0) AS Pendiente,
        ISNULL(SUM(CASE WHEN Estado = 'en_proceso'  THEN 1 ELSE 0 END), 0) AS EnProceso,
        ISNULL(SUM(CASE WHEN Estado = 'finalizado'  THEN 1 ELSE 0 END), 0) AS Finalizado,
        COUNT(*) AS Total
    FROM CTE_Estados
    GROUP BY ProgramaEMOId, ProgramaNombre
    ORDER BY ProgramaNombre;

    SET NOCOUNT OFF;
END
go

CREATE     PROCEDURE S_SEL_EXAMENES_MEDICOS_OCUPACIONALES
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Estado = '1' ORDER BY Nombre;
    SET NOCOUNT OFF;
END
go

-- =============================================
-- PROCEDIMIENTO: EXÁMENES DEL PERFIL CON ESTADO DE REALIZACIÓN
-- Actualizado para nueva estructura con T_PERFIL_TIPO_EMO
-- Solo muestra exámenes requeridos
-- =============================================
CREATE PROCEDURE S_SEL_EXAMENES_PERSONA_PROGRAMA
    @p_PersonaProgramaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Información del Perfil Ocupacional
        PO.Id AS PerfilOcupacionalId,
        PO.Nombre AS NombrePerfilOcupacional,
        PO.Estado AS EstadoPerfilOcupacional,

        -- Información del Programa EMO
        PO.ProgramaEMOId,
        PE.Nombre AS NombreProgramaEMO,

        -- Información del Perfil-Tipo EMO
        PTE.Id AS PerfilTipoEMOId,
        PTE.TipoEMO,
        PTE.Estado AS EstadoPerfilTipo,

        -- Información del Protocolo
        PRO.Id AS ProtocoloEMOId,
        PRO.EsRequerido,
        PRO.Estado AS EstadoProtocolo,

        -- Información del Examen Médico
        EMO.Id AS ExamenId,
        EMO.Nombre AS NombreExamen,
        EMO.Estado AS EstadoExamen,

        -- Información del Resultado (si existe)
        RE.Id AS ResultadoEMOId,
        ISNULL(RE.Realizado, 0) AS Realizado,
        RE.Estado AS EstadoResultado,
        RE.FechaCreacion AS FechaRealizacion,
        RE.FechaAccion AS FechaAccionResultado

    FROM T_PERSONA_PROGRAMA PP

    -- Join con Perfil-Tipo EMO (puede ser NULL según estructura)
    INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id

    -- Join con Perfil Ocupacional
    INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id

    -- Join con Programa EMO
    INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id

    -- Join con Protocolos (usando la nueva referencia a PerfilTipoEMOId)
    INNER JOIN T_PROTOCOLO_EMO PRO ON PTE.Id = PRO.PerfilTipoEMOId

    -- Join con Exámenes Médicos
    INNER JOIN T_EXAMEN_MEDICO_OCUPACIONAL EMO ON PRO.ExamenMedicoOcupacionalId = EMO.Id

    -- Left Join con Resultados para ver si están realizados
    LEFT JOIN T_RESULTADO_EMO RE ON PRO.Id = RE.ProtocoloEMOId
        AND RE.PersonaProgramaId = @p_PersonaProgramaId
        AND RE.Estado = '1'

    WHERE PP.Id = @p_PersonaProgramaId
      AND PP.Estado = '1'
      AND PTE.Estado = '1'
      AND PRO.Estado = '1'
      AND EMO.Estado = '1'
      AND PRO.EsRequerido = 1  -- ⭐ FILTRO AGREGADO: Solo exámenes requeridos

    ORDER BY EMO.Nombre;

    SET NOCOUNT OFF;
END
go

CREATE PROCEDURE [dbo].[S_SEL_EXISTE_DNI]
    @p_NDocumentoIdentidad NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    
    IF EXISTS (SELECT 1 FROM T_PERSONA WHERE NDocumentoIdentidad = @p_NDocumentoIdentidad)
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
    
    SET NOCOUNT OFF
END
go

CREATE   PROCEDURE S_SEL_OBTENER_DATOS_CERTIFICADO_PDF
    @p_PersonaProgramaId INT
AS
BEGIN
    DECLARE @CERTIFICADOID INT;

    -- Obtener el ID del certificado activo
    SELECT TOP 1 @CERTIFICADOID = CE.Id
    FROM T_PERSONA_PROGRAMA PP
    INNER JOIN T_CERTIFICADO_EMO CE ON PP.Id = CE.PersonaProgramaId
    WHERE PP.Id = @p_PersonaProgramaId
        AND CE.Estado = '1'
        AND PP.Estado = '1';

    -- Retornar los datos del certificado
    SELECT TOP 1
        C.Codigo AS CodigoCertificado,
        P.Nombres + ' ' + P.Apellidos AS ApellidosNombres,
        P.TipoDocumento AS TipoDocumento,
        P.NDocumentoIdentidad AS NumeroDocumento,
        P.Edad AS Edad,
        P.Genero AS Genero,
        C.PuestoAlQuePostula AS PuestoPostula,
        E.Nombre AS Empresa,
        C.PuestoActual AS OcupacionActual,
        P.GrupoSanguineo AS GrupoSanguineo,
        P.Rh AS FactorRH,
        C.Observaciones AS Observaciones,
        C.TipoEvaluacion AS TipoEvaluacion,
        C.TipoResultado AS Resultado,
        C.Restricciones AS Restricciones,
        C.FechaEvaluacion AS FechaEvaluacion,
        C.FechaCaducidad AS FechaCaducidad,
        C.Conclusiones AS Conclusiones,
        C.PuestoActual AS Recomendaciones,
        D.RutaImagenFirma AS RutaImagenFirma,
        PD.Nombres + ' ' + PD.Apellidos AS NombreMedico,
        D.Especialidad AS EspecialidadMedico,
        D.Codigo AS CodigoMedico
    FROM T_CERTIFICADO_EMO C
    INNER JOIN dbo.T_PERSONA_PROGRAMA PP ON C.PersonaProgramaId = PP.Id
    INNER JOIN dbo.T_PERSONA P ON PP.PersonaId = P.Id
    INNER JOIN dbo.T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
    INNER JOIN dbo.T_ENTIDAD E ON PE.EntidadId = E.Id
    INNER JOIN dbo.T_DOCTOR D ON C.DoctorId = D.Id  -- ✅ CORRECCIÓN
    INNER JOIN dbo.T_PERSONA PD ON D.PersonaId = PD.Id
    WHERE C.Id = @CERTIFICADOID;
END
go

-- Crear SP para obtener ID de doctor por DNI
CREATE PROCEDURE [dbo].[S_SEL_OBTENER_DOCTOR_ID_POR_DNI]
    @p_NDocumentoIdentidad NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON

    SELECT TOP 1
        d.Id
    FROM T_DOCTOR d
    INNER JOIN T_PERSONA p ON d.PersonaId = p.Id
    WHERE p.NDocumentoIdentidad = @p_NDocumentoIdentidad
        AND d.Estado = '1'

    SET NOCOUNT OFF
END
go

CREATE   PROCEDURE S_SEL_OBTENER_RUTA_CERTIFICADO
    @p_Codigo NVARCHAR(50) = NULL,
    @p_Password NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RUTACERTIFICADO NVARCHAR(500);

    SELECT @RUTACERTIFICADO = RutaArchivoPDF
    FROM T_CERTIFICADO_EMO
    WHERE Codigo = @p_Codigo
      AND Password = @p_Password
      AND Estado = '1';

    -- Retornar cadena vacía si no se encuentra
    SELECT ISNULL(@RUTACERTIFICADO, '') AS RutaCertificado;

END
go

CREATE   PROCEDURE S_SEL_OBTENER_USUARIO_ID_POR_CREDENCIALES
    @p_UserName NVARCHAR(100),
    @p_Password NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsuarioId INT;

    SELECT TOP 1 @UsuarioId = Id
    FROM T_USUARIO WITH (NOLOCK)
    WHERE UserName = @p_UserName
      AND Password = @p_Password
      AND Estado = '1';

    -- Retorna el Id encontrado o 0
    RETURN ISNULL(@UsuarioId, 0);
END
go

CREATE PROCEDURE S_SEL_PERFILES_OCUPACIONALES
    @ProgramaEMOId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Nombre,
        ProgramaEMOId
    FROM T_PERFIL_OCUPACIONAL
    WHERE ProgramaEMOId = @ProgramaEMOId 
      AND Estado = '1'
    ORDER BY Nombre;
    SET NOCOUNT OFF ;    
END
go

CREATE PROCEDURE S_SEL_PERFIL_TIPO_EMO
    @p_ProgramaEMOId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pte.Id AS PerfilTipoEMOId,
        pte.PerfilOcupacionalId,
        po.Nombre AS NombrePerfilOcupacional,
        pte.TipoEMO
    FROM T_PERFIL_TIPO_EMO pte
    INNER JOIN T_PERFIL_OCUPACIONAL po ON pte.PerfilOcupacionalId = po.Id
    WHERE pte.Estado = '1'
      AND po.Estado = '1'
      AND po.ProgramaEMOId = @p_ProgramaEMOId
    ORDER BY po.Nombre, pte.TipoEMO;

    SET NOCOUNT OFF;
END
go

CREATE PROCEDURE [dbo].[S_SEL_PERSONAS_PROGRAMAS]
    @p_ProgramaEMOId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pp.Id AS ParticipanteId,
        pp.PersonaId,
        p.Nombres,
        p.Apellidos,
        p.TipoDocumento,
        p.NDocumentoIdentidad,
        p.Telefono,
        p.Correo,
        p.Edad,
        p.Genero,
        p.GrupoSanguineo,
        p.Rh,
        pp.ProgramaEMOId,
        pe.Nombre AS ProgramaEMONombre,
        pp.PerfilTipoEMOId,
        pte.PerfilOcupacionalId,
        po.Nombre AS PerfilOcupacionalNombre,
        pte.Id AS PerfilTipoEMOId,
        pte.TipoEMO,
        pp.Estado
    FROM dbo.T_PERSONA_PROGRAMA pp
    INNER JOIN T_PERSONA p ON pp.PersonaId = p.Id
    INNER JOIN T_PROGRAMA_EMO pe ON pp.ProgramaEMOId = pe.Id
    LEFT JOIN T_PERFIL_TIPO_EMO pte ON pp.PerfilTipoEMOId = pte.Id
    LEFT JOIN T_PERFIL_OCUPACIONAL po ON pte.PerfilOcupacionalId = po.Id
    WHERE pp.ProgramaEMOId = @p_ProgramaEMOId
      AND pp.Estado = '1'
    ORDER BY p.Apellidos, p.Nombres;

    SET NOCOUNT OFF;
END
go

CREATE PROCEDURE S_SEL_PERSONAS_PROGRAMAS_CERTIFICADOS
    @p_ProgramaEMOId          INT,
    @p_Pagina                 INT = 1,
    @p_TamanoPagina           INT = 30,
    @p_TipoVigencia           VARCHAR(10) = NULL,
    @p_FechaDesde             DATE = NULL,
    @p_FechaHasta             DATE = NULL,
    @p_Busqueda               NVARCHAR(100) = NULL,
    @p_Atencion               VARCHAR(20) = NULL,
    @p_EstadoCertificado      VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_Pagina < 1        SET @p_Pagina = 1;
    IF @p_TamanoPagina < 1  SET @p_TamanoPagina = 10;

    DECLARE @Offset INT = (@p_Pagina - 1) * @p_TamanoPagina;

    -- CTE 1: Solo datos base + validadores
    WITH CTE_Base AS (
        SELECT
            PP.Id AS PersonaProgramaId,
            PP.Estado AS EstadoPersonaPrograma,
            P.Id AS PersonaId,
            P.Nombres,
            P.Apellidos,
            P.TipoDocumento,
            P.NDocumentoIdentidad,
            P.Edad,
            P.Genero,

            PP.PerfilTipoEMOId,
            PTE.TipoEMO,
            PTE.Estado AS EstadoPerfilTipo,
            PO.Id AS PerfilOcupacionalId,
            PO.Nombre AS PerfilOcupacionalNombre,
            PO.Estado AS EstadoPerfilOcupacional,

            CE.Id AS CertificadoId,
            CE.DoctorId,
            CE.Codigo AS CodigoCertificado,
            CE.Estado AS EstadoCertificado,
            CE.RutaArchivoPDF,
            CE.FechaCaducidad AS FechaCaducidadCertificado,
            CE.FechaEvaluacion AS FechaEvaluacionCertificado,

            -- VALIDADOR 1: Perfil asignado y activo
            CASE
                WHEN PP.PerfilTipoEMOId IS NULL THEN 0
                WHEN PTE.Estado != '1' THEN 0
                WHEN PO.Estado != '1' THEN 0
                ELSE 1
            END AS ValidadorPerfilAsignado,

            -- VALIDADOR 2: Exámenes completos
            CASE
                WHEN PP.PerfilTipoEMOId IS NULL OR PTE.Estado != '1' THEN 0
                WHEN NOT EXISTS (SELECT 1 FROM T_PROTOCOLO_EMO 
                                 WHERE PerfilTipoEMOId = PP.PerfilTipoEMOId 
                                   AND EsRequerido = 1 AND Estado = '1') THEN 0
                WHEN EXISTS (SELECT 1 FROM T_PROTOCOLO_EMO PRO
                             LEFT JOIN T_RESULTADO_EMO RE 
                                   ON PRO.Id = RE.ProtocoloEMOId 
                                  AND RE.PersonaProgramaId = PP.Id 
                                  AND RE.Estado = '1'
                             WHERE PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId
                               AND PRO.EsRequerido = 1 AND PRO.Estado = '1'
                               AND (RE.Id IS NULL OR RE.Realizado = 0)) THEN 0
                ELSE 1 
            END AS ValidadorExamenesCompletos,

            -- VALIDADOR 3: Doctor completo
            CASE
                WHEN CE.DoctorId IS NULL THEN 0
                WHEN D.Id IS NULL OR D.Estado != '1' THEN 0
                WHEN ISNULL(RTRIM(D.Codigo), '') = '' THEN 0
                WHEN ISNULL(RTRIM(D.Especialidad), '') = '' THEN 0
                WHEN PD.Id IS NULL OR PD.Estado != '1' THEN 0
                WHEN ISNULL(RTRIM(PD.Nombres), '') = '' THEN 0
                WHEN ISNULL(RTRIM(PD.Apellidos), '') = '' THEN 0
                WHEN ISNULL(RTRIM(PD.TipoDocumento), '') = '' THEN 0
                WHEN ISNULL(RTRIM(PD.NDocumentoIdentidad), '') = '' THEN 0
                ELSE 1
            END AS ValidadorDoctorCompleto,

            -- VALIDADOR 4: Datos del certificado
            CASE
                WHEN CE.Id IS NULL OR CE.Estado != '1' THEN 0
                WHEN ISNULL(RTRIM(CE.Codigo), '') = '' THEN 0
                WHEN ISNULL(RTRIM(CE.TipoEvaluacion), '') = '' THEN 0
                WHEN ISNULL(RTRIM(CE.TipoResultado), '') = '' THEN 0
                WHEN CE.FechaEvaluacion IS NULL THEN 0
                WHEN ISNULL(RTRIM(CE.PuestoAlQuePostula), '') = '' 
                 AND ISNULL(RTRIM(CE.PuestoActual), '') = '' THEN 0
                ELSE 1
            END AS ValidadorDatosCertificado

        FROM T_PERSONA_PROGRAMA PP
        INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id AND P.Estado = '1'
        LEFT JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id AND PTE.Estado = '1'
        LEFT JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id AND PO.Estado = '1'
        LEFT JOIN T_CERTIFICADO_EMO CE ON PP.Id = CE.PersonaProgramaId AND CE.Estado = '1'
        LEFT JOIN T_DOCTOR D ON CE.DoctorId = D.Id AND D.Estado = '1'
        LEFT JOIN T_PERSONA PD ON D.PersonaId = PD.Id AND PD.Estado = '1'

        WHERE PP.ProgramaEMOId = @p_ProgramaEMOId
          AND PP.Estado = '1'
    ),

    -- CTE 2: Aplicar filtros + paginación (aquí SÍ podemos usar los validadores)
    CTE_Final AS (
        SELECT *,
               ROW_NUMBER() OVER (ORDER BY Apellidos, Nombres) AS RowNum
        FROM CTE_Base
        WHERE 1 = 1

          -- FILTRO: Vigencia
          AND (
                @p_TipoVigencia IS NULL
                OR (@p_TipoVigencia = 'emision' 
                    AND FechaEvaluacionCertificado >= ISNULL(@p_FechaDesde, FechaEvaluacionCertificado)
                    AND FechaEvaluacionCertificado <= ISNULL(@p_FechaHasta, FechaEvaluacionCertificado))
                OR (@p_TipoVigencia = 'caducidad' 
                    AND FechaCaducidadCertificado >= ISNULL(@p_FechaDesde, FechaCaducidadCertificado)
                    AND FechaCaducidadCertificado <= ISNULL(@p_FechaHasta, FechaCaducidadCertificado))
          )

          -- FILTRO: Búsqueda
          AND (
                @p_Busqueda IS NULL
                OR NDocumentoIdentidad LIKE '%' + @p_Busqueda + '%'
                OR (Nombres + ' ' + Apellidos) LIKE '%' + @p_Busqueda + '%'
                OR CodigoCertificado LIKE '%' + @p_Busqueda + '%'
          )

          -- FILTRO: Atención
          AND (
                @p_Atencion IS NULL
                OR (@p_Atencion = 'pendiente' 
                    AND (ValidadorPerfilAsignado = 0 
                         OR ValidadorExamenesCompletos = 0 
                         OR ValidadorDoctorCompleto = 0 
                         OR ValidadorDatosCertificado = 0))
                OR (@p_Atencion = 'en_proceso' 
                    AND ValidadorPerfilAsignado = 1 
                    AND ValidadorExamenesCompletos = 1 
                    AND ValidadorDoctorCompleto = 1 
                    AND ValidadorDatosCertificado = 1
                    AND (CertificadoId IS NULL OR LEN(ISNULL(RutaArchivoPDF, '')) = 0))
                OR (@p_Atencion = 'finalizado'
                    AND CertificadoId IS NOT NULL
                    AND EstadoCertificado = '1'
                    AND LEN(ISNULL(RutaArchivoPDF, '')) > 0)
          )

          -- FILTRO: Estado del certificado
          AND (
                @p_EstadoCertificado IS NULL
                OR (@p_EstadoCertificado = 'sin_certificado' AND (CertificadoId IS NULL OR LEN(ISNULL(RutaArchivoPDF, '')) = 0))
                OR (@p_EstadoCertificado = 'emitido' AND EstadoCertificado = '1' AND LEN(ISNULL(RutaArchivoPDF, '')) > 0)
                OR (@p_EstadoCertificado = 'por_vencer' AND EstadoCertificado = '1' AND LEN(ISNULL(RutaArchivoPDF, '')) > 0
                    AND FechaCaducidadCertificado >= CAST(GETDATE() AS DATE)
                    AND FechaCaducidadCertificado <= DATEADD(MONTH, 2, CAST(GETDATE() AS DATE)))
                OR (@p_EstadoCertificado = 'vencido' AND EstadoCertificado = '1' AND LEN(ISNULL(RutaArchivoPDF, '')) > 0
                    AND FechaCaducidadCertificado < CAST(GETDATE() AS DATE))
          )
    )

    -- RESULTADO FINAL
    SELECT
        *,
        (SELECT COUNT(*) FROM CTE_Final) AS TotalRegistros,
        @p_Pagina AS PaginaActual,
        @p_TamanoPagina AS TamanoPagina,
        CEILING((SELECT COUNT(*) * 1.0 FROM CTE_Final) / @p_TamanoPagina) AS TotalPaginas
    FROM CTE_Final
    WHERE RowNum > @Offset AND RowNum <= @Offset + @p_TamanoPagina
    ORDER BY RowNum;

    SET NOCOUNT OFF;
END
go

-- =============================================
-- PROCEDIMIENTO 1: DETALLE COMPLETO PERSONA PROGRAMA CERTIFICADO
-- Actualizado para nueva estructura con T_PERFIL_TIPO_EMO
-- =============================================
CREATE   PROCEDURE S_SEL_PERSONA_PROGRAMA_CERTIFICADO_DETALLE
    @p_PersonaProgramaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        -- Datos PersonaPrograma
        PP.Id AS PersonaProgramaId,
        PP.ProgramaEMOId,
        PP.PerfilTipoEMOId,
        PP.Estado AS EstadoPersonaPrograma,
        PP.FechaAccion,
        PP.FechaCreacion,

        -- Datos Persona
        PP.PersonaId,
        P.Nombres,
        P.Apellidos,
        P.TipoDocumento,
        P.NDocumentoIdentidad,
        P.Telefono,
        P.Correo,
        P.Edad,
        P.Genero,
        P.GrupoSanguineo,
        P.Rh,
        P.Estado AS EstadoPersona,

        -- Datos Programa EMO
        PE.Nombre AS NombrePrograma,
        PE.Estado AS EstadoPrograma,

        -- Datos Entidad
        E.Id AS EntidadId,
        E.Nombre AS NombreEntidad,
        E.Estado AS EstadoEntidad,

        -- Datos Perfil-Tipo EMO
        PTE.Id AS PerfilTipoEMOId,
        PTE.TipoEMO,
        PTE.Estado AS EstadoPerfilTipo,

        -- Datos Perfil Ocupacional
        PO.Id AS PerfilOcupacionalId,
        PO.Nombre AS PerfilOcupacional,
        PO.Estado AS EstadoPerfilOcupacional,

        -- Datos Certificado EMO
        CE.Id AS CertificadoId,
        CE.DoctorId,
        CE.Codigo AS CodigoCertificado,
        CE.Password AS PasswordCertificado,
        CE.PuestoAlQuePostula,
        CE.PuestoActual,
        CE.TipoEvaluacion,
        CE.TipoResultado,
        CE.Observaciones,
        CE.Restricciones,
        CE.Conclusiones,
        CE.FechaEvaluacion,
        CE.FechaCaducidad,
        CE.RutaArchivoPDF,
        CE.NombreArchivo,
        CE.FechaGeneracion,
        CE.TamanoArchivo,
        CE.Estado AS EstadoCertificado,

        -- Datos Doctor
        D.Id AS DoctorIdData,
        D.Codigo AS CodigoDoctor,
        D.Especialidad AS EspecialidadDoctor,
        D.RutaImagenFirma,
        D.RutaCertificadoDigital,
        D.Estado AS EstadoDoctor,

        -- Datos Persona Doctor
        PD.Id AS PersonaDoctorId,
        PD.Nombres AS NombresDoctor,
        PD.Apellidos AS ApellidosDoctor,
        PD.TipoDocumento AS TipoDocumentoDoctor,
        PD.NDocumentoIdentidad AS NDocumentoDoctor,
        PD.Genero AS GeneroDoctor,
        PD.Estado AS EstadoPersonaDoctor

    FROM T_PERSONA_PROGRAMA PP
    INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
    INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
    INNER JOIN T_ENTIDAD E ON PE.EntidadId = E.Id
    LEFT JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
    LEFT JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
    LEFT JOIN T_CERTIFICADO_EMO CE ON PP.Id = CE.PersonaProgramaId
    LEFT JOIN T_DOCTOR D ON CE.DoctorId = D.Id
    LEFT JOIN T_PERSONA PD ON D.PersonaId = PD.Id
    WHERE PP.Id = @p_PersonaProgramaId;

    SET NOCOUNT OFF;
END
go

CREATE     PROCEDURE S_SEL_PROGRAMAS_EMO
    @p_EntidadId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM T_PROGRAMA_EMO
    WHERE Estado = '1'
    AND (@p_EntidadId IS NULL OR EntidadId = @p_EntidadId)
    ORDER BY Nombre;
    SET NOCOUNT OFF;
END
go

CREATE PROCEDURE S_SEL_PROTOCOLOS_EMO
    @p_ProgramaEMOId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pe.Id AS ProtocoloEMOId,
        po.Id AS PerfilOcupacionalId,
        po.Nombre AS NombrePerfilOcupacional,
        pte.Id AS PerfilTipoEMOId,
        pte.TipoEMO,
        pe.ExamenMedicoOcupacionalId,
        emo.Nombre AS NombreExamen,
        pe.EsRequerido
    FROM T_PERFIL_OCUPACIONAL po
    INNER JOIN T_PERFIL_TIPO_EMO pte ON po.Id = pte.PerfilOcupacionalId
    INNER JOIN T_PROTOCOLO_EMO pe ON pte.Id = pe.PerfilTipoEMOId
    INNER JOIN T_EXAMEN_MEDICO_OCUPACIONAL emo ON pe.ExamenMedicoOcupacionalId = emo.Id
    WHERE po.ProgramaEMOId = @p_ProgramaEMOId
      AND po.Estado = '1'
      AND pte.Estado = '1'
      AND pe.Estado = '1'
      AND emo.Estado = '1'
      AND pe.EsRequerido = 1
    ORDER BY po.Nombre, pte.TipoEMO, emo.Nombre;

    SET NOCOUNT OFF;
END
go

CREATE   PROCEDURE S_SEL_ROLES_POR_USUARIO_ID
    @p_UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT R.Id, R.Nombre
    FROM T_ROL R
    INNER JOIN T_USUARIO U ON U.RolId = R.Id
    WHERE U.Id = @p_UsuarioId
      AND U.Estado = '1'
      AND R.Estado = '1';
    SET NOCOUNT OFF;
END
go

CREATE PROCEDURE S_SEL_SEL_OBTENER_ROL_POR_USUARIO_ID
    @p_UsuarioId INT
AS
BEGIN
    SELECT R.Id, R.Nombre
    FROM T_USUARIO_ROL UR
    JOIN T_ROL R ON UR.RolId = R.Id
    WHERE UR.UsuarioId = @p_UsuarioId
      AND UR.Estado = '1'
      AND R.Estado = '1';
end
go

-- =============================================
-- 7. S_UPD_ANULAR_CERTIFICADO
-- Anula un certificado (limpia RutaArchivoPDF y marca como anulado)
-- =============================================
CREATE   PROCEDURE S_UPD_ANULAR_CERTIFICADO
(
    @p_PersonaProgramaId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_CERTIFICADO_EMO
    SET RutaArchivoPDF = '',
        NombreArchivo = '',
        TamanoArchivo = NULL,
        FechaAccion = GETDATE()
    WHERE PersonaProgramaId = @p_PersonaProgramaId;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE   PROCEDURE [dbo].[S_UPD_DOCTOR_RUTA_CERTIFICADO_DIGITAL] @p_DoctorId INT,
                                                               @p_RutaCertificadoDigital NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @VALOR INT = 0

    UPDATE T_DOCTOR
    SET RutaCertificadoDigital = CASE
                                     WHEN @p_RutaCertificadoDigital = '' THEN NULL
                                     ELSE @p_RutaCertificadoDigital
        END,
        FechaAccion            = GETDATE()
    WHERE Id = @p_DoctorId


    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF
    RETURN @VALOR
END
go

CREATE   PROCEDURE [dbo].[S_UPD_DOCTOR_RUTA_IMAGEN_FIRMA] @p_DoctorId INT,
                                                                 @p_RutaImagenFirma NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @VALOR INT = 0


    UPDATE T_DOCTOR
    SET RutaImagenFirma = CASE
                              WHEN @p_RutaImagenFirma = '' THEN NULL
                              ELSE @p_RutaImagenFirma
        END,
        FechaAccion     = GETDATE()
    WHERE Id = @p_DoctorId

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF
    RETURN @VALOR
END
go

CREATE PROCEDURE S_UPD_GUARDAR_PDF_CERTIFICADO
(
    @p_PersonaProgramaId INT,
    @p_RutaArchivoPDF NVARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_CERTIFICADO_EMO
    SET RutaArchivoPDF = @p_RutaArchivoPDF,
        FechaGeneracion = GETDATE(),
        FechaAccion = GETDATE()
    WHERE PersonaProgramaId = @p_PersonaProgramaId
      AND Estado = '1';

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

-- =============================================
-- 5. S_UPD_PERFIL_OCUPACIONAL_PERSONA
-- Cambia el perfil ocupacional de una persona en un programa
-- =============================================
CREATE   PROCEDURE S_UPD_PERFIL_OCUPACIONAL_PERSONA
(
    @p_PersonaProgramaId INT,
    @p_PerfilOcupacionalId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_PERSONA_PROGRAMA
    SET PerfilOcupacionalId = @p_PerfilOcupacionalId,
        FechaAccion = GETDATE()
    WHERE Id = @p_PersonaProgramaId;

    SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

-- =============================================
-- PROCEDIMIENTO 4: VALIDADOR COMPLETO PARA GENERACIÓN DE CERTIFICADO
-- (Sin cambios, mantiene la lógica original)
-- =============================================
CREATE   PROCEDURE S_VAL_CERTIFICADO_PUEDE_GENERAR
    @p_PersonaProgramaId INT,
    @p_PuedeGenerar BIT OUTPUT,
    @p_Mensaje NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PerfilOcupacionalId INT;
    DECLARE @PerfilEstado NVARCHAR(20);
    DECLARE @CertificadoId INT;
    DECLARE @CertificadoEstado NVARCHAR(20);
    DECLARE @ExamenesRequeridos INT;
    DECLARE @ExamenesCompletados INT;
    DECLARE @DoctorId INT;
    DECLARE @DoctorCompleto BIT;
    DECLARE @DatosCertificadoCompletos BIT;
    DECLARE @TienePuesto BIT;

    -- Inicializar salida
    SET @p_PuedeGenerar = 0;
    SET @p_Mensaje = '';

    -- ======================================
    -- Obtener datos básicos
    -- ======================================
    SELECT
        @PerfilOcupacionalId = PP.PerfilOcupacionalId,
        @PerfilEstado = PO.Estado,
        @CertificadoId = CE.Id,
        @CertificadoEstado = CE.Estado,
        @DoctorId = CE.DoctorId
    FROM T_PERSONA_PROGRAMA PP
    LEFT JOIN T_PERFIL_OCUPACIONAL PO ON PP.PerfilOcupacionalId = PO.Id
    LEFT JOIN T_CERTIFICADO_EMO CE ON PP.Id = CE.PersonaProgramaId
    WHERE PP.Id = @p_PersonaProgramaId;

    -- ======================================
    -- VALIDACIÓN 1: Perfil asignado
    -- ======================================
    IF @PerfilOcupacionalId IS NULL
    BEGIN
        SET @p_Mensaje = 'La persona no tiene perfil ocupacional asignado';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 2: Perfil activo (Estado='1')
    -- ======================================
    IF @PerfilEstado != '1'
    BEGIN
        SET @p_Mensaje = 'El perfil ocupacional no está activo (Estado debe ser ''1'')';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 3: Exámenes requeridos completos
    -- ======================================
    SELECT @ExamenesRequeridos = COUNT(*)
    FROM T_PROTOCOLO_EMO
    WHERE PerfilOcupacionalId = @PerfilOcupacionalId
      AND EsRequerido = 1
      AND Estado = '1';

    SELECT @ExamenesCompletados = COUNT(*)
    FROM T_PROTOCOLO_EMO PRO
    INNER JOIN T_RESULTADO_EMO RE ON PRO.Id = RE.ProtocoloEMOId
    WHERE PRO.PerfilOcupacionalId = @PerfilOcupacionalId
      AND RE.PersonaProgramaId = @p_PersonaProgramaId
      AND PRO.EsRequerido = 1
      AND RE.Realizado = 1
      AND PRO.Estado = '1'
      AND RE.Estado = '1';

    IF @ExamenesRequeridos = 0
    BEGIN
        SET @p_Mensaje = 'No hay exámenes requeridos configurados en el perfil';
        RETURN;
    END

    IF @ExamenesCompletados < @ExamenesRequeridos
    BEGIN
        SET @p_Mensaje = 'Exámenes incompletos: ' + CAST(@ExamenesCompletados AS NVARCHAR) +
                        ' de ' + CAST(@ExamenesRequeridos AS NVARCHAR) + ' completados';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 4: Certificado existe
    -- ======================================
    IF @CertificadoId IS NULL
    BEGIN
        SET @p_Mensaje = 'No existe registro de certificado EMO';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 5: Certificado activo (Estado='1')
    -- ======================================
    IF @CertificadoEstado != '1'
    BEGIN
        SET @p_Mensaje = 'El certificado EMO no está activo (Estado debe ser ''1'')';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 6: Doctor asignado
    -- ======================================
    IF @DoctorId IS NULL
    BEGIN
        SET @p_Mensaje = 'El certificado no tiene doctor asignado';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 7: Doctor completo y activo
    -- ======================================
    SELECT @DoctorCompleto = CASE
        WHEN D.Id IS NULL THEN 0
        WHEN D.Estado != '1' THEN 0
        WHEN D.Codigo IS NULL OR LTRIM(RTRIM(D.Codigo)) = '' THEN 0
        WHEN D.Especialidad IS NULL OR LTRIM(RTRIM(D.Especialidad)) = '' THEN 0
        WHEN PD.Id IS NULL THEN 0
        WHEN PD.Estado != '1' THEN 0
        WHEN PD.Nombres IS NULL OR LTRIM(RTRIM(PD.Nombres)) = '' THEN 0
        WHEN PD.Apellidos IS NULL OR LTRIM(RTRIM(PD.Apellidos)) = '' THEN 0
        WHEN PD.TipoDocumento IS NULL OR LTRIM(RTRIM(PD.TipoDocumento)) = '' THEN 0
        WHEN PD.NDocumentoIdentidad IS NULL OR LTRIM(RTRIM(PD.NDocumentoIdentidad)) = '' THEN 0
        ELSE 1
    END
    FROM T_DOCTOR D
    INNER JOIN T_PERSONA PD ON D.PersonaId = PD.Id
    WHERE D.Id = @DoctorId;

    IF @DoctorCompleto = 0
    BEGIN
        SET @p_Mensaje = 'Doctor incompleto. Verifique: Código CMP, Especialidad, Nombres, Apellidos, Tipo Documento, Número Documento y que ambos estén activos (Estado=''1'')';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 8: Datos del certificado completos
    -- ======================================
    SELECT @DatosCertificadoCompletos = CASE
        WHEN Codigo IS NULL OR LTRIM(RTRIM(Codigo)) = '' THEN 0
        WHEN TipoEvaluacion IS NULL OR LTRIM(RTRIM(TipoEvaluacion)) = '' THEN 0
        WHEN TipoResultado IS NULL OR LTRIM(RTRIM(TipoResultado)) = '' THEN 0
        WHEN FechaEvaluacion IS NULL THEN 0
        ELSE 1
    END
    FROM T_CERTIFICADO_EMO
    WHERE Id = @CertificadoId;

    IF @DatosCertificadoCompletos = 0
    BEGIN
        SET @p_Mensaje = 'Datos del certificado incompletos. Verifique: Código, Tipo Evaluación, Tipo Resultado, Fecha Evaluación, Password';
        RETURN;
    END

    -- ======================================
    -- VALIDACIÓN 9: Al menos un puesto definido
    -- ======================================
    SELECT @TienePuesto = CASE
        WHEN (PuestoAlQuePostula IS NOT NULL AND LTRIM(RTRIM(PuestoAlQuePostula)) != '')
             OR (PuestoActual IS NOT NULL AND LTRIM(RTRIM(PuestoActual)) != '')
        THEN 1
        ELSE 0
    END
    FROM T_CERTIFICADO_EMO
    WHERE Id = @CertificadoId;

    IF @TienePuesto = 0
    BEGIN
        SET @p_Mensaje = 'El certificado debe tener al menos un puesto definido (PuestoAlQuePostula o PuestoActual)';
        RETURN;
    END

    -- ======================================
    -- ✅ Si llegamos aquí, todo está OK para generar el PDF
    -- ======================================
    SET @p_PuedeGenerar = 1;
    SET @p_Mensaje = 'Certificado listo para generar PDF';

    SET NOCOUNT OFF;
END
go

