Feature: Incentives Translator

  # AH
  Scenario: Verify that 'UPIC Incentives Translator' retrieves Incentive Data for UPIC source and translate it into the 'CEVD Top Master' database
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Translator" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "incentive feed file (a zip file) is picked up from Azure DataStore" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translator process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Incentives Translator"

    When I open Microsoft SQL Management
    And I go to "CEVD Top Master" database
    Then I verify that the programs are populated/updated/deleted if the program count in the feed contains more than 175 number of programs
      | dataTable              |
      | Program                |
      | ProgramIncentive       |
      | ProgramRegion          |
      | Programvehicle         |
      | ProgramvehicleDetails  |

    And I verify that all expired programs are deleted from the target database based on Program.EndDate in the target DB
    And I verify that all data for "UPIC" source is displayed in the targetDB
    And I verify that 'Incentives Translator' clears incentive-ws cache before completion

    When I open the RabbitMQ management
    And I click "UPIC Notifier" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Translator" indicating process completed
    And I verify that the message received from "UPIC Incentives Translator" include the following data:
      | jobID   | status  | startTime  | endTime   | elapsedTime  | programsCount   | programsInsertedCount | programsUpdatedCount  | programsDeletedCount   | message           |
      | ID_data | SUCCESS | time_Data  | time_Data | 322 seconds  | TotalUPIC       | TotalInserted         | TotalUpdated          | TotalDeleted           |Import succeeded   |


  # AH
  Scenario: Verify that 'UPIC Incentives Translator' retrieves Incentive Data for StdRates source and translate it into the target database
    # Preconditions
    Given I generate Incentives Data with "StdRates" source
    When I open Microsoft Azure Storage
    And I open "upic-incentives" blob container
    Then I verify that new 2 blob files are uploaded to Azure Data Store with same datetime
    #-----------------

    Given I open the RabbitMQ management
    When I click "UPIC Incentives Translator" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "incentive feed file (a zip file) is picked up from Azure DataStore" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translator process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Incentives Translator"

    When I open Microsoft SQL Management
    And I go to "CEVD Top Master" database
    Then I verify that the programs are populated/updated/deleted if the program count in the feed contains more than 175 number of programs
      | dataTable              |
      | Program                |
      | ProgramIncentive       |
      | ProgramRegion          |
      | Programvehicle         |
      | ProgramvehicleDetails  |

    And I verify that all expired programs are deleted from the target database based on Program.EndDate in the target DB
    And I verify that all data for "StdRates" source is displayed in the DB
    And I verify that 'Incentives Translator' clears incentive-ws cache before completion

    When I open the RabbitMQ management
    And I click "UPIC Notifier" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Translator" indicating process completed
    And I verify that the message received from "UPIC Incentives Translator" include the following data:
      | jobID   | status  | startTime  | endTime   | elapsedTime  | programsCount   | programsInsertedCount | programsUpdatedCount  | programsDeletedCount   | message           |
      | ID_data | SUCCESS | time_Data  | time_Data | 322 seconds  | TotalUPIC       | TotalInserted         | TotalUpdated          | TotalDeleted           |Import succeeded   |


  # AH
  Scenario: Verify that 'UPIC Incentives Translator' is triggered by a manual success AMQP message published in a proper exchange
    Given I open the RabbitMQ management
    When I click "ETL Commands" on 'Exchanges' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | routingkey                         | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload           |
      | upic.incentives.translator.start   | content_type  | application/json  | jsonContent  | SUCCESS         | Manual trigger published   |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "translate it into the 'CEVD Top Master' database" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translate process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Incentives Translator"



  #AH
  Scenario: Verify that 'UPIC Incentives Translator' is not triggered by a failed AMQP message emitted by the 'UPIC Incentives Importer'
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Translator" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAILURE         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is not displayed in the log file for "UPIC Incentives Translator"


  # AH
  Scenario: Verify that 'UPIC Incentives Translator' does not populate/update/delete if the program count in the feed contains less than 175 number of programs
    # Preconditions
    Given I generate Incentives Data with less than 175 number of programs
    When I open Microsoft Azure Storage
    And I open "upic-incentives" blob container
    Then I verify that new 2 blob files are uploaded to Azure Data Store with same datetime
    #-----------------

    Given I open the RabbitMQ management
    When I click "UPIC Incentives Translator" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "incentive feed file (a zip file) is picked up from Azure DataStore" message is displayed in the log file for "UPIC Incentives Translator"