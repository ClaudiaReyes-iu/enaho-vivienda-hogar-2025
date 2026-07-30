USE ENAHO_VIVIENDA_HOGAR;
GO

CREATE TABLE dbo.CAT_DOMINIO (
    id_dominio TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_DOMINIO VALUES
(1,'Costa Norte'),(2,'Costa Centro'),(3,'Costa Sur'),(4,'Sierra Norte'),
(5,'Sierra Centro'),(6,'Sierra Sur'),(7,'Selva'),(8,'Lima Metropolitana');

CREATE TABLE dbo.CAT_ESTRATO (
    id_estrato TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_ESTRATO VALUES
(1,'De 500 000 a más habitantes'),(2,'De 100 000 a 499 999 habitantes'),
(3,'De 50 000 a 99 999 habitantes'),(4,'De 20 000 a 49 999 habitantes'),
(5,'De 2 000 a 19 999 habitantes'),(6,'De 500 a 1 999 habitantes'),
(7,'Área de Empadronamiento Rural (AER) Compuesto'),
(8,'Área de Empadronamiento Rural (AER) Simple');

CREATE TABLE dbo.CAT_PERIODO (
    id_periodo TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_PERIODO VALUES
(1,'Primer Período'),(2,'Segundo Período'),(3,'Tercer Período'),
(4,'Cuarto Período'),(5,'Quinto Período');

CREATE TABLE dbo.CAT_TIPO_SELECCION (
    id_tipo_seleccion TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TIPO_SELECCION VALUES
(1,'Selección Automática por Computadora - Área Urbana'),
(3,'Selección por Muestra Panel'),
(4,'Selección Automática por Computadora - Área Rural'),
(5,'Selección por conteo de la encuestadora en el Área Rural');

CREATE TABLE dbo.CAT_RESULTADO_ENCUESTA (
    id_resultado TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_RESULTADO_ENCUESTA VALUES
(1,'Completa'),(2,'Incompleta'),(3,'Rechazo'),(4,'Ausente'),
(5,'Vivienda Desocupada'),(6,'No se Inició la Entrevista'),(7,'Otro');

CREATE TABLE dbo.CAT_ORIGEN_CUESTIONARIO (
    id_origen TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_ORIGEN_CUESTIONARIO VALUES
(1,'Cuestionario en hojas'),(2,'Cuestionario en Tablet');

CREATE TABLE dbo.CAT_SI_NO (
    id_si_no TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_SI_NO VALUES (1,'Sí'),(2,'No');

CREATE TABLE dbo.CAT_TIPO_VIVIENDA (
    id_tipo_vivienda TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TIPO_VIVIENDA VALUES
(1,'Casa independiente'),(2,'Departamento en edificio'),(3,'Vivienda en quinta'),
(4,'Vivienda en casa de vecindad (callejón, solar o corralón)'),
(5,'Choza o cabaña'),(6,'Vivienda improvisada'),
(7,'Local no destinado para habitación humana'),(8,'Otro');

CREATE TABLE dbo.CAT_MATERIAL_PARED (
    id_material_pared TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_MATERIAL_PARED VALUES
(1,'Ladrillo o bloque de cemento'),(2,'Piedra o sillar con cal o cemento'),
(3,'Adobe'),(4,'Tapia'),(5,'Quincha (caña con barro)'),(6,'Piedra con barro'),
(7,'Madera (pona, tornillo, etc.)'),(8,'Triplay/calamina/estera'),(9,'Otro material');

CREATE TABLE dbo.CAT_MATERIAL_PISO (
    id_material_piso TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_MATERIAL_PISO VALUES
(1,'Parquet o madera pulida'),(2,'Láminas asfálticas, vinílicos o similares'),
(3,'Losetas, terrazos o similares'),(4,'Madera (pona, tornillo, etc.)'),
(5,'Cemento'),(6,'Tierra'),(7,'Otro material');

CREATE TABLE dbo.CAT_MATERIAL_TECHO (
    id_material_techo TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_MATERIAL_TECHO VALUES
(1,'Concreto armado'),(2,'Madera'),(3,'Tejas'),
(4,'Planchas de calamina, fibra de cemento o similares'),
(5,'Caña o estera con torta de barro o cemento'),(6,'Triplay/estera/carrizo'),
(7,'Paja, hojas de palmera'),(8,'Otro material');

CREATE TABLE dbo.CAT_FACHADA_TARRAJEO (
    id_fachada_tarrajeo TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_FACHADA_TARRAJEO VALUES
(1,'Total'),(2,'Parcial'),(3,'No está tarrajeada'),(4,'No corresponde');

CREATE TABLE dbo.CAT_FACHADA_PINTADA (
    id_fachada_pintada TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_FACHADA_PINTADA VALUES
(1,'Totalmente'),(2,'Parcialmente'),(3,'Sin pintar');

-- Tenencia y crédito ----------------------------------------------------------
CREATE TABLE dbo.CAT_TENENCIA_VIVIENDA (
    id_tenencia TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TENENCIA_VIVIENDA VALUES
(1,'Alquilada'),(2,'Propia, totalmente pagada'),(3,'Propia, por invasión'),
(4,'Propia, comprándola a plazos'),(5,'Cedida por el centro de trabajo'),
(6,'Cedida por otro hogar o institución'),(7,'Otra forma');

CREATE TABLE dbo.CAT_TITULO_PROPIEDAD (
    id_titulo TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TITULO_PROPIEDAD VALUES
(1,'Sí'),(2,'No'),(3,'En trámite de titulación');

CREATE TABLE dbo.CAT_TIPO_CREDITO (
    id_tipo_credito TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TIPO_CREDITO VALUES
(1,'Comprar casa o departamento'),(2,'Comprar terreno para vivienda'),
(3,'Mejoramiento y/o ampliación de la vivienda'),(4,'Construcción de vivienda nueva');

CREATE TABLE dbo.CAT_ENTIDAD_CREDITO (
    id_entidad TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_ENTIDAD_CREDITO VALUES
(1,'Banco privado'),(2,'Banco de la Nación'),(3,'Caja Municipal'),
(4,'Persona particular'),(6,'Techo propio'),(7,'Financiera de Ahorro y Crédito'),
(8,'Otro'),(9,'Cooperativa de Ahorro y Crédito'),(10,'Derrama Magisterial');

-- Servicios básicos -------------------------------------------------------------
CREATE TABLE dbo.CAT_FUENTE_AGUA (
    id_fuente_agua TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_FUENTE_AGUA VALUES
(1,'Red pública, dentro de la vivienda'),
(2,'Red pública, fuera de la vivienda pero dentro del edificio'),
(3,'Pilón o pileta de uso público'),(4,'Camión-cisterna u otro similar'),
(5,'Pozo (agua subterránea)'),(6,'Manantial o puquio'),(7,'Otra'),
(8,'Río, acequia, lago, laguna'),(9,'Agua potable del vecino');

CREATE TABLE dbo.CAT_NIVEL_CLORO (
    id_nivel_cloro TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_NIVEL_CLORO VALUES
(1,'Seguro (Mayor o igual a 0.5 mg/Lt)'),
(2,'Inadecuada dosificación de Cloro (0.1 a menos de 0.5 mg/Lt)'),
(3,'Sin Cloro (0.0 mg/Lt)');

CREATE TABLE dbo.CAT_EXTRACCION_POR (
    id_extraccion_por TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_EXTRACCION_POR VALUES
(1,'El funcionario de la encuesta'),(2,'El informante');

CREATE TABLE dbo.CAT_EXTRACCION_DE (
    id_extraccion_de TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_EXTRACCION_DE VALUES
(1,'Grifo o caño'),(2,'Cilindro de metal'),(3,'Balde o batea de plástico'),
(4,'Tanque (sin filtro)'),(5,'Tanque (con filtro)'),(6,'Bidón, botella, etc.'),(7,'Otro');

CREATE TABLE dbo.CAT_TIPO_DESAGUE (
    id_tipo_desague TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TIPO_DESAGUE VALUES
(1,'Red pública de desagüe dentro de la vivienda'),
(2,'Red pública de desagüe fuera de la vivienda pero dentro del edificio'),
(3,'Letrina (con tratamiento)'),(4,'Pozo séptico, tanque séptico o biodigestor'),
(5,'Pozo ciego o negro'),(6,'Río, acequia, canal o similar'),(7,'Otra'),
(9,'Campo abierto o al aire libre'),(10,'Letrina (sin tratamiento)'),
(11,'Letrina (tipo compostera)');

CREATE TABLE dbo.CAT_TIPO_ALUMBRADO (
    id_tipo_alumbrado TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TIPO_ALUMBRADO VALUES
(1,'Electricidad'),(3,'Petróleo/gas (lámpara)'),(4,'Vela'),(5,'Generador'),
(6,'Otro'),(7,'No utiliza alumbrado');

CREATE TABLE dbo.CAT_SERVICIO_ELECTRICO (
    id_servicio_electrico TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_SERVICIO_ELECTRICO VALUES
(1,'Con medidor de uso exclusivo para la vivienda'),
(2,'Con medidor de uso colectivo (para varias viviendas)'),(3,'Otro');

CREATE TABLE dbo.CAT_COMBUSTIBLE_COCINA (
    id_combustible TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_COMBUSTIBLE_COCINA VALUES
(1,'Electricidad'),(2,'Gas (balón GLP)'),(3,'Gas natural (sistema de tuberías)'),
(5,'Carbón'),(6,'Leña'),(7,'Otro (residuos agrícolas, etc.)'),
(8,'No cocinan'),(9,'Bosta, estiércol');

-- Telecomunicaciones ------------------------------------------------------------
CREATE TABLE dbo.CAT_SERVICIO_TIC (
    id_servicio_tic TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_SERVICIO_TIC VALUES
(1,'Teléfono (fijo)'),(2,'Teléfono Celular'),(3,'Conexión a TV por cable o satelital'),
(4,'Conexión a Internet (fijo/móvil)'),(5,'No tiene'),(6,'Televisión Digital Terrestre');

CREATE TABLE dbo.CAT_CONEXION_INTERNET (
    id_conexion_internet TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_CONEXION_INTERNET VALUES
(1,'Conexión fija'),(2,'Conexión móvil post pago/control'),(3,'Conexión móvil prepago');

-- Gastos del hogar ----------------------------------------------------------------
CREATE TABLE dbo.CAT_TIPO_GASTO (
    id_tipo_gasto VARCHAR(2) PRIMARY KEY,  
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_TIPO_GASTO VALUES
('01','Agua'),('02','Electricidad'),('04','Gas (balón GLP)'),
('05','Gas Natural (sistema de tuberías)'),('06','Vela'),('07','Carbón'),
('08','Leña'),('09','Petróleo'),('10','Gasolina'),('11','Teléfono fijo'),
('12','Celular'),('13','TV cable o satelital'),('14','Internet'),
('15','Otro'),('16','Bosta, estiércol'),('17','Internet (portátil)');

CREATE TABLE dbo.CAT_SITUACION_GASTO (
    id_situacion TINYINT PRIMARY KEY,
    descripcion VARCHAR(MAX) NOT NULL
);
INSERT INTO dbo.CAT_SITUACION_GASTO VALUES
(0,'No aplica / Pase'),(1,'Incluido en el alquiler'),(2,'No gastó'),
(3,'No sabe/No responde'),(4,'Incluido en el celular');
GO


