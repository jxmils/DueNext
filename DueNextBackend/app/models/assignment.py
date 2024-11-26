from app.extensions import db

class Assignment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(120), nullable=False)
    due_date = db.Column(db.Date, nullable=False)
    subject = db.Column(db.String(80), nullable=False)
    description = db.Column(db.Text, nullable=True)

    def __repr__(self):
        return f"<Assignment {self.title}>"
