# Created by t0240334 at 2/24/2025
*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Library    String
Library    BuiltIn
Library    OperatingSystem
Library    json
Library    String

*** Variables ***
${base_url}    http://localhost:8080/api/v3
${id}       0
${name}     None
${category_id}   0
${category_name}    None
${photo_url}  string
${tag_id}    0
${tag_name}  string
${status}    None
${response_petId}    None  #Global variable to store the pet ID
${image_file}    image.jpg
${work_dir}    ${CURDIR}/${image_file}

*** Keywords ***
Create_categories
    # Create category dictionary
    ${categories}    Create Dictionary
    ...    Dogs=1    Cats=2    Rabbits=3    Lions=4    Fishes=5
    ...    Birds=6    Reptiles=7    Rodents=8    Cows=9    Horses=10
    RETURN    ${categories}

Create_tags
    # Create tag dictionary
    ${tags}    Create Dictionary
    ...    tag1=1    tag2=2    tag3=3    tag4=4    tag5=5
    ...    tag6=6    tag7=7    tag8=8    tag9=9    tag10=10
    RETURN    ${tags}

Get_random_data
    [Arguments]    ${dict_name}
    # Get dictionary by the argument
    ${data_dict}    Run Keyword    Create_${dict_name}

    # Select random key
    ${random_key}    Evaluate    random.choice(list($data_dict.keys()))    modules=random

    # Return value
    ${random_value}    Get From Dictionary    ${data_dict}    ${random_key}

    RETURN    ${random_key}    ${random_value}

Create_pet_json
    #Random Order ID
    ${random_id}  Evaluate    random.randint(11, 99)    modules=random

    #This value is used to select random PetName.
    ${random_key1}  Evaluate    random.randint(0, 9)    modules=random
    Set Global Variable    ${key}    ${random_key1}
    #PetNames list
    ${pet_names}  Create List  Benny  Cometa  Rufo  Bambu  Archie  Merlin  Ralf  Milo  Black  White
    ${random_pet_name}  Get From List     ${pet_names}    ${key}

    #This value is used to select random status.
    ${random_status_id}  Evaluate    random.randint(0, 2)    modules=random
    Set Global Variable    ${status_id}    ${random_status_id}
    #Status list
    ${status_list}  Create List  available  pending  sold
    ${random_status}  Get From List     ${status_list}    ${status_id}

    # Random Category
    ${category_name}    ${category_id}    Get_random_data    categories

    # Random Tag
    ${tag_name}    ${tag_id}    Get_random_data    tags

    # Ensure data format for IDs (Category & Tag)
    ${category_id}    Evaluate    int(${category_id})  #Convert to Int
    ${tag_id}    Evaluate    int(${tag_id})  #Convert to Int

    Set Global Variable    ${id}    ${random_id}
    Set Global Variable    ${name}    ${random_pet_name}
    Set Global Variable    ${status}    ${random_status}

    # Ensure JSON structure for Category, Tag & PhotoURL
    ${category_dict}    Create Dictionary   id=${category_id}   name=${category_name}
    ${tag_dict}    Create Dictionary    id=${tag_id}    name=${tag_name}
    ${tags_list}    Create List    ${tag_dict}
    ${photo_urls_list}    Create List    string

    #Generate JSON
    ${pet_dict}    Create Dictionary
    ...    id=${id}
    ...    name=${name}
    ...    category=${category_dict}
    ...    photoUrls=${photo_urls_list}
    ...    tags=${tags_list}
    ...    status=${status}
    # Dict2JSON
    #${pet_json}    Evaluate    __import__('json').dumps(${pet_dict})    modules=json
    #RETURN    ${pet_json}
    RETURN    ${pet_dict}

#JSON update function
Update_json_values
    [Arguments]    ${data}    ${key}    ${new_value}
    Set To Dictionary    ${data}    ${key}=${new_value}
    RETURN    ${data}

#Dict2JSON
Convert_Dict2Json
    [Arguments]    ${dict_data}
    ${json_data}    Evaluate    json.dumps(${dict_data})
    RETURN    ${json_data}

#URL Tags
Create_url_tags
    [Arguments]    ${tags}
    ${url}    Set Variable    ?
    FOR    ${tag}    IN    @{tags}
        ${url}=    Catenate    ${url}    &tags=${tag}
    END
    RETURN    ${url}


*** Test Cases ***
Test_Case_01
    [Documentation]    Post Pet to Store (200)
    ${pet_data}    Create_pet_json
    ${json_pet_data}    Convert_Dict2Json    ${pet_data}
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${response}    POST On Session    api    /pet    data=${json_pet_data}   headers=${header}
    #Log To Console    ${json_pet_data}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200
    #Log to console    ${response.status_code}
    #Log to console    ${response.content}

    # Save response
    ${response_petId}  Get From Dictionary  ${pet_data}  id
    Set Global Variable    ${response_petId}

Test_Case_02
    [Documentation]    Post Pet to Store Input Error (400)
    ${pet_data}    Create_pet_json
    #Update JSON with invalid input
    ${update_pet_data}  Update_json_values  ${pet_data}  id  string
    ${json_update_pet_data}     Convert_Dict2Json    ${update_pet_data}
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    POST On Session    api    /pet    data=${json_update_pet_data}   headers=${header}
    #Log To Console    ${json_update_pet_data}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_03
    [Documentation]    Get Pet by ID (200)
    Create Session  api  ${base_url}
    ${response}=  GET On Session    api  /pet/${response_petId}

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200
    #Log to console    ${response.content}

Test_Case_04
    [Documentation]    Get Pet not found (404)
    ${response_petId1}  Evaluate    ${response_petId} + 1
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Not Found*    GET On Session    api    /pet/${response_petId1}

    #Validations
    Should Contain    ${error_message}    404

Test_Case_05
    [Documentation]    Get Pet Input Error (400)
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    GET On Session    api    /pet/1_${response_petId}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_06
    [Documentation]    Get Pets by Status (200)

    #This value is used to select random status.
    ${random_status_id2}  Evaluate    random.randint(0, 2)    modules=random
    Set Global Variable    ${status_id2}    ${random_status_id2}
    #Status list
    ${status_list2}  Create List  available  pending  sold
    ${random_status2}  Get From List     ${status_list2}    ${status_id2}

    Create Session  api  ${base_url}
    ${path}    Set Variable     /pet/findByStatus?status=${random_status2}
    ${response}=  GET On Session    api  ${path}

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200

Test_Case_07
    [Documentation]    Get Pets by Invalid Status (400)
    Create Session  api  ${base_url}
    ${invalid_status}    Set Variable    string
    ${path}    Set Variable     /pet/findByStatus?status=${invalid_status}
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    GET On Session    api  ${path}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_08
    [Documentation]    Get Pets by Tags (200)
    Create Session  api  ${base_url}
    ${path}    Set Variable     /pet/findByTags
    ${tags}=    Create_tags
    ${tag_keys}=    Get Dictionary Keys    ${tags}
    ${tag_url}        Create_url_tags   ${tag_keys}
    ${response}=  GET On Session    api  ${path}${tag_url}

    #Log to console  URL:${base_url}${path}${tag_url}

    #Validations
    Should Be Equal As Strings  ${response.status_code}  200

Test_Case_09
    [Documentation]    Get Pets by Invalid Tag value (400)
    Create Session  api  ${base_url}
    ${invalid_tag}    Set Variable    string
    ${path}    Set Variable     /pet/findByTags?tags${invalid_tag}
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    GET On Session    api  ${path}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_10
    [Documentation]    Put Update Pet by ID (200)
    ${pet_data}    Create_pet_json
    #Update JSON with ID
    ${update_pet_data}  Update_json_values  ${pet_data}  id  ${response_petId}
    ${json_update_pet_data}     Convert_Dict2Json    ${update_pet_data}
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${response}    PUT On Session    api    /pet    data=${json_update_pet_data}   headers=${header}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200

Test_Case_11
    [Documentation]    Put Update Pet ID not found (404)
    ${pet_data}    Create_pet_json
    #Update JSON with ID
    ${update_pet_data}  Update_json_values  ${pet_data}  id  101
    ${json_update_pet_data}     Convert_Dict2Json    ${update_pet_data}
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${error_message}=    Run Keyword And Expect Error    *Not Found*    PUT On Session    api    /pet    data=${json_update_pet_data}   headers=${header}

    #Validations
    Should Contain    ${error_message}    404

Test_Case_12
    [Documentation]    Put Update Pet Input error (400)
    ${pet_data}    Create_pet_json
    #Update JSON with ID
    ${update_pet_data}  Update_json_values  ${pet_data}  id  1_101
    ${json_update_pet_data}     Convert_Dict2Json    ${update_pet_data}
    Create Session  api  ${base_url}
    ${header}    Create Dictionary    Content-Type=application/json
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*    PUT On Session    api    /pet    data=${json_update_pet_data}   headers=${header}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_13
    [Documentation]    Post Update Pet with form data (200)
    Create Session  api  ${base_url}
    ${path}    Set Variable     /pet/${response_petId}?name=test013&status=sold
    ${params}=    Create Dictionary    name=test013    status=sold
    ${response}=  POST On Session    api  ${path}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200

Test_Case_14
    [Documentation]    Post Update Pet Invalid Input (400)
    Create Session  api  ${base_url}
    ${path}    Set Variable     /pet/1_${response_petId}?name=test013&status=sold
    ${params}=    Create Dictionary    name=test013    status=sold
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*  POST On Session    api  ${path}

    #Validations
    Should Contain    ${error_message}    400

Test_Case_15
    [Documentation]    Post Upload Image (200)
    Create Session  api  ${base_url}
    ${file_data}=    Get Binary File    ${work_dir}
    ${path}    Set Variable     /pet/${response_petId}/uploadImage?additionalMetadata=string
    ${header}    Create Dictionary    Content-Type=application/octet-stream
    ${response}=    POST On Session    api    ${path}    data=${file_data}    headers=${header}
    #Log to console    ${response.content}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200

Test_Case_16
    [Documentation]    Delete Pet (200)
    Create Session  api  ${base_url}
    ${response}=  DELETE On Session     api  /pet/${response_petId}

    #Validations
    Should Be Equal As Strings    ${response.status_code}    200

Test_Case_17
    [Documentation]    Delete Pet Invalid Input (400)
    Create Session  api  ${base_url}
    ${error_message}=    Run Keyword And Expect Error    *Bad Request*  DELETE On Session     api  /pet/1_${response_petId}

    #Validations
    Should Contain    ${error_message}    400


