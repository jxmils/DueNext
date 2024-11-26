from studentvue import StudentVue

# Replace with actual credentials and domain
username = "luceroalexa"
password = "lcps262098"
district_domain = "https://nm-lcps-psv.edupoint.com"  # Example domain

# Create an instance of StudentVue
studentvue = StudentVue(username, password, district_domain)
gradebook = studentvue.get_gradebook()  # Specify the report period
print(gradebook)
