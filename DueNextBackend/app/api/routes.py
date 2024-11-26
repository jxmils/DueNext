from flask import Blueprint, request, jsonify
from app.services.studentvue_service import StudentVueService
import xml.etree.ElementTree as ET
import logging

logging.basicConfig(level=logging.INFO)

api_bp = Blueprint("api", __name__)

@api_bp.route("/gradebook", methods=["POST"])
def get_gradebook():
    """
    Endpoint to fetch gradebook details, including assignments.
    """
    try:
        data = request.json or {}

        username = data.get("username")
        password = data.get("password")
        school_url = data.get("school_url")

        if not all([username, password, school_url]):
            return jsonify({"error": "Missing required fields"}), 400

        # Call the StudentVueService to fetch gradebook data
        service = StudentVueService(username, password, school_url)
        raw_response = service.get_gradebook()  # Get the raw XML response
        
        # Log the raw XML response
        logging.info(f"Raw Response: {raw_response}")

        # Parse the XML response
        assignments = parse_gradebook(raw_response)

        return jsonify({"assignments": assignments}), 200

    except Exception as e:
        logging.error(f"Error: {e}")
        return jsonify({"error": "An unexpected error occurred", "details": str(e)}), 500


def parse_gradebook(xml_response):
    """
    Parses the raw XML response and returns a structured list of assignments.
    :param xml_response: Raw XML response as a string.
    :return: List of structured assignment details.
    """
    assignments_list = []
    try:
        root = ET.fromstring(xml_response)
        for course in root.findall(".//Course"):
            course_title = course.attrib.get("Title")
            course_name = course.attrib.get("CourseName")
            grade = course.find(".//Mark").attrib.get("CalculatedScoreString", "Not Graded")

            for assignment in course.findall(".//Assignment"):
                assignment_name = assignment.attrib.get("Measure", "Unknown Assignment")
                due_date = assignment.attrib.get("DueDate", "No Due Date")
                score = assignment.attrib.get("DisplayScore", "No Score")
                
                assignments_list.append({
                    "assignment_name": assignment_name,
                    "class_name": course_name,
                    "class_title": course_title,
                    "grade": grade,
                    "due_date": due_date,
                    "score": score
                })
    except ET.ParseError as e:
        logging.error(f"Error parsing XML: {e}")
        return []

    return assignments_list
