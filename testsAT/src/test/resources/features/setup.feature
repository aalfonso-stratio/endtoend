@rest @web
Feature: End to End test - setup tools

  ##################################################
  ## CONFIGURE KHERMES
  ##################################################
  Scenario: Configure Khermes
    # We obtain the ip of the node where Khermes is running
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos task khermes | grep -w khermes | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'seedIP'
    And My app is running in '!{seedIP}:8082'
    And I browse to '/'
    # Create kafka-config
    And I read file 'schemas/khermes_config/create-kafka-config' as 'string' and save it in environment variable 'kafkaConfig' with:
      | <kafka-config-name> | REPLACE | kafka1 |
      | <broker0_port> | REPLACE | 10038 |
      | <broker1_port> | REPLACE | 10038 |
      | <broker2_port> | REPLACE | 10038 |
      | <keystore-password> | REPLACE | ${KAFKA_BROKER_KEYSTORE_PASSWORD} |
      | <key-password>      | REPLACE | ${KAFKA_BROKER_KEY_PASSWORD}      |
      | <trustore-password> | REPLACE | ${CA_TRUSTORE_PASSWORD}           |
      | <bootstrap-servers> | REPLACE | ${BOOTSTRAP_SERVERS}              |
    And '1' element exists with 'css:textarea[id="command"]'
    And I type '!{kafkaConfig}' on the element on index '0'
    And '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text
    # Create twirl-template
    Given I read file 'schemas/khermes_config/create-twirl-template' as 'string' and save it in environment variable 'kafkaConfig' with:
      | <twirl-template-name> | REPLACE | template1 |
    And '1' element exists with 'css:textarea[id="command"]'
    And I type '!{twirlTemplate}' on the element on index '0'
    And '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text
    # Create generator-config
    Given I read file 'schemas/khermes_config/create-generator-config' as 'string' and save it in environment variable 'kafkaConfig' with:
      | <generator-config-name> | REPLACE | generator1 |
    And '1' element exists with 'css:textarea[id="command"]'
    And I type '!{generatorConfig}' on the element on index '0'
    And '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text


  ##################################################
  ## CONFIGURE SPARTA
  ##################################################
  # THIS WILL BE MANUAL FOR THE TIME BEING UNTIL SOLUTION FOR AUTOMATIC TOKEN GENERATION IS PROVIDED
  #Scenario: Setup gosec-management for Sparta

  Scenario: Create Sparta policy - kafka & elasticsearch
    # Obtain Sparta ip
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list /sparta/sparta-auto | grep -v APP | awk '{print $4}' in the ssh connection and save the value in environment variable 'spartaIP'
    And I securely send requests to '!{spartaIP}:10148'
    # Generate workflow
    And I send a 'POST' request to '/policy' based on 'schemas/sparta_workflows/kafka-elastic-tickets-carrefour.json' as 'json' with:
      | id | DELETE | N/A  |
    Then the service response status must be '200'

  Scenario: Create Sparta policy - kafka & postgres
    # Obtain Sparta ip
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list /sparta/sparta-auto | grep -v APP | awk '{print $4}' in the ssh connection and save the value in environment variable 'spartaIP'
    And I securely send requests to '!{spartaIP}:10148'
    # Generate workflow
    And I send a 'POST' request to '/policy' based on 'schemas/sparta_workflows/kafka-postgres-tickets-carrefour.json' as 'json' with:
      | id | DELETE | N/A  |
    Then the service response status must be '200'
