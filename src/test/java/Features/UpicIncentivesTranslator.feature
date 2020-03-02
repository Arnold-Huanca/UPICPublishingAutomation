Feature: Incentives Translator

  # AH
  Scenario Outline: Verify that 'UPIC Incentives Translator' retrieves Incentive Data for UPIC source and translate it into the 'CEVD Top Master' database
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Translator" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | incentiveSourceInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | UPIC                     | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "running incentives importer with jobId of translate-" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "begining translation of datastoreId:" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translate process with a status of SUCCESS." message is displayed in the log file for "UPIC Incentives Translator"

    When I open Microsoft SQL Management
    And I go to "CEVD Top Master" database
    Then I verify that "UPIC Incentives Translator" process starts only if the program count in the feed contains more than 'program.minimumProgramsUPIC' number of programs configured
    Then I verify that the programs for UPIC source are inserted in <dataTable> DB tables if there are new programs
    Then I verify that the programs for UPIC source are updated in <dataTable> DB tables  if there are data differences
    Then I verify that the programs for UPIC source are deleted in <dataTable> DB tables if the programs no longer exists in the source

    When I open the RabbitMQ management
    And I click "UPIC Notifier" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Translator" indicating process completed
    And I verify that the message received from "UPIC Incentives Translator" include the following data:
      | jobID   | status  | startTime  | endTime   | elapsedTime  | insertedCount  | insertedPrograms | deletedCount  | deletedPrograms  | updatedCount | updatedPrograms | failedCount | failedPrograms | sourceProgramCount | expiredCount | expiredPrograms | message                                                                                                                       |
      | ID_data | SUCCESS | time_Data  | time_Data | 322 seconds  | number         | []               | number        | []               | number       | []              | number      | []             | number             | number       | []              |successfully translated incentives blob with datastoreId: a50ed318-d55e-4d90-9af7-e982a5313278 from namespace: upic-incentives |

    Examples:
      | dataTable                                                                       |
      | Program, ProgramIncentive, ProgramRegion, Programvehicle, ProgramvehicleDetails |


  # AH
 Scenario Outline: Verify that 'UPIC Incentives Translator' retrieves Incentive Data for StdRates source and translate it into the target database
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
      | propertyKey   | propertyValue     | payload      | statusInPayload | incentiveSourceInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | STDRATES                 | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "running incentives importer with jobId of translate-" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "begining translation of datastoreId:" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translate process with a status of SUCCESS." message is displayed in the log file for "UPIC Incentives Translator"

    When I open Microsoft SQL Management
    And I go to "CEVD Top Master" database
    Then I verify that "UPIC Incentives Translator" process starts only if the program count in the feed contains more than 'program.minimumProgramsUPIC' number of programs configured
    Then I verify that the programs for STDRATES source are inserted in <dataTable> DB tables if there are new programs
    Then I verify that the programs for STDRATES source are updated in <dataTable> DB tables  if there are data differences
    Then I verify that the programs for STDRATES source are deleted in <dataTable> DB tables if the programs no longer exists in the source

    When I open the RabbitMQ management
    And I click "UPIC Notifier" on 'Queues' tab
    Then I verify that an AMQP message arrives from "UPIC Incentives Translator" indicating process completed
    And I verify that the message received from "UPIC Incentives Translator" include the following data:
      | jobID   | status  | startTime  | endTime   | elapsedTime  | insertedCount  | insertedPrograms | deletedCount  | deletedPrograms  | updatedCount | updatedPrograms | failedCount | failedPrograms | sourceProgramCount | expiredCount | expiredPrograms | message                                                                                                                       |
      | ID_data | SUCCESS | time_Data  | time_Data | 322 seconds  | number         | []               | number        | []               | number       | []              | number      | []             | number             | number       | []              |successfully translated incentives blob with datastoreId: a50ed318-d55e-4d90-9af7-e982a5313278 from namespace: upic-incentives |

    Examples:
      | dataTable                                                                       |
      | Program, ProgramIncentive, ProgramRegion, Programvehicle, ProgramvehicleDetails |

  # AH
  Scenario: Verify that 'UPIC Incentives Translator' is triggered by a manual success AMQP message published in a proper exchange
    Given I open the RabbitMQ management
    When I click "ETL Commands" on 'Exchanges' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | routingkey                         | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload           |
      | upic.incentives.translator.start   | content_type  | application/json  | jsonContent  | SUCCESS         | Manual trigger published   |
    And I click "Publish Message" button
    Then I verify that "manually running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "running incentives importer with jobId of translate-" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "begining translation of datastoreId:" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translate process with a status of SUCCESS." message is displayed in the log file for "UPIC Incentives Translator"


  #AH
  Scenario: Verify that 'UPIC Incentives Translator' is not triggered by a failed AMQP message emitted by the 'UPIC Incentives Importer'
    Given I open the RabbitMQ management
    When I click "UPIC Incentives Translator" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAILURE         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "running incentives translator for message: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "ignoring message with unsuccessful status: TriggerMessage" message is displayed in the log file for "UPIC Incentives Translator"


  # AH
  Scenario: +
    # Preconditions
    Given I generate Incentives Data with less than 'program.minimumProgramsUPIC' number of programs configured by default 175 for UPIC and 85 for STDRATES
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
    And I verify that "running incentives importer with jobId of translate-" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "begining translation of datastoreId:" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "The program count in the feed does not meet the minimum of nnn for a program source of UPIC" message is displayed in the log file for "UPIC Incentives Translator"
    And I verify that "completed incentives translate process with a status of FAILURE." message is displayed in the log file for "UPIC Incentives Translator"