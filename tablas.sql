USE DB_MEDIVALLE
GO

EXEC S_INS_UDP_ENTIDAD @p_Nombre = 'iCRMEdu';

EXEC S_INS_UPD_DOCTOR
     @p_Id = NULL, -- NULL para crear nuevo
     @p_Codigo = 'CMP12345', -- Código CMP del doctor
     @p_Nombres = 'Carlos Eduardo',
     @p_Apellidos = 'Ramírez García',
     @p_TipoDocumento = 'DNI',
     @p_NDocumentoIdentidad = '45678912',
     @p_Genero = 'M',
     @p_Especialidad = 'Medicina Ocupacional',
     @p_UsuarioAccionId = 1;

EXEC S_INS_UPD_PROGRAMA_EMO @p_Nombre = "2023", @p_EntidadId = 1;

EXEC S_INS_UPD_EXAMEN_MEDICO @p_Nombre = "Examen de la vista";


EXEC S_INS_UPD_PROGRAMA_EMO_EXAMEN_MEDICO @p_ProgramaEMOId = 1, @p_ExamenMedicoId = 1, @p_Orden = 1;

EXEC S_INS_UPD_PERFIL_OCUPACIONAL @p_ProgramaEMOId = 1, @p_Nombre = "Constructor";

EXEC S_INS_UPD_PROTOCOLO_EMO
    @p_Id = NULL,
    @p_PerfilOcupacionalId = 1,
    @p_ProgramaEMOExamenMedicoId = 1,
    @p_TipoEMO = 'Ingreso',
    @p_EsRequerido = 1;


CREATE PROCEDURE [dbo].[S_INS_UPD_COLABORADOR]
    @p_ColaboradorId INT = NULL,
    @p_Nombres NVARCHAR(100) = NULL,
    @p_Apellidos NVARCHAR(100) = NULL,
    @p_TipoDocumento NVARCHAR(50) = NULL,
    @p_NDocumentoIdentidad NVARCHAR(20),
    @p_Edad INT = NULL,
    @p_Genero NVARCHAR(20) = NULL,
    @p_GrupoSanguineo NVARCHAR(10) = NULL,
    @p_Rh NVARCHAR(10) = NULL,
    @p_EntidadId INT,
    @p_UsuarioAccionId INT = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @VALOR INT = 0
    DECLARE @NuevoPersonaId INT = NULL
    DECLARE @NuevoColaboradorId INT = NULL
    DECLARE @PersonaIdExistente INT = NULL

    -- MODO CREACIÓN
    IF @p_ColaboradorId IS NULL OR @p_ColaboradorId = 0
    BEGIN
        -- Verificar si existe la persona con ese DNI
        SELECT @PersonaIdExistente = Id FROM T_PERSONA WHERE NDocumentoIdentidad = @p_NDocumentoIdentidad

        IF @PersonaIdExistente IS NOT NULL BEGIN SET @VALOR = -1; RETURN @VALOR; END


        -- Crear persona
        INSERT INTO T_PERSONA (Nombres, Apellidos, TipoDocumento, NDocumentoIdentidad, Edad, Genero, GrupoSanguineo, Rh, Estado, UsuarioAccion, FechaAccion, FechaCreacion)
        VALUES (ISNULL(@p_Nombres, ''), ISNULL(@p_Apellidos, ''), @p_TipoDocumento, @p_NDocumentoIdentidad, @p_Edad, @p_Genero, @p_GrupoSanguineo, @p_Rh, '1', @p_UsuarioAccionId, GETDATE(), GETDATE())

        IF @@ROWCOUNT = 0 BEGIN SET @VALOR = -1 RETURN @VALOR END
        SET @NuevoPersonaId = SCOPE_IDENTITY()
        IF @NuevoPersonaId IS NULL BEGIN SET @VALOR = -1 RETURN @VALOR END

        -- Crear colaborador
        INSERT INTO T_COLABORADOR (PersonaId, EntidadId, Estado, UsuarioAccion, FechaAccion, FechaCreacion)
        VALUES (@NuevoPersonaId, @p_EntidadId, '1', @p_UsuarioAccionId, GETDATE(), GETDATE())

        IF @@ROWCOUNT = 0 BEGIN SET @VALOR = -1 RETURN @VALOR END
        SET @NuevoColaboradorId = SCOPE_IDENTITY()
        IF @NuevoColaboradorId IS NULL BEGIN SET @VALOR = -1 RETURN @VALOR END
        SET @VALOR = 1
    END
    ELSE
    BEGIN
        -- MODO EDICIÓN
        SELECT @NuevoPersonaId = PersonaId FROM T_COLABORADOR WHERE Id = @p_ColaboradorId
        IF @NuevoPersonaId IS NULL BEGIN SET @VALOR = -1 RETURN @VALOR END

        UPDATE T_PERSONA
        SET Nombres = ISNULL(@p_Nombres, Nombres),
            Apellidos = ISNULL(@p_Apellidos, Apellidos),
            TipoDocumento = ISNULL(@p_TipoDocumento, TipoDocumento),
            NDocumentoIdentidad = ISNULL(@p_NDocumentoIdentidad, NDocumentoIdentidad),
            Edad = ISNULL(@p_Edad, Edad),
            Genero = ISNULL(@p_Genero, Genero),
            GrupoSanguineo = ISNULL(@p_GrupoSanguineo, GrupoSanguineo),
            Rh = ISNULL(@p_Rh, Rh),
            UsuarioAccion = ISNULL(@p_UsuarioAccionId, UsuarioAccion),
            FechaAccion = GETDATE()
        WHERE Id = @NuevoPersonaId

        IF @@ROWCOUNT = 0 BEGIN SET @VALOR = -1 RETURN @VALOR END

        UPDATE T_COLABORADOR
        SET EntidadId = ISNULL(@p_EntidadId, EntidadId),
            UsuarioAccion = ISNULL(@p_UsuarioAccionId, UsuarioAccion),
            FechaAccion = GETDATE()
        WHERE Id = @p_ColaboradorId

        IF @@ROWCOUNT = 0 BEGIN SET @VALOR = -1 RETURN @VALOR END
        SET @VALOR = 1
    END

    SET NOCOUNT OFF
    RETURN @VALOR
END
GO
GO

select * from dbo.T_ROL

INSERT T_ROL (Nombre, Estado, FechaAccion, FechaCreacion) VALUES ('Empresa', '1', getdate(), getdate());

update  dbo.T_ROL set Nombre = 'Entidad' where Id  = 1


exec S_INS_UPD_DOCTOR