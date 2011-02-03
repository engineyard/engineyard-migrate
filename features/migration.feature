Feature: Migration
  In order to reduce cost of migrating from Heroku to AppCloud
  As a developer
  I want to migrate as much of my Heroku-hosted application to AppCloud

  Scenario: Migrate a simple app
    Given I have setup my SSH keys
    And I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "app"
    And I have setup my Heroku credentials
    And I have a Heroku application "heroku2ey-simple-app"
    And it has "heroku2ey-simple-app" production data
    And I have setup my AppCloud credentials
    And I have an AppCloud account "heroku2ey" with environment "heroku2eysimpleapp_production"
    When I run local executable "heroku2ey" with arguments "migrate . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see "Migration complete!"
    When I visit the AppCloud application
    Then I should see the "heroku2ey-simple-app" production data displayed
  
  
  
