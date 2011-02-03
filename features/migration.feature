Feature: Migration
  In order to reduce cost of migrating from Heroku to AppCloud
  As a developer
  I want to migrate as much of my Heroku-hosted application to AppCloud

  Scenario: Migrate a simple app
    Given I have a Heroku application "heroku2ey-simple-app"
    And it has "heroku2ey-simple-app" production data
    And the source is hosted at "git@github.com:engineyard/heroku2ey-simple-app.git"
    And I have an AppCloud account "heroku2ey" with environment "heroku2ey-simple-app-production"
    When I run local executable "heroku2ey" with arguments ". --account heroku2ey --environment heroku2ey-simple-app-production"
    Then I should see "Migration complete!"
    When I visit the AppCloud application
    Then I should see the "heroku2ey-simple-app" production data displayed
  
  
  
