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
