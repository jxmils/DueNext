from flask import Flask
from app.config import Config
from app.extensions import db, migrate, ma, jwt
from app.api import api_bp

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    ma.init_app(app)
    jwt.init_app(app)

    # Register blueprints
    app.register_blueprint(api_bp, url_prefix="/api")

    return app
