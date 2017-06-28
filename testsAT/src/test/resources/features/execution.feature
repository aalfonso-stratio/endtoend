@rest @web
Feature: End to End test - start tools
  ##################################################
  ## START SPARTA
  ##################################################
  Scenario: Start Sparta policy - kafka & elasticsearch
    # Obtain Sparta ip
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list /sparta/sparta-auto | grep -v APP | awk '{print $4}' in the ssh connection and save the value in environment variable 'spartaIP'
    And I securely send requests to '!{spartaIP}:10148'
    # Obtain policy id
    And I send a 'GET' request to '/policy/findByName/kafka-elastic-tickets-carrefour'
    Then the service response status must be '200'
    And I save element '$.id' in environment variable 'elasticWorkflowID'
    # Execute workflow
    When I send a 'GET' request to '/policy/run/!{elasticWorkflowID}'
    Then the service response status must be '200' and its response must contain the text '{"message":"Launched policy with name kafka-elastic-tickets-carrefour'
    # Verify the generation of workflow in dcos
    And in less than '100' seconds, checking each '20' seconds, the command output 'dcos marathon task list /sparta/workflows/kafka-elastic-tickets-carrefour | wc -l' contains '2'

  Scenario: Start Sparta policy - kafka & postgres
    # Obtain Sparta ip
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list /sparta/sparta-auto | grep -v APP | awk '{print $4}' in the ssh connection and save the value in environment variable 'spartaIP'
    And I securely send requests to '!{spartaIP}:10148'
    # Obtain policy id
    And I send a 'GET' request to '/policy/findByName/kafka-postgres-tickets-carrefour'
    Then the service response status must be '200'
    And I save element '$.id' in environment variable 'postgresWorkflowID'
    # Execute workflow
    When I send a 'GET' request to '/policy/run/!{postgresWorkflowID}'
    Then the service response status must be '200' and its response must contain the text '{"message":"Launched policy with name kafka-postgres-tickets-carrefour'
    # Verify the generation of workflow in dcos
    And in less than '100' seconds, checking each '20' seconds, the command output 'dcos marathon task list /sparta/workflows/kafka-postgres-tickets-carrefour | wc -l' contains '2'


  ##################################################
  ## START KHERMES
  ##################################################
  Scenario: Start Khermes producer
    # Obtain node-id
    Given I read file 'schemas/khermes_config/ls' as 'string' and save it in environment variable 'lsCommand'
    And '1' element exists with 'css:textarea[id="command"]'
    And I type '!{lsCommand}' on the element on index '0'
    And I wait '2' seconds
    And '1' element exists with 'xpath://*[@id="content"]/button'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And I save content of element in index '0' in environment variable 'nodeText'
    And I run 'echo '!{nodeText}' | jq '.value' | sed 's/"//g' | awk '{print $1}'' locally with exit status '0' and save the value in environment variable 'nodeID'

    # Start production
    Given I read file 'schemas/khermes_config/create-generator-config' as 'string' and save it in environment variable 'startConfig' with:
      | <generator-config-name> | REPLACE | generator1 |
      | <twirl-template-name> | REPLACE | template1 |
      | <kafka-config-name> | REPLACE | kafka1 |
      | <node-id>           | REPLACE | !{nodeID} |
    And '1' element exists with 'css:textarea[id="command"]'
    And I type '!{startConfig}' on the element on index '0'
    And '1' element exists with 'css:button[type="button"]'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And the element on index '0' has '{"value":"OK"}' as text


  ##################################################
  ## RELEASE THE KRAKEN
  ##################################################
#  Scenario: Start generating chaos
#    # Obtain kafka broker-0 ip
#    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
#    And I run 'dcos task broker-0 | grep -w broker-0 | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'kafkaBroker0IP'
#    # Connect to broker-0 and kill process
#    Given I open a ssh connection to '!{kafkaBroker0IP}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
#    Then I run './valkiria o &' in the ssh connection with exit status '0'
