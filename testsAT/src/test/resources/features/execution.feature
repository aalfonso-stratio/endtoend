@rest @web
Feature: End to End test - start tools
  ##################################################
  ## START SPARTA
  ##################################################
  Scenario: Start Sparta policy


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


  # CHAOS GENERATION (PHASE 2)