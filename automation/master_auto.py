# Created by jolmos at 2/23/2025
#Master script file, created to automate the execution of the test cases per module.
import subprocess
import os

# Get the base directory where the Master script is located
base_dir = os.path.dirname(os.path.abspath(__file__))

# Define the relative paths of Robot scripts
robot_scripts = {
    "user": os.path.join(base_dir, "user", "user.robot"),
    "store": os.path.join(base_dir, "store", "store.robot"),
    "pet": os.path.join(base_dir, "pet", "pet.robot")
}

# Global function that receives the key of the test module to run
def run_robot_script(key):
    # Check if the script key exists in the dictionary
    if key not in robot_scripts:
        print(f"Error: Script '{key}' Not found.")
        return

    # Get the path of the Robot script to execute
    robot_script_path = robot_scripts[key]

    # Folder to save reports(same folder of Robot script)
    report_dir = os.path.dirname(robot_script_path)

    # Build the Robot command to execute the script
    command = [
        "robot",  # Call Robot command
        "--outputdir", report_dir,  # Set report folder
        robot_script_path  # Robot script path
    ]

    # Run Robot script
    result = subprocess.run(command, capture_output=True, text=True)

    # Log Robot output in the console
    print(result.stdout)
    print(result.stderr)

    # Check result command
    if result.returncode == 0:
        print("Robot script executed successfully.")
    else:
        print(f"Error to execute Robot script. Error message: {result.returncode}")


if __name__ == "__main__":
    # Prompt user to enter the script key
    robot_script_key = input("Enter Robot script key to run (user, store, pet): ").strip()

    # Run Robot script with key
    run_robot_script(robot_script_key)
