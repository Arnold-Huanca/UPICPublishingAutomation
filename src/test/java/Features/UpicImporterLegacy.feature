Feature: UPIC Importer Legacy

  # AH
  Scenario: Verify that 'Importer Legacy' retrieves feeds files from FileShare and populate a new revision in UPIC database
    Given I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running importer with jobId" message is displayed in the log file for "UPIC Importer Legacy"
    And I verify that "completed import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Importer Legacy"

    When I open Microsoft SQL Management
    And I go to UPIC DB
    Then I verify that new revision is populated in 'Revision' table with the new feed data
      | RevisionUID | ReleaseLevelUID | ImportDate |
      | UID         | 40              | dateTime   |

    When I open the RabbitMQ management
    And I click "UPIC Translator Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Importer Legacy" indicating availability of new Incentives data
    And I verify that the message received from "UPIC Importer Legacy" include the following data:
      | timestamp | jobID   | status  | datastoreId | message          | startTime  | endTime   | UPIC RevisionUID | programsCount     | corporateZipCount | postalZipCount    |
      | time_Data | ID_data | SUCCESS | ID          | import succeeded | time_Data  | time_Data | 40               | imported, Failed  | imported, Failed  | imported, Failed  |


 # AH
  Scenario: Verify that 'Importer Legacy' is triggered by a manual success AMQP message published in a proper exchange
    Given I open the RabbitMQ management
    When I click "ETL Commands" on 'Exchanges' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | routingkey           | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload           |
      | upic.importer.start  | content_type  | application/json  | jsonContent  | SUCCESS         | Manual trigger published   |
    And I click "Publish Message" button
    Then I verify that "running importer legacy with jobId" message is displayed in the log file for "UPIC Importer Legacy"
    And I verify that "completed import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Importer Legacy"

    When I open Microsoft SQL Management
    And I go to UPIC DB
    Then I verify that new revision is populated in 'Revision' table with the new feed data
      | RevisionUID | ReleaseLevelUID | ImportDate |
      | UID         | 40              | dateTime   |


     #AH
  Scenario: Verify that 'Importer Legacy' is not triggered by a failed AMQP message emitted by the 'UPIC translator'
    Given I open the RabbitMQ management
    When I click "UPIC Importer Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAIL            | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running importer legacy" message is not displayed in the log file for "UPIC Importer Legacy"

    When I open Microsoft SQL Management
    And I go to UPIC DB
    Then I verify that no new revision is populated in 'Revision' table


  #AH
  Scenario: Verify that 'Importer Legacy' does not retrieve the UPIC data from Azure datastore when using an invalid datastore ID indicated in the message
    Given I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  | dataStoreID |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger | invalidID   |
    And I click "Publish Message" button
    Then I verify that "running importer with jobId" message is displayed in the log file for "UPIC Importer Legacy"
    And I verify that error message is displayed in the log file for "UPIC Importer Legacy"




