@rest @web
Feature: End to End test for full solution

# INSTALL ALL COMPONENTS
  ##################################################
  ## INSTALL KHERMES
  ##################################################
  Scenario: Install Khermes Seed
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/khermes.json' as 'json' with:
      | $.id | UPDATE | khermes |
      | $.env.SEED | UPDATE | true |
      | $.env.PORT0 | UPDATE | 2551 |
      | $.env.VAULT_HOSTS | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT  | UPDATE | ${VAULT_PORT}  |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.KAFKA_BROKER_INSTANCE_NAME | UPDATE | ${KAFKA_BROKER_INSTANCE_NAME} |
      | $.env.KAFKA_BROKER_PRINCIPAL     | UPDATE | ${KAFKA_BROKER_PRINCIPAL}     |
    Then the service response status must be '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w khermes | wc -l' contains '1'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list khermes | awk '{print $5}' | grep khermes' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


#  Scenario: Install Khermes Client
#    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
#    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
#    And I securely send requests to '${DCOS_IP}:443'
#    When I run 'dcos task khermes | grep -w khermes | awk '{print $2}'' in the ssh connection with exit status '0' and save the value in environment variable 'seedIP'
#    And I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/khermes-node.json' as 'json' with:
#      | $.id | UPDATE | khermes-node |
#      | $.env.SEED | UPDATE | true |
#      | $.env.PORT0 | UPDATE | 2552 |
#      | $.env.SEED_IP | UPDATE | !{seedIP} |
#      | $.env.SEED_PORT | UPDATE | 2551 |
#    Then the service response status must be '201'.
#    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w khermes-node | wc -l' contains '1'
#    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
#    And I run 'dcos marathon task list khermes-node | awk '{print $5}' | grep khermes-node' in the ssh connection and save the value in environment variable 'marathonTaskId'
#    #DCOS dcos marathon task show check healtcheck status
#    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


  ##################################################
  ## INSTALL KAFKA
  ##################################################
  Scenario: Install Kafka
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/confluent-kafka-sec.json' as 'json' with:
      | $.id | UPDATE | confluent-kafka-sec |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
    Then the service response status must be '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w confluent-kafka-sec | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '3'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list confluent-kafka-sec | awk '{print $5}' | grep confluent-kafka-sec' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'


  ##################################################
  ## INSTALL SPARTA
  ##################################################
  Scenario: Install Sparta
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/sparta-no-marathon.json' as 'json' with:
      | $.id | UPDATE | /sparta/sparta-dg-test |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
    Then the service response must contain the text '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w sparta-dg-test.sparta | wc -l' contains '1'

    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list /sparta/sparta-dg-test | awk '{print $5}' | grep /sparta/sparta-dg-test' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'


  ##################################################
  ## INSTALL ELASTICSEARCH
  ##################################################
  Scenario: Install Elasticsearch
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    And I create file 'config.json' based on 'schemas/elasticsearchstratio-config.json' as 'json' with:
      | $.service.name            | UPDATE  | ${SERVICE}      | n/a    |
      | $.coordinator_nodes.count | REPLACE | ${COOR_COUNT}   | number |
      | $.data_nodes.count        | REPLACE | ${DATA_COUNT}   | number |
      | $.kibana_nodes.count      | REPLACE | ${KIBANA_COUNT} | number |
      | $.security.vault_hosts    | UPDATE  | ${VAULT_HOST}   | n/a    |
      | $.security.vault_port     | UPDATE  | ${VAULT_PORT}   | n/a    |
      | $.security.vault_token    | UPDATE  | !{vaultToken}   | n/a    |
    And I outbound copy 'target/test-classes/config.json' through a ssh connection to '/tmp'
    And I run 'dcos package install --options=/tmp/config.json ${SERVICE}' in the ssh connection
    Then the command output contains 'DC/OS STRATIO ElasticSearch is being installed!'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w elasticsearchstratio | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep kibana | wc -l' contains '${KIBANA_COUNT}'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep master | wc -l' contains '3'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep coordinator | wc -l' contains '${COOR_COUNT}'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep data | wc -l' contains '${DATA_COUNT}'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list elasticsearchstratio | awk '{print $5}' | grep elasticsearchstratio' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


  ##################################################
  ## INSTALL POSTGRES COMMUNITY
  ##################################################
  Scenario: Install Postgres Community
    Given I open a ssh connection to '${VAULT_HOST}' with user 'root' and password 'stratio'
    And I run 'jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'

  #install according to json with marathon
  When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/postgres-community.json' as 'json' with:
    | $.id | UPDATE | /${INSTANCE} |
    | $.env.POSTGRES_MESOS_PRINCIPAL | UPDATE | 012345 |
    | $.env.DISABLE_DYNAMIC_RESERVATION | UPDATE | true |
    | $.env.DISABLE_ZOOKEEPER_SEC       | UPDATE | disabled |
    | $.env.POSTGRES_MESOS_ROLE | UPDATE | slave_public |
    | $.env.REALM | UPDATE | DEMO.STRATIO.COM |
    | $.env.POSTGRES_ZOOKEEPER | UPDATE | master.mesos:2181 |
    | $.env.POSTGRES_CPU | UPDATE | 0.5 |
    | $.env.KADMIN_HOST | UPDATE | idp.integration.labs.stratio.com |
    | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
    | $.env.POSTGRES_MESOS_MASTER | UPDATE | master.mesos:2181 |
    | $.env.TENANT_NAME | UPDATE | ${INSTANCE} |
    | $.env.VAULT_PORT | UPDATE | 8200 |
    | $.env.ENABLE_MESOS_SEC | UPDATE | true |
    | $.env.VAULT_HOSTS | UPDATE | gosec2.node.default-cluster.labs.stratio.com |
    | $.env.KDC_HOST | UPDATE | idp.integration.labs.stratio.com |
    | $.env.POSTGRES_DOCKER_IMAGE | UPDATE | qa.stratio.com/stratio/postgresql-community:${COMMUNITY_VERSION} |
    | $.env.POSTGRES_SERVICE_NAME | UPDATE | ${INSTANCE} |
    | $.env.ENABLE_MARATHON_SEC | UPDATE | true |
    | $.container.docker.image | UPDATE | qa.stratio.com/stratio/postgres-bigdata-framework:${FRAMEWORK_VERSION} |
    | $.labels.DCOS_SERVICE_NAME | UPDATE | ${INSTANCE} |
    | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | ${INSTANCE} |
    Then the service response status must be '201'

    #  Check the result with dcos-cli
    Given I open a ssh connection to '${DCOS_CLI}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    Then in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep ${INSTANCE} | grep R | wc -l' contains '1'
    Given I wait '200' seconds
    When I send a 'GET' request to '/mesos/frameworks'
    Then the service response status must be '200'
    And I save element '$' in environment variable 'coordinator'
    And 'coordinator' matches the following cases:
      | $.frameworks[?(@.name == "${INSTANCE}")].tasks[?(@.name == "pg_0001")].statuses[*].state           | contains   | TASK_RUNNING          |
    And 'coordinator' matches the following cases:
      | $.frameworks[?(@.name == "${INSTANCE}")].tasks[?(@.name == "pg_0002")].statuses[*].state           | contains   | TASK_RUNNING          |


  ##################################################
  ## INSTALL VALKIRIA
  ##################################################
  #Scenario: Install Valkiria (PHASE 2)
  #  Given I open a ssh connection to '${DCOS_CLI}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
  #  When I run 'dcos install package --cli valkiria' in the ssh connection with exit status '0'
  #  Then the command output contains 'New command available: dcos valkiria'



# SETUP TOOLS
  ##################################################
  ## CONFIGURE KHERMES
  ##################################################
  Scenario: Configure Khermes
    # TODO: Necesito los secretos
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
    Then I type '!{kafkaConfig}' on the element on index '0'
    Given '1' element exists with 'css:button[type="button"]'
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

  Scenario: Create Sparta policies



# START PROCESS
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



# CHECK RESULTS
  ##################################################
  ## CHECK ELASTICSEARCH
  ##################################################
  Scenario: Check data is correct in Elasticsearch
    # TODO: Check with Sparta wich index and type we have to use
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    # And I obtain mesos master in cluster '${DCOS_IP}' and store it in environment variable 'mesosMaster'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'GET' request to '/mesos/frameworks'
    # obtain elasticsearchstratio node and port
    And I save element in position '0' in '$.frameworks[?(@.name == "elasticsearchstratio")].tasks[?(@.name == "coordinator-0-node")].statuses[0].container_status.network_infos[0].ip_addresses[0].ip_address' in environment variable 'esHost'
    And I save element in position '0' in '$.frameworks[?(@.name == "elasticsearchstratio")].tasks[?(@.name == "coordinator-0-node")].discovery.ports.ports[0].number' in environment variable 'esPort'
    # obtain certs path
    And I open a ssh connection to '!{esHost}' with user '${REMOTE_USER}' and password '${REMOTE_PASSWORD}'
    And I run 'ps -ef | grep java | grep elasticsearch | awk '{print $8;}' | awk -F'/jre' '{print $1}'' in the ssh connection with exit status '0' and save the value in environment variable 'certsPath'
    And I sanitize environment variable 'certsPath'
    # check results
    And I run 'curl -kv -XGET "https://!{esHost}:!{esPort}/myindex/document/count?q=*" --cert !{certsPath}/elasticsearchstratio-scheduler/elasticsearchstratio-keystore.pem:changeit --cacert !{certsPath}/elasticsearchstratio-scheduler/elasticsearchstratiotruststore.pem' in the ssh connection with exit status '0'
    Then the command output contains '"count": 1000'


  ##################################################
  ## CHECK POSTGRES
  ##################################################
  Scenario: Check data is correct in Postgres



