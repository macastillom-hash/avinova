
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET collation_connection = 'utf8mb4_unicode_ci';
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS auditoria_reservas;
DROP TABLE IF EXISTS notificaciones;
DROP TABLE IF EXISTS mensajes_contacto;
DROP TABLE IF EXISTS entregas;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS disponibilidad_semanal;
DROP TABLE IF EXISTS informacion_institucional;
DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre_completo VARCHAR(150) NOT NULL,
    correo VARCHAR(190) NOT NULL,
    telefono VARCHAR(30) DEFAULT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'Hash generado por PHP password_hash(), nunca texto plano',
    tipo_usuario ENUM('cliente','productor','empresa') NOT NULL DEFAULT 'cliente',
    rol ENUM('cliente','administrador') NOT NULL DEFAULT 'cliente',
    estado ENUM('activo','inactivo','bloqueado') NOT NULL DEFAULT 'activo',
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_usuarios_correo (correo),
    KEY idx_usuarios_estado (estado),
    KEY idx_usuarios_rol (rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE disponibilidad_semanal (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    semana_inicio DATE NOT NULL,
    semana_fin DATE NOT NULL,
    genero ENUM('macho','hembra') NOT NULL,
    cajas_totales INT UNSIGNED NOT NULL DEFAULT 0,
    cajas_reservadas INT UNSIGNED NOT NULL DEFAULT 0,
    cajas_disponibles INT UNSIGNED NOT NULL DEFAULT 0,
    estado ENUM('abierta','cerrada','agotada') NOT NULL DEFAULT 'abierta',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_disponibilidad_semana_genero (semana_inicio, semana_fin, genero),
    KEY idx_disponibilidad_semana (semana_inicio, semana_fin),
    KEY idx_disponibilidad_estado (estado),
    CONSTRAINT chk_disponibilidad_fechas CHECK (semana_fin >= semana_inicio),
    CONSTRAINT chk_disponibilidad_reserva CHECK (cajas_reservadas <= cajas_totales),
    CONSTRAINT chk_disponibilidad_disponibles CHECK (cajas_disponibles <= cajas_totales)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reservas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo_reserva VARCHAR(30) NOT NULL,
    usuario_id INT UNSIGNED NOT NULL,
    disponibilidad_id INT UNSIGNED NOT NULL,
    semana_inicio DATE NOT NULL,
    semana_fin DATE NOT NULL,
    genero ENUM('macho','hembra') NOT NULL,
    cantidad_cajas INT UNSIGNED NOT NULL,
    pollitos_por_caja INT UNSIGNED NOT NULL DEFAULT 100,
    pollitos_adicionales INT UNSIGNED NOT NULL DEFAULT 0,
    total_pollitos_aproximado INT UNSIGNED NOT NULL,
    estado ENUM('pendiente','confirmada','cancelada','completada','rechazada') NOT NULL DEFAULT 'pendiente',
    comentarios TEXT DEFAULT NULL,
    fecha_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_confirmacion DATETIME DEFAULT NULL,
    fecha_cancelacion DATETIME DEFAULT NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_reservas_codigo (codigo_reserva),
    KEY idx_reservas_usuario (usuario_id),
    KEY idx_reservas_disponibilidad (disponibilidad_id),
    KEY idx_reservas_estado (estado),
    KEY idx_reservas_semana (semana_inicio, semana_fin),
    CONSTRAINT fk_reservas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reservas_disponibilidad FOREIGN KEY (disponibilidad_id) REFERENCES disponibilidad_semanal(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_reservas_cajas CHECK (cantidad_cajas >= 1),
    CONSTRAINT chk_reservas_adicionales CHECK (pollitos_adicionales >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE entregas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reserva_id INT UNSIGNED NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    detalles_entrega TEXT DEFAULT NULL,
    latitud DECIMAL(10,7) DEFAULT NULL,
    longitud DECIMAL(10,7) DEFAULT NULL,
    persona_recibe VARCHAR(150) NOT NULL,
    telefono_recibe VARCHAR(30) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_entregas_reserva (reserva_id),
    KEY idx_entregas_reserva (reserva_id),
    CONSTRAINT fk_entregas_reserva FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mensajes_contacto (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    usuario_id INT UNSIGNED DEFAULT NULL,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(190) NOT NULL,
    asunto VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    estado ENUM('nuevo','leido','atendido','archivado') NOT NULL DEFAULT 'nuevo',
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_atencion DATETIME DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_mensajes_correo (correo),
    KEY idx_mensajes_estado (estado),
    KEY idx_mensajes_usuario (usuario_id),
    CONSTRAINT fk_mensajes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notificaciones (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    usuario_id INT UNSIGNED NOT NULL,
    reserva_id INT UNSIGNED DEFAULT NULL,
    titulo VARCHAR(150) NOT NULL,
    contenido TEXT NOT NULL,
    leida TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notificaciones_usuario_leida (usuario_id, leida),
    KEY idx_notificaciones_reserva (reserva_id),
    CONSTRAINT fk_notificaciones_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notificaciones_reserva FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE informacion_institucional (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    clave VARCHAR(80) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    imagen VARCHAR(255) DEFAULT NULL,
    estado ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_informacion_clave (clave),
    KEY idx_informacion_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auditoria_reservas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reserva_id INT UNSIGNED NOT NULL,
    usuario_id INT UNSIGNED DEFAULT NULL,
    accion ENUM('creada','confirmada','cancelada','completada','rechazada','actualizada') NOT NULL,
    estado_anterior ENUM('pendiente','confirmada','cancelada','completada','rechazada') DEFAULT NULL,
    estado_nuevo ENUM('pendiente','confirmada','cancelada','completada','rechazada') DEFAULT NULL,
    observaciones TEXT DEFAULT NULL,
    fecha_accion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_auditoria_reserva (reserva_id),
    KEY idx_auditoria_usuario (usuario_id),
    KEY idx_auditoria_fecha (fecha_accion),
    CONSTRAINT fk_auditoria_reserva FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuarios iniciales. El hash bcrypt es compatible con password_verify().
-- Credenciales temporales de instalación: admin@avinova.com / password
-- y cliente@avinova.com / password. Cambiar ambas inmediatamente después de instalar.
INSERT INTO usuarios (nombre_completo, correo, telefono, password, tipo_usuario, rol, estado) VALUES
('Administrador Avinova', 'admin@avinova.com', '3205135667', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'empresa', 'administrador', 'activo'),
('Cliente de prueba', 'cliente@avinova.com', '3000000000', '$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'cliente', 'cliente', 'activo');

-- Disponibilidad independiente para machos y hembras en varias semanas.
INSERT INTO disponibilidad_semanal (semana_inicio, semana_fin, genero, cajas_totales, cajas_reservadas, cajas_disponibles, estado) VALUES
('2026-10-05', '2026-10-11', 'macho', 80, 0, 80, 'abierta'),
('2026-10-05', '2026-10-11', 'hembra', 80, 0, 80, 'abierta'),
('2026-10-12', '2026-10-18', 'macho', 100, 0, 100, 'abierta'),
('2026-10-12', '2026-10-18', 'hembra', 100, 0, 100, 'abierta'),
('2026-10-19', '2026-10-25', 'macho', 120, 0, 120, 'abierta'),
('2026-10-19', '2026-10-25', 'hembra', 120, 0, 120, 'abierta'),
('2026-10-26', '2026-11-01', 'macho', 100, 0, 100, 'abierta'),
('2026-10-26', '2026-11-01', 'hembra', 100, 0, 100, 'abierta');

-- Contenido inicial editable desde el panel administrativo.
INSERT INTO informacion_institucional (clave, titulo, contenido, imagen, estado) VALUES
('nombre_empresa', 'Distribuidora Avinova', 'Distribuidora Avinova conecta granjas y negocios con pollitos bebés de excelente calidad, mediante un servicio seguro, rápido y confiable.', NULL, 'activo'),
('mision', 'Nuestra misión', 'Brindar distribución responsable de pollitos bebés, acompañando a cada cliente con asesoría cercana, cumplimiento y atención personalizada.', NULL, 'activo'),
('vision', 'Nuestra visión', 'Ser un aliado confiable para granjas y negocios avícolas, reconocidos por la calidad del producto y la excelencia en cada entrega.', NULL, 'activo'),
('contacto', 'Información de contacto', 'Teléfono: (57) 320 513 5667 | Correo: avinova@correo.com', NULL, 'activo'),
('horario', 'Horario de atención', 'Lunes a sábado, de 8:00 a.m. a 5:00 p.m.', NULL, 'activo');

SET FOREIGN_KEY_CHECKS = 1;

-- Nota operativa: las reservas canceladas deben conservarse. Para cancelar, use una
-- transacción que bloquee disponibilidad_semanal (SELECT ... FOR UPDATE), cambie
-- reservas.estado a cancelada, incremente cajas_disponibles, reduzca cajas_reservadas
-- y registre la acción en auditoria_reservas; nunca ejecute DELETE sobre reservas.
-- Para crear reservas, valide cantidad_cajas >= 1 y actualice ambos contadores dentro
-- de la misma transacción para impedir sobreventas concurrentes.
