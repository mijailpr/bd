-- ============================================
-- INSERTAR COLABORADORES (PARTICIPANTES)
-- Sistema EMO - 20 personas por programa
-- ============================================
--
-- INSTRUCCIONES:
-- Este script inserta 20 colaboradores por CADA programa EMO existente
-- utilizando el procedimiento S_INS_UPD_PERSONA_PROGRAMA
--
-- REGLAS DE NEGOCIO APLICADAS:
-- 1. Cada colaborador tiene DNI único de 8 dígitos (no se puede repetir)
--    - Primeros 2 dígitos: aleatorios entre 62 y 73
--    - Siguientes 6 dígitos: aleatorios
-- 2. Un colaborador NO puede estar en 2 programas diferentes
-- 3. El T_PERFIL_OCUPACIONAL asignado debe pertenecer al mismo programa
-- 4. Cada T_PERSONA_PROGRAMA tiene un PerfilTipoEMOId (combinación de perfil + tipo EMO)
-- 5. Los colaboradores se distribuyen EQUITATIVAMENTE entre TODOS los perfiles de cada programa
--
-- FUNCIONAMIENTO DINÁMICO:
-- - El script consulta TODOS los programas EMO activos
-- - Para cada programa, consulta TODOS sus perfiles ocupacionales con tipo INGRESO
-- - Distribuye 20 colaboradores entre los perfiles disponibles
-- - Si un programa no tiene perfiles, se omite con advertencia
-- - DNIs realistas: 8 dígitos con prefijos 62-73 (rango típico de DNIs peruanos)
--
-- ============================================

USE DB_MEDIVALLE;
GO

SET NOCOUNT ON;

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║     INSERTANDO COLABORADORES EN PROGRAMAS EMO             ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- Variables globales
DECLARE @TotalColaboradoresInsertar INT = 20; -- Colaboradores por programa
DECLARE @DNIsGenerados TABLE (DNI NVARCHAR(20)); -- Para evitar duplicados

-- Cursor para recorrer todos los programas
DECLARE @ProgramaId INT;
DECLARE @ProgramaNombre NVARCHAR(300);
DECLARE @ColaboradoresInsertados INT;

DECLARE CursorProgramas CURSOR FOR
SELECT Id, Nombre
FROM T_PROGRAMA_EMO
WHERE Estado = '1'
ORDER BY Id;

OPEN CursorProgramas;
FETCH NEXT FROM CursorProgramas INTO @ProgramaId, @ProgramaNombre;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '┌────────────────────────────────────────────────────────────┐';
    PRINT '│ PROGRAMA: ' + @ProgramaNombre;
    PRINT '└────────────────────────────────────────────────────────────┘';

    -- Obtener todos los perfiles con tipo INGRESO de este programa
    DECLARE @PerfilTipoEMOId INT;
    DECLARE @PerfilNombre NVARCHAR(200);
    DECLARE @TotalPerfiles INT;
    DECLARE @ColaboradoresPorPerfil INT;
    DECLARE @ColaboradoresRestantes INT;
    DECLARE @IndicePerfil INT = 0;

    -- Contar perfiles disponibles
    SELECT @TotalPerfiles = COUNT(*)
    FROM T_PERFIL_TIPO_EMO PTE
    INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
    WHERE PO.ProgramaEMOId = @ProgramaId
      AND PTE.TipoEMO = 'INGRESO'
      AND PTE.Estado = '1'
      AND PO.Estado = '1';

    IF @TotalPerfiles = 0
    BEGIN
        PRINT '  ⚠ ADVERTENCIA: No hay perfiles INGRESO configurados para este programa';
        PRINT '  → Saltando programa...';
        PRINT '';

        FETCH NEXT FROM CursorProgramas INTO @ProgramaId, @ProgramaNombre;
        CONTINUE;
    END

    -- Calcular colaboradores por perfil
    SET @ColaboradoresPorPerfil = @TotalColaboradoresInsertar / @TotalPerfiles;
    SET @ColaboradoresRestantes = @TotalColaboradoresInsertar % @TotalPerfiles;

    PRINT '  Total perfiles disponibles: ' + CAST(@TotalPerfiles AS VARCHAR);
    PRINT '  Distribución base: ' + CAST(@ColaboradoresPorPerfil AS VARCHAR) + ' colaboradores por perfil';
    IF @ColaboradoresRestantes > 0
        PRINT '  + ' + CAST(@ColaboradoresRestantes AS VARCHAR) + ' adicionales en primeros perfiles';
    PRINT '';

    SET @ColaboradoresInsertados = 0;

    -- Cursor para recorrer perfiles de este programa
    DECLARE CursorPerfiles CURSOR FOR
    SELECT PTE.Id, PO.Nombre
    FROM T_PERFIL_TIPO_EMO PTE
    INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
    WHERE PO.ProgramaEMOId = @ProgramaId
      AND PTE.TipoEMO = 'INGRESO'
      AND PTE.Estado = '1'
      AND PO.Estado = '1'
    ORDER BY PO.Id;

    OPEN CursorPerfiles;
    FETCH NEXT FROM CursorPerfiles INTO @PerfilTipoEMOId, @PerfilNombre;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @IndicePerfil = @IndicePerfil + 1;

        -- Determinar cuántos colaboradores asignar a este perfil
        DECLARE @ColabsParaEstePerfil INT = @ColaboradoresPorPerfil;
        IF @IndicePerfil <= @ColaboradoresRestantes
            SET @ColabsParaEstePerfil = @ColabsParaEstePerfil + 1;

        PRINT '  → ' + @PerfilNombre + ': insertando ' + CAST(@ColabsParaEstePerfil AS VARCHAR) + ' colaboradores';

        -- Insertar colaboradores para este perfil
        DECLARE @i INT = 0;
        WHILE @i < @ColabsParaEstePerfil AND @ColaboradoresInsertados < @TotalColaboradoresInsertar
        BEGIN
            -- Generar DNI único de 8 dígitos
            -- Primeros 2 dígitos: entre 62 y 73
            -- Siguientes 6 dígitos: aleatorios
            DECLARE @DNI NVARCHAR(20);
            DECLARE @DNIExiste INT = 1;

            WHILE @DNIExiste = 1
            BEGIN
                DECLARE @PrimerDos INT = 62 + CAST((RAND() * 12) AS INT); -- Entre 62 y 73
                DECLARE @Ultimos6 INT = 100000 + CAST((RAND() * 899999) AS INT); -- Entre 100000 y 999999
                SET @DNI = CAST(@PrimerDos AS NVARCHAR(2)) + CAST(@Ultimos6 AS NVARCHAR(6));

                -- Verificar si el DNI ya existe
                IF NOT EXISTS (SELECT 1 FROM @DNIsGenerados WHERE DNI = @DNI)
                BEGIN
                    INSERT INTO @DNIsGenerados (DNI) VALUES (@DNI);
                    SET @DNIExiste = 0;
                END
            END

            -- Generar datos aleatorios para variedad
            DECLARE @Semilla INT = CAST((RAND() * 1000000) AS INT);
            DECLARE @GrupoSang NVARCHAR(10) = CASE (@Semilla % 4)
                WHEN 0 THEN 'O'
                WHEN 1 THEN 'A'
                WHEN 2 THEN 'B'
                ELSE 'AB'
            END;

            DECLARE @RhFactor NVARCHAR(10) = CASE (@Semilla % 2)
                WHEN 0 THEN '+'
                ELSE '-'
            END;

            DECLARE @Genero NVARCHAR(20) = CASE (@Semilla % 2)
                WHEN 0 THEN 'M'
                ELSE 'F'
            END;

            DECLARE @Edad INT = 23 + (@Semilla % 18); -- Edades entre 23 y 40

            -- Nombres aleatorios
            DECLARE @Nombres NVARCHAR(100) = CASE (@Semilla % 10)
                WHEN 0 THEN CASE @Genero WHEN 'M' THEN 'Juan Carlos' ELSE 'María Elena' END
                WHEN 1 THEN CASE @Genero WHEN 'M' THEN 'Pedro Miguel' ELSE 'Ana Patricia' END
                WHEN 2 THEN CASE @Genero WHEN 'M' THEN 'Luis Fernando' ELSE 'Carmen Rosa' END
                WHEN 3 THEN CASE @Genero WHEN 'M' THEN 'Jorge Alberto' ELSE 'Lucía Mercedes' END
                WHEN 4 THEN CASE @Genero WHEN 'M' THEN 'Carlos Andrés' ELSE 'Diana Carolina' END
                WHEN 5 THEN CASE @Genero WHEN 'M' THEN 'Roberto José' ELSE 'Sandra Milena' END
                WHEN 6 THEN CASE @Genero WHEN 'M' THEN 'Andrés Felipe' ELSE 'Paola Andrea' END
                WHEN 7 THEN CASE @Genero WHEN 'M' THEN 'Fernando José' ELSE 'Gabriela Isabel' END
                WHEN 8 THEN CASE @Genero WHEN 'M' THEN 'Sebastián David' ELSE 'Valentina Sofía' END
                ELSE CASE @Genero WHEN 'M' THEN 'Miguel Ángel' ELSE 'Isabella Catalina' END
            END;

            DECLARE @Apellidos NVARCHAR(100) = CASE ((@Semilla / 10) % 10)
                WHEN 0 THEN 'Pérez López'
                WHEN 1 THEN 'García Rodríguez'
                WHEN 2 THEN 'Martínez Silva'
                WHEN 3 THEN 'Hernández Torres'
                WHEN 4 THEN 'González Ramírez'
                WHEN 5 THEN 'Sánchez Vargas'
                WHEN 6 THEN 'Rojas Morales'
                WHEN 7 THEN 'Flores Castro'
                WHEN 8 THEN 'Díaz Gutiérrez'
                ELSE 'Reyes Núñez'
            END;

            -- Insertar colaborador
            EXEC S_INS_UPD_PERSONA_PROGRAMA
                NULL,                                   -- Nuevo registro
                @Nombres,
                @Apellidos,
                'DNI',
                @DNI,                                   -- DNI único aleatorio
                NULL,                                   -- Telefono
                NULL,                                   -- Correo
                @Edad,
                @Genero,
                @GrupoSang,
                @RhFactor,
                @ProgramaId,
                @PerfilTipoEMOId;

            SET @i = @i + 1;
            SET @ColaboradoresInsertados = @ColaboradoresInsertados + 1;
        END

        FETCH NEXT FROM CursorPerfiles INTO @PerfilTipoEMOId, @PerfilNombre;
    END

    CLOSE CursorPerfiles;
    DEALLOCATE CursorPerfiles;

    PRINT '  ✓ Total insertados en este programa: ' + CAST(@ColaboradoresInsertados AS VARCHAR);
    PRINT '';

    FETCH NEXT FROM CursorProgramas INTO @ProgramaId, @ProgramaNombre;
END

CLOSE CursorProgramas;
DEALLOCATE CursorProgramas;

PRINT '╔════════════════════════════════════════════════════════════╗';
PRINT '║    INSERCIÓN DE COLABORADORES COMPLETADA                  ║';
PRINT '╚════════════════════════════════════════════════════════════╝';
PRINT '';

-- Resumen final
PRINT 'RESUMEN POR PROGRAMA:';
PRINT '─────────────────────────────────────────────────────────────';

SELECT
    PE.Nombre AS Programa,
    COUNT(DISTINCT PP.Id) AS TotalColaboradores,
    COUNT(DISTINCT PTE.Id) AS PerfilesUsados
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PROGRAMA_EMO PE ON PP.ProgramaEMOId = PE.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
WHERE PP.Estado = '1'
GROUP BY PE.Id, PE.Nombre
ORDER BY PE.Id;

PRINT '';
PRINT 'DISTRIBUCIÓN POR PERFIL:';
PRINT '─────────────────────────────────────────────────────────────';

SELECT
    PE.Nombre AS Programa,
    PO.Nombre AS Perfil,
    COUNT(PP.Id) AS Colaboradores
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
INNER JOIN T_PROGRAMA_EMO PE ON PO.ProgramaEMOId = PE.Id
WHERE PP.Estado = '1'
GROUP BY PE.Nombre, PO.Nombre
ORDER BY PE.Nombre, PO.Nombre;

SET NOCOUNT OFF;
GO
