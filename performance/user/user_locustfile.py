import random
import string
from locust import HttpUser, task, between


def generate_random_user():
    """Generate random data for a user"""
    first_names = ["Alice", "Bob", "Charlie", "David", "Emma", "Joe", "Kevin", "Tom", "Marie", "Zoe"]
    last_names = ["Jones", "Smith", "Williams", "Brown", "Miller", "Davis", "Cruse", "Wilson", "Anderson", "Stone"]

    return {
        "id": random.randint(10, 99),
        "username": f"user{random.randint(1000, 9999)}",
        "firstName": random.choice(first_names),
        "lastName": random.choice(last_names),
        "email": "user@test.com",
        "password": "TestPwd@123",
        "phone": "".join(random.choices(string.digits, k=9)),
        "userStatus": 1
    }

class UserBehavior(HttpUser):
    wait_time = between(1, 5)  # Random wait time between requests (seconds)
    base_url = "/api/v3"

    @task(1)
    def create_user(self):
        """Create User"""
        user_data = generate_random_user()
        response = self.client.post(f"{self.base_url}/user", json=user_data)
        if response.status_code == 200:
            self.username = user_data["username"]
            self.password = user_data["password"]

    @task(2)
    def get_user(self):
        """Get User"""
        if hasattr(self, "username"):
            self.client.get(f"{self.base_url}/user/{self.username}")

    @task(3)
    def login_user(self):
        """User Login"""
        if hasattr(self, "username") and hasattr(self, "password"):
            self.client.get(f"{self.base_url}/user/login?username={self.username}&password={self.password}")

    @task(4)
    def logout_user(self):
        """User Logout"""
        self.client.get(f"{self.base_url}/user/logout")

    @task(5)
    def update_user(self):
        """Update User"""
        if hasattr(self, "username"):
            updated_data = generate_random_user()
            response = self.client.put(f"{self.base_url}/user/{self.username}", json=updated_data)
            if response.status_code == 200:
                self.username = updated_data["username"]

    @task(6)
    def create_multiple_users(self):
        """Create users by list"""
        users_data = [generate_random_user() for _ in range(3)]
        self.client.post(f"{self.base_url}/user/createWithList", json=users_data)

    '''
    @task(7)
    def delete_user(self):
        """Delete User"""
        if hasattr(self, "username"):
            self.client.delete(f"{self.base_url}/user/{self.username}")
    '''