USE DB_MEDIVALLE
GO
CREATE OR ALTER   PROCEDURE S_DEL_CATALOGO_EXAMEN_PROGRAMA(
    @p_Id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_CATALOGO_EXAMEN_PROGRAMA
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


--------------------------------------------------
-- Empresa: Desarrollo Empresarial System Strategy S.A.C.
-- Autor: GitHub Copilot
-- Creado: 10/10/2025 14:30:00
-- Propósito: Eliminar (inactivar) un doctor
--------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[S_DEL_DOCTOR]

@p_DoctorId INT,
@p_UsuarioAccion INT

AS
SET NOCOUNT ON
DECLARE @VALOR INT = 0

    UPDATE T_DOCTOR
    SET Estado = 'INACTIVO',
        UsuarioAccion = @p_UsuarioAccion,
        FechaAccion = GETDATE()
    WHERE Id = @p_DoctorId

    IF @@ROWCOUNT > 0
        SET @VALOR = 1

IF @@ERROR != 0
    SET @VALOR = -1

RETURN @VALOR
SET NOCOUNT OFF
go

CREATE OR ALTER   PROCEDURE S_DEL_ENTIDAD(
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

CREATE OR ALTER PROCEDURE S_DEL_EXAMEN_MEDICO(
    @p_Id INT
) AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_EXAMEN_MEDICO
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

CREATE OR ALTER   PROCEDURE S_DEL_PERFIL_OCUPACIONAL(
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

CREATE OR ALTER   PROCEDURE S_DEL_PROGRAMA_EMO(
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

CREATE OR ALTER   PROCEDURE S_DEL_PROTOCOLO_EMO(
    @p_Id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    UPDATE T_PROTOCOLO_EMO
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

CREATE OR ALTER   PROCEDURE S_INS_UDP_ENTIDAD(
    @p_Id INT = NULL,
    @p_Nombre NVARCHAR(150) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL AND @p_Id > 0
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

CREATE OR ALTER   PROCEDURE S_INS_UPD_CATALOGO_EXAMEN_PROGRAMA(
    @p_Id INT = NULL,
    @p_ProgramaEMOId INT = NULL,
    @p_ExamenMedicoId INT = NULL,
    @p_Orden INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL AND @p_Id > 0
    BEGIN
        UPDATE T_CATALOGO_EXAMEN_PROGRAMA
        SET Orden = ISNULL(@p_Orden, Orden),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END
    ELSE
    BEGIN
        INSERT INTO T_CATALOGO_EXAMEN_PROGRAMA (ProgramaEMOId, ExamenMedicoId, Orden, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_ProgramaEMOId, @p_ExamenMedicoId, @p_Orden, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END

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
-- Propósito: Registrar o actualizar doctor con su información de persona
--------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[S_INS_UPD_DOCTOR]

@p_DoctorId INT,
@p_PersonaId INT,
@p_Codigo NVARCHAR(50),
@p_Nombres NVARCHAR(100),
@p_Apellidos NVARCHAR(100),
@p_TipoDocumento NVARCHAR(50),
@p_NDocumentoIdentidad NVARCHAR(20),
@p_Especialidad NVARCHAR(200),
@p_Estado NVARCHAR(20),
@p_UsuarioAccion INT

AS
SET NOCOUNT ON
DECLARE @VALOR INT = 0
DECLARE @NuevoPersonaId INT = @p_PersonaId
DECLARE @NuevoDoctorId INT = @p_DoctorId

    -- Si es nuevo doctor (Id = 0), crear o actualizar persona primero
    IF @p_DoctorId = 0
    BEGIN
        -- Verificar si ya existe una persona con ese documento
        IF @p_PersonaId = 0
        BEGIN
            SELECT @NuevoPersonaId = Id
            FROM T_PERSONA
            WHERE NDocumentoIdentidad = @p_NDocumentoIdentidad

            IF @NuevoPersonaId IS NULL
            BEGIN
                -- Insertar nueva persona
                INSERT INTO T_PERSONA
                    (Nombres, Apellidos, TipoDocumento, NDocumentoIdentidad, Estado, UsuarioAccion, FechaAccion, FechaCreacion)
                VALUES
                    (@p_Nombres, @p_Apellidos, @p_TipoDocumento, @p_NDocumentoIdentidad, 'ACTIVO', @p_UsuarioAccion, GETDATE(), GETDATE())

                SET @NuevoPersonaId = SCOPE_IDENTITY()
            END
            ELSE
            BEGIN
                -- Actualizar persona existente
                UPDATE T_PERSONA
                SET Nombres = @p_Nombres,
                    Apellidos = @p_Apellidos,
                    TipoDocumento = @p_TipoDocumento,
                    Estado = 'ACTIVO',
                    UsuarioAccion = @p_UsuarioAccion,
                    FechaAccion = GETDATE()
                WHERE Id = @NuevoPersonaId
            END
        END
        ELSE
        BEGIN
            -- Actualizar persona existente
            UPDATE T_PERSONA
            SET Nombres = @p_Nombres,
                Apellidos = @p_Apellidos,
                TipoDocumento = @p_TipoDocumento,
                NDocumentoIdentidad = @p_NDocumentoIdentidad,
                Estado = 'ACTIVO',
                UsuarioAccion = @p_UsuarioAccion,
                FechaAccion = GETDATE()
            WHERE Id = @p_PersonaId

            SET @NuevoPersonaId = @p_PersonaId
        END

        -- Insertar nuevo doctor
        INSERT INTO T_DOCTOR
            (PersonaId, Codigo, Especialidad, Estado, UsuarioAccion, FechaAccion, FechaCreacion)
        VALUES
            (@NuevoPersonaId, @p_Codigo, @p_Especialidad, @p_Estado, @p_UsuarioAccion, GETDATE(), GETDATE())

        IF @@ROWCOUNT > 0
        BEGIN
            SET @NuevoDoctorId = SCOPE_IDENTITY()
            SET @VALOR = @NuevoDoctorId
        END
    END
    ELSE
    BEGIN
        -- Actualizar persona existente
        UPDATE T_PERSONA
        SET Nombres = @p_Nombres,
            Apellidos = @p_Apellidos,
            TipoDocumento = @p_TipoDocumento,
            NDocumentoIdentidad = @p_NDocumentoIdentidad,
            Estado = 'ACTIVO',
            UsuarioAccion = @p_UsuarioAccion,
            FechaAccion = GETDATE()
        WHERE Id = @p_PersonaId

        -- Actualizar doctor
        UPDATE T_DOCTOR
        SET Codigo = @p_Codigo,
            Especialidad = @p_Especialidad,
            Estado = @p_Estado,
            UsuarioAccion = @p_UsuarioAccion,
            FechaAccion = GETDATE()
        WHERE Id = @p_DoctorId

        IF @@ROWCOUNT > 0
            SET @VALOR = @p_DoctorId
    END

IF @@ERROR != 0
    SET @VALOR = -1

RETURN @VALOR
SET NOCOUNT OFF
go

CREATE OR ALTER PROCEDURE S_INS_UPD_EXAMEN_MEDICO(
    @p_Id INT = NULL,
    @p_Nombre NVARCHAR(300) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL AND @p_Id > 0
    BEGIN

        UPDATE T_EXAMEN_MEDICO
        SET Nombre      = ISNULL(@p_Nombre, Nombre),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    END
    ELSE
    BEGIN

        INSERT INTO T_EXAMEN_MEDICO (Nombre, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_Nombre, '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;

    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END;
go

CREATE OR ALTER   PROCEDURE S_INS_UPD_PERFIL_OCUPACIONAL(
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

CREATE OR ALTER   PROCEDURE S_INS_UPD_PROGRAMA_EMO(
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

CREATE OR ALTER   PROCEDURE S_INS_UPD_PROTOCOLO_EMO(
    @p_Id INT = NULL,
    @p_PerfilOcupacionalId INT = NULL,
    @p_TipoEMOId INT = NULL,
    @p_ExamenMedicoId INT = NULL,
    @p_EsRequerido BIT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @VALOR INT = 0;

    IF @p_Id IS NOT NULL AND @p_Id > 0
    BEGIN
        UPDATE T_PROTOCOLO_EMO
        SET EsRequerido = ISNULL(@p_EsRequerido, EsRequerido),
            FechaAccion = GETDATE()
        WHERE Id = @p_Id;

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END
    ELSE
    BEGIN
        INSERT INTO T_PROTOCOLO_EMO (PerfilOcupacionalId, TipoEMOId, ExamenMedicoId, EsRequerido, Estado, FechaAccion, FechaCreacion)
        VALUES (@p_PerfilOcupacionalId, @p_TipoEMOId, @p_ExamenMedicoId, ISNULL(@p_EsRequerido, 0), '1', GETDATE(), GETDATE());

        SET @VALOR = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    END

    IF @@ERROR <> 0
        SET @VALOR = -1;

    SET NOCOUNT OFF;
    RETURN @VALOR;
END
go

CREATE OR ALTER   PROCEDURE S_SEL_CATALOGOS_EXAMEN_PROGRAMA
    @p_ProgramaEMOId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.Id,
        c.ProgramaEMOId,
        p.Nombre AS NombrePrograma,
        c.ExamenMedicoId,
        e.Nombre AS NombreExamen,
        c.Orden,
        c.Estado
    FROM T_CATALOGO_EXAMEN_PROGRAMA c
    INNER JOIN T_PROGRAMA_EMO p ON c.ProgramaEMOId = p.Id
    INNER JOIN T_EXAMEN_MEDICO e ON c.ExamenMedicoId = e.Id
    WHERE c.Estado = '1'
    AND (@p_ProgramaEMOId IS NULL OR c.ProgramaEMOId = @p_ProgramaEMOId)
    ORDER BY c.Orden, e.Nombre;
    SET NOCOUNT OFF;
END
go

CREATE OR ALTER PROCEDURE [dbo].[S_SEL_CERTIFICADO_VALIDAR_ACCESO]

@p_CodigoCertificado NVARCHAR(50),
@p_Password NVARCHAR(20)

AS
SET NOCOUNT ON

    SELECT
        cert.Id,
        cert.Codigo,
        cert.EMOId,
        cert.RutaArchivoPDF,
        cert.NombreArchivo,
        cert.TipoEvaluacion,
        cert.TipoResultado,
        cert.PuestoAlQuePostula,
        cert.PuestoActual,
        cert.Observaciones,
        cert.Restricciones,
        cert.FechaEvaluacion,
        cert.FechaCaducidad,
        cert.FechaGeneracion,
        cert.Estado,
        p.Nombres,
        p.Apellidos,
        p.NDocumentoIdentidad,
        p.Edad,
        p.Genero,
        p.GrupoSanguineo,
        p.Rh
    FROM    T_EMO_CERTIFICADO cert
    INNER JOIN T_EMO emo ON cert.EMOId = emo.Id
    INNER JOIN T_COLABORADOR col ON emo.ColaboradorId = col.Id
    INNER JOIN T_PERSONA p ON col.PersonaId = p.Id
    WHERE   cert.Codigo = @p_CodigoCertificado
            AND p.NDocumentoIdentidad = @p_Password
            AND cert.Estado = 'ACTIVO'

SET NOCOUNT OFF
go

CREATE OR ALTER PROCEDURE [dbo].[S_SEL_DOCTORES]
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
        d.FechaAccion,
        -- Verificar si todos los datos están completos
        CASE
            WHEN p.Nombres IS NOT NULL
                AND p.Apellidos IS NOT NULL
                AND p.TipoDocumento IS NOT NULL
                AND p.NDocumentoIdentidad IS NOT NULL
                AND d.Especialidad IS NOT NULL
                AND d.Codigo IS NOT NULL
            THEN 1
            ELSE 0
        END AS DatosCompletos
    FROM T_DOCTOR d
    INNER JOIN T_PERSONA p ON d.PersonaId = p.Id
    WHERE d.Estado = 'ACTIVO'
    ORDER BY p.Apellidos, p.Nombres

SET NOCOUNT OFF
go


CREATE OR ALTER PROCEDURE [dbo].[S_SEL_DOCTOR_POR_ID]
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

CREATE OR ALTER   PROCEDURE S_SEL_ENTIDADES
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM T_ENTIDAD WHERE Estado = '1';

    SET NOCOUNT OFF;
END
go

CREATE OR ALTER   PROCEDURE S_SEL_EXAMENES_MEDICOS
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM T_EXAMEN_MEDICO WHERE Estado = '1' ORDER BY Nombre;
    SET NOCOUNT OFF;
END
go

CREATE OR ALTER   PROCEDURE S_SEL_PERFILES_OCUPACIONAL
    @p_ProgramaEMOId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM T_PERFIL_OCUPACIONAL
    WHERE Estado = '1'
    AND (@p_ProgramaEMOId IS NULL OR ProgramaEMOId = @p_ProgramaEMOId)
    ORDER BY Nombre;
    SET NOCOUNT OFF;
END
go

CREATE OR ALTER   PROCEDURE S_SEL_PROGRAMAS_EMO
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

CREATE OR ALTER   PROCEDURE S_SEL_PROTOCOLOS_EMO
    @p_PerfilOcupacionalId INT = NULL,
    @p_TipoEMOId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        pr.Id,
        pr.PerfilOcupacionalId,
        po.Nombre AS NombrePerfil,
        pr.TipoEMOId,
        te.Nombre AS NombreTipoEMO,
        pr.ExamenMedicoId,
        em.Nombre AS NombreExamen,
        pr.EsRequerido,
        pr.Estado
    FROM T_PROTOCOLO_EMO pr
    INNER JOIN T_PERFIL_OCUPACIONAL po ON pr.PerfilOcupacionalId = po.Id
    INNER JOIN T_TIPO_EMO te ON pr.TipoEMOId = te.Id
    INNER JOIN T_EXAMEN_MEDICO em ON pr.ExamenMedicoId = em.Id
    WHERE pr.Estado = '1'
    AND (@p_PerfilOcupacionalId IS NULL OR pr.PerfilOcupacionalId = @p_PerfilOcupacionalId)
    AND (@p_TipoEMOId IS NULL OR pr.TipoEMOId = @p_TipoEMOId)
    ORDER BY po.Nombre, te.Orden, em.Nombre;
    SET NOCOUNT OFF;
END
go

CREATE OR ALTER   PROCEDURE S_SEL_TIPOS_EMO
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM T_TIPO_EMO WHERE Estado = '1' ORDER BY Orden;
    SET NOCOUNT OFF;
END
go

-- =============================================
-- S_INS_UPD_CERTIFICADO_EMO
-- Inserta o actualiza información del certificado EMO
-- Incluye actualización de datos de la persona
-- =============================================
CREATE OR ALTER PROCEDURE S_INS_UPD_CERTIFICADO_EMO
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

-- =============================================
-- PROCEDIMIENTO: EXÁMENES DEL PERFIL CON ESTADO DE REALIZACIÓN
-- Actualizado para nueva estructura con T_PERFIL_TIPO_EMO
-- Solo muestra exámenes requeridos
-- =============================================
CREATE OR ALTER PROCEDURE S_SEL_EXAMENES_PERSONA_PROGRAMA
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

-- =============================================
-- VERSIÓN MEJORADA con validaciones
-- =============================================
CREATE OR ALTER PROCEDURE S_INS_UPD_RESULTADO_EXAMEN
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

-- =============================================
-- S_UPD_GUARDAR_PDF_CERTIFICADO
-- Actualiza la ruta del PDF y la fecha de generación
-- =============================================
CREATE OR ALTER PROCEDURE S_UPD_GUARDAR_PDF_CERTIFICADO
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

