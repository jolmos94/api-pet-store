from locust import HttpUser, task, between
import random
import json
from faker import Faker

fake = Faker()


def create_random_pet():
    """Generate random data"""
    categories = {"Dogs": 1, "Cats": 2, "Rabbits": 3, "Lions": 4, "Fishes": 5}
    tags = {"tag1": 1, "tag2": 2, "tag3": 3, "tag4": 4, "tag5": 5}

    category_name, category_id = random.choice(list(categories.items()))
    tag_name, tag_id = random.choice(list(tags.items()))

    pet_data = {
        "id": random.randint(11, 99),
        "name": fake.first_name(),
        "category": {"id": category_id, "name": category_name},
        "photoUrls": ["string"],
        "tags": [{"id": tag_id, "name": tag_name}],
        "status": random.choice(["available", "pending", "sold"])
    }
    return pet_data


class PetstoreUser(HttpUser):
    wait_time = between(1, 5)  # Random wait time between requests (seconds)
    base_url = "/api/v3"

    def on_start(self):
        """Execute when a new user start"""
        self.headers = {"Content-Type": "application/json"}
        self.pet_id = None

    @task(1)
    def post_pet(self):
        """Create Pet"""
        pet_data = create_random_pet()
        response = self.client.post(f"{self.base_url}/pet", json=pet_data, headers=self.headers)

        if response.status_code == 200:
            self.pet_id = pet_data["id"]
            print(f"Pet created: ID {self.pet_id}")
        else:
            print(f"Error creating pet: {response.status_code}")

    @task(2)
    def get_pet_by_id(self):
        """Get Pet by ID"""
        if self.pet_id:
            response = self.client.get(f"{self.base_url}/pet/{self.pet_id}")
            print(f"Get Pet Response: {response.status_code}")

    @task(3)
    def get_pets_by_status(self):
        """Get Pets by Status"""
        status = random.choice(["available", "pending", "sold"])
        response = self.client.get(f"{self.base_url}/pet/findByStatus?status={status}")
        print(f"Get Pets by Status {status}: {response.status_code}")

    @task(4)
    def get_pets_by_tags(self):
        """Get Pets by Tags"""
        tags = ["tag1", "tag2", "tag3"]
        tag_url = "&".join([f"tags={tag}" for tag in tags])
        response = self.client.get(f"{self.base_url}/pet/findByTags?{tag_url}")
        print(f"Get Pets by Tags Response: {response.status_code}")

    @task(5)
    def update_pet(self):
        """Update Pet"""
        if self.pet_id:
            updated_pet = create_random_pet()
            updated_pet["id"] = self.pet_id  # Keep same ID
            response = self.client.put(f"{self.base_url}/pet", json=updated_pet, headers=self.headers)
            print(f"Update Pet Response: {response.status_code}")

    @task(6)
    def update_pet_with_form_data(self):
        """Update Pet with Form Data"""
        if self.pet_id:
            data = {"name": "UpdatedName", "status": "sold"}
            response = self.client.post(f"{self.base_url}/pet/{self.pet_id}", data=data)
            print(f"Update Pet with Form Data: {response.status_code}")

    @task(7)
    def upload_pet_image(self):
        """Upload Image"""
        if self.pet_id:
            files = {"file": ("image.jpg", open("image.jpg", "rb"), "image/jpeg")}
            response = self.client.post(f"{self.base_url}/pet/{self.pet_id}/uploadImage", files=files)
            print(f"Upload Pet Image: {response.status_code}")

    '''
    @task(8)
    def delete_pet(self):
        """Delete Pet"""
        if self.pet_id:
            response = self.client.delete(f"{self.base_url}/pet/{self.pet_id}")
            print(f"Delete Pet Response: {response.status_code}")
            self.pet_id = None  # Reset ID after delete operation
    '''