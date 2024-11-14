from flask import Blueprint, request, jsonify
from app.services.studentvue_service import StudentVueService

api_bp = Blueprint('api', __name__)

@api_bp.route('/assignments', methods=['POST'])
def get_assignments():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    school_url = data.get('school_url')

    service = StudentVueService(username, password, school_url)
    assignments = service.get_assignments()
    return jsonify(assignments)
