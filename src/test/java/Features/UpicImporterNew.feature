Feature: UPIC Importer New

  # AH
  Scenario: Verify that 'UPIC Importer New' upload UPIC feeds file from FileShare to Azure Data Store
    Given I connect to the FileShare
    When I go the path where the UPIC data is stored
    Then I verify that a zip file is displayed with the following pattern UPIC_B2CUS_{timestamp}
    And I verify that the feed file name has no additions appended like:
      | additionalText |
      | _changes       |
      | _processed     |
      | _failed        |
    And I verify that "UPIC Importer New" retrieves the file only when the uploading is completed
    Then I verify that "running importer new with jobId" message is displayed in the log file for "UPIC Importer New"
    And I verify that "uploaded file to datastore with datastoreId:" message is displayed in the log file for "UPIC Importer new"
    And I verify that "completed import process with a status of: SUCCESS and result of: import succeeded." message is displayed in the log file for "UPIC Importer New"


    When I open Microsoft Azure Storage
    And I open "upic-importer-new" blob container
    Then I verify that new 2 blob files are uploaded to Azure Data Store with same datetime
    And I right click in the blob file with shorter name which is the dataStoreID
    And I verify that feed blob file name associated to the dataStoreID is the other blob file
    And I close the Blob properties popup
    And I download the blob file name associated to the dataStoreID
    And I rename the downloaded file to add ".zip" extension
    And I verify that a UPIC data is present into the zip file

    When I connect to the FileShare
    And I go the path where the UPIC data was stored
    Then I verify that the zip file with the following pattern UPIC_B2CUS_{timestamp} was deleted

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives New" indicating availability of new UPIC data
    And I verify that the message received from "UPIC Incentives Importer" include the following data:
      | jobID   | nameSpace | datastoreId | status   | fileName                    | startTime  | endTime   | message              |
      | ID_data | upic-feed | ID          | SUCCESS  | UPIC_B2CUS_201911270100.zip | time_Data  | time_Data | process completed    |


    # AH
  Scenario: Verify that 'UPIC Importer New' does not delete UPIC feeds file from FileShare when the process is 'FAILURE' status
    # Preconditions
    Given I upload an invalid UPIC feed file into the FileShare
    #-----------------

    Given I connect to the FileShare
    When I go the path where the UPIC data is stored
    Then I verify that a zip file is displayed with the following pattern UPIC_B2CUS_{timestamp}
    And I verify that the feed file name has no additions appended like:
      | additionalText |
      | _changes       |
      | _processed     |
      | _failed        |
    And I verify that "UPIC Importer New" retrieves the file only when the uploading is completed
    Then I verify that "running importer new with jobId" message is displayed in the log file for "UPIC Importer New"
    And I verify that "completed import process with a status of: FAILURE" message is displayed in the log file for "UPIC Importer New"


    When I open Microsoft Azure Storage
    And I open "upic-importer-new" blob container
    Then I verify that no new blob files are uploaded to Azure Data Store with same datetime

    When I connect to the FileShare
    And I go the path where the UPIC data was stored
    Then I verify that the zip file with the following pattern UPIC_B2CUS_{timestamp} was not deleted

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    Then I verify that no AMQP message arrives from "UPIC Incentives New" indicating availability of new UPIC data
