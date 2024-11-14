from zeep import Client

class StudentVueService:
    def __init__(self, username, password, school_url):
        self.username = username
        self.password = password
        self.school_url = school_url
        self.client = Client(f"{school_url}/Service/ParentPortal.svc?wsdl")

    def get_assignments(self):
        try:
            response = self.client.service.ProcessWebServiceRequest(
                userID=self.username,
                password=self.password,
                skipLoginCheck=False,
                webServiceHandleName='PXPWebServices',
                methodName='Gradebook',
                paramStr='{}'
            )
            return response
        except Exception as e:
            return {'error': str(e)}
