Feature: Notifier

  # AH
  @IncentivesTranslator
  Scenario: Verify that 'UPIC Notifier' generates an email message after the 'success' completion of the Incentives Translator
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "UPIC Incentives Translator ETL Completion - [ SUCCESS ]" email notification is displayed


  # AH
  Scenario: Verify that 'UPIC Notifier' generates an email message after the completion of the Incentives Translator with 'failure' status
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAILURE         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "UPIC Incentives Translator ETL Completion - [ FAILURE ]" email notification is displayed



  # AH
  @ImporterLegacy
  Scenario: Verify that 'UPIC Notifier' does not generate an email message after the 'success' completion of the ImporterLegacy
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "Incentives ETL - [upic-importer] Completion - [ SUCCESS ]" email notification is not displayed


  # AH
  Scenario: Verify that 'UPIC Notifier' generates an email message after the completion of the ImporterLegacy with 'failure' status
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAILURE         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "Incentives ETL - [upic-importer] Completion - [ FAILURE ]" email notification is displayed

  @TranslatorLegacy
  #AH
  #FCAUUPA-85
  Scenario: Verify that 'UPIC Notifier' generates an email message after the 'success' completion of the ImporterLegacy
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "Incentives ETL - [upic-translator] Completion - [ SUCCESS ]" email notification is displayed


  # AH
  Scenario: Verify that 'UPIC Notifier' does not generate an email message after the completion of the ImporterLegacy with 'failure' status
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  |
      | content_type  | application/json  | jsonContent  | FAILURE         | Automatic trigger |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "Incentives ETL - [upic-translator] Completion - [ FAILURE ]" email notification is displayed
