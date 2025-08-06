from flask import Blueprint, jsonify, request
from models import Content, db
import requests
import os
from functools import wraps

content_bp = Blueprint('content', __name__)

# Helper para manejar errores de API
def handle_api_errors(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except requests.exceptions.RequestException as e:
            return jsonify({
                "error": "Error de conexión con servicio externo",
                "details": str(e)
            }), 502
        except Exception as e:
            return jsonify({
                "error": "Error interno del servidor",
                "details": str(e)
            }), 500
    return wrapper

@content_bp.route('/movies', methods=['GET'])
@handle_api_errors
def get_movies():
    """Obtiene películas desde la base de datos local con paginación"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    movies = Content.query.filter_by(media_type='movie').paginate(
        page=page,
        per_page=per_page,
        error_out=False
    )
    
    return jsonify({
        "data": [{
            'id': m.id,
            'title': m.title,
            'year': m.release_year,
            'poster': m.cover_image_url,
            'available': m.file_path is not None
        } for m in movies.items],
        "total": movies.total,
        "page": movies.page
    })

@content_bp.route('/search', methods=['GET'])
@handle_api_errors
def search():
    """Búsqueda unificada en Jellyseerr"""
    query = request.args.get('q', '').strip()
    if not query or len(query) < 3:
        return jsonify({"error": "Query debe tener al menos 3 caracteres"}), 400
        
    params = {
        'query': query,
        'page': request.args.get('page', 1),
        'language': request.args.get('lang', os.getenv('DEFAULT_LANGUAGE', 'es'))
    }
    
    # Filtro por tipo si se especifica
    if media_type := request.args.get('type'):
        params['mediaType'] = media_type
    
    response = requests.get(
        f"{os.getenv('JELLYSEERR_URL')}/api/v1/search",
        params=params,
        headers={"X-Api-Key": os.getenv('JELLYSEERR_API_KEY')}
    )
    response.raise_for_status()
    
    return jsonify(response.json())

@content_bp.route('/request', methods=['POST'])
@handle_api_errors
def request_content():
    """Solicitud de contenido con validación mejorada"""
    REQUIRED_FIELDS = ['type', 'title']
    data = request.get_json() or {}
    
    if missing := [field for field in REQUIRED_FIELDS if field not in data]:
        return jsonify({
            "error": f"Campos faltantes: {', '.join(missing)}"
        }), 400
    
    payload = {
        "mediaType": data['type'],
        "title": data['title'],
        "tmdbId": data.get('tmdbId'),
        "year": data.get('year'),
        "requestedBy": request.remote_addr  # O usar usuario autenticado
    }
    
    response = requests.post(
        f"{os.getenv('JELLYSEERR_URL')}/api/v1/request",
        json=payload,
        headers={"X-Api-Key": os.getenv('JELLYSEERR_API_KEY')}
    )
    response.raise_for_status()
    
    return jsonify({
        "success": True,
        "request_id": response.json().get('id'),
        "status_url": f"/api/requests/{response.json().get('id')}"
    })

@content_bp.route('/status/<int:request_id>', methods=['GET'])
@handle_api_errors
def request_status(request_id):
    """Verifica el estado de una solicitud"""
    response = requests.get(
        f"{os.getenv('JELLYSEERR_URL')}/api/v1/request/{request_id}",
        headers={"X-Api-Key": os.getenv('JELLYSEERR_API_KEY')}
    )
    response.raise_for_status()
    
    return jsonify(response.json())