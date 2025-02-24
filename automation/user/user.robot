# Created by jolmos at 2/22/2025
*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Library    String
Library    BuiltIn

*** Variables ***
${base_url}    http://localhost:8080/api/v3
${username}    None
${id}    0
${id1}    0
${name}    None
${lastname}    None
${password}    TestPwd@123
${phone}    None
${response_username}    None  #Global variable to store the username
${response_password}    None  #Global variable to store the username
${update_username}    None  #Global variable to store the update username

*** Keywords ***
Generate_random_data
    #This value is used to randomly scroll through the objects in the lists.
    ${random_id1}  Evaluate    random.randint(0, 9)    modules=random
    Set Global Variable    ${id1}    ${random_id1}

    #Names list
    ${names}  Create List  Alice  Bob  Charlie  David  Emma  Joe  Kevin  Tom  Marie  Zoe
    ${random_name}  Get From List     ${names}    ${id1}

    #Lastnames list
    ${lastnames}  Create List  Jones  Smith  Williams  Brown  Miller  Davis  Cruse  Wilson  Anderson  Stone
    ${random_lastname}  Get From List  ${lastnames}    ${id1}

    #Random user ID
    ${random_id}  Evaluate    random.randint(10, 99)    modules=random

    #Random username
    ${random_username}  Generate Random String    4    [NUMBERS]

    #Random phone number
    ${random_phone}    Generate Random String  9    [NUMBERS]

    Set Global Variable    ${username}    ${random_username}
    Set Global Variable    ${id}    ${random_id}
    Set Global Variable    ${name}    ${random_name}
    Set Global Variable    ${lastname}    ${random_lastname}
    Set Global Variable    ${phone}    ${random_phone}

    # Return user data as dictionary
    ${user_data}  Create Dictionary
    ...    id=${random_id}
    ...    username=user${random_username}
    ...    firstName=${random_name}
    ...    lastName=${random_lastname}
    ...    email=user@test.com
    ...    password=${password}
    ...    phone=${random_phone}
    ...    userStatus=1
    RETURN    ${user_data}


Generate_multiple_users
    #This function is used to generate x users
    ${users}  Create List
    FOR    ${i}  IN RANGE    3
        ${user_data}  Generate_random_data
        Append To List    ${users}    ${user_data}
    END
    RETURN    ${users}

    #Log to console    Name: ${users}
    #Log to console    Lastname: ${random_lastname}
    #Log to console    ID: ${random_id}
    #Log to console    Username: ${random_username}
    #Log to console    Phone: ${random_phone}

*** Test Cases ***
Test_Case_01
    [Documentation]    Create a new user (200)
    ${user_data}  Generate_random_data
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${response}    POST On Session    api    /user    json=${user_data}   headers=${header}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200
    #Log to console    ${response.status_code}
    #Log to console    ${response.content}

    # Save response
    ${response_username}  Get From Dictionary  ${user_data}  username
    ${response_password}  Get From Dictionary  ${user_data}  password
    Set Global Variable    ${response_username}
    Set Global Variable    ${response_password}

Test_Case_02
    [Documentation]    Get User by username (200)
    Create Session  api  ${base_url}
    ${response}=  GET On Session    api  /user/${response_username}

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200
    #Log  ${response.json()}

Test_Case_03
    [Documentation]    User Login (200)
    Create Session  api  ${base_url}
    ${path}    Set Variable    /user/login?username=${response_username}&password=${response_password}
    ${response}=  GET On Session    api  ${path}

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200

Test_Case_04
    [Documentation]    User Logout (200)
    Create Session  api  ${base_url}
    ${response}=  GET On Session    api  /user/logout

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200

Test_Case_05
    [Documentation]    Update User (200)
    ${user_data}  Generate_random_data
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${response}    PUT On Session    api    /user/${response_username}    json=${user_data}   headers=${header}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200
    #Log to console    ${response.status_code}
    #Log to console    ${response.content}

    # Save username response
    ${update_username}  Get From Dictionary  ${user_data}  username
    Set Global Variable    ${update_username}

Test_Case_06
    [Documentation]    User not Found by previous username (404)
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Not Found*    GET On Session    api    /user/${response_username}

    #Validations
    Should Contain    ${error_message}    404

Test_Case_07
    [Documentation]    User not Update by previous username (404)
    ${user_data}  Generate_random_data
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Not Found*    PUT On Session    api    /user/${response_username}    json=${user_data}

    #Validations
    Should Contain    ${error_message}    404

Test_Case_08
    [Documentation]    Delete User (200)
    Create Session  api  ${base_url}
    ${response}=  DELETE On Session     api  /user/${update_username}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200

Test_Case_09
    [Documentation]    Create 3 new users from list (200)
    ${users_data}  Generate_multiple_users
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    # Send list of users as JSON array
    ${response}    POST On Session    api    /user/createWithList    json=${users_data}   headers=${header}
    #Log to console  ${users_data}

    # Validations
    Should Be Equal As Strings    ${response.status_code}    200
    #Log to console    ${response.status_code}
    #Log to console    ${response.content}