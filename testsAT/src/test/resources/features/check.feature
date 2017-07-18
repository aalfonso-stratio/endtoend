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
    #And I run 'ps -ef | grep java | grep elasticsearch | awk '{print $8;}' | awk -F'/jre' '{print $1}'' in the ssh connection with exit status '0' and save the value in environment variable 'certsPath'
    #And I sanitize environment variable 'certsPath'
    # Check results
    #And I run 'curl -kv -XGET "https://!{esHost}:!{esPort}/totaltickets/sparta/count?q=*" --cert !{certsPath}/elasticsearchstratio-scheduler/elasticsearchstratio-keystore.pem:changeit --cacert !{certsPath}/elasticsearchstratio-scheduler/elasticsearchstratiotruststore.pem' in the ssh connection with exit status '0'
    And I run 'curl -kv -XGET "http://!{esHost}:!{esPort}/triggertickets/_count?pretty"' in the ssh connection with exit status '0'
    Then the command output contains '"count": 1000'


  ##################################################
  ## CHECK POSTGRES
  ##################################################
  Scenario: Check data is correct in Postgres
    # Find Aplication ip
    Given I run 'dcos marathon task list /sparta/sparta/sparta-workflow-server | awk '{print $4}'| awk 'NR ==2'' in the ssh connection and save the value in environment variable 'spartaIP'
    Then  I run 'echo !{spartaIP}' in the ssh connection
    # Run sparta'
    Given I securely send requests to '!{spartaIP}:10148'
    # Generate a table to connect to Postgres using crossdata
    Given I send a 'POST' request to '/crossdata/queries/{"query": "CREATE TEMPORARY TABLE blacklist USING org.apache.spark.sql.jdbc OPTIONS (url 'jdbc:postgresql://${POSTGRESIP}:${POSTGRESPORT}/postgres?user=postgres&pass=postgres&connectTimeout=10', dbtable '${TABLEPOSTGRES}', driver 'org.postgresql.Driver')"}'
    Then the service response status must be '200'
    # Generate a table to check the total number of register
    Given I send a 'POST' request to '/crossdata/queries/{"query": "select count(*) as total from blacklist"}'
    Then the service response status must be '200' and its response must contain the text '{""total": ${TOTALDATA}'
    # This is an alternative method pending to test
    #    Given I send a 'POST' request to '/crossdata/queries' based on 'schemas/queries/querycrossdata.conf' as 'string' with:
    #      | $.tablepostgres | UPDATE | ${TABLEPOSTGRES}  |
    #      | $.postgresip  | UPDATE | ${POSTGRESIP}  |
    #      | $.postgresport  | UPDATE | ${POSTGRESPORT}  |
    #    #Generate a table to connect to Postgres using crossdata
    #    Then I send a 'POST' request to '/crossdata/queries' based on 'schemas/queries/searchdatapostgres.conf'

