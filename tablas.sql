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

select * from dbo.T_ROL

INSERT T_ROL (Nombre, Estado, FechaAccion, FechaCreacion) VALUES ('Empresa', '1', getdate(), getdate());

update  dbo.T_ROL set Nombre = 'Entidad' where Id  = 1


exec S_INS_UPD_DOCTOR