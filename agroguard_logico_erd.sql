CREATE TABLE rol (
    id_rol INT NOT NULL,
    nombre VARCHAR(100),
    descripcion VARCHAR(100),
    CONSTRAINT PK_rol PRIMARY KEY (id_rol)
);

CREATE TABLE empresa (
    id_empresa INT NOT NULL,
    razon_social VARCHAR(100),
    ruc VARCHAR(100),
    direccion VARCHAR(100),
    telefono VARCHAR(100),
    fecha_registro VARCHAR(100),
    CONSTRAINT PK_empresa PRIMARY KEY (id_empresa)
);

CREATE TABLE usuario (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    id_empresa INT,
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(100),
    contrasena_hash VARCHAR(100),
    activo VARCHAR(100),
    fecha_registro VARCHAR(100),
    CONSTRAINT PK_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT FK_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol),
    CONSTRAINT FK_usuario_empresa FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE departamento (
    id_departamento INT NOT NULL,
    nombre VARCHAR(100),
    region_natural VARCHAR(100),
    CONSTRAINT PK_departamento PRIMARY KEY (id_departamento)
);

CREATE TABLE parcela (
    id_parcela INT NOT NULL,
    id_propietario INT NOT NULL,
    id_empresa INT,
    id_departamento INT NOT NULL,
    nombre VARCHAR(100),
    distrito VARCHAR(100),
    latitud VARCHAR(100),
    longitud VARCHAR(100),
    area_ha VARCHAR(100),
    altitud_msnm VARCHAR(100),
    tipo_suelo VARCHAR(100),
    estado VARCHAR(100),
    fecha_registro VARCHAR(100),
    CONSTRAINT PK_parcela PRIMARY KEY (id_parcela),
    CONSTRAINT FK_parcela_propietario FOREIGN KEY (id_propietario) REFERENCES usuario(id_usuario),
    CONSTRAINT FK_parcela_empresa FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    CONSTRAINT FK_parcela_departamento FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento)
);

CREATE TABLE asignacion_parcela (
    id_asignacion INT NOT NULL,
    id_parcela INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_asignacion VARCHAR(100),
    activa VARCHAR(100),
    CONSTRAINT PK_asignacion_parcela PRIMARY KEY (id_asignacion),
    CONSTRAINT FK_asignacion_parcela_parcela FOREIGN KEY (id_parcela) REFERENCES parcela(id_parcela),
    CONSTRAINT FK_asignacion_parcela_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE cultivo (
    id_cultivo INT NOT NULL,
    nombre VARCHAR(100),
    nombre_cientifico VARCHAR(100),
    ciclo_dias VARCHAR(100),
    CONSTRAINT PK_cultivo PRIMARY KEY (id_cultivo)
);

CREATE TABLE siembra (
    id_siembra INT NOT NULL,
    id_parcela INT NOT NULL,
    id_cultivo INT NOT NULL,
    fecha_siembra VARCHAR(100),
    fecha_cosecha_estimada VARCHAR(100),
    fecha_cosecha_real VARCHAR(100),
    area_sembrada_ha VARCHAR(100),
    estado VARCHAR(100),
    CONSTRAINT PK_siembra PRIMARY KEY (id_siembra),
    CONSTRAINT FK_siembra_parcela FOREIGN KEY (id_parcela) REFERENCES parcela(id_parcela),
    CONSTRAINT FK_siembra_cultivo FOREIGN KEY (id_cultivo) REFERENCES cultivo(id_cultivo)
);

CREATE TABLE tipo_sensor (
    id_tipo_sensor INT NOT NULL,
    nombre VARCHAR(100),
    variable_medida VARCHAR(100),
    unidad_medida VARCHAR(100),
    rango_min VARCHAR(100),
    rango_max VARCHAR(100),
    CONSTRAINT PK_tipo_sensor PRIMARY KEY (id_tipo_sensor)
);

CREATE TABLE sensor (
    id_sensor INT NOT NULL,
    id_parcela INT NOT NULL,
    id_tipo_sensor INT NOT NULL,
    codigo_serie VARCHAR(100),
    modelo VARCHAR(100),
    fecha_instalacion VARCHAR(100),
    estado VARCHAR(100),
    nivel_bateria VARCHAR(100),
    CONSTRAINT PK_sensor PRIMARY KEY (id_sensor),
    CONSTRAINT FK_sensor_parcela FOREIGN KEY (id_parcela) REFERENCES parcela(id_parcela),
    CONSTRAINT FK_sensor_tipo_sensor FOREIGN KEY (id_tipo_sensor) REFERENCES tipo_sensor(id_tipo_sensor)
);

CREATE TABLE lectura (
    id_lectura INT NOT NULL,
    id_sensor INT NOT NULL,
    valor VARCHAR(100),
    fecha_hora VARCHAR(100),
    CONSTRAINT PK_lectura PRIMARY KEY (id_lectura),
    CONSTRAINT FK_lectura_sensor FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor)
);

CREATE TABLE umbral_riesgo (
    id_umbral INT NOT NULL,
    id_tipo_sensor INT NOT NULL,
    id_cultivo INT NOT NULL,
    nivel VARCHAR(100),
    valor_desde VARCHAR(100),
    valor_hasta VARCHAR(100),
    descripcion VARCHAR(100),
    CONSTRAINT PK_umbral_riesgo PRIMARY KEY (id_umbral),
    CONSTRAINT FK_umbral_riesgo_tipo_sensor FOREIGN KEY (id_tipo_sensor) REFERENCES tipo_sensor(id_tipo_sensor),
    CONSTRAINT FK_umbral_riesgo_cultivo FOREIGN KEY (id_cultivo) REFERENCES cultivo(id_cultivo)
);

CREATE TABLE alerta (
    id_alerta INT NOT NULL,
    id_lectura INT NOT NULL,
    id_umbral INT NOT NULL,
    mensaje VARCHAR(100),
    fecha_generacion VARCHAR(100),
    estado VARCHAR(100),
    id_usuario_atencion INT,
    fecha_atencion VARCHAR(100),
    CONSTRAINT PK_alerta PRIMARY KEY (id_alerta),
    CONSTRAINT FK_alerta_lectura FOREIGN KEY (id_lectura) REFERENCES lectura(id_lectura),
    CONSTRAINT FK_alerta_umbral FOREIGN KEY (id_umbral) REFERENCES umbral_riesgo(id_umbral),
    CONSTRAINT FK_alerta_usuario_atencion FOREIGN KEY (id_usuario_atencion) REFERENCES usuario(id_usuario)
);

CREATE TABLE notificacion (
    id_notificacion INT NOT NULL,
    id_alerta INT NOT NULL,
    id_usuario INT NOT NULL,
    canal VARCHAR(100),
    fecha_envio VARCHAR(100),
    leida VARCHAR(100),
    CONSTRAINT PK_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT FK_notificacion_alerta FOREIGN KEY (id_alerta) REFERENCES alerta(id_alerta),
    CONSTRAINT FK_notificacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
