@rest
Feature: Individual test

  @loop(PRIVATE_AGENTS_LIST,PRIVATE_IP)
  Scenario: Nodes setup to allow elasticsearch installation
    Given I open a ssh connection to '<PRIVATE_IP>' with user 'root' and password 'stratio'
    Then I run 'sudo sysctl -w vm.max_map_count=262144' in the ssh connection with exit status '0'
    And I run 'set ulimit -n 65536' in the ssh connection with exit status '0'