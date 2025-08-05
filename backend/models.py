from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Content(db.Model):
    __tablename__ = 'content'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    # ... (añade todos los campos de tu tabla 'content')

class Movie(db.Model):
    __tablename__ = 'movies'
    id = db.Column(db.Integer, primary_key=True)
    content_id = db.Column(db.Integer, db.ForeignKey('content.id'), unique=True)
    director = db.Column(db.String(255))
    # ... (resto de campos)