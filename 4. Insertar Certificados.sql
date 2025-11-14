-- =============================================
-- SCRIPT: insert-certificados.sql
-- Descripción: Genera certificados EMO con variabilidad realista
--              usando 2 tipos de certificados:
--
--              TIPO 1 (Sin PDF):
--                - Datos completos del certificado
--                - Exámenes: parciales o todos (aleatorio)
--                - Sin RutaArchivoPDF
--
--              TIPO 2 (Con PDF):
--                - Datos completos del certificado
--                - Exámenes: TODOS completados (obligatorio)
--                - RutaArchivoPDF: certificados/{personaprogramaid}/certificado.pdf
--                - Estados por fechas: Vigente/Por vencer/Vencido
--
--              * Todos los certificados: FechaCaducidad = FechaEvaluacion + 2 años
--              * Vigente: >2 meses antes de caducidad
--              * Por vencer: 0-2 meses antes de caducidad
--              * Vencido: Fecha caducidad ya pasó
--
-- Autor: Sistema MediValle
-- Fecha: 2025-01-14
-- Actualización: 2025-01-14 - Simplificación a 2 tipos
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
DECLARE @ContadorSinPDF INT = 0;          -- Tipo 1: Sin PDF
DECLARE @ContadorConPDF INT = 0;          -- Tipo 2: Con PDF
DECLARE @ContadorExamenesParciales INT = 0;  -- Sin PDF con exámenes parciales
DECLARE @ContadorExamenesCompletos INT = 0;  -- Sin PDF con exámenes completos
DECLARE @ContadorVigente INT = 0;         -- Con PDF vigente
DECLARE @ContadorPorVencer INT = 0;       -- Con PDF por vencer
DECLARE @ContadorVencido INT = 0;         -- Con PDF vencido

-- Obtener total de colaboradores
SELECT @TotalColaboradores = COUNT(*)
FROM T_PERSONA_PROGRAMA
WHERE Estado = '1';

PRINT 'Total de colaboradores encontrados: ' + CAST(@TotalColaboradores AS VARCHAR);
PRINT '';
PRINT 'Distribución objetivo:';
PRINT '  - 50% Certificados SIN PDF (exámenes parciales o completos)';
PRINT '  - 50% Certificados CON PDF (todos exámenes + validaciones)';
PRINT '    * Estados: Vigente (>2 meses), Por vencer (0-2 meses), Vencido';
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
    DECLARE @TendraPDF BIT = 0;
    DECLARE @RandomTipo INT = ABS(CHECKSUM(NEWID())) % 100;

    IF @RandomTipo < 50
        SET @TendraPDF = 0;  -- 50%: Sin PDF
    ELSE
        SET @TendraPDF = 1;  -- 50%: Con PDF

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
    -- GENERAR FECHAS (SIEMPRE 2 AÑOS DE DIFERENCIA)
    -- =============================================
    -- La vigencia SIEMPRE es de 2 años
    SET @AniosVigencia = 2;

    IF @TendraPDF = 1
    BEGIN
        -- Con PDF: Distribuir entre Vigente/Por vencer/Vencido
        DECLARE @RandomEstado INT = ABS(CHECKSUM(NEWID())) % 100;

        IF @RandomEstado < 20
        BEGIN
            -- 20%: VENCIDO (fecha de evaluación hace más de 2 años)
            SET @DiasAtras = 730 + (ABS(CHECKSUM(NEWID())) % 180);  -- 730-910 días atrás (más de 2 años)
        END
        ELSE IF @RandomEstado < 40
        BEGIN
            -- 20%: POR VENCER (0-2 meses antes de caducidad)
            -- Si la vigencia es 2 años (730 días), y queremos que esté por vencer (0-60 días restantes)
            -- entonces la evaluación fue hace 670-730 días
            SET @DiasAtras = 670 + (ABS(CHECKSUM(NEWID())) % 60);  -- 670-730 días atrás
        END
        ELSE
        BEGIN
            -- 60%: VIGENTE (más de 2 meses restantes)
            -- Para que esté vigente con más de 2 meses, evaluación hace menos de 670 días
            SET @DiasAtras = ABS(CHECKSUM(NEWID())) % 670;  -- 0-670 días atrás
        END
    END
    ELSE
    BEGIN
        -- Sin PDF: Fechas variadas pero recientes
        SET @DiasAtras = ABS(CHECKSUM(NEWID())) % 365;  -- 0-365 días atrás (último año)
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
    -- ETAPA 2: MARCAR EXÁMENES SEGÚN TIPO
    -- =============================================
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
    DECLARE @ExamenesParciales BIT = 0;

    -- Determinar cuántos exámenes marcar según tipo
    IF @TendraPDF = 1
    BEGIN
        -- Tipo 2 (Con PDF): TODOS los exámenes OBLIGATORIO
        SET @ExamenesAMarcar = @TotalExamenes;
        SET @ExamenesParciales = 0;
    END
    ELSE
    BEGIN
        -- Tipo 1 (Sin PDF): Aleatorio entre parciales o completos
        DECLARE @RandomExamenes INT = ABS(CHECKSUM(NEWID())) % 100;

        IF @RandomExamenes < 50
        BEGIN
            -- 50%: Exámenes PARCIALES (30-70% aleatorio)
            DECLARE @PorcentajeExamenes INT = 30 + (ABS(CHECKSUM(NEWID())) % 41);  -- 30-70%
            SET @ExamenesAMarcar = (@TotalExamenes * @PorcentajeExamenes) / 100;
            IF @ExamenesAMarcar = 0 SET @ExamenesAMarcar = 1;  -- Al menos 1
            SET @ExamenesParciales = 1;
            SET @ContadorExamenesParciales = @ContadorExamenesParciales + 1;
        END
        ELSE
        BEGIN
            -- 50%: TODOS los exámenes
            SET @ExamenesAMarcar = @TotalExamenes;
            SET @ExamenesParciales = 0;
            SET @ContadorExamenesCompletos = @ContadorExamenesCompletos + 1;
        END
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

    -- =============================================
    -- ETAPA 3: GENERAR PDF (Solo Tipo 2)
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
    ELSE
    BEGIN
        -- Incrementar contador de sin PDF
        SET @ContadorSinPDF = @ContadorSinPDF + 1;
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
PRINT '--- DISTRIBUCIÓN POR TIPO DE CERTIFICADO ---';
PRINT 'Sin PDF: ' + CAST(@ContadorSinPDF AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorSinPDF * 100.0 / @ContadorCertificados AS DECIMAL(5,2)) AS VARCHAR) + '%)';
PRINT '  - Exámenes parciales: ' + CAST(@ContadorExamenesParciales AS VARCHAR);
PRINT '  - Exámenes completos: ' + CAST(@ContadorExamenesCompletos AS VARCHAR);
PRINT '';
PRINT 'Con PDF: ' + CAST(@ContadorConPDF AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorConPDF * 100.0 / @ContadorCertificados AS DECIMAL(5,2)) AS VARCHAR) + '%)';
PRINT '  - Vigente (>2 meses): ' + CAST(@ContadorVigente AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorVigente * 100.0 / NULLIF(@ContadorConPDF, 0) AS DECIMAL(5,2)) AS VARCHAR) + '%)';
PRINT '  - Por vencer (0-2 meses): ' + CAST(@ContadorPorVencer AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorPorVencer * 100.0 / NULLIF(@ContadorConPDF, 0) AS DECIMAL(5,2)) AS VARCHAR) + '%)';
PRINT '  - Vencido: ' + CAST(@ContadorVencido AS VARCHAR) + ' (' +
      CAST(CAST(@ContadorVencido * 100.0 / NULLIF(@ContadorConPDF, 0) AS DECIMAL(5,2)) AS VARCHAR) + '%)';
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