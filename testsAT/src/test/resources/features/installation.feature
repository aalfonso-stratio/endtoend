@rest
Feature: End to End test - install tools

# INSTALL ALL COMPONENTS
  ##################################################
  ## INSTALL KHERMES
  ##################################################
  @runOnEnv(INSTALL_KHERMES)
  Scenario: Install Khermes Seed
    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    And I run 'sudo jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/khermes-seed.json' as 'json' with:
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
    When I run 'dcos marathon task list khermes | awk '{print $5}' | grep khermes' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'

#  Scenario: Install Khermes Client
#    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
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
  ## INSTALL GOSEC-MANAGEMENT
  ##################################################
  Scenario: Install gosec-management
    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    And I run 'sudo jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/gosec-management.json' as 'json' with:
      | $.id | UPDATE | gosecmanagement |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.ZOOKEEPER_HOSTS | UPDATE | ${ZOOKEEPER_HOSTS} |
      | $.env.KAFKA_HOST      | UPDATE | ${KAFKA_HOST}      |
      | $.env.SSO_PRINCIPAL   | UPDATE | ${SSO_PRINCIPAL}   |
      | $.env.MANAGEMENT_PRINCIPAL | UPDATE | ${MANAGEMENT_PRINCIPAL} |
      | $.env.KERBEROS_KDC         | UPDATE | ${KERBEROS_KDC}         |
      | $.env.LDAP_HOST            | UPDATE | ${LDAP_HOST}            |
      | $.env.KERBEROS_ADMIN_SERVER | UPDATE | ${KERBEROS_ADMIN_SERVER} |
    Then the service response status must be '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w gosecmanagement | wc -l' contains '1'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I run 'dcos marathon task list gosecmanagement | awk '{print $5}' | grep gosecmanagement' in the ssh connection and save the value in environment variable 'marathonTaskId'
    #DCOS dcos marathon task show check healtcheck status
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'


  ##################################################
  ## INSTALL ZOOKEEPER FRAMEWORK PLUGIN
  ##################################################
  @runOnEnv(INSTALL_ZK_PLUGIN)
  Scenario: Install Zookeeper framework
    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    And I run 'sudo jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/zookeeper-security-plugin.json' as 'json' with:
      | $.id | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.env.ZOOKEEPER_SERVICE_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.env.TENANT_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID} |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.ZOOKEEPER_DOCKER_IMAGE | UPDATE | ${ZOOKEEPER_DOCKER_IMAGE} |
      | $.env.CONSUL_ADDRESS         | UPDATE | ${CONSUL_ADDRESS}         |
      | $.env.ZOOKEEPER_CLIENT_PORT  | UPDATE | 4444                      |
      | $.env.ZOOKEEPER_FOLLOW_PORT  | UPDATE | 5555                      |
      | $.env.ZOOKEEPER_LEADER_PORT  | UPDATE | 6666                      |
      | $.env.ZOOKEEPER_ADMIN_PORT   | UPDATE | 7777                      |
      | $.env.ZOOKEEPER_INSTANCES    | UPDATE | 3                         |
      | $.container.docker.image | UPDATE | ${FRAMEWORK_DOCKER_IMAGE} |
      | $.env.REALM              | UPDATE | ${REALM}                  |
      | $.env.LDAP_HOST          | UPDATE | ${LDAP_HOST}              |
      | $.env.KDC_HOST           | UPDATE | ${KDC_HOST}               |
      | $.env.KADMIN_HOST        | UPDATE | ${KADMIN_HOST}            |
    Then the service response status must be '201'

    # We check that installation finished successfully
    Given I wait '10' seconds
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I securely send requests to '${DCOS_IP}:443'
    When in less than '300' seconds, checking each '10' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains 'RUNNING'
    And I save element '$.status[0].status' in environment variable 'zk01_status'
    And I save element '$.status[1].status' in environment variable 'zk02_status'
    And I save element '$.status[2].status' in environment variable 'zk03_status'
    Then in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains '"zk-0001","role":"zkNode","status":"RUNNING"'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains '"zk-0002","role":"zkNode","status":"RUNNING"'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID}/v1/service/status' so that the response contains '"zk-0003","role":"zkNode","status":"RUNNING"'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list ${ZOOKEEPER_FRAMEWORK_ID} | awk '{print $5}' | grep ${ZOOKEEPER_FRAMEWORK_ID}' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show state RUNNING
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'



  ##################################################
  ## INSTALL ZOOKEEPER FRAMEWORK NO PLUGIN
  ##################################################
  @runOnEnv(INSTALL_ZK_NOPLUGIN)
  Scenario: Install Zookeeper framework no plugin
    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    And I run 'sudo jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/zookeeper-security-noplugin.json' as 'json' with:
      | $.id | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN} |
      | $.env.ZOOKEEPER_SERVICE_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN} |
      | $.env.TENANT_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN} |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN} |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN} |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.ZOOKEEPER_DOCKER_IMAGE | UPDATE | ${ZOOKEEPER_DOCKER_IMAGE} |
      | $.env.CONSUL_ADDRESS         | UPDATE | ${CONSUL_ADDRESS}         |
      | $.env.ZOOKEEPER_CLIENT_PORT  | UPDATE | 4444                      |
      | $.env.ZOOKEEPER_FOLLOW_PORT  | UPDATE | 5555                      |
      | $.env.ZOOKEEPER_LEADER_PORT  | UPDATE | 6666                      |
      | $.env.ZOOKEEPER_ADMIN_PORT   | UPDATE | 7777                      |
      | $.env.ZOOKEEPER_INSTANCES    | UPDATE | 3                         |
      | $.container.docker.image | UPDATE | ${FRAMEWORK_DOCKER_IMAGE} |
      | $.env.KDC_HOST           | UPDATE | ${KDC_HOST}               |
      | $.env.KADMIN_HOST        | UPDATE | ${KADMIN_HOST}            |
      | $.env.REALM              | UPDATE | ${REALM}                  |
    Then the service response status must be '201'

    # We check that installation finished successfully
    Given I wait '10' seconds
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I securely send requests to '${DCOS_IP}:443'
    When in less than '300' seconds, checking each '10' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN}/v1/service/status' so that the response contains 'RUNNING'
    And I save element '$.status[0].status' in environment variable 'zk01_status'
    And I save element '$.status[1].status' in environment variable 'zk02_status'
    And I save element '$.status[2].status' in environment variable 'zk03_status'
    Then in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN}/v1/service/status' so that the response contains '"zk-0001","role":"zkNode","status":"RUNNING"'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN}/v1/service/status' so that the response contains '"zk-0002","role":"zkNode","status":"RUNNING"'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN}/v1/service/status' so that the response contains '"zk-0003","role":"zkNode","status":"RUNNING"'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN} | awk '{print $5}' | grep ${ZOOKEEPER_FRAMEWORK_ID_NOPLUGIN}' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show state RUNNING
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


  ##################################################
  ## INSTALL KAFKA
  ##################################################
  @runOnEnv(INSTALL_KAFKA)
  Scenario: Install Kafka
    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    And I run 'sudo jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/kafka-sec.json' as 'json' with:
      | $.id | UPDATE | kafka-sec |
      | $.env.VAULT_HOST | UPDATE | ${VAULT_HOST} |
      | $.env.VAULT_PORT | UPDATE | ${VAULT_PORT} |
      | $.env.VAULT_TOKEN | UPDATE | !{vaultToken} |
      | $.env.KAFKA_CERTIFICATE_DOMAIN | UPDATE | ${KAFKA_CERTIFICATE_DOMAIN} |
      | $.env.KRB5_DNS_DOMAIN          | UPDATE | ${KRB5_DNS_DOMAIN}          |
      | $.env.KDC_HOST           | UPDATE | ${KDC_HOST}               |
      | $.env.KADMIN_HOST        | UPDATE | ${KADMIN_HOST}            |
      | $.env.REALM              | UPDATE | ${REALM}                  |
      | $.env.LDAP_HOST          | UPDATE | ${LDAP_HOST}              |

    Then the service response status must be '201'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w kafka-sec | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep broker | wc -l' contains '3'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list kafka-sec | awk '{print $5}' | grep kafka-sec' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep healthCheckResults | wc -l' contains '1'
    And in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep '"alive": true' | wc -l' contains '1'


  ##################################################
  ## INSTALL SPARTA
  ##################################################
  @runOnEnv(INSTALL_SPARTA)
  Scenario: Install Sparta
    # Connect to dcos to get token and vault
    Given I open a ssh connection to '${DCOS_IP}' with user 'root' and password 'stratio'
    # Get token
    Then I run ' cat /etc/sds/gosec-sso/cas/cas-vault.properties |grep token | cut -f 2 -d :' in the ssh connection and save the value in environment variable 'vaultToken'
    # Get vault ip url
    And I run 'cat /etc/sds/gosec-sso/cas/cas-vault.properties |grep address | cut -f 3 -d / | cut -f 1 -d :' in the ssh connection and save the value in environment variable 'vaultIP'
    # Get vault port url
    And I run 'cat /etc/sds/gosec-sso/cas/cas-vault.properties |grep address | cut -f 3 -d / | cut -f 2 -d :' in the ssh connection and save the value in environment variable 'vaultport'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    Given I create file 'SpartaSecurityInstalation.json' based on 'schemas/install_jsons/spartaSecurelywithoutMarathon.json' as 'json' with:
      |   $.container.docker.image                           |  UPDATE     | ${SPARTA_DOCKER_IMAGE}           | n/a    |
      |   $.container.docker.forcePullImage                  |  REPLACE    | ${FORCEPULLIMAGE}                |boolean |
      |   $.env.SPARTA_ZOOKEEPER_CONNECTION_STRING           |  UPDATE     | ${ZK_URL}                        |n/a |
      |   $.env.VAULT_TOKEN                                  |  UPDATE     | !{vaultToken}                    |n/a |
      |   $.env.MARATHON_TIKI_TAKKA_MARATHON_URI             |  UPDATE     | ${MARATHON_TIKI_TAKKA}           |n/a |
      |   $.env.SPARTA_DOCKER_IMAGE                          |  UPDATE     | ${SPARTA_DOCKER_IMAGE}           |n/a |
      |   $.env.VAULT_HOSTS                                  |  UPDATE     | !{vaultIP}                       | n/a |
      |   $.env.HADOOP_NAMENODE_KRB_PRINCIPAL_PATTERN        |  UPDATE     | ${HADOOP_PATTERN}                |n/a |
      |   $.env.HADOOP_NAMENODE_KRB_PRINCIPAL                |  UPDATE     | ${HADOOP_PRINCIPAL}              |n/a |
      |   $.env.HADOOP_FS_DEFAULT_NAME                       |  UPDATE     | ${HADOOP_DEFAULT_NAME}          |n/a |
    # Copy DEPLOY JSON to DCOS-CLI
    When I outbound copy 'target/test-classes/SpartaSecurityInstalation.json' through a ssh connection to '/dcos'
    # Start image from JSON
    Then I run 'dcos marathon app add /dcos/SpartaSecurityInstalation.json' in the ssh connection
    # Check Sparta is Running
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep sparta-workflow-server.sparta | grep R | wc -l' contains '1'
    # Find task-id if from DCOS-CLI
    And in less than '400' seconds, checking each '20' seconds, the command output 'dcos marathon task list /sparta/sparta/sparta-workflow-server | grep sparta-workflow-server | awk '{print $2}'' contains 'True'


  ##################################################
  ## INSTALL ELASTICSEARCH
  ##################################################
  @runOnEnv(SETUP_ELASTIC)
  @loop(PRIVATE_AGENTS_LIST,PRIVATE_IP)
  Scenario: Nodes setup to allow elasticsearch installation
    Given I open a ssh connection to '<PRIVATE_IP>' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    Then I run 'sudo sysctl -w vm.max_map_count=262144' in the ssh connection with exit status '0'
    And I run 'set ulimit -n 65536' in the ssh connection with exit status '0'

  @runOnEnv(INSTALL_ES)
  Scenario: Install Elasticsearch
    Given I open a ssh connection to '${VAULT_HOST}' with user '${REMOTE_USER}' using pem file 'src/test/resources/credentials/key.pem'
    And I run 'sudo jq .root_token /opt/stratio/vault/vault_response | sed -e 's/^"//' -e 's/"$//'' in the ssh connection and save the value in environment variable 'vaultToken'
    And I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    And I securely send requests to '${DCOS_IP}:443'
    And I create file 'config.json' based on 'schemas/install_jsons/elasticsearchstratio-config.json' as 'json' with:
      | $.service.name            | UPDATE  | ${SERVICE}      | n/a    |
      | $.coordinator_nodes.count | REPLACE | ${COOR_COUNT}   | number |
      | $.data_nodes.count        | REPLACE | ${DATA_COUNT}   | number |
      | $.kibana_nodes.count      | REPLACE | ${KIBANA_COUNT} | number |
      | $.security.vault_hosts    | UPDATE  | ${VAULT_HOST}   | n/a    |
      | $.security.vault_port     | UPDATE  | ${VAULT_PORT}   | n/a    |
      | $.security.vault_token    | UPDATE  | !{vaultToken}   | n/a    |
      | $.security.krb_realm      | UPDATE  | ${KRB_REALM}    | n/a    |
      | $.security.krb_kdc_host   | UPDATE  | ${KRB_KDC_HOST} | n/a    |
      | $.security.krb_admin_host | UPDATE  | ${KRB_ADMIN_HOST} | n/a  |
      | $.security.krb_user_folder | UPDATE | ${KRB_USER_FOLDER} | n/a |
      | $.security.dynamic_authentication | UPDATE | ${DYNAMIC_AUTHENTICATION} | n/a |
      | $.security.mesos_securized        | UPDATE | ${MESOS_SECURIZED} | n/a |
      | $.security.principal              | UPDATE | ${PRINCIPAL}       | n/a |
    And I outbound copy 'target/test-classes/config.json' through a ssh connection to '/tmp'
    When I run 'dcos package install --options=/tmp/config.json elasticsearchstratio_e2e' in the ssh connection
    Then the command output contains 'DC/OS STRATIO ElasticSearch is being installed!'
    And in less than '300' seconds, checking each '20' seconds, the command output 'dcos task | grep -w elasticsearchstratio | wc -l' contains '1'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep kibana | wc -l' contains '${KIBANA_COUNT}'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep master | wc -l' contains '3'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep coordinator | wc -l' contains '${COOR_COUNT}'
    And in less than '500' seconds, checking each '20' seconds, the command output 'dcos task | grep data | wc -l' contains '${DATA_COUNT}'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When I run 'dcos marathon task list elasticsearchstratio | awk '{print $5}' | grep elasticsearchstratio' in the ssh connection and save the value in environment variable 'marathonTaskId'
    # DCOS dcos marathon task show check healtcheck status
    Then in less than '300' seconds, checking each '10' seconds, the command output 'dcos marathon task show !{marathonTaskId} | grep TASK_RUNNING | wc -l' contains '1'


  ##################################################
  ## INSTALL POSTGRES COMMUNITY
  ##################################################
  @runOnEnv(INSTALL_POSTGRES)
  Scenario: Install Postgres Community
    Given I authenticate to DCOS cluster '${DCOS_IP}' using email '${DCOS_USER}' with user '${REMOTE_USER}' and pem file 'src/test/resources/credentials/key.pem'
    And I securely send requests to '${DCOS_IP}:443'
    # Install according to json with marathon
    When I send a 'POST' request to '/marathon/v2/apps' based on 'schemas/install_jsons/${POSTGRES_JSON}' as 'json' with:
      | $.id | UPDATE | /${INSTANCE} |
      | $.env.POSTGRES_MESOS_PRINCIPAL | UPDATE | postgres2 |
      | $.env.POSTGRES_MESOS_ROLE | UPDATE | postgres |
      | $.env.POSTGRES_ZOOKEEPER | UPDATE | master.mesos:2181 |
      | $.env.POSTGRES_CPU | UPDATE | 0.5 |
      | $.env.POSTGRES_MESOS_MASTER | UPDATE | master.mesos:2181 |
      | $.env.VAULT_PORT | UPDATE | 8200 |
      | $.env.POSTGRES_DOCKER_IMAGE | UPDATE | qa.stratio.com/stratio/postgresql-community:${COMMUNITY_VERSION} |
      | $.env.POSTGRES_SERVICE_NAME | UPDATE | ${INSTANCE} |
      | $.container.docker.image | UPDATE | qa.stratio.com/stratio/postgres-bigdata-framework:${FRAMEWORK_VERSION} |
      | $.labels.DCOS_SERVICE_NAME | UPDATE | ${INSTANCE} |
      | $.labels.DCOS_PACKAGE_FRAMEWORK_NAME | UPDATE | ${INSTANCE} |
    Then the service response status must be '201'
    Given I open a ssh connection to '${DCOS_CLI_HOST}' with user '${CLI_USER}' and password '${CLI_PASSWORD}'
    When in less than '300' seconds, checking each '10' seconds, I send a 'GET' request to '/service/${INSTANCE}/v1/service/status' so that the response contains 'RUNNING'
    Then I save element '$.status[0].status' in environment variable 'pg_0001'
    #Then I save element '$.status[1].status' in environment variable 'pg_0002'
    #Then I save element '$.status[2].status' in environment variable 'pg_0003'
    And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${INSTANCE}/v1/service/status' so that the response contains '"pg_0001","role":"master","status":"RUNNING"'
    #And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${INSTANCE}/v1/service/status' so that the response contains '"pg_0002","role":"sync_slave","status":"RUNNING"'
    #And in less than '300' seconds, checking each '20' seconds, I send a 'GET' request to '/service/${INSTANCE}/v1/service/status' so that the response contains '"pg_0003","role":"async_slave","status":"RUNNING"'

  ##################################################
  ## INSTALL VALKIRIA
  ##################################################
  @runOnEnv(INSTALL_VALKIRIA)
  @loop(PRIVATE_AGENTS_LIST,PRIVATE_IP)
  Scenario: Install Valkiria (PHASE 2)
    Given I open a ssh connection to '<PRIVATE_IP>' with user 'cloud-user' using pem file 'src/test/resources/credentials/key.pem'
    When I run 'sudo mkdir /tmp/valkiria && sudo cd /tmp/valkiria && sudo wget http://sodio.stratio.com/repository/paas/valkiria/0.2.0-SNAPSHOT/valkiria-0.2.0-SNAPSHOT.tar.gz && tar -xvf valkiria-0.2.0-SNAPSHOT.tar.gz' in the ssh connection with exit status '0'
