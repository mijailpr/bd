-- ============================================
-- INSERTAR COLABORADORES (PARTICIPANTES)
-- Sistema EMO - 150 personas por programa
-- ============================================
--
-- INSTRUCCIONES:
-- Este script inserta 150 colaboradores por CADA programa EMO existente
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
-- - Distribuye 150 colaboradores entre los perfiles disponibles
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
DECLARE @TotalColaboradoresInsertar INT = 150; -- Colaboradores por programa
DECLARE @DNIsGenerados TABLE
                       (
                           DNI NVARCHAR(20)
                       );
-- Para evitar duplicados

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

                PRINT '  → ' + @PerfilNombre + ': insertando ' + CAST(@ColabsParaEstePerfil AS VARCHAR) +
                      ' colaboradores';

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

                        DECLARE @Edad INT = 23 + (@Semilla % 18);
                        -- Edades entre 23 y 40

                        -- Nombres aleatorios

                        DECLARE @Nombres NVARCHAR(100) = CASE (@Semilla % 300)
                                                             WHEN 0
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Juan Carlos' ELSE 'María Elena' END
                                                             WHEN 1
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Pedro Miguel' ELSE 'Ana Patricia' END
                                                             WHEN 2
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luis Fernando' ELSE 'Carmen Rosa' END
                                                             WHEN 3
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jorge Alberto' ELSE 'Lucía Mercedes' END
                                                             WHEN 4
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Carlos Andrés' ELSE 'Diana Carolina' END
                                                             WHEN 5
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Roberto José' ELSE 'Sandra Milena' END
                                                             WHEN 6
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Andrés Felipe' ELSE 'Paola Andrea' END
                                                             WHEN 7
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Fernando José' ELSE 'Gabriela Isabel' END
                                                             WHEN 8
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Sebastián David' ELSE 'Valentina Sofía' END
                                                             WHEN 9
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Miguel Ángel' ELSE 'Isabella Catalina' END
                                                             WHEN 10
                                                                 THEN CASE @Genero WHEN 'M' THEN 'José Luis' ELSE 'Laura Vanessa' END
                                                             WHEN 11
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Diego Armando' ELSE 'Camila Alejandra' END
                                                             WHEN 12
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Alejandro José' ELSE 'Sofía Elizabeth' END
                                                             WHEN 13
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ricardo Martín' ELSE 'Valeria Marisol' END
                                                             WHEN 14
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Eduardo Martín' ELSE 'Natalia Beatriz' END
                                                             WHEN 15
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Manuel Jesús' ELSE 'Carolina Isabel' END
                                                             WHEN 16
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Francisco Javier' ELSE 'Juliana Andrea' END
                                                             WHEN 17
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Gustavo Adolfo' ELSE 'Daniela Patricia' END
                                                             WHEN 18
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Raúl Ernesto' ELSE 'Adriana Lucía' END
                                                             WHEN 19
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Víctor Manuel' ELSE 'Mariana Fernanda' END
                                                             WHEN 20
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ángel David' ELSE 'Nicole Stefany' END
                                                             WHEN 21
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Marco Antonio' ELSE 'Fiorella Geraldine' END
                                                             WHEN 22
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Javier Alonso' ELSE 'Lesly Giuliana' END
                                                             WHEN 23
                                                                 THEN CASE @Genero WHEN 'M' THEN 'César Augusto' ELSE 'Maricarmen del Pilar' END
                                                             WHEN 24
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Renzo Alessandro' ELSE 'Katherine Melissa' END
                                                             WHEN 25
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jean Pierre' ELSE 'Ximena del Pilar' END
                                                             WHEN 26
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Bryan Stiven' ELSE 'Milagros del Rosario' END
                                                             WHEN 27
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jhonatan Paul' ELSE 'Fátima del Rocío' END
                                                             WHEN 28
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Christian Fabricio' ELSE 'Angie Geraldine' END
                                                             WHEN 29
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Kevin Alexander' ELSE 'Brigitte Natali' END
                                                             WHEN 30
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Edison Mauricio' ELSE 'Yessica Milenka' END
                                                             WHEN 31
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Wilfredo Jesús' ELSE 'María del Carmen' END
                                                             WHEN 32
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Julio César' ELSE 'Rosa Elena' END
                                                             WHEN 33
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Héctor Raúl' ELSE 'Gloria Mercedes' END
                                                             WHEN 34
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Enrique Martín' ELSE 'Patricia del Rosario' END
                                                             WHEN 35
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Omar Alejandro' ELSE 'Esther Elizabeth' END
                                                             WHEN 36
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Rodolfo Antonio' ELSE 'Clara Inés' END
                                                             WHEN 37
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Walter Eduardo' ELSE 'Silvia Roxana' END
                                                             WHEN 38
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Alfredo José' ELSE 'Mónica Liliana' END
                                                             WHEN 39
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Guillermo Enrique' ELSE 'Cynthia Vanessa' END
                                                             WHEN 40
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Felipe Andrés' ELSE 'Marisol Alejandra' END
                                                             WHEN 41
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Santiago Martín' ELSE 'Jimena Valeria' END
                                                             WHEN 42
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Mateo Alejandro' ELSE 'Renata Sofía' END
                                                             WHEN 43
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Thiago Nicolás' ELSE 'Emma Valentina' END
                                                             WHEN 44
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Liam Santiago' ELSE 'Zoe Victoria' END
                                                             WHEN 45
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Dylan Fabricio' ELSE 'Luna Catalina' END
                                                             WHEN 46
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Gael Mauricio' ELSE 'Mía Alessandra' END
                                                             WHEN 47
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ian Sebastián' ELSE 'Amelia Isabella' END
                                                             WHEN 48
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Noah Benjamín' ELSE 'Olivia Regina' END
                                                             WHEN 49
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lucas Matías' ELSE 'Aurora Celeste' END

                                                             WHEN 50
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Benjamín Alonso' ELSE 'Emilia Guadalupe' END
                                                             WHEN 51
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Emilio Andrés' ELSE 'Valentina Paz' END
                                                             WHEN 52
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Tomás Ignacio' ELSE 'Martina Belén' END
                                                             WHEN 53
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Joaquín Mateo' ELSE 'Isabella Renata' END
                                                             WHEN 54
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Agustín Gabriel' ELSE 'Catalina Sofía' END
                                                             WHEN 55
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lautaro Nicolás' ELSE 'Antonella Victoria' END
                                                             WHEN 56
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maximiliano José' ELSE 'Florencia Camila' END
                                                             WHEN 57
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Facundo Alexis' ELSE 'Luciana Abigail' END
                                                             WHEN 58
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Bruno Ezequiel' ELSE 'Delfina Milagros' END
                                                             WHEN 59
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Valentín Hugo' ELSE 'Morena Elizabeth' END
                                                             WHEN 60
                                                                 THEN CASE @Genero WHEN 'M' THEN 'René Alberto' ELSE 'Yomira del Pilar' END
                                                             WHEN 61
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Percy William' ELSE 'Yadira Marisol' END
                                                             WHEN 62
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Edwin Roberto' ELSE 'Maribel del Carmen' END
                                                             WHEN 63
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ronny Alexander' ELSE 'Lizbeth Carolina' END
                                                             WHEN 64
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yerson Fabricio' ELSE 'Mayte Alessandra' END
                                                             WHEN 65
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Pool Junior' ELSE 'Kiara Valentina' END
                                                             WHEN 66
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jerson Miguel' ELSE 'Naomi Scarlett' END
                                                             WHEN 67
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Deyvis Jesús' ELSE 'Luana Fernanda' END
                                                             WHEN 68
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yeferson Staly' ELSE 'Ashley Nicol' END
                                                             WHEN 69
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Cruz Ángel' ELSE 'Fabiola del Rosario' END
                                                             WHEN 70
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Wilson Omar' ELSE 'María Pía' END
                                                             WHEN 71
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Rony Alexander' ELSE 'María José' END
                                                             WHEN 72
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Joel David' ELSE 'María Fe' END
                                                             WHEN 73
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yober Alejandro' ELSE 'María Auxiliadora' END
                                                             WHEN 74
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Javier Eduardo' ELSE 'Rosa María' END
                                                             WHEN 75
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Harold Martín' ELSE 'Carmen Rosa' END
                                                             WHEN 76
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Eder Jesús' ELSE 'Luz Marina' END
                                                             WHEN 77
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Roy Jesús' ELSE 'Mercedes del Pilar' END
                                                             WHEN 78
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elvis Manuel' ELSE 'Esperanza Milagros' END
                                                             WHEN 79
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Segundo Manuel' ELSE 'Graciela del Carmen' END
                                                             WHEN 80
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Teófilo Antonio' ELSE 'Inés del Rosario' END
                                                             WHEN 81
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Fortunato Luis' ELSE 'Susana Elizabeth' END
                                                             WHEN 82
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aníbal César' ELSE 'Teresa de Jesús' END
                                                             WHEN 83
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Néstor Hugo' ELSE 'Julia Mercedes' END
                                                             WHEN 84
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Efraín Moisés' ELSE 'Lorena del Pilar' END
                                                             WHEN 85
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Darío Alberto' ELSE 'Yolanda Patricia' END
                                                             WHEN 86
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Rómulo Augusto' ELSE 'Zully Marisol' END
                                                             WHEN 87
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Claudio Enrique' ELSE 'Marleny del Carmen' END
                                                             WHEN 88
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lisandro David' ELSE 'Yudith Vanessa' END
                                                             WHEN 89
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yuri Alexander' ELSE 'Noelia Fernanda' END
                                                             WHEN 90
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Giancarlo Paolo' ELSE 'Ximena Alessandra' END
                                                             WHEN 91
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maicol Stiven' ELSE 'Brithany Nicol' END
                                                             WHEN 92
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jampier Jesús' ELSE 'Shalom Milagros' END
                                                             WHEN 93
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Keyser Fabricio' ELSE 'Naara Valentina' END
                                                             WHEN 94
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Axel Jostin' ELSE 'Alisson Camila' END
                                                             WHEN 95
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Mathias André' ELSE 'Samantha Nicole' END
                                                             WHEN 96
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Samuel Isaac' ELSE 'Abigail Sofía' END
                                                             WHEN 97
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elías Josué' ELSE 'Regina Fátima' END
                                                             WHEN 98
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aaron Gabriel' ELSE 'Salomé Victoria' END
                                                             WHEN 99
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Leónidas David' ELSE 'Danna Isabella' END
                                                             WHEN 100
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Alexander Jesús' ELSE 'María Alejandra' END
                                                             WHEN 101
                                                                 THEN CASE @Genero WHEN 'M' THEN 'José Antonio' ELSE 'Rosa Angélica' END
                                                             WHEN 102
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luis Alberto' ELSE 'Carmen Luz' END
                                                             WHEN 103
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Pedro Pablo' ELSE 'Ana María' END
                                                             WHEN 104
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Carlos Alberto' ELSE 'María Luisa' END
                                                             WHEN 105
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Miguel Ángel' ELSE 'Elizabeth del Pilar' END
                                                             WHEN 106
                                                                 THEN CASE @Genero WHEN 'M' THEN 'David Ricardo' ELSE 'Patricia del Carmen' END
                                                             WHEN 107
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jesús María' ELSE 'Gloria Esther' END
                                                             WHEN 108
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Roberto Carlos' ELSE 'Susana Mercedes' END
                                                             WHEN 109
                                                                 THEN CASE @Genero WHEN 'M' THEN 'William Andrés' ELSE 'Julia Marisol' END
                                                             WHEN 110
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jhon Fredy' ELSE 'María Isabel' END
                                                             WHEN 111
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Fredy Alexander' ELSE 'Lucila del Rosario' END
                                                             WHEN 112
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Henry Junior' ELSE 'Yolanda Rosario' END
                                                             WHEN 113
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Víctor Raúl' ELSE 'Nancy Elizabeth' END
                                                             WHEN 114
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Manuel Antonio' ELSE 'Fanny del Pilar' END
                                                             WHEN 115
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Oscar Eduardo' ELSE 'Miriam Alejandra' END
                                                             WHEN 116
                                                                 THEN CASE @Genero WHEN 'M' THEN 'César Martín' ELSE 'Liliana Patricia' END
                                                             WHEN 117
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jorge Luis' ELSE 'Verónica del Carmen' END
                                                             WHEN 118
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Edgardo Martín' ELSE 'Claudia Marisol' END
                                                             WHEN 119
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ronaldo Jesús' ELSE 'María Antonieta' END
                                                             WHEN 120
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yonatan David' ELSE 'Fiorella Maribel' END
                                                             WHEN 121
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Emanuel Jesús' ELSE 'Brigitte Milagros' END
                                                             WHEN 122
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Brayan Smith' ELSE 'Jhoselyn Natali' END
                                                             WHEN 123
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Stalin Mauricio' ELSE 'María Fernanda' END
                                                             WHEN 124
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Julián Andrés' ELSE 'Valeria Sofía' END
                                                             WHEN 125
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Santiago José' ELSE 'Camila Isabella' END
                                                             WHEN 126
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Matías Alejandro' ELSE 'Renata Victoria' END
                                                             WHEN 127
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Sebastián Mateo' ELSE 'Valentina Renata' END
                                                             WHEN 128
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Nicolás Gabriel' ELSE 'Sofía Catalina' END
                                                             WHEN 129 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Gabriel Alejandro'
                                                                               ELSE 'Isabella Valentina' END
                                                             WHEN 130
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Alejandro David' ELSE 'Martina Lucía' END
                                                             WHEN 131
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Diego Fernando' ELSE 'Florencia Milagros' END
                                                             WHEN 132
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Felipe Ignacio' ELSE 'Luciana Paz' END
                                                             WHEN 133
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Tomás Benjamín' ELSE 'Antonella Belén' END
                                                             WHEN 134
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Joaquín Andrés' ELSE 'Delfina Sofía' END
                                                             WHEN 135
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Agustín Mateo' ELSE 'Morena Valentina' END
                                                             WHEN 136
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lautaro Ezequiel' ELSE 'Abigail Renata' END
                                                             WHEN 137
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maximiliano Luis' ELSE 'Victoria Isabel' END
                                                             WHEN 138
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Bruno Alexander' ELSE 'Emilia Catalina' END
                                                             WHEN 139
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Valentín José' ELSE 'Olivia Regina' END
                                                             WHEN 140
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Renzo Fabricio' ELSE 'Amelia Guadalupe' END
                                                             WHEN 141
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jean Paul' ELSE 'Zoe Victoria' END
                                                             WHEN 142
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Cristhian Paul' ELSE 'Luna Isabella' END
                                                             WHEN 143
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jampier Jesús' ELSE 'Mía Alessandra' END
                                                             WHEN 144
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yeferson Luis' ELSE 'Aurora Celeste' END
                                                             WHEN 145
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Keyler Stiven' ELSE 'Salomé Victoria' END
                                                             WHEN 146
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Axel Mauricio' ELSE 'Danna Sofía' END
                                                             WHEN 147
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Mathias André' ELSE 'Regina Fátima' END
                                                             WHEN 148
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Samuel Isaac' ELSE 'Naomi Scarlett' END
                                                             WHEN 149
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elías Josué' ELSE 'Luana Fernanda' END
                                                             WHEN 150
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aaron Gabriel' ELSE 'Ashley Nicol' END
                                                             WHEN 151
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Leónidas David' ELSE 'Shalom Milagros' END
                                                             WHEN 152
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jhosep Andrés' ELSE 'Naara Valentina' END
                                                             WHEN 153
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Brayan Jesús' ELSE 'Alisson Camila' END
                                                             WHEN 154
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Stiven Alexander' ELSE 'Samantha Nicole' END
                                                             WHEN 155
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Junior Alexis' ELSE 'Abigail Sofía' END
                                                             WHEN 156 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Yampier Fabricio'
                                                                               ELSE 'Fabiola del Rosario' END
                                                             WHEN 157
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maicol Jesús' ELSE 'María Pía' END
                                                             WHEN 158
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jair Alejandro' ELSE 'María José' END
                                                             WHEN 159
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yair Stiven' ELSE 'María Fe' END
                                                             WHEN 160
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jostin Smith' ELSE 'María Auxiliadora' END
                                                             WHEN 161
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jean Marco' ELSE 'Rosa María' END
                                                             WHEN 162
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luis Fernando' ELSE 'Carmen Rosa' END
                                                             WHEN 163
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Carlos Miguel' ELSE 'Luz Marina' END
                                                             WHEN 164
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Pedro Antonio' ELSE 'Mercedes del Pilar' END
                                                             WHEN 165
                                                                 THEN CASE @Genero WHEN 'M' THEN 'José Miguel' ELSE 'Esperanza Milagros' END
                                                             WHEN 166
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Juan Diego' ELSE 'Graciela del Carmen' END
                                                             WHEN 167
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Raúl Alberto' ELSE 'Inés del Rosario' END
                                                             WHEN 168
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Víctor Hugo' ELSE 'Susana Elizabeth' END
                                                             WHEN 169
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Oscar Iván' ELSE 'Teresa de Jesús' END
                                                             WHEN 170
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Edison Paul' ELSE 'Julia Mercedes' END
                                                             WHEN 171
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Wilmer Jesús' ELSE 'Lorena del Pilar' END
                                                             WHEN 172
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yony Alexander' ELSE 'Yolanda Patricia' END
                                                             WHEN 173
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Roy Stiven' ELSE 'Zully Marisol' END
                                                             WHEN 174
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elvis Junior' ELSE 'Marleny del Carmen' END
                                                             WHEN 175
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Segundo Alberto' ELSE 'Yudith Vanessa' END
                                                             WHEN 176
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Teófilo Jesús' ELSE 'Noelia Fernanda' END
                                                             WHEN 177
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Fortunato David' ELSE 'Ximena Alessandra' END
                                                             WHEN 178
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aníbal Moisés' ELSE 'Brithany Nicol' END
                                                             WHEN 179
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Néstor Fabián' ELSE 'Kiara Valentina' END
                                                             WHEN 180
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Efraín Josué' ELSE 'Naomi Scarlett' END
                                                             WHEN 181
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Darío Isaac' ELSE 'Luana Fernanda' END
                                                             WHEN 182
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Rómulo César' ELSE 'Ashley Nicol' END
                                                             WHEN 183
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Claudio Martín' ELSE 'Fabiola del Rosario' END
                                                             WHEN 184
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lisandro José' ELSE 'María Pía' END
                                                             WHEN 185
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yuri Stiven' ELSE 'María José' END
                                                             WHEN 186
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Giancarlo Jesús' ELSE 'María Fe' END
                                                             WHEN 187
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maicol Fabricio' ELSE 'María Auxiliadora' END
                                                             WHEN 188
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jampier Luis' ELSE 'Rosa María' END
                                                             WHEN 189
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Keyser Alexander' ELSE 'Carmen Rosa' END
                                                             WHEN 190
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Axel Stiven' ELSE 'Luz Marina' END
                                                             WHEN 191
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Mathias Jesús' ELSE 'Mercedes del Pilar' END
                                                             WHEN 192
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Samuel David' ELSE 'Esperanza Milagros' END
                                                             WHEN 193
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elías Fabricio' ELSE 'Graciela del Carmen' END
                                                             WHEN 194
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aaron Stiven' ELSE 'Inés del Rosario' END
                                                             WHEN 195
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Leónidas Jesús' ELSE 'Susana Elizabeth' END
                                                             WHEN 196
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jhosep Fabricio' ELSE 'Teresa de Jesús' END
                                                             WHEN 197
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Brayan Mauricio' ELSE 'Julia Mercedes' END
                                                             WHEN 198
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Stiven Jesús' ELSE 'Lorena del Pilar' END
                                                             WHEN 199
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Junior Stiven' ELSE 'Yolanda Patricia' END
                                                             WHEN 200
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yampier Alexander' ELSE 'Zully Marisol' END
                                                             WHEN 201
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maicol Mauricio' ELSE 'Marleny del Carmen' END
                                                             WHEN 202
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jair Jesús' ELSE 'Yudith Vanessa' END
                                                             WHEN 203
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yair Fabricio' ELSE 'Noelia Fernanda' END
                                                             WHEN 204
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jostin Alexander' ELSE 'Ximena Alessandra' END
                                                             WHEN 205
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jean Carlos' ELSE 'Brithany Nicol' END
                                                             WHEN 206
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luis Miguel' ELSE 'Kiara Valentina' END
                                                             WHEN 207
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Carlos Eduardo' ELSE 'Naomi Scarlett' END
                                                             WHEN 208
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Pedro José' ELSE 'Luana Fernanda' END
                                                             WHEN 209
                                                                 THEN CASE @Genero WHEN 'M' THEN 'José David' ELSE 'Ashley Nicol' END
                                                             WHEN 210
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Juan Pablo' ELSE 'Shalom Milagros' END
                                                             WHEN 211
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Raúl Enrique' ELSE 'Naara Valentina' END
                                                             WHEN 212
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Víctor Daniel' ELSE 'Alisson Camila' END
                                                             WHEN 213
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Oscar Mauricio' ELSE 'Samantha Nicole' END
                                                             WHEN 214
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Edison Fabricio' ELSE 'Abigail Sofía' END
                                                             WHEN 215
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Wilmer Alexander' ELSE 'Regina Fátima' END
                                                             WHEN 216
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yony Jesús' ELSE 'Salomé Victoria' END
                                                             WHEN 217
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Roy Mauricio' ELSE 'Danna Isabella' END
                                                             WHEN 218
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elvis Alexander' ELSE 'Valeria Paz' END
                                                             WHEN 219
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Segundo Jesús' ELSE 'Martina Belén' END
                                                             WHEN 220
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Teófilo Fabricio' ELSE 'Isabella Renata' END
                                                             WHEN 221
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Fortunato Alexander' ELSE 'Catalina Sofía' END
                                                             WHEN 222
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aníbal Jesús' ELSE 'Antonella Victoria' END
                                                             WHEN 223
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Néstor Mauricio' ELSE 'Florencia Camila' END
                                                             WHEN 224
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Efraín Alexander' ELSE 'Luciana Abigail' END
                                                             WHEN 225
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Darío Jesús' ELSE 'Delfina Milagros' END
                                                             WHEN 226
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Rómulo Fabricio' ELSE 'Morena Elizabeth' END
                                                             WHEN 227
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Claudio Alexander' ELSE 'Yomira del Pilar' END
                                                             WHEN 228
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lisandro Jesús' ELSE 'Yadira Marisol' END
                                                             WHEN 229
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yuri Mauricio' ELSE 'Maribel del Carmen' END
                                                             WHEN 230
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Giancarlo Fabricio' ELSE 'Lizbeth Carolina' END
                                                             WHEN 231
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maicol Alexander' ELSE 'Mayte Alessandra' END
                                                             WHEN 232
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jampier Mauricio' ELSE 'Kiara Valentina' END
                                                             WHEN 233
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Keyser Jesús' ELSE 'Naomi Scarlett' END
                                                             WHEN 234
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Axel Fabricio' ELSE 'Luana Fernanda' END
                                                             WHEN 235
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Mathias Alexander' ELSE 'Ashley Nicol' END
                                                             WHEN 236
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Samuel Jesús' ELSE 'Fabiola del Rosario' END
                                                             WHEN 237
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Elías Mauricio' ELSE 'María Pía' END
                                                             WHEN 238
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Aaron Fabricio' ELSE 'María José' END
                                                             WHEN 239
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Leónidas Alexander' ELSE 'María Fe' END
                                                             WHEN 240
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jhosep Jesús' ELSE 'María Auxiliadora' END
                                                             WHEN 241
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Brayan Fabricio' ELSE 'Rosa María' END
                                                             WHEN 242
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Stiven Mauricio' ELSE 'Carmen Rosa' END
                                                             WHEN 243
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Junior Jesús' ELSE 'Luz Marina' END
                                                             WHEN 244
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yampier Jesús' ELSE 'Mercedes del Pilar' END
                                                             WHEN 245
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Maicol Stiven' ELSE 'Esperanza Milagros' END
                                                             WHEN 246
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jair Fabricio' ELSE 'Graciela del Carmen' END
                                                             WHEN 247
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yair Mauricio' ELSE 'Inés del Rosario' END
                                                             WHEN 248
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jostin Jesús' ELSE 'Susana Elizabeth' END
                                                             WHEN 249
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Jean Pierre' ELSE 'Teresa de Jesús' END
                                                             WHEN 250
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Julia Mercedes' ELSE 'Lorena del Pilar' END
                                                             WHEN 251
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yolanda Patricia' ELSE 'Zully Marisol' END
                                                             WHEN 252
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Marleny del Carmen' ELSE 'Yudith Vanessa' END
                                                             WHEN 253
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Noelia Fernanda' ELSE 'Ximena Alessandra' END
                                                             WHEN 254
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Brithany Nicol' ELSE 'Kiara Valentina' END
                                                             WHEN 255
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Naomi Scarlett' ELSE 'Luana Fernanda' END
                                                             WHEN 256
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ashley Nicol' ELSE 'Shalom Milagros' END
                                                             WHEN 257
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Fabiola del Rosario' ELSE 'Naara Valentina' END
                                                             WHEN 258
                                                                 THEN CASE @Genero WHEN 'M' THEN 'María Pía' ELSE 'Alisson Camila' END
                                                             WHEN 259
                                                                 THEN CASE @Genero WHEN 'M' THEN 'María José' ELSE 'Samantha Nicole' END
                                                             WHEN 260
                                                                 THEN CASE @Genero WHEN 'M' THEN 'María Fe' ELSE 'Abigail Sofía' END
                                                             WHEN 261
                                                                 THEN CASE @Genero WHEN 'M' THEN 'María Auxiliadora' ELSE 'Regina Fátima' END
                                                             WHEN 262
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Rosa María' ELSE 'Salomé Victoria' END
                                                             WHEN 263
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Carmen Rosa' ELSE 'Danna Isabella' END
                                                             WHEN 264
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luz Marina' ELSE 'Valeria Paz' END
                                                             WHEN 265
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Mercedes del Pilar' ELSE 'Martina Belén' END
                                                             WHEN 266
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Esperanza Milagros' ELSE 'Isabella Renata' END
                                                             WHEN 267
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Graciela del Carmen' ELSE 'Catalina Sofía' END
                                                             WHEN 268
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Inés del Rosario' ELSE 'Antonella Victoria' END
                                                             WHEN 269
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Susana Elizabeth' ELSE 'Florencia Camila' END
                                                             WHEN 270
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Teresa de Jesús' ELSE 'Luciana Abigail' END
                                                             WHEN 271
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Julia Mercedes' ELSE 'Delfina Milagros' END
                                                             WHEN 272
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Lorena del Pilar' ELSE 'Morena Elizabeth' END
                                                             WHEN 273
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yolanda Patricia' ELSE 'Yomira del Pilar' END
                                                             WHEN 274
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Zully Marisol' ELSE 'Yadira Marisol' END
                                                             WHEN 275 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Marleny del Carmen'
                                                                               ELSE 'Maribel del Carmen' END
                                                             WHEN 276
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Yudith Vanessa' ELSE 'Lizbeth Carolina' END
                                                             WHEN 277
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Noelia Fernanda' ELSE 'Mayte Alessandra' END
                                                             WHEN 278 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Ximena Alessandra'
                                                                               ELSE 'Fiorella Geraldine' END
                                                             WHEN 279
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Brithany Nicol' ELSE 'Lesly Giuliana' END
                                                             WHEN 280 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Kiara Valentina'
                                                                               ELSE 'Maricarmen del Pilar' END
                                                             WHEN 281
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Naomi Scarlett' ELSE 'Katherine Melissa' END
                                                             WHEN 282
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luana Fernanda' ELSE 'Milagros del Rosario' END
                                                             WHEN 283
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Ashley Nicol' ELSE 'Fátima del Rocío' END
                                                             WHEN 284
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Shalom Milagros' ELSE 'Angie Geraldine' END
                                                             WHEN 285
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Naara Valentina' ELSE 'Brigitte Natali' END
                                                             WHEN 286
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Alisson Camila' ELSE 'Yessica Milenka' END
                                                             WHEN 287
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Samantha Nicole' ELSE 'María del Carmen' END
                                                             WHEN 288
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Abigail Sofía' ELSE 'Rosa Elena' END
                                                             WHEN 289
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Regina Fátima' ELSE 'Gloria Mercedes' END
                                                             WHEN 290 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Salomé Victoria'
                                                                               ELSE 'Patricia del Rosario' END
                                                             WHEN 291
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Danna Isabella' ELSE 'Esther Elizabeth' END
                                                             WHEN 292
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Valeria Paz' ELSE 'Clara Inés' END
                                                             WHEN 293
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Martina Belén' ELSE 'Silvia Roxana' END
                                                             WHEN 294
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Isabella Renata' ELSE 'Mónica Liliana' END
                                                             WHEN 295
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Catalina Sofía' ELSE 'Cynthia Vanessa' END
                                                             WHEN 296 THEN CASE @Genero
                                                                               WHEN 'M' THEN 'Antonella Victoria'
                                                                               ELSE 'Marisol Alejandra' END
                                                             WHEN 297
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Florencia Camila' ELSE 'Jimena Valeria' END
                                                             WHEN 298
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Luciana Abigail' ELSE 'Renata Sofía' END
                                                             WHEN 299
                                                                 THEN CASE @Genero WHEN 'M' THEN 'Delfina Milagros' ELSE 'Emma Valentina' END

                                                             ELSE CASE @Genero WHEN 'M' THEN 'Juan Diego' ELSE 'María Fernanda' END -- fallback por si @Semilla es muy grande
                            END;

                        -- Apellidos aleatorios

                        DECLARE @Apellidos NVARCHAR(100) = CASE ((@Semilla / 10) % 300)
                                                               WHEN 0 THEN 'Quispe Mamani'
                                                               WHEN 1 THEN 'Flores García'
                                                               WHEN 2 THEN 'Rojas López'
                                                               WHEN 3 THEN 'Huamán Pérez'
                                                               WHEN 4 THEN 'García Flores'
                                                               WHEN 5 THEN 'Vargas Sánchez'
                                                               WHEN 6 THEN 'Torres Ramírez'
                                                               WHEN 7 THEN 'Castro Díaz'
                                                               WHEN 8 THEN 'Pérez Gómez'
                                                               WHEN 9 THEN 'López Rodríguez'
                                                               WHEN 10 THEN 'Martínez Silva'
                                                               WHEN 11 THEN 'González Chávez'
                                                               WHEN 12 THEN 'Ramírez Ortiz'
                                                               WHEN 13 THEN 'Sánchez Mendoza'
                                                               WHEN 14 THEN 'Morales Ruiz'
                                                               WHEN 15 THEN 'Jiménez Herrera'
                                                               WHEN 16 THEN 'Reyes Navarro'
                                                               WHEN 17 THEN 'Cruz Aguilar'
                                                               WHEN 18 THEN 'Medina Romero'
                                                               WHEN 19 THEN 'Guerrero Castro'
                                                               WHEN 20 THEN 'Ortiz Vargas'
                                                               WHEN 21 THEN 'Núñez Ramos'
                                                               WHEN 22 THEN 'Ríos Salazar'
                                                               WHEN 23 THEN 'Vega Castillo'
                                                               WHEN 24 THEN 'Molina Soto'
                                                               WHEN 25 THEN 'Cabrera Delgado'
                                                               WHEN 26 THEN 'Ortega Campos'
                                                               WHEN 27 THEN 'Soto Fuentes'
                                                               WHEN 28 THEN 'Silva Contreras'
                                                               WHEN 29 THEN 'Luna Benítez'
                                                               WHEN 30 THEN 'Juárez Velásquez'
                                                               WHEN 31 THEN 'Cerna Palacios'
                                                               WHEN 32 THEN 'Chávez Huamani'
                                                               WHEN 33 THEN 'Apaza Quispe'
                                                               WHEN 34 THEN 'Condori Chura'
                                                               WHEN 35 THEN 'Mamani Flores'
                                                               WHEN 36 THEN 'Flores Condori'
                                                               WHEN 37 THEN 'Pari Huanca'
                                                               WHEN 38 THEN 'Hancco Hancco'
                                                               WHEN 39 THEN 'Ccama Ccama'
                                                               WHEN 40 THEN 'Huanca Huanca'
                                                               WHEN 41 THEN 'Choque Choque'
                                                               WHEN 42 THEN 'Ticona Ticona'
                                                               WHEN 43 THEN 'Cayo Cayo'
                                                               WHEN 44 THEN 'Yucra Yucra'
                                                               WHEN 45 THEN 'Calcina Calcina'
                                                               WHEN 46 THEN 'Lluta Lluta'
                                                               WHEN 47 THEN 'Pacompia Pacompia'
                                                               WHEN 48 THEN 'Callo Ccallocunto'
                                                               WHEN 49 THEN 'Ccallocunto Ccallocunto'
                                                               WHEN 50 THEN 'Fernández Díaz'
                                                               WHEN 51 THEN 'Gómez Ruiz'
                                                               WHEN 52 THEN 'Díaz Morales'
                                                               WHEN 53 THEN 'Ruiz Jiménez'
                                                               WHEN 54 THEN 'Herrera Reyes'
                                                               WHEN 55 THEN 'Navarro Cruz'
                                                               WHEN 56 THEN 'Aguilar Medina'
                                                               WHEN 57 THEN 'Romero Guerrero'
                                                               WHEN 58 THEN 'Castillo Ortiz'
                                                               WHEN 59 THEN 'Ramos Núñez'
                                                               WHEN 60 THEN 'Salazar Ríos'
                                                               WHEN 61 THEN 'Vega Molina'
                                                               WHEN 62 THEN 'Soto Cabrera'
                                                               WHEN 63 THEN 'Delgado Ortega'
                                                               WHEN 64 THEN 'Campos Fuentes'
                                                               WHEN 65 THEN 'Contreras Silva'
                                                               WHEN 66 THEN 'Benítez Luna'
                                                               WHEN 67 THEN 'Velásquez Juárez'
                                                               WHEN 68 THEN 'Palacios Cerna'
                                                               WHEN 69 THEN 'Huamani Chávez'
                                                               WHEN 70 THEN 'Chura Condori'
                                                               WHEN 71 THEN 'Flores Mamani'
                                                               WHEN 72 THEN 'Huanca Pari'
                                                               WHEN 73 THEN 'Hancco Lima'
                                                               WHEN 74 THEN 'Ccama Flores'
                                                               WHEN 75 THEN 'Huanca Ccama'
                                                               WHEN 76 THEN 'Choque Condori'
                                                               WHEN 77 THEN 'Ticona Flores'
                                                               WHEN 78 THEN 'Cayo Huanca'
                                                               WHEN 79 THEN 'Yucra Mamani'
                                                               WHEN 80 THEN 'Calcina Quispe'
                                                               WHEN 81 THEN 'Lluta Flores'
                                                               WHEN 82 THEN 'Pacompia Huamán'
                                                               WHEN 83 THEN 'Ccallo Quispe'
                                                               WHEN 84 THEN 'Ccallocunto Mamani'
                                                               WHEN 85 THEN 'Poma Flores'
                                                               WHEN 86 THEN 'Turpo Quispe'
                                                               WHEN 87 THEN 'Ccahuana Mamani'
                                                               WHEN 88 THEN 'Llalli Quispe'
                                                               WHEN 89 THEN 'Ccanccapa Flores'
                                                               WHEN 90 THEN 'Chanca Mamani'
                                                               WHEN 91 THEN 'Huaraca Quispe'
                                                               WHEN 92 THEN 'Ccoyllo Flores'
                                                               WHEN 93 THEN 'Nina Quispe'
                                                               WHEN 94 THEN 'Taipe Mamani'
                                                               WHEN 95 THEN 'Yanqui Flores'
                                                               WHEN 96 THEN 'Curo Quispe'
                                                               WHEN 97 THEN 'Ccama Huamán'
                                                               WHEN 98 THEN 'Flores Taipe'
                                                               WHEN 99 THEN 'Quispe Ccama'
                                                               WHEN 100 THEN 'Rodríguez Mendoza'
                                                               WHEN 101 THEN 'Alva Castro'
                                                               WHEN 102 THEN 'Bravo Huamán'
                                                               WHEN 103 THEN 'Cueva Flores'
                                                               WHEN 104 THEN 'Díaz Quispe'
                                                               WHEN 105 THEN 'Escobar Rojas'
                                                               WHEN 106 THEN 'Fernández Mamani'
                                                               WHEN 107 THEN 'Gómez Vargas'
                                                               WHEN 108 THEN 'Herrera Torres'
                                                               WHEN 109 THEN 'Inga Huamán'
                                                               WHEN 110 THEN 'Jara Condori'
                                                               WHEN 111 THEN 'Lazo Quispe'
                                                               WHEN 112 THEN 'Mendoza Flores'
                                                               WHEN 113 THEN 'Nolasco García'
                                                               WHEN 114 THEN 'Ochoa López'
                                                               WHEN 115 THEN 'Pacheco Rojas'
                                                               WHEN 116 THEN 'Ramírez Quispe'
                                                               WHEN 117 THEN 'Sánchez Mamani'
                                                               WHEN 118 THEN 'Tello Vargas'
                                                               WHEN 119 THEN 'Ugarte Torres'
                                                               WHEN 120 THEN 'Vega Castro'
                                                               WHEN 121 THEN 'Vilca Flores'
                                                               WHEN 122 THEN 'Yucra Condori'
                                                               WHEN 123 THEN 'Zegarra Huamán'
                                                               WHEN 124 THEN 'Abarca Quispe'
                                                               WHEN 125 THEN 'Becerra Mamani'
                                                               WHEN 126 THEN 'Cárdenas Rojas'
                                                               WHEN 127 THEN 'Domínguez Vargas'
                                                               WHEN 128 THEN 'Espinoza Torres'
                                                               WHEN 129 THEN 'Fuentes Castro'
                                                               WHEN 130 THEN 'Gálvez Flores'
                                                               WHEN 131 THEN 'Huanca Condori'
                                                               WHEN 132 THEN 'Iglesias Quispe'
                                                               WHEN 133 THEN 'López Mamani'
                                                               WHEN 134 THEN 'Miranda Rojas'
                                                               WHEN 135 THEN 'Navarro Vargas'
                                                               WHEN 136 THEN 'Orozco Torres'
                                                               WHEN 137 THEN 'Paredes Castro'
                                                               WHEN 138 THEN 'Quiroz Flores'
                                                               WHEN 139 THEN 'Ramos Condori'
                                                               WHEN 140 THEN 'Salinas Quispe'
                                                               WHEN 141 THEN 'Tapia Mamani'
                                                               WHEN 142 THEN 'Urrutia Rojas'
                                                               WHEN 143 THEN 'Vásquez Vargas'
                                                               WHEN 144 THEN 'Zamora Torres'
                                                               WHEN 145 THEN 'Aguirre Castro'
                                                               WHEN 146 THEN 'Bernal Flores'
                                                               WHEN 147 THEN 'Cáceres Condori'
                                                               WHEN 148 THEN 'Delgado Quispe'
                                                               WHEN 149 THEN 'Escudero Mamani'
                                                               WHEN 150 THEN 'Farfán Rojas'
                                                               WHEN 151 THEN 'Guerrero Vargas'
                                                               WHEN 152 THEN 'Hurtado Torres'
                                                               WHEN 153 THEN 'Inga Castro'
                                                               WHEN 154 THEN 'Jurado Flores'
                                                               WHEN 155 THEN 'León Condori'
                                                               WHEN 156 THEN 'Mendoza Quispe'
                                                               WHEN 157 THEN 'Núñez Mamani'
                                                               WHEN 158 THEN 'Ocaña Rojas'
                                                               WHEN 159 THEN 'Pinto Vargas'
                                                               WHEN 160 THEN 'Rivas Torres'
                                                               WHEN 161 THEN 'Soto Castro'
                                                               WHEN 162 THEN 'Tito Flores'
                                                               WHEN 163 THEN 'Uscata Condori'
                                                               WHEN 164 THEN 'Valenzuela Quispe'
                                                               WHEN 165 THEN 'Yauri Mamani'
                                                               WHEN 166 THEN 'Zárate Rojas'
                                                               WHEN 167 THEN 'Acosta Vargas'
                                                               WHEN 168 THEN 'Barrios Torres'
                                                               WHEN 169 THEN 'Ccorahua Castro'
                                                               WHEN 170 THEN 'Chanca Flores'
                                                               WHEN 171 THEN 'Huaraca Condori'
                                                               WHEN 172 THEN 'Llacta Quispe'
                                                               WHEN 173 THEN 'Merma Mamani'
                                                               WHEN 174 THEN 'Nina Rojas'
                                                               WHEN 175 THEN 'Ochoa Vargas'
                                                               WHEN 176 THEN 'Pari Torres'
                                                               WHEN 177 THEN 'Quispe Castro'
                                                               WHEN 178 THEN 'Ramos Flores'
                                                               WHEN 179 THEN 'Sullca Condori'
                                                               WHEN 180 THEN 'Taipe Quispe'
                                                               WHEN 181 THEN 'Usca Mamani'
                                                               WHEN 182 THEN 'Vilca Rojas'
                                                               WHEN 183 THEN 'Yanqui Vargas'
                                                               WHEN 184 THEN 'Zevallos Torres'
                                                               WHEN 185 THEN 'Ayme Castro'
                                                               WHEN 186 THEN 'Ccanccapa Flores'
                                                               WHEN 187 THEN 'Ccoyllo Condori'
                                                               WHEN 188 THEN 'Chura Quispe'
                                                               WHEN 189 THEN 'Flores Mamani'
                                                               WHEN 190 THEN 'Hancco Rojas'
                                                               WHEN 191 THEN 'Huamán Vargas'
                                                               WHEN 192 THEN 'Llalli Torres'
                                                               WHEN 193 THEN 'Mamani Castro'
                                                               WHEN 194 THEN 'Nina Flores'
                                                               WHEN 195 THEN 'Poma Condori'
                                                               WHEN 196 THEN 'Quispe Quispe'
                                                               WHEN 197 THEN 'Ramos Mamani'
                                                               WHEN 198 THEN 'Taipe Rojas'
                                                               WHEN 199 THEN 'Yucra Vargas'
                                                               WHEN 200 THEN 'Turpo Torres'
                                                               WHEN 201 THEN 'Ccahuana Castro'
                                                               WHEN 202 THEN 'Ccama Flores'
                                                               WHEN 203 THEN 'Choque Condori'
                                                               WHEN 204 THEN 'Curo Quispe'
                                                               WHEN 205 THEN 'Hancco Mamani'
                                                               WHEN 206 THEN 'Huanca Rojas'
                                                               WHEN 207 THEN 'Lluta Vargas'
                                                               WHEN 208 THEN 'Pacompia Torres'
                                                               WHEN 209 THEN 'Pari Castro'
                                                               WHEN 210 THEN 'Ticona Flores'
                                                               WHEN 211 THEN 'Yucra Condori'
                                                               WHEN 212 THEN 'Calcina Quispe'
                                                               WHEN 213 THEN 'Callo Mamani'
                                                               WHEN 214 THEN 'Ccallocunto Rojas'
                                                               WHEN 215 THEN 'Ccanccapa Vargas'
                                                               WHEN 216 THEN 'Ccoyllo Torres'
                                                               WHEN 217 THEN 'Chanca Castro'
                                                               WHEN 218 THEN 'Huaraca Flores'
                                                               WHEN 219 THEN 'Llacta Condori'
                                                               WHEN 220 THEN 'Merma Quispe'
                                                               WHEN 221 THEN 'Nina Mamani'
                                                               WHEN 222 THEN 'Ochoa Rojas'
                                                               WHEN 223 THEN 'Poma Vargas'
                                                               WHEN 224 THEN 'Quispe Torres'
                                                               WHEN 225 THEN 'Ramos Castro'
                                                               WHEN 226 THEN 'Sullca Flores'
                                                               WHEN 227 THEN 'Taipe Condori'
                                                               WHEN 228 THEN 'Usca Quispe'
                                                               WHEN 229 THEN 'Vilca Mamani'
                                                               WHEN 230 THEN 'Yanqui Rojas'
                                                               WHEN 231 THEN 'Zevallos Vargas'
                                                               WHEN 232 THEN 'Ayme Torres'
                                                               WHEN 233 THEN 'Ccorahua Castro'
                                                               WHEN 234 THEN 'Chura Flores'
                                                               WHEN 235 THEN 'Flores Condori'
                                                               WHEN 236 THEN 'Hancco Quispe'
                                                               WHEN 237 THEN 'Huamán Mamani'
                                                               WHEN 238 THEN 'Llalli Rojas'
                                                               WHEN 239 THEN 'Mamani Vargas'
                                                               WHEN 240 THEN 'Nina Torres'
                                                               WHEN 241 THEN 'Poma Castro'
                                                               WHEN 242 THEN 'Quispe Flores'
                                                               WHEN 243 THEN 'Ramos Condori'
                                                               WHEN 244 THEN 'Taipe Quispe'
                                                               WHEN 245 THEN 'Yucra Mamani'
                                                               WHEN 246 THEN 'Turpo Rojas'
                                                               WHEN 247 THEN 'Ccahuana Vargas'
                                                               WHEN 248 THEN 'Ccama Torres'
                                                               WHEN 249 THEN 'Choque Castro'
                                                               WHEN 250 THEN 'Curo Flores'
                                                               WHEN 251 THEN 'Hancco Condori'
                                                               WHEN 252 THEN 'Huanca Quispe'
                                                               WHEN 253 THEN 'Lluta Mamani'
                                                               WHEN 254 THEN 'Pacompia Rojas'
                                                               WHEN 255 THEN 'Pari Vargas'
                                                               WHEN 256 THEN 'Ticona Torres'
                                                               WHEN 257 THEN 'Yucra Castro'
                                                               WHEN 258 THEN 'Calcina Flores'
                                                               WHEN 259 THEN 'Callo Condori'
                                                               WHEN 260 THEN 'Ccallocunto Quispe'
                                                               WHEN 261 THEN 'Ccanccapa Mamani'
                                                               WHEN 262 THEN 'Ccoyllo Rojas'
                                                               WHEN 263 THEN 'Chanca Vargas'
                                                               WHEN 264 THEN 'Huaraca Torres'
                                                               WHEN 265 THEN 'Llacta Castro'
                                                               WHEN 266 THEN 'Merma Flores'
                                                               WHEN 267 THEN 'Nina Condori'
                                                               WHEN 268 THEN 'Ochoa Quispe'
                                                               WHEN 269 THEN 'Poma Mamani'
                                                               WHEN 270 THEN 'Quispe Rojas'
                                                               WHEN 271 THEN 'Ramos Vargas'
                                                               WHEN 272 THEN 'Sullca Torres'
                                                               WHEN 273 THEN 'Taipe Castro'
                                                               WHEN 274 THEN 'Usca Flores'
                                                               WHEN 275 THEN 'Vilca Condori'
                                                               WHEN 276 THEN 'Yanqui Quispe'
                                                               WHEN 277 THEN 'Zevallos Mamani'
                                                               WHEN 278 THEN 'Ayme Rojas'
                                                               WHEN 279 THEN 'Ccorahua Vargas'
                                                               WHEN 280 THEN 'Chura Torres'
                                                               WHEN 281 THEN 'Flores Castro'
                                                               WHEN 282 THEN 'Hancco Quispe'
                                                               WHEN 283 THEN 'Huamán Mamani'
                                                               WHEN 284 THEN 'Llalli Flores'
                                                               WHEN 285 THEN 'Mamani Condori'
                                                               WHEN 286 THEN 'Nina Quispe'
                                                               WHEN 287 THEN 'Poma Mamani'
                                                               WHEN 288 THEN 'Quispe Vargas'
                                                               WHEN 289 THEN 'Ramos Torres'
                                                               WHEN 290 THEN 'Sullca Castro'
                                                               WHEN 291 THEN 'Taipe Flores'
                                                               WHEN 292 THEN 'Usca Condori'
                                                               WHEN 293 THEN 'Vilca Quispe'
                                                               WHEN 294 THEN 'Yanqui Mamani'
                                                               WHEN 295 THEN 'Zevallos Rojas'
                                                               WHEN 296 THEN 'Ayme Vargas'
                                                               WHEN 297 THEN 'Ccorahua Torres'
                                                               WHEN 298 THEN 'Chura Castro'
                                                               WHEN 299 THEN 'Flores Quispe'
                                                               ELSE 'Rodríguez Mendoza' -- fallback por si acaso
                            END;

                        -- Insertar colaborador
                        EXEC S_INS_UPD_PERSONA_PROGRAMA
                             NULL, -- Nuevo registro
                             @Nombres,
                             @Apellidos,
                             'DNI',
                             @DNI, -- DNI único aleatorio
                             NULL, -- Telefono
                             NULL, -- Correo
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

SELECT PE.Nombre              AS Programa,
       COUNT(DISTINCT PP.Id)  AS TotalColaboradores,
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

SELECT PE.Nombre    AS Programa,
       PO.Nombre    AS Perfil,
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
