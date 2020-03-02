Feature: UPIC Importer New

  # AH
  Scenario: Verify that 'Incentives SFTP Importer' uploads UPIC feeds file from FileShare to Azure Data Store
    Given I connect to the sftp.importer
    When I go the path "/share/upic/" where the UPIC data is processed
    And I upload a zip file with the following pattern UPIC_B2CUS_{timestamp}
    Then I verify that "poll cycle starting..." message is displayed in the log file for "sftp.importer"
    And I verify that "UPIC Incentives SFTP Importer" retrieves the file only when the uploading is completed
    Then I verify that "Started" message is displayed in the log file for "UPIC Incentives SFTP Importer"
    And I verify that "Downloaded" message is displayed in the log file for "UPIC Incentives SFTP Importer"
    And I verify that "Stored" and "Uploaded "/share/upic/UPIC_B2CUS_202002070350.zip" to datastore with ID..." messages are displayed in the log file for "UPIC Incentives SFTP Importer"
    And I verify that "... for deletion" message is displayed in the log file for "UPIC Incentives SFTP Importer"
    And I verify that "SUCCESS" message is displayed in the log file for "UPIC Incentives SFTP Importer"

    When I open Microsoft Azure Storage
    And I open "upic-feed" blob container
    Then I verify that new 2 blob files are uploaded to Azure Data Store with same datetime
    And I right click in the blob file with shorter name which is the dataStoreID
    And I verify that feed blob file name associated to the dataStoreID is the other blob file
    And I close the Blob properties popup
    And I download the blob file name associated to the dataStoreID
    And I rename the downloaded file to add ".zip" extension
    And I verify that a UPIC data is present into the zip file

    When I connect to the FileShare
    And I go the path "/share/upic/" where the UPIC data is processed
    Then I verify that the zip file with the following pattern UPIC_B2CUS_{timestamp} was deleted

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives SFTP Importer indicating availability of new UPIC data
    And I verify that the message received from "UPIC Incentives Importer" include the following data:
      | Status   | Application             | datastoreId                           | status   | SourceFileName                          | JobID                                 | Message   | Timestamp            |
      | SUCCESS | incentives-sftp-importer | 8e7b5b63-e98f-449f-8528-e09684960e18  | SUCCESS  | /share/upic/UPIC_B2CUS_202002071500.zip | 93c6acb7-72f8-4a3a-9dbe-d9bb2079f026  | empty     | 2020-02-07T17:01Z    |


    # AH
  Scenario Outline: Verify that 'Incentives SFTP Importer' does not delete UPIC feeds file from FileShare when the process is 'FAILURE' status
    Given I connect to the sftp.importer
    When I go the path "/share/upic/" where the UPIC data is processed
    And I upload an invalid UPIC feed file with the following pattern "<feedFile>"
    Then I verify that "poll cycle starting..." message is displayed in the log file for "sftp.importer"
    And I verify that "UPIC Incentives SFTP Importer" does not retrieve the file
    And I verify that "FAILURE" message is displayed in the log file for "UPIC Incentives SFTP Importer"

    When I open Microsoft Azure Storage
    And I open "upic-feed" blob container
    Then I verify that no new blob files are uploaded to Azure Data Store with same datetime

    When I connect to the FileShare
    And I go the path "/share/upic/" where the UPIC data is processed
    Then I verify that the zip file with the following pattern "<feedFile>" was not deleted

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives SFTP Importer" with 'FAILURE' status

    Examples:
    | feedFile                   |
    | UPIC_B2CUS_{timestamp}     |

  # AH
  Scenario: Verify that 'Incentives SFTP Importer' creates only one new blob file when the same file is uploaded with different datetime
    Given I connect to the sftp.importer
    When I go the path "/share/upic/" where the UPIC data is processed
    And I upload a UPIC feed file with the following pattern "<feedFile>"
    Then I verify that "poll cycle starting..." message is displayed in the log file for "sftp.importer"
    And I verify that "UPIC Incentives SFTP Importer" retrieves the file
    And I verify that "SUCCESS" message is displayed in the log file for "UPIC Incentives SFTP Importer"
    And I go the path "/share/upic/" where the UPIC data is processed
    And I upload the same previous UPIC feed file uploaded but with different datetime and with the following pattern "<feedFile>"

    When I open Microsoft Azure Storage
    And I open "upic-feed" blob container
    Then I verify that only one blob file is uploaded to Azure Data Store pointing to previous file uploaded

    When I connect to the FileShare
    And I go the path "/share/upic/" where the UPIC data is processed
    Then I verify that the zip file with the following pattern "<feedFile>" was deleted

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives SFTP Importer" indicating availability of new UPIC data

    Examples:
      | feedFile                   |
      | UPIC_B2CUS_{timestamp}     |


     # AH
  Scenario Outline: Verify that 'Incentives SFTP Importer' does not upload UPIC feeds file to Azure Data Store when it has invalid pattern
    Given I connect to the sftp.importer
    When I go the path "/share/upic/" where the UPIC data will be processed
    And I upload a zip file with the following pattern "<feedFilePattern>"
    Then I verify that "poll cycle starting..." message is displayed in the log file for "sftp.importer"
    And I verify that "poll cycle ending - no work to be done - skipping 0 changed files" message is displayed in the log file for "sftp.importer" if no file to be processed is found

    When I open Microsoft Azure Storage
    And I open "upic-feed" blob container
    Then I verify that no new blob files are uploaded to Azure Data Store with same datetime

    When I connect to the FileShare
    And I go the path where the UPIC data was stored
    Then I verify that the zip file with the following pattern "<feedFilePattern>" was not deleted

    When I open the RabbitMQ management
    And I click "UPIC Importer Legacy" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives SFTP Importer" indicating availability of new UPIC data

    Examples:
      | feedFilePattern                     |
      | UPIC_B2CUX_                         |
      | UPIC_B2CUS                          |
      | 202002140_UPIC_B2CUS                |
      | 20                                  |
      | UPIC_B2CUS_2020020715600_done       |
      | UPIC_B2CUS_2020020715600_changes    |
      | UPIC_B2CUS_2020020715600_processed  |
