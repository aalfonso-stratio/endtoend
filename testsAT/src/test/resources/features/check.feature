@rest
Feature: End to End test - check results
  ##################################################
  ## CHECK ELASTICSEARCH
  ##################################################
  Scenario: Check data is correct in Elasticsearch
    # TODO: Check with Sparta wich index and type we have to use
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'GET' request to '/mesos/frameworks'
    # Obtain elasticsearchstratio node and port
    And I save element in position '0' in '$.frameworks[?(@.name == "elasticsearchstratio")].tasks[?(@.name == "coordinator-0-node")].statuses[0].container_status.network_infos[0].ip_addresses[0].ip_address' in environment variable 'esHost'
    And I save element in position '0' in '$.frameworks[?(@.name == "elasticsearchstratio")].tasks[?(@.name == "coordinator-0-node")].discovery.ports.ports[0].number' in environment variable 'esPort'
    # Obtain certs path
    And I open a ssh connection to '!{esHost}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I run 'ps -ef | grep java | grep elasticsearch | awk '{print $8;}' | awk -F'/jre' '{print $1}'' in the ssh connection with exit status '0' and save the value in environment variable 'certsPath'
    And I sanitize environment variable 'certsPath'
    # Check results
    And I run 'curl -kv -XGET "https://!{esHost}:!{esPort}/totaltickets/sparta/count?q=*" --cert !{certsPath}/elasticsearchstratio-scheduler/elasticsearchstratio-keystore.pem:changeit --cacert !{certsPath}/elasticsearchstratio-scheduler/elasticsearchstratiotruststore.pem' in the ssh connection with exit status '0'
    Then the command output contains '"count": 1000'


  ##################################################
  ## CHECK POSTGRES
  ##################################################
  #Scenario: Check data is correct in Postgres