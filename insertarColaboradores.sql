-- ============================================
-- INSERTAR COLABORADORES (PARTICIPANTES)
-- Sistema EMO - 20 personas por programa
-- ============================================
--
-- INSTRUCCIONES:
-- Este script inserta 60 colaboradores (20 por cada programa EMO)
-- utilizando el procedimiento S_INS_UPD_PERSONA_PROGRAMA
--
-- REGLAS DE NEGOCIO APLICADAS:
-- 1. Cada colaborador tiene DNI único (no se puede repetir)
-- 2. Un colaborador NO puede estar en 2 programas diferentes
-- 3. El T_PERFIL_OCUPACIONAL asignado debe pertenecer al mismo programa
-- 4. Cada T_PERSONA_PROGRAMA tiene un PerfilTipoEMOId (combinación de perfil + tipo EMO)
-- 5. Los colaboradores se distribuyen entre los diferentes perfiles de cada programa
--
-- DISTRIBUCIÓN:
-- - Programa 1 (Operativo): 20 colaboradores en 4 perfiles
-- - Programa 2 (Comercial): 20 colaboradores en 6 perfiles
-- - Programa 3 (Administrativo): 20 colaboradores
--
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║     INSERTANDO COLABORADORES EN PROGRAMAS EMO             ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

DECLARE @Resultado INT;
DECLARE @DNIBase INT = 10000000; -- Base para DNIs únicos

-- ============================================
-- PROGRAMA 1: PERSONAL OPERATIVO
-- 20 colaboradores distribuidos en 4 perfiles
-- ============================================
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 1: PERSONAL OPERATIVO (20 colaboradores)         │';
PRINT '└────────────────────────────────────────────────────────────┘';

-- Obtener IDs de Perfil-Tipo EMO para Programa 1 (INGRESO)
DECLARE @P1_Cajero_Ingreso INT, @P1_Seguridad_Ingreso INT, @P1_Boveda_Ingreso INT, @P1_Mensajero_Ingreso INT;

SELECT @P1_Cajero_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Cajero'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Operativo%'
  AND PTE.Estado = '1';

SELECT @P1_Seguridad_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Oficial de Seguridad'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Operativo%'
  AND PTE.Estado = '1';

SELECT @P1_Boveda_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Operador de Bóveda'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Operativo%'
  AND PTE.Estado = '1';

SELECT @P1_Mensajero_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Mensajero/Courier'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Operativo%'
  AND PTE.Estado = '1';

DECLARE @ProgramaId1 INT;
SELECT @ProgramaId1 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Operativo%' AND Estado = '1';

-- 5 Cajeros
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Juan Carlos', 'Pérez López', 'DNI', '10000001', NULL, NULL, 28, 'M', 'O', '+', @ProgramaId1, @P1_Cajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'María Elena', 'García Rodríguez', 'DNI', '10000002', NULL, NULL, 32, 'F', 'A', '+', @ProgramaId1, @P1_Cajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Carlos Alberto', 'Sánchez Vargas', 'DNI', '10000003', NULL, NULL, 25, 'M', 'B', '+', @ProgramaId1, @P1_Cajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Ana Patricia', 'Torres Mendoza', 'DNI', '10000004', NULL, NULL, 29, 'F', 'AB', '+', @ProgramaId1, @P1_Cajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Roberto José', 'Flores Castro', 'DNI', '10000005', NULL, NULL, 31, 'M', 'O', '-', @ProgramaId1, @P1_Cajero_Ingreso;

-- 5 Oficiales de Seguridad
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Luis Fernando', 'Ramírez Díaz', 'DNI', '10000006', NULL, NULL, 35, 'M', 'A', '+', @ProgramaId1, @P1_Seguridad_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Carmen Rosa', 'Gutiérrez Silva', 'DNI', '10000007', NULL, NULL, 33, 'F', 'B', '-', @ProgramaId1, @P1_Seguridad_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Pedro Miguel', 'Hernández Rojas', 'DNI', '10000008', NULL, NULL, 38, 'M', 'O', '+', @ProgramaId1, @P1_Seguridad_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Lucía Mercedes', 'Morales Vega', 'DNI', '10000009', NULL, NULL, 30, 'F', 'AB', '+', @ProgramaId1, @P1_Seguridad_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Jorge Luis', 'Campos Ríos', 'DNI', '10000010', NULL, NULL, 36, 'M', 'A', '-', @ProgramaId1, @P1_Seguridad_Ingreso;

-- 5 Operadores de Bóveda
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Diana Carolina', 'Reyes Núñez', 'DNI', '10000011', NULL, NULL, 27, 'F', 'O', '+', @ProgramaId1, @P1_Boveda_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Miguel Ángel', 'Cruz Paredes', 'DNI', '10000012', NULL, NULL, 34, 'M', 'B', '+', @ProgramaId1, @P1_Boveda_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Sandra Milena', 'Ortiz Fuentes', 'DNI', '10000013', NULL, NULL, 26, 'F', 'A', '+', @ProgramaId1, @P1_Boveda_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Andrés Felipe', 'Maldonado Peña', 'DNI', '10000014', NULL, NULL, 29, 'M', 'AB', '-', @ProgramaId1, @P1_Boveda_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Paola Andrea', 'Ramos Cabrera', 'DNI', '10000015', NULL, NULL, 31, 'F', 'O', '-', @ProgramaId1, @P1_Boveda_Ingreso;

-- 5 Mensajeros/Couriers
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Fernando José', 'Salazar Montes', 'DNI', '10000016', NULL, NULL, 24, 'M', 'A', '+', @ProgramaId1, @P1_Mensajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Gabriela Isabel', 'Medina Lara', 'DNI', '10000017', NULL, NULL, 23, 'F', 'B', '+', @ProgramaId1, @P1_Mensajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Ricardo Javier', 'Figueroa Toro', 'DNI', '10000018', NULL, NULL, 26, 'M', 'O', '+', @ProgramaId1, @P1_Mensajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Valeria Sofía', 'Cortés Palacios', 'DNI', '10000019', NULL, NULL, 25, 'F', 'AB', '+', @ProgramaId1, @P1_Mensajero_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Héctor Manuel', 'Aguilar Bermúdez', 'DNI', '10000020', NULL, NULL, 27, 'M', 'A', '-', @ProgramaId1, @P1_Mensajero_Ingreso;

PRINT '✓ Programa 1: 20 colaboradores insertados (5 por perfil)';
PRINT '';

-- ============================================
-- PROGRAMA 2: PERSONAL COMERCIAL Y SOPORTE
-- 20 colaboradores distribuidos en 6 perfiles
-- ============================================
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 2: PERSONAL COMERCIAL (20 colaboradores)         │';
PRINT '└────────────────────────────────────────────────────────────┘';

-- Obtener IDs de Perfil-Tipo EMO para Programa 2 (INGRESO)
DECLARE @P2_Asesor_Ingreso INT, @P2_Ejecutivo_Ingreso INT, @P2_TI_Ingreso INT;
DECLARE @P2_CallCenter_Ingreso INT, @P2_Recepcion_Ingreso INT, @P2_Limpieza_Ingreso INT;

SELECT @P2_Asesor_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Asesor de Negocios'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Comercial%'
  AND PTE.Estado = '1';

SELECT @P2_Ejecutivo_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Ejecutivo de Atención al Cliente'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Comercial%'
  AND PTE.Estado = '1';

SELECT @P2_TI_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Tecnólogo de Información'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Comercial%'
  AND PTE.Estado = '1';

SELECT @P2_CallCenter_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Personal de Call Center'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Comercial%'
  AND PTE.Estado = '1';

SELECT @P2_Recepcion_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Recepcionista'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Comercial%'
  AND PTE.Estado = '1';

SELECT @P2_Limpieza_Ingreso = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PO.Nombre = 'Personal de Limpieza'
  AND PTE.TipoEMO = 'INGRESO'
  AND PE.Nombre LIKE '%Comercial%'
  AND PTE.Estado = '1';

DECLARE @ProgramaId2 INT;
SELECT @ProgramaId2 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Comercial%' AND Estado = '1';

-- 4 Asesores de Negocios
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Daniela Marcela', 'Vargas León', 'DNI', '20000001', NULL, NULL, 30, 'F', 'O', '+', @ProgramaId2, @P2_Asesor_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Sebastián Andrés', 'Navarro Bravo', 'DNI', '20000002', NULL, NULL, 28, 'M', 'A', '+', @ProgramaId2, @P2_Asesor_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Natalia Fernanda', 'Jiménez Cano', 'DNI', '20000003', NULL, NULL, 32, 'F', 'B', '-', @ProgramaId2, @P2_Asesor_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Alejandro David', 'Romero Paz', 'DNI', '20000004', NULL, NULL, 29, 'M', 'AB', '+', @ProgramaId2, @P2_Asesor_Ingreso;

-- 4 Ejecutivos de Atención
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Isabella Valentina', 'Guerrero Luna', 'DNI', '20000005', NULL, NULL, 27, 'F', 'O', '-', @ProgramaId2, @P2_Ejecutivo_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Mateo Santiago', 'Prieto Márquez', 'DNI', '20000006', NULL, NULL, 26, 'M', 'A', '+', @ProgramaId2, @P2_Ejecutivo_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Camila Andrea', 'Molina Arias', 'DNI', '20000007', NULL, NULL, 31, 'F', 'B', '+', @ProgramaId2, @P2_Ejecutivo_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Diego Alejandro', 'Delgado Santos', 'DNI', '20000008', NULL, NULL, 28, 'M', 'O', '+', @ProgramaId2, @P2_Ejecutivo_Ingreso;

-- 3 Tecnólogos TI
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Sofía Catalina', 'Peña Duarte', 'DNI', '20000009', NULL, NULL, 25, 'F', 'AB', '+', @ProgramaId2, @P2_TI_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Nicolás Eduardo', 'Rubio Cardona', 'DNI', '20000010', NULL, NULL, 27, 'M', 'A', '-', @ProgramaId2, @P2_TI_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Juliana María', 'Ibáñez Franco', 'DNI', '20000011', NULL, NULL, 26, 'F', 'B', '+', @ProgramaId2, @P2_TI_Ingreso;

-- 3 Personal Call Center
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Martín Alonso', 'Pacheco Vera', 'DNI', '20000012', NULL, NULL, 24, 'M', 'O', '+', @ProgramaId2, @P2_CallCenter_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Valentina Lucía', 'Serrano Arce', 'DNI', '20000013', NULL, NULL, 23, 'F', 'A', '+', @ProgramaId2, @P2_CallCenter_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Felipe Augusto', 'Suárez Ossa', 'DNI', '20000014', NULL, NULL, 25, 'M', 'AB', '-', @ProgramaId2, @P2_CallCenter_Ingreso;

-- 3 Recepcionistas
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Laura Tatiana', 'Mora Espinosa', 'DNI', '20000015', NULL, NULL, 26, 'F', 'O', '-', @ProgramaId2, @P2_Recepcion_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Emilio José', 'Bautista Robles', 'DNI', '20000016', NULL, NULL, 27, 'M', 'B', '+', @ProgramaId2, @P2_Recepcion_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Carolina Isabel', 'Acosta Miranda', 'DNI', '20000017', NULL, NULL, 28, 'F', 'A', '+', @ProgramaId2, @P2_Recepcion_Ingreso;

-- 3 Personal de Limpieza
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Rosa Elena', 'Villa Cárdenas', 'DNI', '20000018', NULL, NULL, 35, 'F', 'O', '+', @ProgramaId2, @P2_Limpieza_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Manuel Antonio', 'Escobar Mejía', 'DNI', '20000019', NULL, NULL, 38, 'M', 'B', '+', @ProgramaId2, @P2_Limpieza_Ingreso;
EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Gloria Amparo', 'Pineda Carrillo', 'DNI', '20000020', NULL, NULL, 40, 'F', 'A', '-', @ProgramaId2, @P2_Limpieza_Ingreso;

PRINT '✓ Programa 2: 20 colaboradores insertados (distribuidos en 6 perfiles)';
PRINT '';

-- ============================================
-- PROGRAMA 3: PERSONAL ADMINISTRATIVO
-- 20 colaboradores (asumiendo que hay perfiles administrativos)
-- ============================================
PRINT '┌────────────────────────────────────────────────────────────┐';
PRINT '│ PROGRAMA 3: PERSONAL ADMINISTRATIVO (20 colaboradores)    │';
PRINT '└────────────────────────────────────────────────────────────┘';

-- Nota: Se insertarán cuando se definan los perfiles para Programa 3
-- Por ahora, usar los perfiles disponibles del Programa 3 si existen

DECLARE @ProgramaId3 INT;
DECLARE @P3_Perfil1 INT, @P3_Perfil2 INT, @P3_Perfil3 INT, @P3_Perfil4 INT;

SELECT @ProgramaId3 = Id FROM T_PROGRAMA_EMO WHERE Nombre LIKE '%Administrativo%' AND Estado = '1';

-- Obtener hasta 4 perfiles del Programa 3 (si existen)
SELECT TOP 1 @P3_Perfil1 = PTE.Id
FROM T_PERFIL_TIPO_EMO PTE
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
WHERE PO.ProgramaEMOId = @ProgramaId3
  AND PTE.TipoEMO = 'INGRESO'
  AND PTE.Estado = '1'
ORDER BY PTE.Id;

IF @P3_Perfil1 IS NOT NULL
BEGIN
    -- 20 colaboradores administrativos (usar los perfiles disponibles)
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Álvaro Enrique', 'Gómez Barrera', 'DNI', '30000001', NULL, NULL, 33, 'M', 'O', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Beatriz Eugenia', 'Montoya Parra', 'DNI', '30000002', NULL, NULL, 34, 'F', 'A', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Cristian Camilo', 'Valencia Ochoa', 'DNI', '30000003', NULL, NULL, 30, 'M', 'B', '-', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Dora Cecilia', 'Zapata Arango', 'DNI', '30000004', NULL, NULL, 36, 'F', 'AB', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Eduardo Fabián', 'Muñoz Betancur', 'DNI', '30000005', NULL, NULL, 32, 'M', 'O', '-', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Fernanda Cristina', 'Henao Álvarez', 'DNI', '30000006', NULL, NULL, 29, 'F', 'A', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Germán Arturo', 'Castaño Gil', 'DNI', '30000007', NULL, NULL, 35, 'M', 'B', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Helena Victoria', 'Aristizábal Calle', 'DNI', '30000008', NULL, NULL, 31, 'F', 'O', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Ignacio Mauricio', 'Vélez Ramírez', 'DNI', '30000009', NULL, NULL, 33, 'M', 'AB', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Jimena Patricia', 'Cardona Mesa', 'DNI', '30000010', NULL, NULL, 28, 'F', 'A', '-', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Kevin Andrés', 'Hurtado Ríos', 'DNI', '30000011', NULL, NULL, 27, 'M', 'B', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Liliana Marcela', 'Bedoya Salazar', 'DNI', '30000012', NULL, NULL, 30, 'F', 'O', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Mario Alberto', 'Correa Gómez', 'DNI', '30000013', NULL, NULL, 34, 'M', 'A', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Nora Liliana', 'Uribe Tobón', 'DNI', '30000014', NULL, NULL, 32, 'F', 'AB', '-', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Óscar Iván', 'Londoño Ramírez', 'DNI', '30000015', NULL, NULL, 37, 'M', 'O', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Patricia Elena', 'Mejía Gómez', 'DNI', '30000016', NULL, NULL, 35, 'F', 'B', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Quintín Raúl', 'Restrepo García', 'DNI', '30000017', NULL, NULL, 39, 'M', 'A', '-', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Rocío Amparo', 'Jaramillo López', 'DNI', '30000018', NULL, NULL, 36, 'F', 'O', '-', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Sergio Andrés', 'Ospina Martínez', 'DNI', '30000019', NULL, NULL, 31, 'M', 'AB', '+', @ProgramaId3, @P3_Perfil1;
    EXEC S_INS_UPD_PERSONA_PROGRAMA NULL, 'Teresa Inés', 'Giraldo Pérez', 'DNI', '30000020', NULL, NULL, 33, 'F', 'A', '+', @ProgramaId3, @P3_Perfil1;

    PRINT '✓ Programa 3: 20 colaboradores insertados';
END
ELSE
BEGIN
    PRINT '⚠ Programa 3: No se encontraron perfiles. Configurar perfiles primero.';
END

PRINT '';
PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║    INSERCIÓN DE COLABORADORES COMPLETADA                  ║';
PRINT '║    Total: 60 colaboradores (20 por programa)              ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- Verificar totales
SELECT
    PE.Nombre AS Programa,
    COUNT(PP.Id) AS TotalColaboradores
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
WHERE PP.Estado = '1'
GROUP BY PE.Id, PE.Nombre
ORDER BY PE.Id;

SET NOCOUNT OFF;
GO
