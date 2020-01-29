Feature: Incentives Importer

  # AH
  Scenario: Verify that 'Incentives Importer' retrieves Incentive Data for UPIC source from OMSProgramIncentive DB
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Importer" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives importer for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that "uploaded file to datastore with datastoreId:" message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that "completed incentives import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Incentives Importer"

    When I open Microsoft Azure Storage
    And I open "upic-incentives" blob container
    Then I verify that new 2 blob files are uploaded to Azure Data Store with same datetime
    And I right click in the blob file with shorter name which is the dataStoreID
    And I verify that feed blob file name associated to the dataStoreID is the other blob file
    And I close the Blob properties popup
    And I download the blob file name associated to the dataStoreID
    And I rename the downloaded file to add ".zip" extension
    And I verify that a CSV file is present for each dataTable into the zip file
      | dataTable              |
      | Program                |
      | ProgramIncentive       |
      | ProgramRegion          |
      | Programvehicle         |
      | ProgramvehicleDetails  |
    And I verify that all data for "UPIC" source is displayed in each file

    When I open the RabbitMQ management
    And I click "UPIC Incentives Translator" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Importer" indicating availability of new Incentives data
    And I verify that the message received from "UPIC Incentives Importer" include the following data:
      | timestamp | jobID   | status  | datastoreId |nameSpace        | message          | incentiveSource  | startTime  | endTime   |
      | time_Data | ID_data | SUCCESS | ID          |upic-incentives  | import succeeded | UPIC             | time_Data  | time_Data |


  # AH
  Scenario: Verify that 'Incentives Importer' retrieves Incentive Data for StdRates source from OMSProgramIncentive DB
    # Preconditions
    Given I connect to kube environment
    When I edit the program.source to "StdRates" in configmap file for "UPIC Incentives Importer"
    And I save the change made
    Then I verify that configmap was updated
    #-----------------

    Given I open the RabbitMQ management
    When I click "UPIC Incentives Importer" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives importer with jobId" message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that "uploaded file to datastore with datastoreId:" message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that "completed incentives import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Incentives Importer"

    When  I open Microsoft Azure Storage
    And I open "upic-incentives" blob container
    Then I verify that new 2 blob files are uploaded to Azure Data Store with same datetime
    And I right click in the blob file with shorter name which is the dataStoreID
    And I verify that feed blob file name associated to the dataStoreID is the other blob file
    And I close the Blob properties popup
    And I download the blob file name associated to the dataStoreID
    And I rename the downloaded file to add ".zip" extension
    And I verify that a CSV file is present for each dataTable into the zip file
      | dataTable              |
      | Program                |
      | ProgramIncentive       |
      | ProgramRegion          |
      | Programvehicle         |
      | ProgramvehicleDetails  |
    And I verify that all data for "StdRates" source is displayed in each file into the zip file

    When I open the RabbitMQ management
    And I click "UPIC Incentives Translator" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Importer" indicating availability of new Incentives data
    And I verify that the message received from "UPIC Incentives Importer" include the following data:
      | timestamp | jobID   | status  | datastoreId |nameSpace        | message          | incentiveSource  | startTime  | endTime   |
      | time_Data | ID_data | SUCCESS |  ID         |upic-incentives  | import succeeded | StdRates         | time_Data  | time_Data |


  # AH
  Scenario: Verify that 'UPIC Incentives Importer' is triggered by a manual success AMQP message published in a proper exchange
    Given I open the RabbitMQ management
    When I click "ETL Commands" on 'Exchanges' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
    | routingkey                      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload           |
    | upic.incentives.importer.start  | content_type  | application/json  | jsonContent  | SUCCESS         | Manual trigger published   |
    And I click "Publish Message" button
    Then I verify that "running incentives importer with jobId" message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that "uploaded file to datastore with datastoreId:" message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that "completed incentives import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that new blob file is uploaded to Azure Data Store


  #AH
  Scenario: Verify that 'UPIC Incentives Importer' is not triggered by a failed AMQP message emitted by the 'UPIC translator'
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Importer" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAIL            | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives importer" message is not displayed in the log file for "UPIC Incentives Importer"
    And I verify that no blob file is uploaded to Azure Data Store


  # AH
  Scenario: Verify that 'UPIC Incentives Importer' tries to upload 5 times the UPIC feeds when there is no connection to Azure Data Store
    # Preconditions
    Given I connect to kube environment
    When I edit the blobstore-key in azure-credentials yaml file with an invalid key
    And I save the change made
    Then I verify that azure-credentials was updated
    #-----------------

    Given I open the RabbitMQ management
    When I click "UPIC Incentives Importer" on 'Queues' tab
    And I expand "Publish message" section
    And I fill 'Properties' and 'Payload' fields with a "SUCCESS" status
    And I click "Publish Message" button
    Then I verify that an error message is displayed in the log file for "UPIC Incentives Importer"
    And I verify that no blob file is uploaded to Azure Data Store

    When I open the RabbitMQ management
    And I click "UPIC Incentives Translator" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Importer" indicating availability of new Incentives data
    And I verify that the message received from "UPIC Incentives Importer" include the following data:
      | timestamp | status  | message                     |
      | time_Data | FAIL    | failed message description  |


  # AH
  Scenario: Verify that 'UPIC Incentives Importer' retrieves Incentive Data for UPIC source from OMSProgramIncentive DB after updating some values each data table
    # Preconditions
    Given I connect to Microsoft SQL Server Management Studio
    When I execute a query to update some values in each data table
      | dataTable              |
      | Program                |
      | ProgramIncentive       |
      | ProgramRegion          |
      | Programvehicle         |
      | ProgramvehicleDetails  |

    And I execute a query to check the values
    Then I verify that values were updated
    #-----------------

    Given I open the RabbitMQ management
    When I click "UPIC Incentives Importer" on 'Queues' tab
    And I expand "Publish message" section
    And I fill 'Properties' and 'Payload' fields with a "SUCCESS" status
    And I click "Publish Message" button
    Then I verify that "running incentives importer" message is displayed in the log file for "UPIC Incentives Importer"

    When  I open Microsoft Azure Storage
    And I open "upic-incentives" blob container
    Then I verify that new blob file is uploaded to Azure Data Store
    And I download the blob file name associated to the dataStoreID
    And I rename the downloaded file to add ".zip" extension
    And I verify that every value updated is present in each file generated into the zip file


  # AH
  # This scenario needs AMQP message from the new UPIC Translator
  Scenario Outline: Verify that an AMQP message arrives to 'UPI Incentives Importer' emitted by the 'UPIC translator'
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Importer" on 'Queues' tab
    And I expand "Get messages" section
    And I click "Get Message(s)" button
    Then I verify that the message received from "UPIC translator" include the following data:
      | <timestamp> | <jobID>   | <status>  | <message>      | <startTime>  | <endTime>   |
    And I verify that "running incentives importer with jobId" message is displayed in the log file for "UPIC Incentives Importer"

    Examples:
      | timestamp | jobID   | status  | message            | startTime  | endTime   |
      | time_Data | ID_data | SUCCESS | Successful message | time_Data  | time_Data |
      | time_Data | ID_data | FAIL    | Failed message     | time_Data  | time_Data |

