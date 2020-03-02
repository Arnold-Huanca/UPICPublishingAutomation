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
      | RevisionUID | ReleaseLevelUID | ImportDate                |
      | 115500      | 40              | 2020-01-28 16:10:24.187   |

    When I open the RabbitMQ management
    And I click "UPIC Translator Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Importer Legacy" indicating availability of new data
    And I verify that the message received from "UPIC Importer Legacy" include the following data:
      | jobID   | status  | startTime  | endTime   | elapsedTime  | RevisionUID | programsCount     | corporateZipCount | postalZipCount    | message          |
      | ID_data | SUCCESS | time_Data  | time_Data | 322 seconds  | 115500      | Imported, Failed  | Imported, Failed  | Imported, Failed  | Import succeeded |


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
      | RevisionUID | ReleaseLevelUID | ImportDate                |
      | 115500      | 40              | 2020-01-28 16:10:24.187   |


  #AH
  Scenario Outline: Verify that 'Importer Legacy' is not triggered by a failed AMQP message emitted by the 'UPIC Importer New'
    Given I open the RabbitMQ management
    When I click "UPIC Importer Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message <propertyKey>, <propertyValue>, <payload>, <statusInPayload>, <messageInPayload>
    And I click "Publish Message" button
    Then I verify that "running importer legacy" message is not displayed in the log file for "UPIC Importer Legacy"
    And I verify that "Ignoring import event with invalid status" message is displayed in the log file for "UPIC Importer Legacy"

    When I open Microsoft SQL Management
    And I go to UPIC DB
    Then I verify that no new revision is populated in 'Revision' table

    Examples:
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAILURE         | Automatic trigger |
      | content_type  | application/json  | jsonContent  | FAIL            | Automatic trigger |


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


  #AH
  Scenario: Verify that 'Importer Legacy' sends an AMQP message upon completion when it fail
    # Preconditions
    Given I connect to kube environment
    When I edit the timeout to 2 in configmap file for "UPIC Incentives Importer"
    And I save the change made
    Then I verify that configmap was updated
    #-----------------

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running importer with jobId" message is displayed in the log file for "UPIC Importer Legacy"
    And I verify that "ERROR Importer" message is displayed in the log file for "UPIC Importer Legacy"

    When I open Microsoft SQL Management
    And I go to UPIC DB
    Then I verify that new revision is populated in 'Revision' table with the new feed data
      | RevisionUID | ImportDate                |
      | 115500      | 2020-01-28 16:10:24.187   |

    When I open the RabbitMQ management
    And I click "UPIC Translator Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Importer Legacy" indicating availability of new data
    And I verify that the message received from "UPIC Importer Legacy" include the following data:
      | jobID   | status  | startTime  | endTime   | elapsedTime  | RevisionUID | programsCount     | corporateZipCount | postalZipCount    | message             |
      | ID_data | FAILURE | time_Data  | time_Data | 120 seconds  | 115500      | Imported, Failed  | Imported, Failed  | Imported, Failed  | Importer timed out  |


  #AH
  Scenario: Verify that 'Importer Legacy' skips the UPIC data when the feed is older than or equal than the last imported
    # Preconditions
    Given I upload a file with a previous or equal date of the last imported
    Then I verify that file is uploaded to sftp.importer folder
    #-----------------

    When I open the log file for 'UPIC Importer Legacy'
    Then I verify that "Skipping upic-feed ..." message is displayed with the following data:
     | upic-feed filename,  imported_date,  last_imported_date,  current_datastore_id,  job_id,  namespace  |
    And I verify that "Importer has skipped the feed" message is displayed in the log file for "UPIC Importer Legacy"
