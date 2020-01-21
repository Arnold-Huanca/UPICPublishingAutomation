Feature: UPIC Translator Legacy

  # AH
  Scenario: Verify that 'Translator Legacy' retrieves data from CWD database and translates into the OMSLookupMasterData and OMSProgramIncentive databases.
    Given I open the RabbitMQ management
    And I click "UPIC Translator Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running translator with jobId" message is displayed in the log file for "UPIC Translator Legacy"
    And I verify that "completed import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Importer Legacy"

    When I open Microsoft SQL Management
    And I go to OMSLookupMasterData database
    Then I verify that new data is populated in the OMSLookupMasterData database
    And I go to OMSProgramIncentive database
    Then I verify that new data is populated in the OMSProgramIncentive database
    And I verify that 'OMSLookupMasterData' and 'OMSProgramIncentive' databases are replicated to OMS Prod

    When I open the RabbitMQ management
    And I click "UPIC Incentives Importer" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Translator Legacy" indicating availability of new Incentives data
    And I verify that the message received from "UPIC Translator Legacy" include the following data:
      | timestamp | jobID   | status  | message                 | startTime  | endTime   |
      | time_Data | ID_data | SUCCESS | completed successfully  | time_Data  | time_Data |

    
     # AH
  Scenario: Verify that 'Translator Legacy' is triggered by a manual success AMQP message published in a proper exchange
    Given I open the RabbitMQ management
    When I click "ETL Commands" on 'Exchanges' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | routingkey             | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload           |
      | translator.upic.start  | content_type  | application/json  | jsonContent  | SUCCESS         | Manual trigger published   |
    And I click "Publish Message" button
    Then I verify that "running importer legacy with jobId" message is displayed in the log file for "UPIC Translator Legacy"
    And I verify that "completed import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Translator Legacy"

    When I open Microsoft SQL Management
    And I go to OMSLookupMasterData database
    Then I verify that new data is populated in the OMSLookupMasterData database
    And I go to OMSProgramIncentive database
    Then I verify that new data is populated in the OMSProgramIncentive database


     #AH
  Scenario: Verify that 'Translator Legacy' is not triggered by a failed AMQP message emitted by the 'UPIC translator'
    Given I open the RabbitMQ management
    When I click "UPIC Importer Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAIL            | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running importer legacy" message is not displayed in the log file for "UPIC Translator Legacy"

    When I open Microsoft SQL Management
    And I go to UPIC DB
    Then I verify that no new data is populated in 'OMSLookupMasterData' and 'OMSProgramIncentive' databases