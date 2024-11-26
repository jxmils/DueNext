import pytest
from app import create_app

@pytest.fixture
def app():
    app = create_app()
    app.config["TESTING"] = True
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"
    return app

def test_get_assignments(client):
    response = client.get("/api/assignments")
    assert response.status_code == 200
