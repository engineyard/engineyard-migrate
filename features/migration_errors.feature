Feature: Migration errors
  I want useful error messages and prompts

  Scenario: Fail if application isn't on Heroku
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    When I run local executable "ey-migrate" with arguments "heroku . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      Not a Salesforce Heroku application.
      """

  Scenario: Fail if no Git 'origin' repo URI
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials
    Given I run executable "git" with arguments "remote rm origin"
    When I run local executable "ey-migrate" with arguments "heroku . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      Please host your Git repo externally and add as remote 'origin'.
      """

  Scenario: Fail if AppCloud credentials not available
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials

    When I run local executable "ey-migrate" with arguments "heroku . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see
      """
      Please create, boot and deploy an AppCloud application for git@github.com:engineyard/heroku2ey-simple-app.git.
      """

  Scenario: Fail if no AppCloud environments/applications match this application
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials

    Given I have setup my AppCloud credentials
    And I run executable "git" with arguments "remote rm origin"
    And I run executable "git" with arguments "remote add origin git@github.com:engineyard/UNKNOWN.git"
  
    When I run local executable "ey-migrate" with arguments "heroku . -e heroku2eysimpleapp_production"
    Then I should see
      """
      Please create, boot and deploy an AppCloud application for git@github.com:engineyard/UNKNOWN.git.
      """

  Scenario: Fail if too many AppCloud environments match
    Given I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"
    And I have a Heroku application "heroku2ey-simple-app"
    And I have setup my SSH keys
    And I have setup my Heroku credentials

    Given I have setup my AppCloud credentials
    When I run local executable "ey-migrate" with arguments "heroku . -V"
    Then I should see "Multiple environments possible, please be more specific:"
    Then I should see
      """
        ey-migrate heroku . --app='heroku2eysimpleapp' --account='heroku2ey' --environment='heroku2eysimpleapp_production'
        ey-migrate heroku . --app='heroku2eysimpleapp' --account='heroku2ey' --environment='heroku2ey_noinstances'
      """
      

  Scenario: Fail if environment hasn't been booted yet
    Given I have setup my SSH keys
    And I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"

    And I have setup my Heroku credentials
    And I have a Heroku application "heroku2ey-simple-app"

    Given I have setup my AppCloud credentials

    When I run local executable "ey-migrate" with arguments "heroku . -e heroku2ey_noinstances"
    Then I should see
      """
      Please boot your AppCloud environment and then deploy your application.
      """

  Scenario: Fail if application hasn't been deployed yet
    Given I have setup my SSH keys
    And I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"

    And I have setup my Heroku credentials
    And I have a Heroku application "heroku2ey-simple-app"

    Given I have setup my AppCloud credentials
    And I remove AppCloud "heroku2eysimpleapp_production" application "heroku2eysimpleapp" folder

    When I run local executable "ey-migrate" with arguments "heroku . -e heroku2eysimpleapp_production"
    Then I should see
      """
      Please deploy your AppCloud application before running migration.
      """

