@rest @web
Feature: Testing individual scenarios

# Setup tools
  Scenario: Configure Khermes
    # TODO: Necesito los secretos
    # We obtain the ip of the node where Khermes is running
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos task khermes | grep -w khermes | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'seedIP'
    Then My app is running in '!{seedIP}:8082'
    And I browse to '/'
    # TODO: add step to read file, modify it and store in environment variable
    # Create kafka-config
    Given I read file 'schemas/khermes_config/ls' as 'string' and save it in environment variable 'lsCommand'
    And '1' element exists with 'css:textarea[id="command"]'
    Then I type '!{lsCommand}' on the element on index '0'
    And I wait '2' seconds
    Given '1' element exists with 'xpath://*[@id="content"]/button'
    When I click on the element on index '0'
    Then '1' element exists with 'xpath://*[@id="content"]/div/p'
    And I save content of element in index '0' in environment variable 'nodeText'
    And I run 'echo '!{nodeText}' | jq '.value' | sed 's/"//g' | awk '{print $1}'' locally with exit status '0' and save the value in environment variable 'nodeID'
    And I run 'echo !{nodeID}' locally with exit status '0'