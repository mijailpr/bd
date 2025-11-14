-- =============================================
-- SCRIPT: insert-certificados.sql
-- Descripción: Genera certificados EMO con variabilidad realista
--              usando 3 tipos de certificados:
--
--              TIPO 0 (10%): Sin certificado
--                - No se crea registro
--                - Colaborador sin proceso EMO iniciado
--
--              TIPO 1 (40%): Sin PDF - 4 sub-tipos
--                1A (10%): Datos completos + sin exámenes (0%)
--                1B (10%): Datos completos + exámenes parciales bajo (20-40%)
--                1C (10%): Datos completos + exámenes parciales medio (50-70%)
--                1D (10%): Datos completos + todos exámenes (100%), sin PDF
--
--              TIPO 2 (50%): Con PDF
--                - Datos completos OBLIGATORIO
--                - TODOS exámenes OBLIGATORIO
--                - RutaArchivoPDF: certificados/{personaprogramaid}/certificado.pdf
--                - Estados: Vigente (60%), Por vencer (20%), Vencido (20%)
--
--              * FechaCaducidad = FechaEvaluacion + 2 años (SIEMPRE)
--              * Puestos: UNO de dos (PuestoAlQuePostula O PuestoActual)
--
-- Autor: Sistema MediValle
-- Fecha: 2025-01-14
-- Actualización: 2025-01-14 - Lógica completa 3 tipos
-- =============================================

USE DB_MEDIVALLE
GO

PRINT '========================================';
PRINT 'INICIO: Generación de Certificados EMO';
PRINT '========================================';
PRINT '';

-- =============================================
-- VARIABLES GLOBALES
-- =============================================
DECLARE @TotalColaboradores INT = 0;
DECLARE @ContadorCertificados INT = 0;
DECLARE @CodigoSecuencial INT = 1;
DECLARE @AnioActual INT = YEAR(GETDATE());

-- Contadores para estadísticas
DECLARE @ContadorSinCertificado INT = 0;  -- Tipo 0: Sin certificado
DECLARE @ContadorDatosMinimos INT = 0;    -- Tipo 1A: Completo + 0% exámenes
DECLARE @ContadorSinExamenes INT = 0;     -- Tipo 1B: Completo + 20-40% exámenes
DECLARE @ContadorParcial INT = 0;         -- Tipo 1C: Completo + 50-70% exámenes
DECLARE @ContadorCompletoSinPDF INT = 0;  -- Tipo 1D: Completo + 100% exámenes, sin PDF
DECLARE @ContadorConPDF INT = 0;          -- Tipo 2: Con PDF
DECLARE @ContadorVigente INT = 0;         -- Tipo 2 vigente
DECLARE @ContadorPorVencer INT = 0;       -- Tipo 2 por vencer
DECLARE @ContadorVencido INT = 0;         -- Tipo 2 vencido

-- Obtener total de colaboradores
SELECT @TotalColaboradores = COUNT(*)
FROM T_PERSONA_PROGRAMA
WHERE Estado = '1';

PRINT 'Total de colaboradores encontrados: ' + CAST(@TotalColaboradores AS VARCHAR);
PRINT '';
PRINT 'Distribución objetivo:';
PRINT '  - 10% Sin certificado (Tipo 0)';
PRINT '  - 40% Certificados SIN PDF (Tipo 1: TODOS con datos completos)';
PRINT '    * 1A (10%): 0% exámenes';
PRINT '    * 1B (10%): 20-40% exámenes';
PRINT '    * 1C (10%): 50-70% exámenes';
PRINT '    * 1D (10%): 100% exámenes';
PRINT '  - 50% Certificados CON PDF (Tipo 2: validaciones completas)';
PRINT '    * Estados con PDF: Vigente (60%), Por vencer (20%), Vencido (20%)';
PRINT '';

-- =============================================
-- TABLA TEMPORAL: Doctores disponibles
-- =============================================
DECLARE @Doctores TABLE (
    DoctorId INT,
    RowNum INT
);

INSERT INTO @Doctores (DoctorId, RowNum)
SELECT Id, ROW_NUMBER() OVER (ORDER BY NEWID())
FROM T_DOCTOR
WHERE Estado = '1';

DECLARE @TotalDoctores INT = (SELECT COUNT(*) FROM @Doctores);

IF @TotalDoctores = 0
BEGIN
    PRINT 'ERROR: No hay doctores activos en el sistema';
    RETURN;
END

PRINT 'Doctores disponibles: ' + CAST(@TotalDoctores AS VARCHAR);
PRINT '';

-- =============================================
-- CURSOR: Recorrer todos los colaboradores
-- =============================================
DECLARE @PersonaProgramaId INT;
DECLARE @PersonaId INT;
DECLARE @Nombres NVARCHAR(100);
DECLARE @Apellidos NVARCHAR(100);
DECLARE @DNI NVARCHAR(20);
DECLARE @NombrePerfil NVARCHAR(200);
DECLARE @TipoEMO NVARCHAR(150);
DECLARE @PerfilTipoEMOId INT;

DECLARE CursorColaboradores CURSOR FOR
SELECT
    PP.Id AS PersonaProgramaId,
    P.Id AS PersonaId,
    P.Nombres,
    P.Apellidos,
    P.NDocumentoIdentidad,
    PO.Nombre AS NombrePerfil,
    PTE.TipoEMO,
    PTE.Id AS PerfilTipoEMOId
FROM T_PERSONA_PROGRAMA PP
INNER JOIN T_PERSONA P ON PP.PersonaId = P.Id
INNER JOIN T_PERFIL_TIPO_EMO PTE ON PP.PerfilTipoEMOId = PTE.Id
INNER JOIN T_PERFIL_OCUPACIONAL PO ON PTE.PerfilOcupacionalId = PO.Id
WHERE PP.Estado = '1'
ORDER BY PP.Id;

OPEN CursorColaboradores;
FETCH NEXT FROM CursorColaboradores INTO @PersonaProgramaId, @PersonaId, @Nombres, @Apellidos, @DNI, @NombrePerfil, @TipoEMO, @PerfilTipoEMOId;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- =============================================
    -- DETERMINAR TIPO DE CERTIFICADO ALEATORIAMENTE
    -- =============================================
    DECLARE @TipoCertificado INT;  -- 0=Sin cert, 1=Sin PDF, 2=Con PDF
    DECLARE @SubTipo1 INT = 0;     -- Para Tipo 1: 1A, 1B, 1C, 1D
    DECLARE @RandomTipo INT = ABS(CHECKSUM(NEWID())) % 100;

    IF @RandomTipo < 10
    BEGIN
        -- 10%: TIPO 0 - Sin certificado
        SET @TipoCertificado = 0;
        SET @ContadorSinCertificado = @ContadorSinCertificado + 1;

        -- Skip - Continuar al siguiente colaborador
        FETCH NEXT FROM CursorColaboradores INTO @PersonaProgramaId, @PersonaId, @Nombres, @Apellidos, @DNI, @NombrePerfil, @TipoEMO, @PerfilTipoEMOId;
        CONTINUE;
    END
    ELSE IF @RandomTipo < 50
    BEGIN
        -- 40%: TIPO 1 - Sin PDF (determinar sub-tipo)
        SET @TipoCertificado = 1;

        DECLARE @RandomSubTipo INT = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomSubTipo < 25
        BEGIN
            SET @SubTipo1 = 1;  -- 1A: Datos mínimos
            SET @ContadorDatosMinimos = @ContadorDatosMinimos + 1;
        END
        ELSE IF @RandomSubTipo < 50
        BEGIN
            SET @SubTipo1 = 2;  -- 1B: Completo sin exámenes
            SET @ContadorSinExamenes = @ContadorSinExamenes + 1;
        END
        ELSE IF @RandomSubTipo < 75
        BEGIN
            SET @SubTipo1 = 3;  -- 1C: Completo + parcial
            SET @ContadorParcial = @ContadorParcial + 1;
        END
        ELSE
        BEGIN
            SET @SubTipo1 = 4;  -- 1D: Completo + todos
            SET @ContadorCompletoSinPDF = @ContadorCompletoSinPDF + 1;
        END
    END
    ELSE
    BEGIN
        -- 50%: TIPO 2 - Con PDF
        SET @TipoCertificado = 2;
    END

    -- =============================================
    -- VARIABLES PARA ESTE COLABORADOR
    -- =============================================
    DECLARE @CodigoCertificado NVARCHAR(50);
    DECLARE @Password NVARCHAR(250);
    DECLARE @DoctorId INT;
    DECLARE @TipoEvaluacion NVARCHAR(100);
    DECLARE @TipoResultado NVARCHAR(100);
    DECLARE @Observaciones NVARCHAR(800);
    DECLARE @Conclusiones NVARCHAR(800);
    DECLARE @Restricciones NVARCHAR(800);
    DECLARE @PuestoAlQuePostula NVARCHAR(200);
    DECLARE @PuestoActual NVARCHAR(200);
    DECLARE @FechaEvaluacion DATETIME;
    DECLARE @FechaCaducidad DATETIME;
    DECLARE @DiasAtras INT;
    DECLARE @AniosVigencia INT;

    -- Generar código y password (SIEMPRE)
    SET @CodigoCertificado = 'EMO-' + CAST(@AnioActual AS VARCHAR) + '-' + RIGHT('000000' + CAST(@CodigoSecuencial AS VARCHAR), 6);
    SET @CodigoSecuencial = @CodigoSecuencial + 1;
    SET @Password = @DNI;

    -- Generar datos completos (SIEMPRE cuando se crea certificado)
    -- Seleccionar doctor aleatorio
    SELECT TOP 1 @DoctorId = DoctorId
    FROM @Doctores
    ORDER BY NEWID();

    -- Generar puestos (UNO de dos, NUNCA ambos)
    DECLARE @RandomPuesto INT = ABS(CHECKSUM(NEWID())) % 2;
    IF @RandomPuesto = 0
    BEGIN
        SET @PuestoAlQuePostula = @NombrePerfil;
        SET @PuestoActual = NULL;
    END
    ELSE
    BEGIN
        SET @PuestoAlQuePostula = NULL;
        SET @PuestoActual = @NombrePerfil;
    END

    -- Generar TipoEvaluacion
    DECLARE @RandomTipoEval INT = ABS(CHECKSUM(NEWID())) % 100;
    IF @RandomTipoEval < 40
        SET @TipoEvaluacion = 'examenPreocupacional';
    ELSE IF @RandomTipoEval < 85
        SET @TipoEvaluacion = 'examenOcupacionalAnual';
    ELSE IF @RandomTipoEval < 95
        SET @TipoEvaluacion = 'examenOcupacionalDeRetiro';
    ELSE
        SET @TipoEvaluacion = 'otros';

    -- =============================================
    -- DETERMINAR TIPO DE RESULTADO Y DATOS (SIEMPRE)
    -- =============================================
    DECLARE @RandomResultado INT = ABS(CHECKSUM(NEWID())) % 100;

    IF @RandomResultado < 80
    BEGIN
        -- 80%: apto
        SET @TipoResultado = 'apto';

        -- Observaciones (60% tiene, 40% NULL)
        DECLARE @RandomObs INT = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomObs < 60
        BEGIN
            DECLARE @RandomTextoObs INT = ABS(CHECKSUM(NEWID())) % 4;
            IF @RandomTextoObs = 0
                SET @Observaciones = 'Sin observaciones';
            ELSE IF @RandomTextoObs = 1
                SET @Observaciones = 'Evaluación satisfactoria';
            ELSE IF @RandomTextoObs = 2
                SET @Observaciones = 'Mantener hábitos saludables';
            ELSE
                SET @Observaciones = 'Requiere evaluación adicional';
        END
        ELSE
            SET @Observaciones = NULL;

        -- Restricciones (20% aleatorio, 80% NULL)
        DECLARE @RandomRestAleatorio INT = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomRestAleatorio < 20
            SET @Restricciones = 'Uso obligatorio de lentes correctivos';
        ELSE
            SET @Restricciones = NULL;

        -- Conclusiones (70% tiene, 30% NULL)
        DECLARE @RandomConcl INT = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomConcl < 70
            SET @Conclusiones = 'Apto para el puesto de ' + @NombrePerfil;
        ELSE
            SET @Conclusiones = NULL;
    END
    ELSE IF @RandomResultado < 95
    BEGIN
        -- 15%: aptoConRestricciones
        SET @TipoResultado = 'aptoConRestricciones';

        -- Restricciones OBLIGATORIO
        DECLARE @RandomRest INT = ABS(CHECKSUM(NEWID())) % 4;
        IF @RandomRest = 0
            SET @Restricciones = 'No cargar peso mayor a 20kg';
        ELSE IF @RandomRest = 1
            SET @Restricciones = 'No trabajar en alturas';
        ELSE IF @RandomRest = 2
            SET @Restricciones = 'Uso obligatorio de lentes correctivos';
        ELSE
            SET @Restricciones = 'Evitar exposición prolongada a ruidos fuertes';

        -- Observaciones (60%)
        SET @RandomObs = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomObs < 60
            SET @Observaciones = 'Presenta restricciones para ciertas actividades';
        ELSE
            SET @Observaciones = NULL;

        -- Conclusiones (70%)
        SET @RandomConcl = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomConcl < 70
            SET @Conclusiones = 'Apto con restricciones para el puesto de ' + @NombrePerfil;
        ELSE
            SET @Conclusiones = NULL;
    END
    ELSE IF @RandomResultado < 99
    BEGIN
        -- 4%: noApto
        SET @TipoResultado = 'noApto';

        -- Restricciones OBLIGATORIO
        SET @Restricciones = 'No apto para el puesto evaluado';

        -- Observaciones (60%)
        SET @RandomObs = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomObs < 60
            SET @Observaciones = 'Requiere evaluación adicional';
        ELSE
            SET @Observaciones = NULL;

        -- Conclusiones (70%)
        SET @RandomConcl = ABS(CHECKSUM(NEWID())) % 100;
        IF @RandomConcl < 70
            SET @Conclusiones = 'No apto para el puesto de ' + @NombrePerfil;
        ELSE
            SET @Conclusiones = NULL;
    END
    ELSE
    BEGIN
        -- 1%: noAplica
        SET @TipoResultado = 'noAplica';
        SET @Restricciones = NULL;
        SET @Observaciones = NULL;
        SET @Conclusiones = NULL;
    END

    -- =============================================
    -- GENERAR FECHAS (SIEMPRE)
    -- =============================================
    -- La vigencia SIEMPRE es de 2 años
    SET @AniosVigencia = 2;

    IF @TipoCertificado = 2
    BEGIN
        -- TIPO 2 (Con PDF): Distribuir entre Vigente/Por vencer/Vencido
        DECLARE @RandomEstado INT = ABS(CHECKSUM(NEWID())) % 100;

        IF @RandomEstado < 20
        BEGIN
            -- 20%: VENCIDO
            SET @DiasAtras = 731 + (ABS(CHECKSUM(NEWID())) % 365);  -- 731-1095 días atrás
        END
        ELSE IF @RandomEstado < 40
        BEGIN
            -- 20%: POR VENCER (0-60 días restantes)
            SET @DiasAtras = 670 + (ABS(CHECKSUM(NEWID())) % 61);  -- 670-730 días atrás
        END
        ELSE
        BEGIN
            -- 60%: VIGENTE (>60 días restantes)
            SET @DiasAtras = ABS(CHECKSUM(NEWID())) % 670;  -- 0-669 días atrás
        END
    END
    ELSE
    BEGIN
        -- TIPO 1 (Sin PDF): Fechas recientes variadas
        SET @DiasAtras = ABS(CHECKSUM(NEWID())) % 365;  -- 0-365 días atrás
    END

    SET @FechaEvaluacion = DATEADD(DAY, -@DiasAtras, GETDATE());
    SET @FechaCaducidad = DATEADD(YEAR, @AniosVigencia, @FechaEvaluacion);

    -- =============================================
    -- ETAPA 1: INSERTAR DATOS BÁSICOS DEL CERTIFICADO
    -- =============================================
    EXEC S_INS_UPD_CERTIFICADO_EMO
        @p_Id = NULL,
        @p_PersonaProgramaId = @PersonaProgramaId,
        @p_DoctorId = @DoctorId,
        @p_Codigo = @CodigoCertificado,
        @p_Password = @Password,
        @p_PuestoAlQuePostula = @PuestoAlQuePostula,
        @p_PuestoActual = @PuestoActual,
        @p_TipoEvaluacion = @TipoEvaluacion,
        @p_TipoResultado = @TipoResultado,
        @p_Observaciones = @Observaciones,
        @p_Conclusiones = @Conclusiones,
        @p_Restricciones = @Restricciones,
        @p_FechaEvaluacion = @FechaEvaluacion,
        @p_FechaCaducidad = @FechaCaducidad;

    SET @ContadorCertificados = @ContadorCertificados + 1;

    -- =============================================
    -- ETAPA 2: MARCAR EXÁMENES SEGÚN TIPO/SUBTIPO
    -- =============================================
    DECLARE @ExamenesAMarcar INT = 0;

    -- Determinar cuántos exámenes marcar
    IF @SubTipo1 = 1
    BEGIN
        -- Tipo 1A: Sin exámenes (0%)
        SET @ExamenesAMarcar = 0;
    END
    ELSE IF @SubTipo1 = 2 OR @SubTipo1 = 3 OR @TipoCertificado = 2
    BEGIN
        -- Tipo 1B, 1C o Tipo 2: Necesitamos obtener los exámenes
        DECLARE @ExamenesRequeridos TABLE (
            ProtocoloEMOId INT,
            RowNum INT
        );

        INSERT INTO @ExamenesRequeridos (ProtocoloEMOId, RowNum)
        SELECT
            PRO.Id,
            ROW_NUMBER() OVER (ORDER BY PRO.Id)
        FROM T_PROTOCOLO_EMO PRO
        WHERE PRO.PerfilTipoEMOId = @PerfilTipoEMOId
          AND PRO.EsRequerido = 1
          AND PRO.Estado = '1';

        DECLARE @TotalExamenes INT = (SELECT COUNT(*) FROM @ExamenesRequeridos);

        IF @SubTipo1 = 2
        BEGIN
            -- Tipo 1B: Exámenes PARCIALES BAJO (20-40%)
            DECLARE @PorcentajeExamenes INT = 20 + (ABS(CHECKSUM(NEWID())) % 21);
            SET @ExamenesAMarcar = (@TotalExamenes * @PorcentajeExamenes) / 100;
            IF @ExamenesAMarcar = 0 SET @ExamenesAMarcar = 1;  -- Al menos 1
        END
        ELSE IF @SubTipo1 = 3
        BEGIN
            -- Tipo 1C: Exámenes PARCIALES MEDIO (50-70%)
            SET @PorcentajeExamenes = 50 + (ABS(CHECKSUM(NEWID())) % 21);
            SET @ExamenesAMarcar = (@TotalExamenes * @PorcentajeExamenes) / 100;
            IF @ExamenesAMarcar = 0 SET @ExamenesAMarcar = 1;  -- Al menos 1
        END
        ELSE
        BEGIN
            -- Tipo 2: TODOS los exámenes OBLIGATORIO
            SET @ExamenesAMarcar = @TotalExamenes;
        END

        -- Marcar exámenes
        DECLARE @ProtocoloEMOId INT;
        DECLARE @ExamenRowNum INT = 1;

        WHILE @ExamenRowNum <= @ExamenesAMarcar
        BEGIN
            SELECT @ProtocoloEMOId = ProtocoloEMOId
            FROM @ExamenesRequeridos
            WHERE RowNum = @ExamenRowNum;

            EXEC S_INS_UPD_RESULTADO_EXAMEN
                @p_PersonaProgramaId = @PersonaProgramaId,
                @p_ProtocoloEMOId = @ProtocoloEMOId,
                @p_Realizado = 1;

            SET @ExamenRowNum = @ExamenRowNum + 1;
        END

        DELETE FROM @ExamenesRequeridos;
    END
    ELSE IF @SubTipo1 = 4
    BEGIN
        -- Tipo 1D: TODOS los exámenes
        DECLARE @ExamenesRequeridos1D TABLE (
            ProtocoloEMOId INT,
            RowNum INT
        );

        INSERT INTO @ExamenesRequeridos1D (ProtocoloEMOId, RowNum)
        SELECT
            PRO.Id,
            ROW_NUMBER() OVER (ORDER BY PRO.Id)
        FROM T_PROTOCOLO_EMO PRO
        WHERE PRO.PerfilTipoEMOId = @PerfilTipoEMOId
          AND PRO.EsRequerido = 1
          AND PRO.Estado = '1';

        DECLARE @ProtocoloEMOId1D INT;
        DECLARE @ExamenRowNum1D INT = 1;
        DECLARE @TotalExamenes1D INT = (SELECT COUNT(*) FROM @ExamenesRequeridos1D);

        WHILE @ExamenRowNum1D <= @TotalExamenes1D
        BEGIN
            SELECT @ProtocoloEMOId1D = ProtocoloEMOId
            FROM @ExamenesRequeridos1D
            WHERE RowNum = @ExamenRowNum1D;

            EXEC S_INS_UPD_RESULTADO_EXAMEN
                @p_PersonaProgramaId = @PersonaProgramaId,
                @p_ProtocoloEMOId = @ProtocoloEMOId1D,
                @p_Realizado = 1;

            SET @ExamenRowNum1D = @ExamenRowNum1D + 1;
        END

        DELETE FROM @ExamenesRequeridos1D;
    END

    -- =============================================
    -- ETAPA 3: GENERAR PDF (Solo Tipo 2)
    -- =============================================
    IF @TipoCertificado = 2
    BEGIN
        -- =============================================
        -- VALIDACIONES OBLIGATORIAS ANTES DE GENERAR PDF
        -- =============================================
        DECLARE @PuedeGenerarPDF BIT = 1;
        DECLARE @MensajeValidacion NVARCHAR(500) = '';

        -- Validar que todos los datos del certificado están completos
        IF @DoctorId IS NULL OR @CodigoCertificado IS NULL OR
           @TipoResultado IS NULL OR @FechaEvaluacion IS NULL OR
           @FechaCaducidad IS NULL
        BEGIN
            SET @PuedeGenerarPDF = 0;
            SET @MensajeValidacion = 'Datos del certificado incompletos para PersonaProgramaId: ' + CAST(@PersonaProgramaId AS VARCHAR);
        END

        -- Validar que TODOS los exámenes requeridos están realizados
        DECLARE @ExamenesRequeridosTotal INT;
        DECLARE @ExamenesRealizadosTotal INT;

        SELECT @ExamenesRequeridosTotal = COUNT(*)
        FROM T_PROTOCOLO_EMO PRO
        WHERE PRO.PerfilTipoEMOId = @PerfilTipoEMOId
          AND PRO.EsRequerido = 1
          AND PRO.Estado = '1';

        SELECT @ExamenesRealizadosTotal = COUNT(*)
        FROM T_RESULTADO_EMO RE
        INNER JOIN T_PROTOCOLO_EMO PRO ON RE.ProtocoloEMOId = PRO.Id
        WHERE RE.PersonaProgramaId = @PersonaProgramaId
          AND RE.Realizado = 1
          AND RE.Estado = '1'
          AND PRO.EsRequerido = 1;

        IF @ExamenesRequeridosTotal > @ExamenesRealizadosTotal
        BEGIN
            SET @PuedeGenerarPDF = 0;
            SET @MensajeValidacion = 'Exámenes incompletos para PersonaProgramaId: ' + CAST(@PersonaProgramaId AS VARCHAR) +
                                    ' (Realizados: ' + CAST(@ExamenesRealizadosTotal AS VARCHAR) +
                                    '/' + CAST(@ExamenesRequeridosTotal AS VARCHAR) + ')';
        END

        -- Solo generar PDF si todas las validaciones pasan
        IF @PuedeGenerarPDF = 1
        BEGIN
            DECLARE @RutaPDF NVARCHAR(500);

            -- Usar formato: certificados/{personaprogramaid}/certificado.pdf
            SET @RutaPDF = 'certificados/' + CAST(@PersonaProgramaId AS VARCHAR) + '/certificado.pdf';

            -- Guardar PDF
            EXEC S_UPD_GUARDAR_PDF_CERTIFICADO
                @p_PersonaProgramaId = @PersonaProgramaId,
                @p_RutaArchivoPDF = @RutaPDF;

            -- Incrementar contador de con PDF
            SET @ContadorConPDF = @ContadorConPDF + 1;

            -- Determinar y contar estado (Vigente/Por vencer/Vencido)
            DECLARE @DiasParaCaducidad INT = DATEDIFF(DAY, GETDATE(), @FechaCaducidad);

            IF @DiasParaCaducidad < 0
                SET @ContadorVencido = @ContadorVencido + 1;  -- Ya venció
            ELSE IF @DiasParaCaducidad <= 60
                SET @ContadorPorVencer = @ContadorPorVencer + 1;  -- Faltan 0-60 días (0-2 meses)
            ELSE
                SET @ContadorVigente = @ContadorVigente + 1;  -- Más de 60 días restantes
        END
        ELSE
        BEGIN
            -- Mostrar mensaje de advertencia si no se puede generar PDF
            PRINT 'ADVERTENCIA: ' + @MensajeValidacion;
        END
    END

    -- Progreso cada 20 certificados
    IF @ContadorCertificados % 20 = 0
    BEGIN
        PRINT 'Progreso: ' + CAST(@ContadorCertificados AS VARCHAR) + ' de ' + CAST(@TotalColaboradores AS VARCHAR) + ' certificados creados...';
    END

    FETCH NEXT FROM CursorColaboradores INTO @PersonaProgramaId, @PersonaId, @Nombres, @Apellidos, @DNI, @NombrePerfil, @TipoEMO, @PerfilTipoEMOId;
END

CLOSE CursorColaboradores;
DEALLOCATE CursorColaboradores;

PRINT '';
PRINT '========================================';
PRINT 'RESUMEN FINAL';
PRINT '========================================';
PRINT 'Total de certificados creados: ' + CAST(@ContadorCertificados AS VARCHAR);
PRINT '';

-- =============================================
-- ESTADÍSTICAS FINALES
-- =============================================
PRINT '--- DISTRIBUCIÓN GENERAL ---';
PRINT 'Total colaboradores procesados: ' + CAST(@TotalColaboradores AS VARCHAR);
PRINT 'Sin certificado (Tipo 0): ' + CAST(@ContadorSinCertificado AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorSinCertificado * 100.0 / @TotalColaboradores AS DECIMAL(5,2)) AS VARCHAR) + '%)';
PRINT '';

PRINT '--- CERTIFICADOS SIN PDF (Tipo 1) ---';
DECLARE @TotalSinPDF INT = @ContadorDatosMinimos + @ContadorSinExamenes + @ContadorParcial + @ContadorCompletoSinPDF;
PRINT 'Total sin PDF: ' + CAST(@TotalSinPDF AS VARCHAR) + ' (' +
      CAST(CAST(@TotalSinPDF * 100.0 / @TotalColaboradores AS DECIMAL(5,2)) AS VARCHAR) + '%)';
PRINT '  - 1A (Completo + 0% exámenes): ' + CAST(@ContadorDatosMinimos AS VARCHAR);
PRINT '  - 1B (Completo + 20-40% exámenes): ' + CAST(@ContadorSinExamenes AS VARCHAR);
PRINT '  - 1C (Completo + 50-70% exámenes): ' + CAST(@ContadorParcial AS VARCHAR);
PRINT '  - 1D (Completo + 100% exámenes): ' + CAST(@ContadorCompletoSinPDF AS VARCHAR);
PRINT '';

PRINT '--- CERTIFICADOS CON PDF (Tipo 2) ---';
PRINT 'Total con PDF: ' + CAST(@ContadorConPDF AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorConPDF * 100.0 / @TotalColaboradores AS DECIMAL(5,2)) AS VARCHAR) + '%)';
IF @ContadorConPDF > 0
BEGIN
    PRINT '  - Vigente (>60 días): ' + CAST(@ContadorVigente AS VARCHAR) + ' (' +
          CAST(CAST(@ContadorVigente * 100.0 / @ContadorConPDF AS DECIMAL(5,2)) AS VARCHAR) + '%)';
    PRINT '  - Por vencer (0-60 días): ' + CAST(@ContadorPorVencer AS VARCHAR) + ' (' +
          CAST(CAST(@ContadorPorVencer * 100.0 / @ContadorConPDF AS DECIMAL(5,2)) AS VARCHAR) + '%)';
    PRINT '  - Vencido: ' + CAST(@ContadorVencido AS VARCHAR) + ' (' +
          CAST(CAST(@ContadorVencido * 100.0 / @ContadorConPDF AS DECIMAL(5,2)) AS VARCHAR) + '%)';
END
PRINT '';

PRINT '--- DISTRIBUCIÓN POR ESTADO DE CERTIFICADO ---';

SELECT
    CASE
        WHEN CERT.RutaArchivoPDF = '' THEN 'Sin PDF'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END AS EstadoCertificado,
    COUNT(*) AS Cantidad,
    CAST(COUNT(*) * 100.0 / @ContadorCertificados AS DECIMAL(5,2)) AS Porcentaje
FROM T_CERTIFICADO_EMO CERT
WHERE CERT.Estado = '1'
GROUP BY
    CASE
        WHEN CERT.RutaArchivoPDF = '' THEN 'Sin PDF'
        WHEN GETDATE() > CERT.FechaCaducidad THEN 'Vencido'
        WHEN DATEDIFF(DAY, GETDATE(), CERT.FechaCaducidad) < 60 THEN 'Por vencer'
        ELSE 'Vigente'
    END
ORDER BY Cantidad DESC;

PRINT '';
PRINT '--- DISTRIBUCIÓN POR TIPO DE RESULTADO ---';

SELECT
    TipoResultado,
    COUNT(*) AS Cantidad,
    CAST(COUNT(*) * 100.0 / @ContadorCertificados AS DECIMAL(5,2)) AS Porcentaje
FROM T_CERTIFICADO_EMO
WHERE Estado = '1'
GROUP BY TipoResultado
ORDER BY Cantidad DESC;

PRINT '';
PRINT '--- DISTRIBUCIÓN DE EXÁMENES REALIZADOS ---';

SELECT
    CASE
        WHEN ExamenesRealizados = 0 THEN 'Sin exámenes'
        WHEN ExamenesRealizados < ExamenesRequeridos THEN 'Parcial'
        ELSE 'Completo'
    END AS EstadoExamenes,
    COUNT(*) AS Cantidad,
    CAST(COUNT(*) * 100.0 / @ContadorCertificados AS DECIMAL(5,2)) AS Porcentaje
FROM (
    SELECT
        CERT.Id,
        (SELECT COUNT(*)
         FROM T_PROTOCOLO_EMO PRO
         WHERE PRO.PerfilTipoEMOId = PP.PerfilTipoEMOId
           AND PRO.EsRequerido = 1 AND PRO.Estado = '1') AS ExamenesRequeridos,
        (SELECT COUNT(*)
         FROM T_RESULTADO_EMO RE
         WHERE RE.PersonaProgramaId = PP.Id
           AND RE.Realizado = 1 AND RE.Estado = '1') AS ExamenesRealizados
    FROM T_CERTIFICADO_EMO CERT
    INNER JOIN T_PERSONA_PROGRAMA PP ON CERT.PersonaProgramaId = PP.Id
    WHERE CERT.Estado = '1'
) AS SubQuery
GROUP BY
    CASE
        WHEN ExamenesRealizados = 0 THEN 'Sin exámenes'
        WHEN ExamenesRealizados < ExamenesRequeridos THEN 'Parcial'
        ELSE 'Completo'
    END
ORDER BY Cantidad DESC;

PRINT '';
PRINT '========================================';
PRINT 'PROCESO COMPLETADO EXITOSAMENTE';
PRINT '========================================';

GO