-- ============================================
-- SCRIPT DE CONFIGURACIÓN COMPLETA (CORREGIDO)
-- SISTEMA EMO - BANCO DE LA NACIÓN
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║   CONFIGURACIÓN SISTEMA EMO - BANCO DE LA NACIÓN          ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- ============================================
-- PASO 1: CREAR EXÁMENES MÉDICOS (CATÁLOGO COMPLETO)
-- ============================================
PRINT '═══════════════════════════════════════════════════════════';
PRINT '  PASO 1: CREANDO CATÁLOGO DE EXÁMENES MÉDICOS';
PRINT '═══════════════════════════════════════════════════════════';

-- Exámenes Médicos Generales
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Evaluación Médica General';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Examen Físico Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Antropometría (Peso, Talla, IMC)';

-- Exámenes de Laboratorio
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Hemograma Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Glucosa en Sangre';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Perfil Lipídico Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Examen de Orina Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Creatinina Sérica';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Ácido Úrico';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Grupo Sanguíneo y Factor RH';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Perfil Hepático';

-- Exámenes de Imágenes
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Radiografía de Tórax PA';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Radiografía de Columna Cervical';

-- Exámenes Funcionales Respiratorios
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Espirometría';

-- Exámenes Auditivos
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Audiometría';

-- Exámenes Oftalmológicos
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Agudeza Visual';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Visión Cromática';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Ishihara (Daltonismo)';

-- Exámenes Cardiovasculares
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Electrocardiograma en Reposo';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Presión Arterial';

-- Exámenes Psicológicos
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Personalidad (16PF)';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Evaluación de Riesgo Psicosocial';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Atención y Concentración';

-- Exámenes Musculoesqueléticos
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Evaluación Osteomuscular';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Movilidad Articular';

-- Exámenes Específicos
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Test de Estrés Laboral';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Examen Odontológico';
EXEC S_INS_UPD_EXAMEN_MEDICO_OCUPACIONAL NULL, 'Valoración Nutricional';

DECLARE @TotalExamenes INT;
SELECT @TotalExamenes = COUNT(*) FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Estado = '1';
PRINT '✓ Exámenes creados: ' + CAST(@TotalExamenes AS VARCHAR);
PRINT '';

-- ============================================
-- PASO 2: CREAR ENTIDADES
-- ============================================
PRINT '═══════════════════════════════════════════════════════════';
PRINT '  PASO 2: CREANDO ENTIDADES';
PRINT '═══════════════════════════════════════════════════════════';

DECLARE @EntidadBancoId INT;

EXEC S_INS_UDP_ENTIDAD NULL, 'Banco de la Nación';
SELECT TOP 1 @EntidadBancoId = Id FROM T_ENTIDAD WHERE Nombre = 'Banco de la Nación' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Entidad creada - ID: ' + CAST(@EntidadBancoId AS VARCHAR) + ' (Banco de la Nación)';
PRINT '';

-- ============================================
-- PASO 3: CREAR PROGRAMAS EMO
-- ============================================
PRINT '═══════════════════════════════════════════════════════════';
PRINT '  PASO 3: CREANDO PROGRAMAS EMO';
PRINT '═══════════════════════════════════════════════════════════';

DECLARE @ProgramaId1 INT, @ProgramaId2 INT, @ProgramaId3 INT;

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Operativo - 2023', @EntidadBancoId;
SELECT TOP 1 @ProgramaId1 = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadBancoId AND Nombre LIKE '%Operativo%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa 1 creado - ID: ' + CAST(@ProgramaId1 AS VARCHAR) + ' (Personal Operativo - 2023)';

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Comercial y Soporte - 2024', @EntidadBancoId;
SELECT TOP 1 @ProgramaId2 = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadBancoId AND Nombre LIKE '%Comercial%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa 2 creado - ID: ' + CAST(@ProgramaId2 AS VARCHAR) + ' (Personal Comercial y Soporte - 2024)';

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Administrativo y Gerencial - 2025', @EntidadBancoId;
SELECT TOP 1 @ProgramaId3 = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadBancoId AND Nombre LIKE '%Administrativo%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa 3 creado - ID: ' + CAST(@ProgramaId3 AS VARCHAR) + ' (Personal Administrativo y Gerencial - 2025)';
PRINT '';

-- ============================================
-- PASO 4: CREAR PERFILES Y PROTOCOLOS
-- ============================================
PRINT '═══════════════════════════════════════════════════════════';
PRINT '  PASO 4: CONFIGURANDO PERFILES Y PROTOCOLOS';
PRINT '═══════════════════════════════════════════════════════════';

DECLARE @PerfilId INT;
DECLARE @ExamenId INT;

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 1: PERSONAL OPERATIVO (4 perfiles, 2 tipos EMO)
-- ═══════════════════════════════════════════════════════════
PRINT '';
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 1: PERSONAL OPERATIVO                         │';
PRINT '└─────────────────────────────────────────────────────────┘';

-- ═══ PERFIL 1.1: CAJERO ═══
PRINT '  → Configurando: Cajero';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Cajero', @ProgramaId1;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Cajero' AND ProgramaEMOId = @ProgramaId1 ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Glucosa en Sangre';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Atención y Concentración';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Glucosa en Sangre';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

PRINT '    ✓ Cajero configurado';

-- ═══ PERFIL 1.2: OFICIAL DE SEGURIDAD ═══
PRINT '  → Configurando: Oficial de Seguridad';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Oficial de Seguridad', @ProgramaId1;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Oficial de Seguridad' AND ProgramaEMOId = @ProgramaId1 ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Electrocardiograma en Reposo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Personalidad (16PF)';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Electrocardiograma en Reposo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

PRINT '    ✓ Oficial de Seguridad configurado';

-- ═══ PERFIL 1.3: OPERADOR DE BÓVEDA ═══
PRINT '  → Configurando: Operador de Bóveda';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Operador de Bóveda', @ProgramaId1;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Operador de Bóveda' AND ProgramaEMOId = @ProgramaId1 ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Movilidad Articular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

PRINT '    ✓ Operador de Bóveda configurado';

-- ═══ PERFIL 1.4: MENSAJERO/COURIER ═══
PRINT '  → Configurando: Mensajero/Courier';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Mensajero/Courier', @ProgramaId1;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Mensajero/Courier' AND ProgramaEMOId = @ProgramaId1 ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Visión Cromática';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

PRINT '    ✓ Mensajero/Courier configurado';

PRINT '  ✓ Programa 1 completado: 4 perfiles con 2 tipos EMO (INGRESO, PERIÓDICO)';

-- Debido a la longitud, continúo en el siguiente mensaje con el resto de programas...

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║              CONFIGURACIÓN COMPLETADA                      ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

SET NOCOUNT OFF;
GO


-- ============================================
-- CREAR DOCTORES PARA EL SISTEMA
-- ============================================

USE DB_MEDIVALLE;
GO

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║              CREANDO DOCTORES DEL SISTEMA                 ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

DECLARE @Resultado INT;

-- Doctor 1: Medicina Ocupacional
EXEC @Resultado = S_INS_UPD_DOCTOR
    @p_Id = NULL,
    @p_Codigo = 'CMP-045123',
    @p_Nombres = 'María Elena',
    @p_Apellidos = 'Rodríguez Sánchez',
    @p_TipoDocumento = 'DNI',
    @p_NDocumentoIdentidad = '42156789',
    @p_Genero = 'F',
    @p_Especialidad = 'Medicina Ocupacional',
    @p_RutaImagenFirma = NULL,
    @p_RutaCertificadoDigital = NULL;

PRINT '✓ Doctor 1 creado: Dra. María Elena Rodríguez Sánchez (Medicina Ocupacional)';

-- Doctor 2: Medicina Ocupacional y del Trabajo
EXEC @Resultado = S_INS_UPD_DOCTOR
    @p_Id = NULL,
    @p_Codigo = 'CMP-038756',
    @p_Nombres = 'Carlos Alberto',
    @p_Apellidos = 'Mendoza Torres',
    @p_TipoDocumento = 'DNI',
    @p_NDocumentoIdentidad = '38945621',
    @p_Genero = 'M',
    @p_Especialidad = 'Medicina Ocupacional y del Trabajo',
    @p_RutaImagenFirma = NULL,
    @p_RutaCertificadoDigital = NULL;

PRINT '✓ Doctor 2 creado: Dr. Carlos Alberto Mendoza Torres (Medicina Ocupacional y del Trabajo)';

-- Doctor 3: Medicina General con especialidad en Salud Ocupacional
EXEC @Resultado = S_INS_UPD_DOCTOR
    @p_Id = NULL,
    @p_Codigo = 'CMP-052341',
    @p_Nombres = 'Ana Patricia',
    @p_Apellidos = 'Vargas León',
    @p_TipoDocumento = 'DNI',
    @p_NDocumentoIdentidad = '45789123',
    @p_Genero = 'F',
    @p_Especialidad = 'Medicina General - Salud Ocupacional',
    @p_RutaImagenFirma = NULL,
    @p_RutaCertificadoDigital = NULL;

PRINT '✓ Doctor 3 creado: Dra. Ana Patricia Vargas León (Medicina General - Salud Ocupacional)';

-- Doctor 4: Medicina Ocupacional
EXEC @Resultado = S_INS_UPD_DOCTOR
    @p_Id = NULL,
    @p_Codigo = 'CMP-041289',
    @p_Nombres = 'Roberto José',
    @p_Apellidos = 'Flores Gutiérrez',
    @p_TipoDocumento = 'DNI',
    @p_NDocumentoIdentidad = '41234567',
    @p_Genero = 'M',
    @p_Especialidad = 'Medicina Ocupacional',
    @p_RutaImagenFirma = NULL,
    @p_RutaCertificadoDigital = NULL;

PRINT '✓ Doctor 4 creado: Dr. Roberto José Flores Gutiérrez (Medicina Ocupacional)';

-- Doctor 5: Medicina del Trabajo
EXEC @Resultado = S_INS_UPD_DOCTOR
    @p_Id = NULL,
    @p_Codigo = 'CMP-047892',
    @p_Nombres = 'Lucia Mercedes',
    @p_Apellidos = 'Castro Ramírez',
    @p_TipoDocumento = 'DNI',
    @p_NDocumentoIdentidad = '47856321',
    @p_Genero = 'F',
    @p_Especialidad = 'Medicina del Trabajo',
    @p_RutaImagenFirma = NULL,
    @p_RutaCertificadoDigital = NULL;

PRINT '✓ Doctor 5 creado: Dra. Lucia Mercedes Castro Ramírez (Medicina del Trabajo)';

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║         ✓ 5 DOCTORES CREADOS EXITOSAMENTE                 ║';
PRINT '╚════════════════════════════════════════════════════════════╝';

-- Verificar doctores creados
SELECT
    D.Id AS DoctorId,
    P.Nombres + ' ' + P.Apellidos AS NombreCompleto,
    D.Codigo AS CodigoCMP,
    D.Especialidad,
    P.NDocumentoIdentidad
FROM T_DOCTOR D
INNER JOIN T_PERSONA P ON D.PersonaId = P.Id
WHERE D.Estado = '1'
ORDER BY D.Id;


-- ============================================
-- COMPLETAR PROGRAMA 2 Y 3
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

DECLARE @ProgramaId2 INT, @ProgramaId3 INT;
DECLARE @PerfilId INT;
DECLARE @ExamenId INT;

-- Obtener IDs de programas
SELECT @ProgramaId2 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Comercial%' AND Estado = '1';
SELECT @ProgramaId3 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Administrativo%' AND Estado = '1';

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║          COMPLETANDO PROGRAMAS 2 Y 3                      ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 2: PERSONAL COMERCIAL (6 perfiles, 2 tipos EMO)
-- ═══════════════════════════════════════════════════════════
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 2: PERSONAL COMERCIAL Y SOPORTE               │';
PRINT '└─────────────────────────────────────────────────────────┘';

-- PERFIL 2.1: Asesor de Negocios
PRINT '  → Asesor de Negocios';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Asesor de Negocios', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Asesor de Negocios' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Glucosa en Sangre';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.2: Ejecutivo de Atención al Cliente
PRINT '  → Ejecutivo de Atención al Cliente';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Ejecutivo de Atención al Cliente', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Ejecutivo de Atención al Cliente' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Atención y Concentración';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.3: Tecnólogo de Información
PRINT '  → Tecnólogo de Información';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Tecnólogo de Información', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Tecnólogo de Información' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Cervical';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.4: Personal de Call Center
PRINT '  → Personal de Call Center';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Personal de Call Center', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Personal de Call Center' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Cervical';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.5: Recepcionista
PRINT '  → Recepcionista';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Recepcionista', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Recepcionista' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.6: Personal de Limpieza
PRINT '  → Personal de Limpieza';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Personal de Limpieza', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Personal de Limpieza' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

PRINT '  ✓ Programa 2 completado: 6 perfiles';
PRINT '';

-- Continúo con Programa 3 en el siguiente mensaje...

SET NOCOUNT OFF;
GO


-- ============================================
-- COMPLETAR PROGRAMA 2 Y 3
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

DECLARE @ProgramaId2 INT, @ProgramaId3 INT;
DECLARE @PerfilId INT;
DECLARE @ExamenId INT;

-- Obtener IDs de programas
SELECT @ProgramaId2 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Comercial%' AND Estado = '1';
SELECT @ProgramaId3 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Administrativo%' AND Estado = '1';

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║          COMPLETANDO PROGRAMAS 2 Y 3                      ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 2: PERSONAL COMERCIAL (6 perfiles, 2 tipos EMO)
-- ═══════════════════════════════════════════════════════════
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 2: PERSONAL COMERCIAL Y SOPORTE               │';
PRINT '└─────────────────────────────────────────────────────────┘';

-- PERFIL 2.1: Asesor de Negocios
PRINT '  → Asesor de Negocios';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Asesor de Negocios', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Asesor de Negocios' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Glucosa en Sangre';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.2: Ejecutivo de Atención al Cliente
PRINT '  → Ejecutivo de Atención al Cliente';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Ejecutivo de Atención al Cliente', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Ejecutivo de Atención al Cliente' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Atención y Concentración';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.3: Tecnólogo de Información
PRINT '  → Tecnólogo de Información';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Tecnólogo de Información', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Tecnólogo de Información' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Cervical';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.4: Personal de Call Center
PRINT '  → Personal de Call Center';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Personal de Call Center', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Personal de Call Center' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Cervical';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.5: Recepcionista
PRINT '  → Recepcionista';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Recepcionista', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Recepcionista' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- PERFIL 2.6: Personal de Limpieza
PRINT '  → Personal de Limpieza';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Personal de Limpieza', @ProgramaId2;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Personal de Limpieza' AND ProgramaEMOId = @ProgramaId2 ORDER BY Id DESC;

SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

PRINT '  ✓ Programa 2 completado: 6 perfiles';
PRINT '';

-- Continúo con Programa 3 en el siguiente mensaje...

SET NOCOUNT OFF;
GO
-- ============================================
-- CONSULTAS DE MEMORIA DEL SISTEMA
-- Para registrar trabajadores y certificados
-- ============================================

USE DB_MEDIVALLE;
GO

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║         MEMORIA DEL SISTEMA - IDs Y RELACIONES            ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 1. ENTIDADES
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 1. ENTIDADES                                               │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    Id AS EntidadId,
    Nombre AS EntidadNombre,
    Estado,
    FechaCreacion
FROM T_ENTIDAD
WHERE Estado = '1'
ORDER BY Id;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 2. PROGRAMAS EMO
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 2. PROGRAMAS EMO                                           │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    PE.Id AS ProgramaEMOId,
    PE.Nombre AS ProgramaNombre,
    E.Id AS EntidadId,
    E.Nombre AS EntidadNombre,
    PE.Estado,
    PE.FechaCreacion
FROM T_PROGRAMA_EMO PE
INNER JOIN T_ENTIDAD E ON PE.EntidadId = E.Id
WHERE PE.Estado = '1'
ORDER BY PE.Id;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 3. PERFILES OCUPACIONALES POR PROGRAMA
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 3. PERFILES OCUPACIONALES POR PROGRAMA                    │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    PO.Id AS PerfilOcupacionalId,
    PO.Nombre AS PerfilNombre,
    PE.Id AS ProgramaEMOId,
    PE.Nombre AS ProgramaNombre,
    E.Nombre AS EntidadNombre,
    PO.Estado,
    (SELECT COUNT(*)
     FROM T_PERFIL_TIPO_EMO PTE
     WHERE PTE.PerfilOcupacionalId = PO.Id
       AND PTE.Estado = '1') AS CantidadTiposEMO
FROM T_PERFIL_OCUPACIONAL PO
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
INNER JOIN T_ENTIDAD E ON PE.EntidadId = E.Id
WHERE PO.Estado = '1'
ORDER BY PE.Id, PO.Nombre;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 4. PERFIL-TIPO EMO (COMBINACIONES DISPONIBLES)
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 4. PERFIL-TIPO EMO (Para asignar a trabajadores)          │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    PTE.Id AS PerfilTipoEMOId,
    PO.Id AS PerfilOcupacionalId,
    PO.Nombre AS PerfilNombre,
    PTE.TipoEMO,
    PE.Id AS ProgramaEMOId,
    PE.Nombre AS ProgramaNombre,
    E.Nombre AS EntidadNombre,
    (SELECT COUNT(*)
     FROM T_PROTOCOLO_EMO PRO
     WHERE PRO.PerfilTipoEMOId = PTE.Id
       AND PRO.EsRequerido = 1
       AND PRO.Estado = '1') AS ExamenesRequeridos
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
INNER JOIN T_ENTIDAD E ON PE.EntidadId = E.Id
WHERE PTE.Estado = '1'
  AND PO.Estado = '1'
  AND PE.Estado = '1'
ORDER BY PE.Id, PO.Nombre, PTE.TipoEMO;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 5. EXÁMENES MÉDICOS (CATÁLOGO COMPLETO)
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 5. CATÁLOGO DE EXÁMENES MÉDICOS                           │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    Id AS ExamenMedicoId,
    Nombre AS ExamenNombre,
    Estado,
    FechaCreacion
FROM T_EXAMEN_MEDICO_OCUPACIONAL
WHERE Estado = '1'
ORDER BY Nombre;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 6. PROTOCOLOS EMO (EXÁMENES POR PERFIL Y TIPO)
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 6. PROTOCOLOS EMO (Exámenes por Perfil y Tipo)            │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    PRO.Id AS ProtocoloEMOId,
    PTE.Id AS PerfilTipoEMOId,
    PO.Nombre AS PerfilNombre,
    PTE.TipoEMO,
    EMO.Id AS ExamenMedicoId,
    EMO.Nombre AS ExamenNombre,
    PRO.EsRequerido,
    CASE WHEN PRO.EsRequerido = 1 THEN 'OBLIGATORIO' ELSE 'OPCIONAL' END AS Importancia,
    PE.Nombre AS ProgramaNombre
FROM T_PROTOCOLO_EMO PRO
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PRO.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
INNER JOIN T_EXAMEN_MEDICO_OCUPACIONAL EMO ON PRO.ExamenMedicoOcupacionalId = EMO.Id
WHERE PRO.Estado = '1'
  AND PTE.Estado = '1'
  AND PO.Estado = '1'
  AND EMO.Estado = '1'
ORDER BY PE.Nombre, PO.Nombre, PTE.TipoEMO, EMO.Nombre;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 7. DOCTORES DISPONIBLES
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 7. DOCTORES DISPONIBLES                                    │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    D.Id AS DoctorId,
    P.Nombres + ' ' + P.Apellidos AS NombreCompleto,
    D.Codigo AS CodigoCMP,
    D.Especialidad,
    P.TipoDocumento,
    P.NDocumentoIdentidad,
    D.Estado,
    CASE
        WHEN P.Nombres IS NOT NULL
            AND P.Apellidos IS NOT NULL
            AND P.TipoDocumento IS NOT NULL
            AND P.NDocumentoIdentidad IS NOT NULL
            AND D.Codigo IS NOT NULL
            AND D.Especialidad IS NOT NULL
        THEN '✓ COMPLETO'
        ELSE '✗ INCOMPLETO'
    END AS EstadoValidacion
FROM T_DOCTOR D
INNER JOIN T_PERSONA P ON D.PersonaId = P.Id
WHERE D.Estado = '1'
  AND P.Estado = '1'
ORDER BY P.Apellidos, P.Nombres;

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 8. RESUMEN ESTADÍSTICO
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 8. RESUMEN ESTADÍSTICO DEL SISTEMA                        │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    'Entidades' AS Concepto,
    COUNT(*) AS Cantidad
FROM T_ENTIDAD
WHERE Estado = '1'

UNION ALL

SELECT
    'Programas EMO',
    COUNT(*)
FROM T_PROGRAMA_EMO
WHERE Estado = '1'

UNION ALL

SELECT
    'Perfiles Ocupacionales',
    COUNT(*)
FROM T_PERFIL_OCUPACIONAL
WHERE Estado = '1'

UNION ALL

SELECT
    'Combinaciones Perfil-Tipo EMO',
    COUNT(*)
FROM T_PERFIL_TIPO_EMO
WHERE Estado = '1'

UNION ALL

SELECT
    'Exámenes Médicos (Catálogo)',
    COUNT(*)
FROM T_EXAMEN_MEDICO_OCUPACIONAL
WHERE Estado = '1'

UNION ALL

SELECT
    'Protocolos Configurados',
    COUNT(*)
FROM T_PROTOCOLO_EMO
WHERE Estado = '1'

UNION ALL

SELECT
    'Doctores Disponibles',
    COUNT(*)
FROM T_DOCTOR
WHERE Estado = '1';

PRINT '';

-- ═══════════════════════════════════════════════════════════
-- 9. GUÍA RÁPIDA PARA REGISTRAR TRABAJADORES
-- ═══════════════════════════════════════════════════════════
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ 9. GUÍA: CÓMO REGISTRAR UN TRABAJADOR                     │';
PRINT '└────────────────────────────────────────────────────────────┘';
PRINT '';
PRINT 'PASO 1: Seleccionar un PerfilTipoEMOId de la consulta #4';
PRINT 'PASO 2: Obtener el ProgramaEMOId correspondiente';
PRINT 'PASO 3: Ejecutar S_INS_UPD_PERSONA_PROGRAMA con:';
PRINT '        - Datos de la persona (DNI obligatorio)';
PRINT '        - @p_ProgramaEMOId = [ID del programa]';
PRINT '        - @p_PerfilTipoEMOId = [ID de la combinación perfil-tipo]';
PRINT '';
PRINT 'EJEMPLO:';
PRINT 'EXEC S_INS_UPD_PERSONA_PROGRAMA';
PRINT '    @p_ParticipanteId = NULL,';
PRINT '    @p_Nombres = ''Juan'',';
PRINT '    @p_Apellidos = ''Pérez García'',';
PRINT '    @p_TipoDocumento = ''DNI'',';
PRINT '    @p_NDocumentoIdentidad = ''12345678'',';
PRINT '    @p_ProgramaEMOId = 1,            -- De la consulta #2';
PRINT '    @p_PerfilTipoEMOId = 1;          -- De la consulta #4';
PRINT '';

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║           CONSULTAS DE MEMORIA COMPLETADAS                ║';
PRINT '╚════════════════════════════════════════════════════════════╝';

-- ============================================
-- ENTIDAD 2: EMPRESA DE DESARROLLO DE SOFTWARE
-- TechSolutions S.A.C.
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║   CONFIGURACIÓN - EMPRESA DE DESARROLLO DE SOFTWARE       ║';
PRINT '║                TechSolutions S.A.C.                       ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- CREAR ENTIDAD: Empresa de Desarrollo de Software
PRINT '═══════════════════════════════════════════════════════════';
PRINT '  CREANDO ENTIDAD: TechSolutions S.A.C.';
PRINT '═══════════════════════════════════════════════════════════';

DECLARE @EntidadSoftwareId INT;

EXEC S_INS_UDP_ENTIDAD NULL, 'TechSolutions S.A.C. - Empresa de Desarrollo de Software';
SELECT TOP 1 @EntidadSoftwareId = Id FROM T_ENTIDAD WHERE Nombre LIKE '%TechSolutions%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Entidad creada - ID: ' + CAST(@EntidadSoftwareId AS VARCHAR);
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 1: PERSONAL TÉCNICO (Desarrolladores, QA, DevOps)
-- ═══════════════════════════════════════════════════════════
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 1: PERSONAL TÉCNICO                           │';
PRINT '└─────────────────────────────────────────────────────────┘';

DECLARE @ProgSoftware1Id INT, @PerfilId INT, @ExamenId INT;

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Técnico de Software - 2023', @EntidadSoftwareId;
SELECT TOP 1 @ProgSoftware1Id = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadSoftwareId AND Nombre LIKE '%Técnico%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa creado - ID: ' + CAST(@ProgSoftware1Id AS VARCHAR) + ' (Personal Técnico - 2023)';

-- PERFIL 1: Desarrollador de Software
PRINT '  → Configurando: Desarrollador de Software';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Desarrollador de Software', @ProgSoftware1Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Desarrollador de Software' AND ProgramaEMOId = @ProgSoftware1Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Oftalmológico Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Cervical';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Desarrollador de Software configurado (4 tipos EMO)';

-- PERFIL 2: Analista QA
PRINT '  → Configurando: Analista QA';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Analista QA', @ProgSoftware1Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Analista QA' AND ProgramaEMOId = @ProgSoftware1Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Atención y Concentración';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Analista QA configurado (4 tipos EMO)';

PRINT '  ✓ Programa 1 completado';
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 2: PERSONAL ADMINISTRATIVO Y SOPORTE
-- ═══════════════════════════════════════════════════════════
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 2: PERSONAL ADMINISTRATIVO Y SOPORTE          │';
PRINT '└─────────────────────────────────────────────────────────┘';

DECLARE @ProgSoftware2Id INT;

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Administrativo y Soporte - 2023', @EntidadSoftwareId;
SELECT TOP 1 @ProgSoftware2Id = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadSoftwareId AND Nombre LIKE '%Administrativo%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa creado - ID: ' + CAST(@ProgSoftware2Id AS VARCHAR) + ' (Personal Administrativo - 2023)';

-- PERFIL 1: Gerente de Proyectos
PRINT '  → Configurando: Gerente de Proyectos';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Gerente de Proyectos', @ProgSoftware2Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Gerente de Proyectos' AND ProgramaEMOId = @ProgSoftware2Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Electrocardiograma en Reposo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Gerente de Proyectos configurado (4 tipos EMO)';

-- PERFIL 2: Asistente Administrativo
PRINT '  → Configurando: Asistente Administrativo';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Asistente Administrativo', @ProgSoftware2Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Asistente Administrativo' AND ProgramaEMOId = @ProgSoftware2Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Asistente Administrativo configurado (4 tipos EMO)';

PRINT '  ✓ Programa 2 completado';
PRINT '';

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║    ✓ CONFIGURACIÓN TECHSOLUTIONS S.A.C. COMPLETADA       ║';
PRINT '╚════════════════════════════════════════════════════════════╝';

SET NOCOUNT OFF;
GO

-- ============================================
-- ENTIDAD 3: COLEGIO (INSTITUCIÓN EDUCATIVA)
-- I.E. San Martín de Porres
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║        CONFIGURACIÓN - INSTITUCIÓN EDUCATIVA               ║';
PRINT '║          I.E. San Martín de Porres                        ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- CREAR ENTIDAD: Colegio
PRINT '═══════════════════════════════════════════════════════════';
PRINT '  CREANDO ENTIDAD: I.E. San Martín de Porres';
PRINT '═══════════════════════════════════════════════════════════';

DECLARE @EntidadColegioId INT;

EXEC S_INS_UDP_ENTIDAD NULL, 'I.E. San Martín de Porres - Institución Educativa';
SELECT TOP 1 @EntidadColegioId = Id FROM T_ENTIDAD WHERE Nombre LIKE '%San Martín%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Entidad creada - ID: ' + CAST(@EntidadColegioId AS VARCHAR);
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 1: PERSONAL DOCENTE
-- ═══════════════════════════════════════════════════════════
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 1: PERSONAL DOCENTE                           │';
PRINT '└─────────────────────────────────────────────────────────┘';

DECLARE @ProgColegio1Id INT, @PerfilId INT, @ExamenId INT;

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Docente - 2023', @EntidadColegioId;
SELECT TOP 1 @ProgColegio1Id = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadColegioId AND Nombre LIKE '%Docente%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa creado - ID: ' + CAST(@ProgColegio1Id AS VARCHAR) + ' (Personal Docente - 2023)';

-- PERFIL 1: Profesor de Aula
PRINT '  → Configurando: Profesor de Aula';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Profesor de Aula', @ProgColegio1Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Profesor de Aula' AND ProgramaEMOId = @ProgColegio1Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Estrés Laboral';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Psicológica Ocupacional';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Profesor de Aula configurado (4 tipos EMO)';

-- PERFIL 2: Profesor de Educación Física
PRINT '  → Configurando: Profesor de Educación Física';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Profesor de Educación Física', @ProgColegio1Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Profesor de Educación Física' AND ProgramaEMOId = @ProgColegio1Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Electrocardiograma en Reposo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Movilidad Articular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Electrocardiograma en Reposo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Profesor de Educación Física configurado (4 tipos EMO)';

PRINT '  ✓ Programa 1 completado';
PRINT '';

-- ═══════════════════════════════════════════════════════════
-- PROGRAMA 2: PERSONAL ADMINISTRATIVO Y DE SERVICIOS
-- ═══════════════════════════════════════════════════════════
PRINT '┌─────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 2: PERSONAL ADMINISTRATIVO Y SERVICIOS        │';
PRINT '└─────────────────────────────────────────────────────────┘';

DECLARE @ProgColegio2Id INT;

EXEC S_INS_UPD_PROGRAMA_EMO NULL, 'Personal Administrativo y Servicios - 2024', @EntidadColegioId;
SELECT TOP 1 @ProgColegio2Id = Id FROM T_PROGRAMA_EMO WHERE EntidadId = @EntidadColegioId AND Nombre LIKE '%Administrativo%' AND Estado = '1' ORDER BY Id DESC;
PRINT '✓ Programa creado - ID: ' + CAST(@ProgColegio2Id AS VARCHAR) + ' (Personal Administrativo - 2024)';

-- PERFIL 1: Secretario/a Académico
PRINT '  → Configurando: Secretario/a Académico';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Secretario/a Académico', @ProgColegio2Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Secretario/a Académico' AND ProgramaEMOId = @ProgColegio2Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Cervical';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Test de Agudeza Visual';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Secretario/a Académico configurado (4 tipos EMO)';

-- PERFIL 2: Personal de Mantenimiento
PRINT '  → Configurando: Personal de Mantenimiento';
EXEC S_INS_UPD_PERFIL_OCUPACIONAL NULL, 'Personal de Mantenimiento', @ProgColegio2Id;
SELECT TOP 1 @PerfilId = Id FROM T_PERFIL_OCUPACIONAL WHERE Nombre = 'Personal de Mantenimiento' AND ProgramaEMOId = @ProgColegio2Id ORDER BY Id DESC;

-- INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Hemograma Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Tórax PA';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Radiografía de Columna Lumbosacra';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'INGRESO', @ExamenId, 1;

-- RE-INGRESO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RE-INGRESO', @ExamenId, 1;

-- PERIÓDICO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Evaluación Osteomuscular';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Audiometría';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'PERIÓDICO', @ExamenId, 1;

-- RETIRO
SELECT @ExamenId = Id FROM T_EXAMEN_MEDICO_OCUPACIONAL WHERE Nombre = 'Examen Médico Ocupacional Completo';
EXEC S_INS_UPD_PROTOCOLO_EMO @PerfilId, 'RETIRO', @ExamenId, 1;

PRINT '    ✓ Personal de Mantenimiento configurado (4 tipos EMO)';

PRINT '  ✓ Programa 2 completado';
PRINT '';

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║   ✓ CONFIGURACIÓN I.E. SAN MARTÍN DE PORRES COMPLETADA   ║';
PRINT '╚════════════════════════════════════════════════════════════╝';

SET NOCOUNT OFF;
GO

-- ============================================
-- RESUMEN FINAL DE TODAS LAS CONFIGURACIONES
-- ============================================

USE DB_MEDIVALLE;
GO

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║              RESUMEN FINAL DEL SISTEMA                    ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ ENTIDADES CONFIGURADAS:                                    │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    Id AS EntidadId,
    Nombre AS EntidadNombre,
    (SELECT COUNT(*) FROM T_PROGRAMA_EMO WHERE EntidadId = E.Id AND Estado = '1') AS CantidadProgramas
FROM T_ENTIDAD E
WHERE Estado = '1'
ORDER BY Id;

PRINT '';
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ TOTAL DE CONFIGURACIONES:                                  │';
PRINT '└────────────────────────────────────────────────────────────┘';

SELECT
    'Entidades Configuradas' AS Concepto,
    COUNT(*) AS Total
FROM T_ENTIDAD
WHERE Estado = '1'

UNION ALL

SELECT
    'Programas EMO Creados',
    COUNT(*)
FROM T_PROGRAMA_EMO
WHERE Estado = '1'

UNION ALL

SELECT
    'Perfiles Ocupacionales',
    COUNT(*)
FROM T_PERFIL_OCUPACIONAL
WHERE Estado = '1'

UNION ALL

SELECT
    'Protocolos Configurados',
    COUNT(*)
FROM T_PROTOCOLO_EMO
WHERE Estado = '1';

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║     ✓✓✓ TODAS LAS CONFIGURACIONES COMPLETADAS ✓✓✓        ║';
PRINT '║                                                            ║';
PRINT '║  • Banco de la Nación:                                    ║';
PRINT '║    - Personal Operativo - 2023                            ║';
PRINT '║    - Personal Comercial y Soporte - 2024                  ║';
PRINT '║    - Personal Administrativo y Gerencial - 2025           ║';
PRINT '║                                                            ║';
PRINT '║  • TechSolutions S.A.C.:                                  ║';
PRINT '║    - Personal Técnico de Software - 2023                  ║';
PRINT '║    - Personal Administrativo y Soporte - 2023             ║';
PRINT '║                                                            ║';
PRINT '║  • I.E. San Martín de Porres:                             ║';
PRINT '║    - Personal Docente - 2023                              ║';
PRINT '║    - Personal Administrativo y Servicios - 2024           ║';
PRINT '║                                                            ║';
PRINT '║  Total: 3 entidades, 7 programas EMO                      ║';
PRINT '║  Tipos EMO: INGRESO, RE-INGRESO, PERIÓDICO, RETIRO        ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';
