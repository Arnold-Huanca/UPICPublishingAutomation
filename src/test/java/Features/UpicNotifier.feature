Feature: Notifier

  # AH
  Scenario: Verify that 'UPIC Notifier' generates an email message after the 'success' completion of the Incentives Translator
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  | emailAddress  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger | customEmail   |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "UPIC Incentives Translator ETL Completion - [ SUCCESS ]" email notification is displayed


  # AH
  Scenario: Verify that 'UPIC Notifier' generates a email message after not completing of the Incentives Translator
    Given I open the RabbitMQ management
    When I click "UPIC Notifier" on 'Queues' tab
    And I expand "Publish message" section
    And I fill the following fields for publishing an AMQP message
      | propertyKey   | propertyValue     | payload      | statusInPayload | messageInPayload  | emailAddress  |
      | content_type  | application/json  | jsonContent  | SUCCESS         | Automatic trigger | customEmail   |
    And I click "Publish Message" button
    Then I verify that "email notification was sent" message is displayed in the log file for "UPIC Notifier"

    When I open user Inbox
    Then I verify that the "UPIC Incentives Translator ETL Completion - [ FAILURE ]" email notification is displayed