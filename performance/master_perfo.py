import sys
import subprocess
import os

# Get the base directory where the Master script is located
base_dir = os.path.dirname(os.path.abspath(__file__))

# Define the relative paths of Locust scripts
locust_scripts = {
    "user": os.path.join(base_dir, "user", "user_locustfile.py"),
    "store": os.path.join(base_dir, "store", "store_locustfile.py"),
    "pet": os.path.join(base_dir, "pet", "pet_locustfile.py")
}

# Global function that receives the key of the test module to run
def run_locust_script(script_path):
    # Check if the script key exists in the dictionary
    if not os.path.exists(script_path):
        print(f"Error: Locust script {script_path} not found.")
        return

    # Run Locust with provided script
    try:
        subprocess.run(["locust", "-f", script_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing Locust script: {e}")

def main():
    # Check key as argument
    if len(sys.argv) != 2:
        print("Usage: python master_perfo.py <key>")
        sys.exit(1)

    key = sys.argv[1]

    # Get the path of the Locust script to execute
    script_path = locust_scripts.get(key)

    if script_path:
        print(f"Executing Locust script: {script_path}")
        run_locust_script(script_path)
    else:
        print(f"Error: No script found for key '{key}'")

if __name__ == "__main__":
    # Prompt user to enter the script key
    locust_script_key = input("Enter Locust script key to run (user, store, pet): ").strip()

    # Run Robot script with key
    run_locust_script(locust_script_key)
