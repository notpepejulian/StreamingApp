**Plataforma de streaming autohospedada** con catálogo personalizado, autenticación segura y soporte para multiperfiles. Desarrollada con Python (Flask), PostgreSQL, Docker y Nginx.

## 🌟 Características
- **Reproducción en streaming** (MP4, HLS)
- **Gestión de contenido**: Películas, series, episodios
- **Multiperfil**: Soporte para varios usuarios/niños
- **Metadatos completos**: Géneros, año, duración, etc.
- **Descarga offline** de contenido
- **Autenticación segura** con JWT
- **Dockerizado**: Fácil despliegue

## 🛠️ Tecnologías
| Componente       | Tecnología                |
|------------------|---------------------------|
| Backend          | Python + Flask            |
| Base de Datos    | PostgreSQL                |
| Frontend         | HTML5, CSS3, JavaScript   |
| Streaming        | Nginx + FFmpeg            |
| Contenedores     | Docker + Docker Compose   |

## 🚀 Instalación
### Requisitos
- Docker 20+
- Docker Compose 2.2+

### Pasos rápidos
1. Clonar repositorio:
   ```bash
   git clone https://github.com/tu-usuario/mi-netflix-privado.git
   cd mi-netflix-privado
   ```

2. Configurar entorno:
   ```bash
   cp .env.example .env
   # Editar .env (credenciales DB, secrets)
   ```

3. Iniciar servicios:
   ```bash
   docker-compose up -d --build
   ```

## 📂 Estructura del Proyecto
```
mi-netflix-privado/
├── docker-compose.yml    # Configuración de servicios
├── backend/             # Código Flask
├── frontend/            # Interfaz web
├── nginx/               # Configuración de streaming
└── db/                  # Scripts SQL iniciales
```

## 🔒 Variables de Entorno
Archivo `.env` requerido:
```ini
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=dbname
JWT_SECRET_KEY=tu_super_secreto_aqui
```

## 📌 Uso Básico
1. Accede a la web: `http://localhost:8000`
2. Inicia sesión con:
   - Usuario: `admin@example.com`
   - Contraseña: `admin123`
3. Sube contenido a `/var/www/videos` (vía Docker volumes)

## 🐛 Solución de Problemas
- **PostgreSQL no inicia**:
  ```bash
  docker logs streaming_db
  ```
- **Puertos ocupados**:
  ```bash
  sudo lsof -i :8000 | awk 'NR!=1 {print $2}' | xargs kill -9
  ```
