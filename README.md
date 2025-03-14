# QA Challenge API Petstore

## Overview
This is the API test automation and performance test solution developed for the pet store sample hosted at https://petstore3.swagger.io.

The solution is composed of a separate folder containing the test automation implementation and a separate folder for the performance test implementation.

### Pre-requisites
To execute this project you need at least __Python 3.9__ or higher.

In addition, before running this project, make sure you have the following packages installed:

#### • Install Robot Framework
```
pip install robotframework


# Additional packages

pip install robotframework-requests
pip install robotframework-jsonlibrary
pip install robotframework-jsonvalidator
```

#### • Install Locust Framework
```
# Locust with Library for HTTP requests

pip install locust requests faker
```


## 1. API Test Automation
This is a python project that use Robot Framework to build a test suite per Petstore API module.  You can find out
more about both the spec and the framework at https://robotframework.org/.

This is the test set covered per module:

<details>
  <summary>User - <i style="opacity: 0.6;">Click to expand</i></summary>

    - TC1: Create a new user (200)
    - TC2: Get User by username (200)
    - TC3: User Login (200)
    - TC4: User Logout (200)
    - TC5: Update User (200)
    - TC6: User not Found by previous username (404)
    - TC7: User not Update by previous username (404)
    - TC8: Delete User (200)
    - TC9: Create 3 new users from list (200)  

</details>
<details>
  <summary>Store - <i style="opacity: 0.6;">Click to expand</i></summary>

    - TC1: Get quantity per inventory by status (200)
    - TC2: Post Pet Order (200)
    - TC3: Post Pet Order Input Error (400)
    - TC4: Get Order by ID (200)
    - TC5: Get Order not found (404)
    - TC6: Get Order Input Error (400)
    - TC7: Delete Order (200)
    - TC8: Delete Order not found (404)
    - TC9: Delete Order Input Error (400)  

</details>

<details>
  <summary>Pet - <i style="opacity: 0.6;">Click to expand</i></summary>

    - TC1: Post Pet to Store (200)
    - TC2: Post Pet to Store Input Error (400)
    - TC3: Get Pet by ID (200)
    - TC4: Get Pet not found (404)
    - TC5: Get Pet Input Error (400)
    - TC6: Get Pets by Status (200)
    - TC7: Get Pets by Invalid Status (400)
    - TC8: Get Pets by Tags (200)
    - TC9: Get Pets by Invalid Tag value (400)
    - TC10: Put Update Pet by ID (200)
    - TC11: Put Update Pet ID not found (404)
    - TC12: Put Update Pet Input error (400)
    - TC13: Post Update Pet with form data (200)
    - TC14: Post Update Pet Invalid Input (400)
    - TC15: Post Upload Image (200)
    - TC16: Delete Pet (200))
    - TC17: Delete Pet Input Error (400)  

</details>

### To run (Command Prompt)
To run the test suite per module, execute the Master script locate in automation folder:

```
python master_auto.py
```

This will prompt the user to enter the key of the module to be tested:

*Example*:

```
Enter Robot script key to run (user, store, pet): user
```

The modules available for testing are:

```
user
store
pet
```

### Output
The console will print the result of the executed tests, as shown below:

```
==============================================================================
User                                                                          
==============================================================================
Test_Case_01 :: Create a new user (200)                               | PASS |
```

In addition, three types of report files will be saved in the path of each module:

```
Output:  {working_dir}\api-pet-store\automation\user\output.xml
Log:     {working_dir}\api-pet-store\automation\user\log.html
Report:  {working_dir}\api-pet-store\automation\user\report.html
```

## 2. API Performance Test
This is a python project that use Locust Framework to build Load test for Petstore API.  You can find out
more about both the spec and the framework at https://locust.io/.

### To run (Command Prompt)
To run the test suite per module, execute the Master script locate in performance folder:

```
python master_perfo.py
```

This will prompt the user to enter the key of the module to be tested:

*Example*:

```
Enter Locust script key to run (user, store, pet): user
```

The modules available for testing are:

```
user
store
pet
```

You can also run each script directly in the corresponding folder (Recommended method):

*Example*:

```
locust -f .\user_locustfile.py -u 100 -r 10
```
- -u : Number of virtual users.
- -r : Ramp up.

### Output
The console will print as shown below:

```
[2025-02-24 23:23:55,666] ${HOSTNAME{/INFO/locust.main: Starting Locust 2.33.0
[2025-02-24 23:23:55,667] ${HOSTNAME}/INFO/locust.main: Starting web interface at http://localhost:8089, press enter to open your default browser.
```

Then proceed to open the default Locust web portal:  http://localhost:8089

Configure in the web interface the number of users, the ramp up and the host to be evaluated respectively.

![Descripción de la imagen](performance/locust.jpg)