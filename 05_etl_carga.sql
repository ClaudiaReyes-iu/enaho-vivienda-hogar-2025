
USE ENAHO_VIVIENDA_HOGAR;
GO

--TB_UBICACION

;WITH ubic_unica AS (
    SELECT
        s.UBIGEO,
        TRY_CAST(LTRIM(RTRIM(s.DOMINIO)) AS TINYINT) AS DOMINIO,
        TRY_CAST(LTRIM(RTRIM(s.ESTRATO)) AS TINYINT) AS ESTRATO,
        NULLIF(s.CODCCPP,'') AS CODCCPP,
        NULLIF(s.NOMCCPP,'') AS NOMCCPP,
        TRY_CAST(REPLACE(LTRIM(RTRIM(s.LONGITUD)), ',', '.') AS DECIMAL(11,7)) AS LONGITUD,
        TRY_CAST(REPLACE(LTRIM(RTRIM(s.LATITUD)), ',', '.') AS DECIMAL(11,7)) AS LATITUD,
        ROW_NUMBER() OVER (
            PARTITION BY s.UBIGEO, ISNULL(NULLIF(s.CODCCPP,''),'')
            ORDER BY s.CONGLOME
        ) AS rn
    FROM staging.STG_ENAHO01_100 s
)
INSERT INTO dbo.TB_UBICACION (ubigeo, id_dominio, id_estrato, codccpp, nomccpp, longitud, latitud)
SELECT UBIGEO, DOMINIO, ESTRATO, CODCCPP, NOMCCPP, LONGITUD, LATITUD
FROM ubic_unica
WHERE rn = 1;
GO

--TB_HOGAR
INSERT INTO dbo.TB_HOGAR (
    anio, mes, conglome, vivienda, hogar, id_ubicacion, id_periodo,
    id_tipo_seleccion, fecha_entrevista, id_resultado, id_panel,
    id_origen_cuestionario, factor_expansion
)
SELECT
    TRY_CAST(LTRIM(RTRIM(s.[AÑO])) AS SMALLINT),
    TRY_CAST(LTRIM(RTRIM(s.MES)) AS TINYINT),
    s.CONGLOME, s.VIVIENDA, s.HOGAR,
    u.id_ubicacion,
    TRY_CAST(LTRIM(RTRIM(s.PERIODO)) AS TINYINT),
    TRY_CAST(LTRIM(RTRIM(s.TIPENC)) AS TINYINT),
    TRY_CONVERT(DATE, LTRIM(RTRIM(s.FECENT)), 112),       
    TRY_CAST(LTRIM(RTRIM(s.RESULT)) AS TINYINT),
    CASE WHEN TRY_CAST(LTRIM(RTRIM(s.PANEL)) AS TINYINT) IN (1,2)
         THEN TRY_CAST(LTRIM(RTRIM(s.PANEL)) AS TINYINT) ELSE NULL END,
    TRY_CAST(LTRIM(RTRIM(s.TICUEST01)) AS TINYINT),
    TRY_CAST(REPLACE(LTRIM(RTRIM(s.FACTOR07)), ',', '.') AS DECIMAL(12,4)) 
FROM staging.STG_ENAHO01_100 s
LEFT JOIN dbo.TB_UBICACION u
    ON u.ubigeo = s.UBIGEO AND ISNULL(u.codccpp,'') = ISNULL(NULLIF(s.CODCCPP,''),'');
GO

-- Vista de apoyo: relaciona cada fila de staging con su id_hogar ya generado ----
IF OBJECT_ID('dbo.VW_STG_HOGAR_MAP') IS NOT NULL DROP VIEW dbo.VW_STG_HOGAR_MAP;
GO
CREATE VIEW dbo.VW_STG_HOGAR_MAP AS
SELECT h.id_hogar, s.*
FROM staging.STG_ENAHO01_100 s
JOIN dbo.TB_HOGAR h
  ON h.anio = TRY_CAST(LTRIM(RTRIM(s.[AÑO])) AS SMALLINT)
 AND h.conglome = s.CONGLOME AND h.vivienda = s.VIVIENDA AND h.hogar = s.HOGAR;
GO

--TB_VIVIENDA 
INSERT INTO dbo.TB_VIVIENDA
(
    id_hogar,
    id_tipo_vivienda,
    id_material_pared,
    id_material_piso,
    id_material_techo,
    id_fachada_tarrajeo,
    id_fachada_pintada,
    calle_pista_asfaltada,
    calle_pista_afirmada,
    calle_veredas,
    calle_poste_alumbrado,
    calle_sin_elementos,
    num_habitaciones,
    num_habitaciones_dormir,
    existe_otra_vivienda_id
)
SELECT
    m.id_hogar,

    tv.id_tipo_vivienda,
    mp.id_material_pared,
    mpi.id_material_piso,
    mt.id_material_techo,

    NULLIF(TRY_CAST(m.P24A AS TINYINT),9),
    NULLIF(TRY_CAST(m.P24B AS TINYINT),9),

    CASE WHEN m.[P25$1]='1' THEN 1 ELSE 0 END,
    CASE WHEN m.[P25$2]='1' THEN 1 ELSE 0 END,
    CASE WHEN m.[P25$3]='1' THEN 1 ELSE 0 END,
    CASE WHEN m.[P25$4]='1' THEN 1 ELSE 0 END,
    CASE WHEN m.[P25$5]='1' THEN 1 ELSE 0 END,

    NULLIF(TRY_CAST(m.P104 AS TINYINT),99),
    NULLIF(TRY_CAST(m.P104A AS TINYINT),99),

    TRY_CAST(m.P22 AS TINYINT)

FROM dbo.VW_STG_HOGAR_MAP m

LEFT JOIN dbo.CAT_TIPO_VIVIENDA tv
       ON tv.id_tipo_vivienda=TRY_CAST(m.P101 AS TINYINT)

LEFT JOIN dbo.CAT_MATERIAL_PARED mp
       ON mp.id_material_pared=TRY_CAST(m.P102 AS TINYINT)

LEFT JOIN dbo.CAT_MATERIAL_PISO mpi
       ON mpi.id_material_piso=TRY_CAST(m.P103 AS TINYINT)

LEFT JOIN dbo.CAT_MATERIAL_TECHO mt
       ON mt.id_material_techo=TRY_CAST(m.P103A AS TINYINT)

WHERE tv.id_tipo_vivienda IS NOT NULL
  AND mp.id_material_pared IS NOT NULL
  AND mpi.id_material_piso IS NOT NULL
  AND mt.id_material_techo IS NOT NULL;
GO

--TB_TENENCIA 
INSERT INTO dbo.TB_TENENCIA
(
    id_hogar,
    id_tenencia,
    monto_alquiler_compra,
    monto_alquiler_estimado,
    id_titulo_propiedad,
    id_titulo_sunarp
)
SELECT
    m.id_hogar,

    CASE
        WHEN TRY_CAST(m.P105A AS TINYINT) BETWEEN 1 AND 8
        THEN TRY_CAST(m.P105A AS TINYINT)
        ELSE NULL
    END,

    NULLIF(TRY_CAST(m.P105B AS DECIMAL(10,2)),99999),

    NULLIF(TRY_CAST(m.P106 AS DECIMAL(10,2)),99999),

    CASE
        WHEN TRY_CAST(m.P106A AS TINYINT) IN (1,2)
        THEN TRY_CAST(m.P106A AS TINYINT)
        ELSE NULL
    END,

    CASE
        WHEN TRY_CAST(m.P106B AS TINYINT) IN (1,2)
        THEN TRY_CAST(m.P106B AS TINYINT)
        ELSE NULL
    END

FROM dbo.VW_STG_HOGAR_MAP m;
GO
--TB_CREDITO_VIVIENDA
INSERT INTO dbo.TB_CREDITO_VIVIENDA (id_hogar, id_tipo_credito, obtuvo_credito_id, monto_total_credito)
SELECT m.id_hogar, 1, TRY_CAST(LTRIM(RTRIM(m.P107B1)) AS TINYINT), NULLIF(TRY_CAST(LTRIM(RTRIM(m.P107D1)) AS DECIMAL(10,2)),999999)
FROM dbo.VW_STG_HOGAR_MAP m WHERE m.P107B1 IS NOT NULL AND m.P107B1 <> ''
UNION ALL
SELECT m.id_hogar, 2, TRY_CAST(LTRIM(RTRIM(m.P107B2)) AS TINYINT), NULLIF(TRY_CAST(LTRIM(RTRIM(m.P107D2)) AS DECIMAL(10,2)),999999)
FROM dbo.VW_STG_HOGAR_MAP m WHERE m.P107B2 IS NOT NULL AND m.P107B2 <> ''
UNION ALL
SELECT m.id_hogar, 3, TRY_CAST(LTRIM(RTRIM(m.P107B3)) AS TINYINT), NULLIF(TRY_CAST(LTRIM(RTRIM(m.P107D3)) AS DECIMAL(10,2)),999999)
FROM dbo.VW_STG_HOGAR_MAP m WHERE m.P107B3 IS NOT NULL AND m.P107B3 <> ''
UNION ALL
SELECT m.id_hogar, 4, TRY_CAST(LTRIM(RTRIM(m.P107B4)) AS TINYINT), NULLIF(TRY_CAST(LTRIM(RTRIM(m.P107D4)) AS DECIMAL(10,2)),999999)
FROM dbo.VW_STG_HOGAR_MAP m WHERE m.P107B4 IS NOT NULL AND m.P107B4 <> '';
GO

--TB_CREDITO_ENTIDAD 
INSERT INTO dbo.TB_CREDITO_ENTIDAD (id_credito, id_entidad)
SELECT c.id_credito, v.id_entidad
FROM dbo.TB_CREDITO_VIVIENDA c
JOIN dbo.VW_STG_HOGAR_MAP m ON m.id_hogar = c.id_hogar
CROSS APPLY (VALUES
    (1, CASE c.id_tipo_credito WHEN 1 THEN m.P107C11 WHEN 2 THEN m.P107C21 WHEN 3 THEN m.P107C31 WHEN 4 THEN m.P107C41 END),
    (2, CASE c.id_tipo_credito WHEN 1 THEN m.P107C12 WHEN 2 THEN m.P107C22 WHEN 3 THEN m.P107C32 WHEN 4 THEN m.P107C42 END),
    (3, CASE c.id_tipo_credito WHEN 1 THEN m.P107C13 WHEN 2 THEN m.P107C23 WHEN 3 THEN m.P107C33 WHEN 4 THEN m.P107C43 END),
    (4, CASE c.id_tipo_credito WHEN 1 THEN m.P107C14 WHEN 2 THEN m.P107C24 WHEN 3 THEN m.P107C34 WHEN 4 THEN m.P107C44 END),
    (6, CASE c.id_tipo_credito WHEN 1 THEN m.P107C16 WHEN 2 THEN m.P107C26 WHEN 3 THEN m.P107C36 WHEN 4 THEN m.P107C46 END),
    (7, CASE c.id_tipo_credito WHEN 1 THEN m.P107C17 WHEN 2 THEN m.P107C27 WHEN 3 THEN m.P107C37 WHEN 4 THEN m.P107C47 END),
    (8, CASE c.id_tipo_credito WHEN 1 THEN m.P107C18 WHEN 2 THEN m.P107C28 WHEN 3 THEN m.P107C38 WHEN 4 THEN m.P107C48 END),
    (9, CASE c.id_tipo_credito WHEN 1 THEN m.P107C19 WHEN 2 THEN m.P107C29 WHEN 3 THEN m.P107C39 WHEN 4 THEN m.P107C49 END),
    (10,CASE c.id_tipo_credito WHEN 1 THEN m.P107C110 WHEN 2 THEN m.P107C210 WHEN 3 THEN m.P107C310 WHEN 4 THEN m.P107C410 END)
) v(id_entidad, valor)
WHERE v.valor IS NOT NULL AND v.valor NOT IN ('', '0');
GO

--TB_SERVICIOS_BASICOS
INSERT INTO dbo.TB_SERVICIOS_BASICOS
(
    id_hogar,
    id_fuente_agua,
    agua_potable_id,
    agua_servicio_diario_id,
    agua_horas_dia,
    agua_dias_semana,
    id_tipo_desague,
    id_servicio_electrico
)
SELECT

    m.id_hogar,

    fa.id_fuente_agua,

    sn1.id_si_no,

    sn2.id_si_no,

    NULLIF(TRY_CAST(COALESCE(NULLIF(m.P110C1,''),m.P110C3) AS TINYINT),99),

    NULLIF(TRY_CAST(m.P110C2 AS TINYINT),9),

    td.id_tipo_desague,

    se.id_servicio_electrico

FROM dbo.VW_STG_HOGAR_MAP m

LEFT JOIN dbo.CAT_FUENTE_AGUA fa
ON fa.id_fuente_agua=
COALESCE(
TRY_CAST(m.T110 AS TINYINT),
TRY_CAST(m.P110 AS TINYINT)
)

LEFT JOIN dbo.CAT_SI_NO sn1
ON sn1.id_si_no=TRY_CAST(m.P110A1 AS TINYINT)

LEFT JOIN dbo.CAT_SI_NO sn2
ON sn2.id_si_no=TRY_CAST(m.P110C AS TINYINT)

LEFT JOIN dbo.CAT_TIPO_DESAGUE td
ON td.id_tipo_desague=
COALESCE(
TRY_CAST(m.T111A AS TINYINT),
TRY_CAST(m.P111A AS TINYINT)
)

LEFT JOIN dbo.CAT_SERVICIO_ELECTRICO se
ON se.id_servicio_electrico=TRY_CAST(m.P112A AS TINYINT)

WHERE fa.id_fuente_agua IS NOT NULL
AND td.id_tipo_desague IS NOT NULL
AND se.id_servicio_electrico IS NOT NULL;
GO

--TB_HOGAR_ALUMBRADO
INSERT INTO dbo.TB_HOGAR_ALUMBRADO (id_hogar, id_tipo_alumbrado)
SELECT m.id_hogar, v.id_tipo_alumbrado
FROM dbo.VW_STG_HOGAR_MAP m
CROSS APPLY (VALUES
    (1, m.P1121),(3, m.P1123),(4, m.P1124),(5, m.P1125),(6, m.P1126),(7, m.P1127)
) v(id_tipo_alumbrado, valor)
WHERE v.valor = '1';
GO

--TB_HOGAR_COMBUSTIBLE
INSERT INTO dbo.TB_HOGAR_COMBUSTIBLE (id_hogar, id_combustible)
SELECT m.id_hogar, v.id_combustible
FROM dbo.VW_STG_HOGAR_MAP m
CROSS APPLY (VALUES
    (1, m.P1131),(2, m.P1132),(3, m.P1133),(5, m.P1135),(6, m.P1136),
    (9, m.P1139),(7, m.P1137),(8, m.P1138)
) v(id_combustible, valor)
WHERE v.valor = '1';
GO

--TB_CLORO_AGUA
INSERT INTO dbo.TB_CLORO_AGUA
(
    id_hogar,
    id_nivel_cloro,
    lectura_disco,
    id_extraccion_por,
    id_extraccion_de
)
SELECT

    m.id_hogar,

    nc.id_nivel_cloro,

    NULLIF(
        TRY_CAST(REPLACE(m.P110A_MODIFICADA,',','.') AS DECIMAL(3,1))
    ,9),

    ep.id_extraccion_por,

    ed.id_extraccion_de

FROM dbo.VW_STG_HOGAR_MAP m

LEFT JOIN dbo.CAT_NIVEL_CLORO nc
ON nc.id_nivel_cloro=TRY_CAST(m.P110A AS TINYINT)

LEFT JOIN dbo.CAT_EXTRACCION_POR ep
ON ep.id_extraccion_por=TRY_CAST(m.P110D AS TINYINT)

LEFT JOIN dbo.CAT_EXTRACCION_DE ed
ON ed.id_extraccion_de=TRY_CAST(m.P110E AS TINYINT)

WHERE nc.id_nivel_cloro IS NOT NULL;
GO

--TB_HOGAR_SERVICIO_TIC
INSERT INTO dbo.TB_HOGAR_SERVICIO_TIC (id_hogar, id_servicio_tic)
SELECT m.id_hogar, v.id_servicio_tic
FROM dbo.VW_STG_HOGAR_MAP m
CROSS APPLY (VALUES
    (1, m.P1141),(2, m.P1142),(3, m.P1143),(4, m.P1144),(5, m.P1145),(6, m.P1146)
) v(id_servicio_tic, valor)
WHERE v.valor = '1';
GO

--TB_HOGAR_CONEXION_INTERNET
INSERT INTO dbo.TB_HOGAR_CONEXION_INTERNET (id_hogar, id_conexion_internet)
SELECT m.id_hogar, v.id_conexion
FROM dbo.VW_STG_HOGAR_MAP m
CROSS APPLY (VALUES (1, m.P114B1),(2, m.P114B2),(3, m.P114B3)) v(id_conexion, valor)
WHERE v.valor IN ('1','2','3') AND v.valor <> '0';
GO

--TB_GASTO_HOGAR
INSERT INTO dbo.TB_GASTO_HOGAR (id_hogar, id_tipo_gasto, monto_pagado_hogar, monto_donado_otro_hogar, monto_autoconsumo, id_situacion_gasto)
SELECT m.id_hogar, v.codigo,
       TRY_CAST(v.pagado AS DECIMAL(10,2)),
       TRY_CAST(v.donado AS DECIMAL(10,2)),
       TRY_CAST(v.autoconsumo AS DECIMAL(10,2)),
       TRY_CAST(v.situacion AS TINYINT)
FROM dbo.VW_STG_HOGAR_MAP m
CROSS APPLY (VALUES
    ('01', m.[P1172$01], m.[P1173$01], m.[P1174$01], m.[P1175$01]),
    ('02', m.[P1172$02], m.[P1173$02], m.[P1174$02], m.[P1175$02]),
    ('04', m.[P1172$04], m.[P1173$04], m.[P1174$04], m.[P1175$04]),
    ('05', m.[P1172$05], m.[P1173$05], m.[P1174$05], m.[P1175$05]),
    ('06', m.[P1172$06], m.[P1173$06], m.[P1174$06], m.[P1175$06]),
    ('07', m.[P1172$07], m.[P1173$07], m.[P1174$07], m.[P1175$07]),
    ('08', m.[P1172$08], m.[P1173$08], m.[P1174$08], m.[P1175$08]),
    ('09', m.[P1172$09], m.[P1173$09], m.[P1174$09], m.[P1175$09]),
    ('10', m.[P1172$10], m.[P1173$10], m.[P1174$10], m.[P1175$10]),
    ('11', m.[P1172$11], m.[P1173$11], m.[P1174$11], m.[P1175$11]),
    ('12', m.[P1172$12], m.[P1173$12], m.[P1174$12], m.[P1175$12]),
    ('13', m.[P1172$13], m.[P1173$13], m.[P1174$13], m.[P1175$13]),
    ('14', m.[P1172$14], m.[P1173$14], m.[P1174$14], m.[P1175$14]),
    ('15', m.[P1172$15], m.[P1173$15], m.[P1174$15], m.[P1175$15]),
    ('16', m.[P1172$16], m.[P1173$16], m.[P1174$16], m.[P1175$16]),
    ('17', m.[P1172$17], m.[P1173$17], m.[P1174$17], m.[P1175$17])
) v(codigo, pagado, donado, autoconsumo, situacion)
WHERE NOT (
    (v.pagado IS NULL OR v.pagado='') AND (v.donado IS NULL OR v.donado='')
    AND (v.autoconsumo IS NULL OR v.autoconsumo='')
    AND (v.situacion IS NULL OR v.situacion IN ('','0'))
);
GO

--TB_INDICADORES_NBI 
INSERT INTO dbo.TB_INDICADORES_NBI (id_hogar, nbi1_vivienda_inadecuada, nbi2_hacinamiento,
    nbi3_sin_servicios_higienicos, nbi4_ninos_no_escuela, nbi5_alta_dependencia)
SELECT
    m.id_hogar,
    TRY_CAST(LTRIM(RTRIM(m.NBI1)) AS BIT), TRY_CAST(LTRIM(RTRIM(m.NBI2)) AS BIT), TRY_CAST(LTRIM(RTRIM(m.NBI3)) AS BIT),
    TRY_CAST(LTRIM(RTRIM(m.NBI4)) AS BIT), TRY_CAST(LTRIM(RTRIM(m.NBI5)) AS BIT)
FROM dbo.VW_STG_HOGAR_MAP m;
GO

/* ============================================================================
   VERIFICACIÓN
   ============================================================================ */
SELECT 'TB_HOGAR' t, COUNT(*) filas FROM dbo.TB_HOGAR
UNION ALL SELECT 'TB_VIVIENDA', COUNT(*) FROM dbo.TB_VIVIENDA
UNION ALL SELECT 'TB_TENENCIA', COUNT(*) FROM dbo.TB_TENENCIA
UNION ALL SELECT 'TB_CREDITO_VIVIENDA', COUNT(*) FROM dbo.TB_CREDITO_VIVIENDA
UNION ALL SELECT 'TB_CREDITO_ENTIDAD', COUNT(*) FROM dbo.TB_CREDITO_ENTIDAD
UNION ALL SELECT 'TB_SERVICIOS_BASICOS', COUNT(*) FROM dbo.TB_SERVICIOS_BASICOS
UNION ALL SELECT 'TB_HOGAR_ALUMBRADO', COUNT(*) FROM dbo.TB_HOGAR_ALUMBRADO
UNION ALL SELECT 'TB_HOGAR_COMBUSTIBLE', COUNT(*) FROM dbo.TB_HOGAR_COMBUSTIBLE
UNION ALL SELECT 'TB_CLORO_AGUA', COUNT(*) FROM dbo.TB_CLORO_AGUA
UNION ALL SELECT 'TB_HOGAR_SERVICIO_TIC', COUNT(*) FROM dbo.TB_HOGAR_SERVICIO_TIC
UNION ALL SELECT 'TB_HOGAR_CONEXION_INTERNET', COUNT(*) FROM dbo.TB_HOGAR_CONEXION_INTERNET
UNION ALL SELECT 'TB_GASTO_HOGAR', COUNT(*) FROM dbo.TB_GASTO_HOGAR
UNION ALL SELECT 'TB_INDICADORES_NBI', COUNT(*) FROM dbo.TB_INDICADORES_NBI;

-- Ejemplo de consulta ya "des-codificada" (un hogar completo legible) ----------
SELECT TOP 10
    h.anio, h.conglome, h.vivienda, h.hogar,
    cu.departamento, cu.provincia, cu.distrito,
    dom.descripcion AS dominio, est.descripcion AS estrato,
    tv.descripcion  AS tipo_vivienda, mp.descripcion AS material_pared,
    ten.descripcion AS tenencia, fa.descripcion AS fuente_agua,
    td.descripcion  AS tipo_desague
FROM dbo.TB_HOGAR h
LEFT JOIN dbo.TB_UBICACION u ON u.id_ubicacion = h.id_ubicacion
LEFT JOIN dbo.CAT_UBIGEO cu ON cu.ubigeo = u.ubigeo
LEFT JOIN dbo.CAT_DOMINIO dom ON dom.id_dominio = u.id_dominio
LEFT JOIN dbo.CAT_ESTRATO est ON est.id_estrato = u.id_estrato
LEFT JOIN dbo.TB_VIVIENDA v ON v.id_hogar = h.id_hogar
LEFT JOIN dbo.CAT_TIPO_VIVIENDA tv ON tv.id_tipo_vivienda = v.id_tipo_vivienda
LEFT JOIN dbo.CAT_MATERIAL_PARED mp ON mp.id_material_pared = v.id_material_pared
LEFT JOIN dbo.TB_TENENCIA t ON t.id_hogar = h.id_hogar
LEFT JOIN dbo.CAT_TENENCIA_VIVIENDA ten ON ten.id_tenencia = t.id_tenencia
LEFT JOIN dbo.TB_SERVICIOS_BASICOS sb ON sb.id_hogar = h.id_hogar
LEFT JOIN dbo.CAT_FUENTE_AGUA fa ON fa.id_fuente_agua = sb.id_fuente_agua
LEFT JOIN dbo.CAT_TIPO_DESAGUE td ON td.id_tipo_desague = sb.id_tipo_desague;
GO
