@rest @web
Feature: End to End test - setup tools

  ##################################################
  ## CONFIGURE KHERMES
  ##################################################
  Scenario: Configure Khermes
    # TODO: Necesito los secretos
    # We obtain the ip of the node where Khermes is running
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos task khermes | grep -w khermes | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'seedIP'
    Then My app is running in '!{seedIP}:8082'
    And I browse to '/'
    # Create kafka-config
    Given I read file 'schemas/khermes_config/create-kafka-config' as 'string' and save it in environment variable 'kafkaConfig' with:
      | <kafka-config-name> | REPLACE | kafka1 |
      | <broker0_port> | REPLACE | 10038 |
      | <broker1_port> | REPLACE | 10038 |
      | <broker2_port> | REPLACE | 10038 |
      | <keystore-password> | REPLACE | ${KAFKA_BROKER_KEYSTORE_PASSWORD} |
      | <key-password>      | REPLACE | ${KAFKA_BROKER_KEY_PASSWORD}      |
      | <trustore-password> | REPLACE | ${CA_TRUSTORE_PASSWORD}           |
      | <bootstrap-servers> | REPLACE | ${BOOTSTRAP_SERVERS}              |
    And '1' element exists with 'css:textarea[id="command"]'
    Then I type '!{kafkaConfig}' on the element on index '0'
    Given '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text
    # Create twirl-template
    Given I read file 'schemas/khermes_config/create-twirl-template' as 'string' and save it in environment variable 'kafkaConfig' with:
      | <twirl-template-name> | REPLACE | template1 |
    And '1' element exists with 'css:textarea[id="command"]'
    Then I type '!{twirlTemplate}' on the element on index '0'
    Given '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text
    # Create generator-config
    Given I read file 'schemas/khermes_config/create-generator-config' as 'string' and save it in environment variable 'kafkaConfig' with:
      | <generator-config-name> | REPLACE | generator1 |
    And '1' element exists with 'css:textarea[id="command"]'
    Then I type '!{generatorConfig}' on the element on index '0'
    Given '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text


  ##################################################
  ## CONFIGURE SPARTA
  ##################################################
  # THIS WILL BE MANUAL FOR THE TIME BEING UNTIL SOLUTION FOR AUTOMATIC TOKEN GENERATION IS PROVIDED
  #Scenario: Setup gosec-management for Sparta


  #Scenario: Create Sparta policies
