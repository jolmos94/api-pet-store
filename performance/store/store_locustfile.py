from locust import HttpUser, task, between
import random
from datetime import datetime


def generate_random_data():
    """Generate random data"""
    random_id = random.randint(1, 99)  # Random Order ID
    random_quantity = random.randint(0, 99)  # Random quantity number
    random_status_id = random.randint(0, 2)  # Random status ID
    status_list = ["approved", "placed", "delivered"]
    random_status = status_list[random_status_id]

    date_utc = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'  # Date format

    return {
        "id": random_id,
        "petId": 198772,
        "quantity": random_quantity,
        "shipDate": date_utc,
        "status": random_status,
        "complete": True
    }


class UserAPITest(HttpUser):
    wait_time = between(1, 5)  # Random wait time between requests (seconds)

    # Variables
    base_url = "/api/v3"
    response_orderId = None  # Variable to store OrderID

    @task(1)
    def test_case_01(self):
        """Get quantity pet inventory by status"""
        self.client.get(f"{self.base_url}/store/inventory")

    @task(2)
    def test_case_02(self):
        """Post Pet Order"""
        store_data = generate_random_data()
        headers = {"Content-Type": "application/json"}

        with self.client.post(f"{self.base_url}/store/order", json=store_data, headers=headers, catch_response=True) as response:
            if response.status_code == 200:
                response.success()
                # Save response orderId
                self.response_orderId = store_data["id"]
            else:
                response.failure(f"Error {response.status_code}")

    @task(3)
    def test_case_03(self):
        """Get order by ID"""
        if self.response_orderId is None:
            return

        with self.client.get(f"{self.base_url}/store/order/{self.response_orderId}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Error {response.status_code}")

    '''
    @task(4)
    def test_case_04(self):
        """Delete Order"""
        if self.response_orderId is None:
            return

        with self.client.delete(f"{self.base_url}/store/order/{self.response_orderId}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Error {response.status_code}")
    '''