import logging
import requests
from zeep import Client
from zeep.plugins import HistoryPlugin

logging.basicConfig(level=logging.DEBUG)

class StudentVueService:
    def __init__(self, username, password, school_url):
        self.username = username
        self.password = password
        self.school_url = school_url.rstrip("/")  # Ensure no trailing slash

        # SOAP endpoint
        self.endpoint = f"{self.school_url}/Service/PXPCommunication.asmx"

        # Initialize zeep client with history plugin for debugging
        self.history = HistoryPlugin()
        self.client = Client(f"{self.endpoint}?wsdl", plugins=[self.history])

    def get_gradebook_zeep(self):
        """
        Fetch gradebook details using the zeep library.
        """
        try:
            logging.debug(f"Authenticating user {self.username} at {self.school_url}")
            
            # Perform SOAP call using zeep
            response = self.client.service.ProcessWebServiceRequest(
                userID=self.username,
                password=self.password,
                skipLoginLog=True,
                parent=False,
                webServiceHandleName="PXPWebServices",
                methodName="Gradebook",
                paramStr="<Parms><ChildIntID>0</ChildIntID></Parms>"
            )
            
            logging.debug(f"Response: {response}")
            return response
        except Exception as e:
            logging.error(f"Error in SOAP request using zeep: {e}")
            raise

    def get_gradebook_requests(self):
        """
        Fetch gradebook details using the requests library with raw XML payload.
        """
        payload = f"""<?xml version="1.0" encoding="utf-8"?>
        <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
          <soap12:Body>
            <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
              <userID>{self.username}</userID>
              <password>{self.password}</password>
              <skipLoginLog>true</skipLoginLog>
              <parent>false</parent>
              <webServiceHandleName>PXPWebServices</webServiceHandleName>
              <methodName>Gradebook</methodName>
              <paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr>
            </ProcessWebServiceRequest>
          </soap12:Body>
        </soap12:Envelope>"""

        headers = {
            "Content-Type": "application/soap+xml; charset=utf-8"
        }

        try:
            logging.debug(f"Sending raw SOAP request to {self.endpoint}")
            
            response = requests.post(self.endpoint, data=payload, headers=headers)
            response.raise_for_status()
            
            logging.debug(f"Response status: {response.status_code}")
            logging.debug(f"Response content: {response.text}")
            return response.text
        except requests.exceptions.RequestException as e:
            logging.error(f"Error in SOAP request using requests: {e}")
            raise

    def get_gradebook(self, method="zeep"):
        """
        Wrapper to fetch gradebook details using the specified method.
        :param method: 'zeep' (default) or 'requests'
        :return: Raw XML response as a string.
        """
        if method == "zeep":
            return self.get_gradebook_zeep()
        elif method == "requests":
            return self.get_gradebook_requests()
        else:
            raise ValueError("Invalid method. Use 'zeep' or 'requests'.")
