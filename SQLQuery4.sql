USE ENAHO_VIVIENDA_HOGAR;
GO

--UBICACIÓN 

CREATE TABLE dbo.TB_UBICACION (
    id_ubicacion   INT IDENTITY(1,1) PRIMARY KEY,
    ubigeo         CHAR(6)      NOT NULL REFERENCES dbo.CAT_UBIGEO(ubigeo),
    id_dominio     TINYINT      NULL REFERENCES dbo.CAT_DOMINIO(id_dominio),
    id_estrato     TINYINT      NULL REFERENCES dbo.CAT_ESTRATO(id_estrato),
    codccpp        VARCHAR(4)   NULL,       
    nomccpp        VARCHAR(80)  NULL,       
    longitud       DECIMAL(9,2) NULL,
    latitud        DECIMAL(9,2) NULL,
    CONSTRAINT UQ_UBICACION UNIQUE (ubigeo, codccpp)
);
GO

--HOGAR 
CREATE TABLE dbo.TB_HOGAR (
    id_hogar        BIGINT IDENTITY(1,1) PRIMARY KEY,
    anio            SMALLINT     NOT NULL,
    mes             TINYINT      NOT NULL,
    conglome        VARCHAR(6)   NOT NULL,
    vivienda        VARCHAR(3)   NOT NULL,
    hogar           VARCHAR(2)   NOT NULL,
    id_ubicacion    INT          NULL REFERENCES dbo.TB_UBICACION(id_ubicacion),
    id_periodo      TINYINT      NULL REFERENCES dbo.CAT_PERIODO(id_periodo),
    id_tipo_seleccion TINYINT    NULL REFERENCES dbo.CAT_TIPO_SELECCION(id_tipo_seleccion),
    fecha_entrevista DATE        NULL,
    id_resultado    TINYINT      NULL REFERENCES dbo.CAT_RESULTADO_ENCUESTA(id_resultado),
    id_panel        TINYINT      NULL REFERENCES dbo.CAT_SI_NO(id_si_no),
    id_origen_cuestionario TINYINT NULL REFERENCES dbo.CAT_ORIGEN_CUESTIONARIO(id_origen),
    factor_expansion DECIMAL(9,2) NULL,
    CONSTRAINT UQ_HOGAR UNIQUE (anio, conglome, vivienda, hogar)
);
GO

--VIVIENDA
CREATE TABLE dbo.TB_VIVIENDA (
    id_hogar            BIGINT PRIMARY KEY REFERENCES dbo.TB_HOGAR(id_hogar),
    id_tipo_vivienda     TINYINT REFERENCES dbo.CAT_TIPO_VIVIENDA(id_tipo_vivienda),
    id_material_pared    TINYINT REFERENCES dbo.CAT_MATERIAL_PARED(id_material_pared),
    id_material_piso     TINYINT REFERENCES dbo.CAT_MATERIAL_PISO(id_material_piso),
    id_material_techo    TINYINT REFERENCES dbo.CAT_MATERIAL_TECHO(id_material_techo),
    id_fachada_tarrajeo  TINYINT REFERENCES dbo.CAT_FACHADA_TARRAJEO(id_fachada_tarrajeo),
    id_fachada_pintada   TINYINT REFERENCES dbo.CAT_FACHADA_PINTADA(id_fachada_pintada),
    calle_pista_asfaltada BIT NULL,
    calle_pista_afirmada  BIT NULL,
    calle_veredas         BIT NULL,
    calle_poste_alumbrado BIT NULL,
    calle_sin_elementos   BIT NULL,
    num_habitaciones      TINYINT NULL,
    num_habitaciones_dormir TINYINT NULL,
    existe_otra_vivienda_id TINYINT NULL REFERENCES dbo.CAT_SI_NO(id_si_no)
);
GO

--TENENCIA
CREATE TABLE dbo.TB_TENENCIA (
    id_hogar               BIGINT PRIMARY KEY REFERENCES dbo.TB_HOGAR(id_hogar),
    id_tenencia            TINYINT REFERENCES dbo.CAT_TENENCIA_VIVIENDA(id_tenencia),
    monto_alquiler_compra  DECIMAL(10,2) NULL,   
    monto_alquiler_estimado DECIMAL(10,2) NULL,  
    id_titulo_propiedad    TINYINT REFERENCES dbo.CAT_TITULO_PROPIEDAD(id_titulo),
    id_titulo_sunarp       TINYINT REFERENCES dbo.CAT_SI_NO(id_si_no)
);
GO

--CRÉDITOS PARA VIVIENDA  
CREATE TABLE dbo.TB_CREDITO_VIVIENDA (
    id_credito       BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_hogar         BIGINT NOT NULL REFERENCES dbo.TB_HOGAR(id_hogar),
    id_tipo_credito  TINYINT NOT NULL REFERENCES dbo.CAT_TIPO_CREDITO(id_tipo_credito),
    obtuvo_credito_id TINYINT NULL REFERENCES dbo.CAT_SI_NO(id_si_no),
    monto_total_credito DECIMAL(10,2) NULL,
    CONSTRAINT UQ_CREDITO_HOGAR UNIQUE (id_hogar, id_tipo_credito)
);
GO

--Entidad
CREATE TABLE dbo.TB_CREDITO_ENTIDAD (
    id_credito BIGINT NOT NULL REFERENCES dbo.TB_CREDITO_VIVIENDA(id_credito),
    id_entidad TINYINT NOT NULL REFERENCES dbo.CAT_ENTIDAD_CREDITO(id_entidad),
    PRIMARY KEY (id_credito, id_entidad)
);
GO

--SERVICIOS BÁSICOS
CREATE TABLE dbo.TB_SERVICIOS_BASICOS (
    id_hogar             BIGINT PRIMARY KEY REFERENCES dbo.TB_HOGAR(id_hogar),
    id_fuente_agua       TINYINT REFERENCES dbo.CAT_FUENTE_AGUA(id_fuente_agua),
    agua_potable_id      TINYINT NULL REFERENCES dbo.CAT_SI_NO(id_si_no),
    agua_servicio_diario_id TINYINT NULL REFERENCES dbo.CAT_SI_NO(id_si_no),
    agua_horas_dia       TINYINT NULL,
    agua_dias_semana     TINYINT NULL,
    id_tipo_desague      TINYINT REFERENCES dbo.CAT_TIPO_DESAGUE(id_tipo_desague),
    id_servicio_electrico TINYINT REFERENCES dbo.CAT_SERVICIO_ELECTRICO(id_servicio_electrico)
);
GO


--Tipos de alumbrado del hogar
CREATE TABLE dbo.TB_HOGAR_ALUMBRADO (
    id_hogar          BIGINT NOT NULL REFERENCES dbo.TB_HOGAR(id_hogar),
    id_tipo_alumbrado TINYINT NOT NULL REFERENCES dbo.CAT_TIPO_ALUMBRADO(id_tipo_alumbrado),
    PRIMARY KEY (id_hogar, id_tipo_alumbrado)
);
GO

--Combustible(s) usados para cocinar
CREATE TABLE dbo.TB_HOGAR_COMBUSTIBLE (
    id_hogar        BIGINT NOT NULL REFERENCES dbo.TB_HOGAR(id_hogar),
    id_combustible  TINYINT NOT NULL REFERENCES dbo.CAT_COMBUSTIBLE_COCINA(id_combustible),
    PRIMARY KEY (id_hogar, id_combustible)
);
GO

--CALIDAD DEL AGUA / CLORO RESIDUAL
CREATE TABLE dbo.TB_CLORO_AGUA (
    id_hogar            BIGINT PRIMARY KEY REFERENCES dbo.TB_HOGAR(id_hogar),
    id_nivel_cloro      TINYINT REFERENCES dbo.CAT_NIVEL_CLORO(id_nivel_cloro),
    lectura_disco       DECIMAL(3,1) NULL,      -- ej. 0.3 mg/Lt (entero.decimal)
    id_extraccion_por   TINYINT REFERENCES dbo.CAT_EXTRACCION_POR(id_extraccion_por),
    id_extraccion_de    TINYINT REFERENCES dbo.CAT_EXTRACCION_DE(id_extraccion_de)
);
GO

--SERVICIOS TIC del hogar 
CREATE TABLE dbo.TB_HOGAR_SERVICIO_TIC (
    id_hogar        BIGINT NOT NULL REFERENCES dbo.TB_HOGAR(id_hogar),
    id_servicio_tic TINYINT NOT NULL REFERENCES dbo.CAT_SERVICIO_TIC(id_servicio_tic),
    PRIMARY KEY (id_hogar, id_servicio_tic)
);
GO

--Tipo de conexión a internet
CREATE TABLE dbo.TB_HOGAR_CONEXION_INTERNET (
    id_hogar              BIGINT NOT NULL REFERENCES dbo.TB_HOGAR(id_hogar),
    id_conexion_internet  TINYINT NOT NULL REFERENCES dbo.CAT_CONEXION_INTERNET(id_conexion_internet),
    PRIMARY KEY (id_hogar, id_conexion_internet)
);
GO

--GASTOS DEL HOGAR 
CREATE TABLE dbo.TB_GASTO_HOGAR (
    id_gasto              BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_hogar              BIGINT NOT NULL REFERENCES dbo.TB_HOGAR(id_hogar),
    id_tipo_gasto         VARCHAR(2) NOT NULL REFERENCES dbo.CAT_TIPO_GASTO(id_tipo_gasto),
    monto_pagado_hogar    DECIMAL(10,2) NULL,   
    monto_donado_otro_hogar DECIMAL(10,2) NULL, 
    monto_autoconsumo     DECIMAL(10,2) NULL,   
    id_situacion_gasto     TINYINT NULL REFERENCES dbo.CAT_SITUACION_GASTO(id_situacion),
    CONSTRAINT UQ_GASTO_HOGAR UNIQUE (id_hogar, id_tipo_gasto)
);
GO

--INDICADORES NBI
CREATE TABLE dbo.TB_INDICADORES_NBI (
    id_hogar                    BIGINT PRIMARY KEY REFERENCES dbo.TB_HOGAR(id_hogar),
    nbi1_vivienda_inadecuada    BIT NULL,
    nbi2_hacinamiento           BIT NULL,
    nbi3_sin_servicios_higienicos BIT NULL,
    nbi4_ninos_no_escuela       BIT NULL,
    nbi5_alta_dependencia       BIT NULL
);
GO

-- Índices de apoyo para las consultas de análisis más comunes
CREATE INDEX IX_HOGAR_UBICACION ON dbo.TB_HOGAR(id_ubicacion);
CREATE INDEX IX_GASTO_TIPO ON dbo.TB_GASTO_HOGAR(id_tipo_gasto);
CREATE INDEX IX_CREDITO_HOGAR ON dbo.TB_CREDITO_VIVIENDA(id_hogar);
GO