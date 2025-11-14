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

