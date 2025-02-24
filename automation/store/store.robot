# Created by jolmos at 2/23/2025
*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Library    String
Library    BuiltIn
Library    DateTime

*** Variables ***
${base_url}    http://localhost:8080/api/v3
${id}    0
${quantity}    0
${date}    ${None}
${response_orderId}    None  #Global variable to store the order ID


*** Keywords ***
Generate_random_data
    #Random Order ID
    ${random_id}  Evaluate    random.randint(1, 99)    modules=random

    #Random quantity number
    ${random_quantity}  Evaluate    random.randint(0, 99)    modules=random

    #This value is used to randomly scroll through the objects in the lists.
    ${random_status_id}  Evaluate    random.randint(0, 2)    modules=random
    Set Global Variable    ${status_id}    ${random_status_id}

    #Status list
    ${status_list}  Create List  approved  placed  delivered
    ${random_status}  Get From List     ${status_list}    ${status_id}

    #Date formatted
    ${date_utc}    Evaluate    __import__('datetime').datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3] + 'Z'

    Set Global Variable    ${id}    ${random_id}
    Set Global Variable    ${quantity}    ${random_quantity}
    Set Global Variable    ${status}    ${random_status}
    Set Global Variable    ${date}    ${date_utc}


    # Return user data as dictionary
    ${store_data}  Create Dictionary
    ...    id=${id}
    ...    petId=198772
    ...    quantity=${random_quantity}
    ...    shipDate=${date}
    ...    status=${status}
    ...    complete=true
    RETURN    ${store_data}

#JSON update function
Update_json_values
    [Arguments]    ${data}    ${key}    ${new_value}
    Set To Dictionary    ${data}    ${key}=${new_value}
    RETURN    ${data}


*** Test Cases ***
Test_Case_01
    [Documentation]    Get quantity pet inventory by status (200)
    Create Session  api  ${base_url}
    ${response}=  GET On Session    api  /store/inventory

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200
    #Log to console    ${response.content}

Test_Case_02
    [Documentation]    Post Pet Order (200)
    ${store_data}  Generate_random_data
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${response}    POST On Session    api    /store/order    json=${store_data}   headers=${header}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200
    #Log to console    ${response.status_code}
    #Log to console    ${response.content}

    # Save response
    ${response_orderId}  Get From Dictionary  ${store_data}  id
    Set Global Variable    ${response_orderId}

Test_Case_03
    [Documentation]    Post Pet Order Input Error (400)
    ${store_data}  Generate_random_data
    #Update JSON with invalid input
    ${store_data}  Update_json_values  ${store_data}  shipDate  string
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    POST On Session    api    /store/order    json=${store_data}   headers=${header}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_04
    [Documentation]    Get order by ID (200)
    Create Session  api  ${base_url}
    ${response}=  GET On Session    api  /store/order/${response_orderId}

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200
    #Log to console    ${response.content}

Test_Case_05
    [Documentation]    Get Order not found (404)
    ${response_orderId1}  Evaluate    ${response_orderId} + 1
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Not Found*    GET On Session    api    /store/order/${response_orderId1}

    #Validations
    Should Contain    ${error_message}    404

Test_Case_06
    [Documentation]    Get Order Input Error (400)
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    GET On Session    api    /store/order/1_${response_orderId}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_07
    [Documentation]    Delete Order (200)
    Create Session  api  ${base_url}
    ${response}=  DELETE On Session     api  /store/order/${response_orderId}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200

Test_Case_08
    [Documentation]    Delete Order not found (404)
    #Expected error did not occur.
    ${response_orderId1}  Evaluate    ${response_orderId} + 1
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Not Found*  DELETE On Session     api  /store/order/${response_orderId1}

    #Validations
    Should Contain    ${error_message}    404

Test_Case_09
    [Documentation]    Delete Order Input Error (400)
    Create Session  api  ${base_url}
   ${error_message}=    Run Keyword And Expect Error    *Bad Request*  DELETE On Session     api  /store/order/1_${response_orderId}

    #Validations
    Should Contain    ${error_message}    400
