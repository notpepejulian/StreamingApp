-- 1. Tabla de usuarios (autenticación)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

-- 2. Tabla de perfiles (multi-perfil por usuario)
CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    avatar_url VARCHAR(512),
    is_child BOOLEAN DEFAULT FALSE,
    language VARCHAR(10) DEFAULT 'es'
);

-- 3. Tabla de contenido principal (abstracta)
CREATE TABLE content (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INTEGER,
    duration_minutes INTEGER,
    cover_image_url VARCHAR(512),
    background_image_url VARCHAR(512),
    content_rating VARCHAR(10), -- PG, R, etc.
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

-- 4. Tabla de películas
CREATE TABLE movies (
    content_id INTEGER PRIMARY KEY REFERENCES content(id) ON DELETE CASCADE,
    director VARCHAR(255),
    trailer_url VARCHAR(512)
);

-- 5. Tabla de series
CREATE TABLE series (
    content_id INTEGER PRIMARY KEY REFERENCES content(id) ON DELETE CASCADE,
    total_seasons INTEGER DEFAULT 1
);

-- 6. Tabla de temporadas
CREATE TABLE seasons (
    id SERIAL PRIMARY KEY,
    series_id INTEGER REFERENCES series(content_id) ON DELETE CASCADE,
    season_number INTEGER NOT NULL,
    title VARCHAR(255),
    overview TEXT,
    poster_url VARCHAR(512)
);

-- 7. Tabla de episodios
CREATE TABLE episodes (
    id SERIAL PRIMARY KEY,
    season_id INTEGER REFERENCES seasons(id) ON DELETE CASCADE,
    episode_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    file_path VARCHAR(512) NOT NULL,
    duration_minutes INTEGER,
    aired_date DATE,
    UNIQUE(season_id, episode_number)
);

-- 8. Tabla de géneros
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- 9. Relación contenido-géneros (many-to-many)
CREATE TABLE content_genres (
    content_id INTEGER REFERENCES content(id) ON DELETE CASCADE,
    genre_id INTEGER REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, genre_id)
);

-- 10. Tabla de archivos multimedia (diferentes calidades/formatos)
CREATE TABLE media_files (
    id SERIAL PRIMARY KEY,
    content_id INTEGER REFERENCES content(id) ON DELETE CASCADE,
    file_path VARCHAR(512) NOT NULL,
    file_type VARCHAR(10) NOT NULL, -- mp4, mkv, etc.
    quality VARCHAR(10) NOT NULL, -- 1080p, 4K, etc.
    codec VARCHAR(20),
    size_mb INTEGER,
    is_downloadable BOOLEAN DEFAULT TRUE
);

-- 11. Tabla de progreso de visualización
CREATE TABLE watch_history (
    profile_id INTEGER REFERENCES profiles(id) ON DELETE CASCADE,
    content_id INTEGER REFERENCES content(id) ON DELETE CASCADE,
    progress_minutes INTEGER NOT NULL,
    last_watched TIMESTAMP DEFAULT NOW(),
    is_completed BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (profile_id, content_id)
);

-- 12. Tabla de favoritos
CREATE TABLE favorites (
    profile_id INTEGER REFERENCES profiles(id) ON DELETE CASCADE,
    content_id INTEGER REFERENCES content(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (profile_id, content_id)
);

-- 13. Tabla de logs de descargas
CREATE TABLE downloads (
    id SERIAL PRIMARY KEY,
    profile_id INTEGER REFERENCES profiles(id) ON DELETE SET NULL,
    media_file_id INTEGER REFERENCES media_files(id) ON DELETE SET NULL,
    downloaded_at TIMESTAMP DEFAULT NOW(),
    device_info VARCHAR(255)
);

-- 14. Tabla de subtítulos
CREATE TABLE subtitles (
    id SERIAL PRIMARY KEY,
    content_id INTEGER REFERENCES content(id) ON DELETE CASCADE,
    language VARCHAR(10) NOT NULL,
    file_path VARCHAR(512) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE
);

-- Insertar géneros básicos
INSERT INTO genres (name) VALUES 
('Acción'), ('Aventura'), ('Comedia'), ('Drama'), 
('Ciencia Ficción'), ('Terror'), ('Romance'), ('Documental');