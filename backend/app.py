from flask import Flask
from flask_migrate import Migrate
from models import db, Content
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)
migrate = Migrate(app, db)  # Para migraciones con Flask-Migrate

# Registra blueprints (ejemplo)
from routes.content import content_bp
app.register_blueprint(content_bp, url_prefix='/api/content')

@app.route('/')
def home():
    return "Bienvenido a tu Netflix Privado!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)