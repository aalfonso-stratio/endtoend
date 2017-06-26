# README

## ACCEPTANCE TESTS

Cucumber automated acceptance tests for End to End Demo.
Multiple technologies will be involved in this demo:

* Khermes: For random data generation.
* Kafka: As stream processor. 
* Sparta: To process data.
* Elasticsearch: To store processed info.
* Postgres: To store processed data.
* Valkiria: For chaos generation.

This module depends on a QA library (stratio-test-bdd), where common logic and steps are implemented.

## EXECUTION

These tests will be executed as part of the continuous integration flow as follows:

mvn verify [-D\<ENV_VAR>=\<VALUE>] [-Dit.test=\<TEST_TO_EXECUTE>|-Dgroups=\<GROUP_TO_EXECUTE>]

Example:

mvn verify -U -DDCOS_CLI_HOST=dcos-cli.demo.stratio.com -DDCOS_CLI_USER=root -DDCOS_CLI_PASSWORD=stratio -DPAAS_UNIVERSE_NAME=myuniverse -DPAAS_UNIVERSE_VERSION=0.2.0-SNAPSHOT -Dgroups=universe

By default, in jenkins we will execute the group endtoend, which could contain a subset of tests, that are key to the functioning of the module and the ones generated for the new feature.

All tests, that are not fully implemented, should be tagged with '@ignore @tillfixed(PAAS-XXX)'
