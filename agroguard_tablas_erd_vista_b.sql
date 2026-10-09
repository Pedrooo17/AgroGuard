CREATE TABLE usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    id_rol INT NOT NULL,
    id_empresa INT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    email VARCHAR(120) NOT NULL,
    telefono VARCHAR(15) NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BIT NOT NULL CONSTRAINT DF_usuario_activo DEFAULT (1),
    fecha_registro DATETIME2(0) NOT NULL CONSTRAINT DF_usuario_fecha_registro DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_usuario_email UNIQUE (email),
    CONSTRAINT CK_usuario_email CHECK (email LIKE '%_@_%._%')
);

CREATE TABLE parcela (
    id_parcela INT IDENTITY(1,1) NOT NULL,
    id_propietario INT NOT NULL,
    id_empresa INT NULL,
    id_departamento INT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    distrito VARCHAR(60) NOT NULL,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    area_ha DECIMAL(10,2) NOT NULL,
    altitud_msnm INT NULL,
    tipo_suelo VARCHAR(30) NULL,
    estado VARCHAR(10) NOT NULL CONSTRAINT DF_parcela_estado DEFAULT ('ACTIVA'),
    fecha_registro DATE NOT NULL CONSTRAINT DF_parcela_fecha_registro DEFAULT (GETDATE()),
    CONSTRAINT PK_parcela PRIMARY KEY (id_parcela),
    CONSTRAINT FK_parcela_propietario FOREIGN KEY (id_propietario) REFERENCES usuario(id_usuario),
    CONSTRAINT CK_parcela_latitud CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT CK_parcela_longitud CHECK (longitud BETWEEN -180 AND 180),
    CONSTRAINT CK_parcela_area_ha CHECK (area_ha > 0),
    CONSTRAINT CK_parcela_altitud_msnm CHECK (altitud_msnm BETWEEN 0 AND 6800),
    CONSTRAINT CK_parcela_tipo_suelo CHECK (tipo_suelo IS NULL OR tipo_suelo IN ('FRANCO','ARENOSO','ARCILLOSO','LIMOSO','FRANCO_ARENOSO','FRANCO_ARCILLOSO','FRANCO_LIMOSO')),
    CONSTRAINT CK_parcela_estado CHECK (estado IN ('ACTIVA','INACTIVA')),
    CONSTRAINT UQ_parcela_propietario_nombre UNIQUE (id_propietario, nombre)
);

CREATE TABLE cultivo (
    id_cultivo INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    nombre_cientifico VARCHAR(100) NULL,
    ciclo_dias INT NOT NULL,
    CONSTRAINT PK_cultivo PRIMARY KEY (id_cultivo),
    CONSTRAINT UQ_cultivo_nombre UNIQUE (nombre),
    CONSTRAINT CK_cultivo_ciclo_dias CHECK (ciclo_dias > 0)
);

CREATE TABLE tipo_sensor (
    id_tipo_sensor INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    variable_medida VARCHAR(40) NOT NULL,
    unidad_medida VARCHAR(15) NOT NULL,
    rango_min DECIMAL(10,2) NOT NULL,
    rango_max DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_tipo_sensor PRIMARY KEY (id_tipo_sensor),
    CONSTRAINT UQ_tipo_sensor_nombre UNIQUE (nombre),
    CONSTRAINT CK_tipo_sensor_rango CHECK (rango_min < rango_max)
);

CREATE TABLE sensor (
    id_sensor INT IDENTITY(1,1) NOT NULL,
    id_parcela INT NOT NULL,
    id_tipo_sensor INT NOT NULL,
    codigo_serie VARCHAR(40) NOT NULL,
    modelo VARCHAR(50) NULL,
    fecha_instalacion DATE NOT NULL CONSTRAINT DF_sensor_fecha_instalacion DEFAULT (GETDATE()),
    estado VARCHAR(13) NOT NULL CONSTRAINT DF_sensor_estado DEFAULT ('ACTIVO'),
    nivel_bateria TINYINT NULL,
    CONSTRAINT PK_sensor PRIMARY KEY (id_sensor),
    CONSTRAINT FK_sensor_parcela FOREIGN KEY (id_parcela) REFERENCES parcela(id_parcela),
    CONSTRAINT FK_sensor_tipo_sensor FOREIGN KEY (id_tipo_sensor) REFERENCES tipo_sensor(id_tipo_sensor),
    CONSTRAINT UQ_sensor_codigo_serie UNIQUE (codigo_serie),
    CONSTRAINT CK_sensor_estado CHECK (estado IN ('ACTIVO','INACTIVO','MANTENIMIENTO')),
    CONSTRAINT CK_sensor_nivel_bateria CHECK (nivel_bateria BETWEEN 0 AND 100)
);

CREATE TABLE lectura (
    id_lectura BIGINT IDENTITY(1,1) NOT NULL,
    id_sensor INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    fecha_hora DATETIME2(0) NOT NULL CONSTRAINT DF_lectura_fecha_hora DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_lectura PRIMARY KEY (id_lectura),
    CONSTRAINT FK_lectura_sensor FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor),
    CONSTRAINT UQ_lectura_sensor_fecha_hora UNIQUE (id_sensor, fecha_hora)
);

CREATE TABLE umbral_riesgo (
    id_umbral INT IDENTITY(1,1) NOT NULL,
    id_tipo_sensor INT NOT NULL,
    id_cultivo INT NOT NULL,
    nivel VARCHAR(7) NOT NULL,
    valor_desde DECIMAL(10,2) NULL,
    valor_hasta DECIMAL(10,2) NULL,
    descripcion VARCHAR(200) NOT NULL,
    CONSTRAINT PK_umbral_riesgo PRIMARY KEY (id_umbral),
    CONSTRAINT FK_umbral_riesgo_tipo_sensor FOREIGN KEY (id_tipo_sensor) REFERENCES tipo_sensor(id_tipo_sensor),
    CONSTRAINT FK_umbral_riesgo_cultivo FOREIGN KEY (id_cultivo) REFERENCES cultivo(id_cultivo),
    CONSTRAINT CK_umbral_riesgo_nivel CHECK (nivel IN ('MEDIO','ALTO','CRITICO')),
    CONSTRAINT CK_umbral_riesgo_banda CHECK ((valor_desde IS NOT NULL OR valor_hasta IS NOT NULL) AND (valor_desde IS NULL OR valor_hasta IS NULL OR valor_desde <= valor_hasta))
);

CREATE TABLE alerta (
    id_alerta BIGINT IDENTITY(1,1) NOT NULL,
    id_lectura BIGINT NOT NULL,
    id_umbral INT NOT NULL,
    mensaje VARCHAR(300) NOT NULL,
    fecha_generacion DATETIME2(0) NOT NULL CONSTRAINT DF_alerta_fecha_generacion DEFAULT (SYSDATETIME()),
    estado VARCHAR(10) NOT NULL CONSTRAINT DF_alerta_estado DEFAULT ('PENDIENTE'),
    id_usuario_atencion INT NULL,
    fecha_atencion DATETIME2(0) NULL,
    CONSTRAINT PK_alerta PRIMARY KEY (id_alerta),
    CONSTRAINT FK_alerta_lectura FOREIGN KEY (id_lectura) REFERENCES lectura(id_lectura),
    CONSTRAINT FK_alerta_umbral FOREIGN KEY (id_umbral) REFERENCES umbral_riesgo(id_umbral),
    CONSTRAINT FK_alerta_usuario_atencion FOREIGN KEY (id_usuario_atencion) REFERENCES usuario(id_usuario),
    CONSTRAINT CK_alerta_estado CHECK (estado IN ('PENDIENTE','ATENDIDA','DESCARTADA')),
    CONSTRAINT UQ_alerta_lectura_umbral UNIQUE (id_lectura, id_umbral),
    CONSTRAINT CK_alerta_atencion CHECK ((estado = 'PENDIENTE' AND id_usuario_atencion IS NULL AND fecha_atencion IS NULL) OR (estado <> 'PENDIENTE' AND id_usuario_atencion IS NOT NULL AND fecha_atencion IS NOT NULL)),
    CONSTRAINT CK_alerta_fechas CHECK (fecha_atencion IS NULL OR fecha_atencion >= fecha_generacion)
);

CREATE TABLE notificacion (
    id_notificacion BIGINT IDENTITY(1,1) NOT NULL,
    id_alerta BIGINT NOT NULL,
    id_usuario INT NOT NULL,
    canal VARCHAR(5) NOT NULL,
    fecha_envio DATETIME2(0) NOT NULL CONSTRAINT DF_notificacion_fecha_envio DEFAULT (SYSDATETIME()),
    leida BIT NOT NULL CONSTRAINT DF_notificacion_leida DEFAULT (0),
    CONSTRAINT PK_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT FK_notificacion_alerta FOREIGN KEY (id_alerta) REFERENCES alerta(id_alerta),
    CONSTRAINT FK_notificacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT CK_notificacion_canal CHECK (canal IN ('EMAIL','SMS','APP')),
    CONSTRAINT UQ_notificacion_alerta_usuario_canal UNIQUE (id_alerta, id_usuario, canal)
);

CREATE INDEX IX_lectura_fecha_hora ON lectura (fecha_hora);
CREATE INDEX IX_alerta_estado ON alerta (estado, fecha_generacion);
CREATE INDEX IX_sensor_parcela ON sensor (id_parcela);
