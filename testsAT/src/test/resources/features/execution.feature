@rest @web
Feature: End to End test - start tools
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
    And in less than '400' seconds, checking each '20' seconds, the command output 'dcos marathon task list /sparta/workflows/kafka-elastic-tickets-carrefour | wc -l' contains '2'

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
    And in less than '400' seconds, checking each '20' seconds, the command output 'dcos marathon task list /sparta/workflows/kafka-postgres-tickets-carrefour | wc -l' contains '2'


  ##################################################
  ## RELEASE THE KRAKEN
  ##################################################
  @runOnEnv(GENERATE_CHAOS)
  Scenario: Start generating chaos
    Given I wait '180' seconds
    # Obtain kafka broker-1 ip
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos task broker-0001 | grep -w broker-0001 | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'kafkaBroker1IP'
    # Connect to broker-1 and kill process
    Given I open a ssh connection to '!{kafkaBroker1IP}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    When I run 'cd /tmp/valkiria && ./valkiria a --ip=!{kafkaBroker1IP}:9050 &' in the ssh connection with exit status '0'
    And I run 'curl -s -X GET "http://!{kafkaBroker1IP}:9050/api/v1/list" | jq '.findProcess[1] | select(.KillName | startswith("broker-0001")) | .KillName'' locally with exit status '0' and save the value in environment variable 'killName1'
    Then I run 'curl -X POST -d '{"name":"!{killName1}","properties":"killExecutor=0"}' "http://!{kafkaBroker0IP}:9050/api/v1/valkiria"' locally with exit status '0'

    # We wait some time
    And I wait '180' seconds

    # Obtain kafka broker-2 ip
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos task broker-0002 | grep -w broker-0002 | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'kafkaBroker2IP'
    # Connect to broker-2 and kill process
    Given I open a ssh connection to '!{kafkaBroker2IP}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    When I run 'cd /tmp/valkiria && ./valkiria a --ip=!{kafkaBroker2IP}:9050 &' in the ssh connection with exit status '0'
    And I run 'curl -s -X GET "http://!{kafkaBroker2IP}:9050/api/v1/list" | jq '.findProcess[1] | select(.KillName | startswith("broker-0002")) | .KillName'' locally with exit status '0' and save the value in environment variable 'killName2'
    Then I run 'curl -X POST -d '{"name":"!{killName2}","properties":"killExecutor=0"}' "http://!{kafkaBroker2IP}:9050/api/v1/valkiria"' locally with exit status '0'

    # We wait some time
    And I wait '180' seconds

    # Obtain kafka broker-3 ip
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos task broker-0003 | grep -w broker-0003 | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'kafkaBroker3IP'
    # Connect to broker-3 and kill process
    Given I open a ssh connection to '!{kafkaBroker3IP}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    When I run 'cd /tmp/valkiria && ./valkiria a --ip=!{kafkaBroker3IP}:9050 &' in the ssh connection with exit status '0'
    And I run 'curl -s -X GET "http://!{kafkaBroker3IP}:9050/api/v1/list" | jq '.findProcess[1] | select(.KillName | startswith("broker-0003")) | .KillName'' locally with exit status '0' and save the value in environment variable 'killName3'
    Then I run 'curl -X POST -d '{"name":"!{killName3}","properties":"killExecutor=0"}' "http://!{kafkaBroker3IP}:9050/api/v1/valkiria"' locally with exit status '0'
