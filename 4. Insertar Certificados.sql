-- =============================================
-- SCRIPT: insert-certificados.sql
-- Descripción: Genera certificados EMO para todos los colaboradores
--              con 3 etapas y variabilidad realista
-- Autor: Sistema MediValle
-- Fecha: 2025-01-14
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

-- Variables para control de variabilidad
DECLARE @TotalProcesados INT = 0;
DECLARE @Limite20Pct INT;  -- Solo Etapa 1
DECLARE @Limite35Pct INT;  -- Etapa 1 + exámenes parciales
DECLARE @Limite60Pct INT;  -- Etapa 1 + todos exámenes, SIN PDF
-- El resto (40%): Etapa 1 + Etapa 2 + Etapa 3 COMPLETO

-- Obtener total de colaboradores
SELECT @TotalColaboradores = COUNT(*)
FROM T_PERSONA_PROGRAMA
WHERE Estado = '1';

-- Calcular límites de variabilidad
SET @Limite20Pct = CAST(@TotalColaboradores * 0.20 AS INT);
SET @Limite35Pct = @Limite20Pct + CAST(@TotalColaboradores * 0.15 AS INT);
SET @Limite60Pct = @Limite35Pct + CAST(@TotalColaboradores * 0.25 AS INT);

PRINT 'Total de colaboradores encontrados: ' + CAST(@TotalColaboradores AS VARCHAR);
PRINT '';
PRINT 'Distribución de variabilidad:';
PRINT '  - Solo Etapa 1 (sin exámenes): ' + CAST(@Limite20Pct AS VARCHAR) + ' colaboradores (20%)';
PRINT '  - Etapa 1 + exámenes parciales: ' + CAST(@Limite35Pct - @Limite20Pct AS VARCHAR) + ' colaboradores (15%)';
PRINT '  - Etapa 1 + todos exámenes, SIN PDF: ' + CAST(@Limite60Pct - @Limite35Pct AS VARCHAR) + ' colaboradores (25%)';
PRINT '  - COMPLETO con PDF: ' + CAST(@TotalColaboradores - @Limite60Pct AS VARCHAR) + ' colaboradores (40%)';
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
    -- Incrementar contador de procesados
    SET @TotalProcesados = @TotalProcesados + 1;

    -- =============================================
    -- VARIABLES PARA ESTE COLABORADOR
    -- =============================================
    DECLARE @CodigoCertificado NVARCHAR(50);
    DECLARE @Password NVARCHAR(250);
    DECLARE @DoctorId INT;
    DECLARE @TipoResultado NVARCHAR(100);
    DECLARE @Observaciones NVARCHAR(800);
    DECLARE @Conclusiones NVARCHAR(800);
    DECLARE @Restricciones NVARCHAR(800);
    DECLARE @FechaEvaluacion DATETIME;
    DECLARE @FechaCaducidad DATETIME;
    DECLARE @DiasAtras INT;
    DECLARE @AniosVigencia INT;

    -- Generar código único
    SET @CodigoCertificado = 'EMO-' + CAST(@AnioActual AS VARCHAR) + '-' + RIGHT('000000' + CAST(@CodigoSecuencial AS VARCHAR), 6);
    SET @CodigoSecuencial = @CodigoSecuencial + 1;

    -- Password = DNI
    SET @Password = @DNI;

    -- Seleccionar doctor aleatorio
    SELECT TOP 1 @DoctorId = DoctorId
    FROM @Doctores
    ORDER BY NEWID();

    -- =============================================
    -- DETERMINAR TIPO DE RESULTADO Y DATOS
    -- =============================================
    DECLARE @RandomResultado INT = ABS(CHECKSUM(NEWID())) % 100;

    IF @RandomResultado < 80
    BEGIN
        -- 80%: APTO
        SET @TipoResultado = 'APTO';
        SET @Restricciones = NULL;

        -- Variedad en observaciones
        DECLARE @RandomObs INT = ABS(CHECKSUM(NEWID())) % 3;
        IF @RandomObs = 0
            SET @Observaciones = 'Sin observaciones';
        ELSE IF @RandomObs = 1
            SET @Observaciones = 'Evaluación satisfactoria';
        ELSE
            SET @Observaciones = 'Mantener hábitos saludables';

        SET @Conclusiones = 'Apto para el puesto de ' + @NombrePerfil;
    END
    ELSE IF @RandomResultado < 95
    BEGIN
        -- 15%: APTO CON RESTRICCIONES
        SET @TipoResultado = 'APTO CON RESTRICCIONES';

        -- Restricciones variables
        DECLARE @RandomRest INT = ABS(CHECKSUM(NEWID())) % 4;
        IF @RandomRest = 0
            SET @Restricciones = 'No cargar peso mayor a 20kg';
        ELSE IF @RandomRest = 1
            SET @Restricciones = 'No trabajar en alturas';
        ELSE IF @RandomRest = 2
            SET @Restricciones = 'Uso obligatorio de lentes correctivos';
        ELSE
            SET @Restricciones = 'Evitar exposición prolongada a ruidos fuertes';

        SET @Observaciones = 'Presenta restricciones para ciertas actividades';
        SET @Conclusiones = 'Apto con restricciones para el puesto de ' + @NombrePerfil;
    END
    ELSE
    BEGIN
        -- 5%: NO APTO
        SET @TipoResultado = 'NO APTO';
        SET @Restricciones = 'No apto para el puesto evaluado';
        SET @Observaciones = 'Requiere evaluación adicional';
        SET @Conclusiones = 'No apto para el puesto de ' + @NombrePerfil;
    END

    -- =============================================
    -- GENERAR FECHAS SEGÚN VARIABILIDAD
    -- =============================================
    -- Determinar si tendrá PDF (40% de los colaboradores)
    DECLARE @TendraPDF BIT = 0;
    IF @TotalProcesados > @Limite60Pct
        SET @TendraPDF = 1;

    IF @TendraPDF = 1
    BEGIN
        -- Para certificados con PDF: distribuir estados
        DECLARE @RandomEstado INT = ABS(CHECKSUM(NEWID())) % 100;

        IF @RandomEstado < 15
        BEGIN
            -- 15%: VENCIDO (fecha muy antigua)
            SET @DiasAtras = 700 + (ABS(CHECKSUM(NEWID())) % 200);  -- 700-900 días atrás
            SET @AniosVigencia = 2;  -- Vigencia de 2 años (ya vencido)
        END
        ELSE IF @RandomEstado < 40
        BEGIN
            -- 25%: POR VENCER (<60 días)
            SET @DiasAtras = 690 + (ABS(CHECKSUM(NEWID())) % 40);  -- 690-730 días atrás (cerca de 2 años)
            SET @AniosVigencia = 2;
        END
        ELSE
        BEGIN
            -- 60%: VIGENTE (mucho tiempo restante)
            SET @DiasAtras = ABS(CHECKSUM(NEWID())) % 180;  -- 0-6 meses atrás
            SET @AniosVigencia = 2 + (ABS(CHECKSUM(NEWID())) % 2);  -- 2 o 3 años
        END
    END
    ELSE
    BEGIN
        -- Para certificados sin PDF: fechas recientes
        SET @DiasAtras = ABS(CHECKSUM(NEWID())) % 90;  -- 0-3 meses atrás
        SET @AniosVigencia = 2 + (ABS(CHECKSUM(NEWID())) % 2);
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
        @p_PuestoAlQuePostula = @NombrePerfil,
        @p_PuestoActual = NULL,
        @p_TipoEvaluacion = @TipoEMO,
        @p_TipoResultado = @TipoResultado,
        @p_Observaciones = @Observaciones,
        @p_Conclusiones = @Conclusiones,
        @p_Restricciones = @Restricciones,
        @p_FechaEvaluacion = @FechaEvaluacion,
        @p_FechaCaducidad = @FechaCaducidad;

    SET @ContadorCertificados = @ContadorCertificados + 1;

    -- =============================================
    -- ETAPA 2: MARCAR EXÁMENES COMO REALIZADOS
    -- =============================================
    -- Solo si el colaborador NO está en el primer 20% (solo Etapa 1)
    IF @TotalProcesados > @Limite20Pct
    BEGIN
        -- Obtener exámenes requeridos para este perfil
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
        DECLARE @ExamenesAMarcar INT = 0;

        -- Determinar cuántos exámenes marcar según variabilidad
        IF @TotalProcesados <= @Limite35Pct
        BEGIN
            -- 15%: Exámenes PARCIALES (50%)
            SET @ExamenesAMarcar = @TotalExamenes / 2;
            IF @ExamenesAMarcar = 0 SET @ExamenesAMarcar = 1;  -- Al menos 1
        END
        ELSE
        BEGIN
            -- 25% + 40%: TODOS los exámenes
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

            -- Marcar examen como realizado
            EXEC S_INS_UPD_RESULTADO_EXAMEN
                @p_PersonaProgramaId = @PersonaProgramaId,
                @p_ProtocoloEMOId = @ProtocoloEMOId,
                @p_Realizado = 1;

            SET @ExamenRowNum = @ExamenRowNum + 1;
        END

        DELETE FROM @ExamenesRequeridos;
    END

    -- =============================================
    -- ETAPA 3: GENERAR PDF (Solo para el 40%)
    -- =============================================
    IF @TendraPDF = 1
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