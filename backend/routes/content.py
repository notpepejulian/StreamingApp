from flask import Blueprint, jsonify
from models import Content, db

content_bp = Blueprint('content', __name__)

@content_bp.route('/movies', methods=['GET'])
def get_movies():
    movies = Content.query.join(Movie).all()
    return jsonify([{'id': m.id, 'title': m.title} for m in movies])