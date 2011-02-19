Feature: Migration from Heroku
  In order to reduce cost of migrating from Heroku to AppCloud
  As a developer
  I want to migrate as much of my Heroku-hosted application to AppCloud

  Scenario: Migrate a simple app
    Given I have setup my SSH keys
    And I clone the application "git@github.com:engineyard/heroku2ey-simple-app.git" as "simple-app"

    And I have setup my Heroku credentials
    And I have a Heroku application "heroku2ey-simple-app"
    And it has production data
    When I visit the application at "heroku2ey-simple-app.heroku.com"
    Then I should see table
      | People |
      | Dr Nic |
      | Danish |

    Given I have setup my AppCloud credentials
    And I reset the AppCloud "heroku2eysimpleapp_production" application "heroku2eysimpleapp" database
    When I visit the application at "ec2-50-17-248-148.compute-1.amazonaws.com"
    Then I should see table
      | People |

    When I run local executable "ey-migrate" with arguments "heroku . --account heroku2ey --environment heroku2eysimpleapp_production"
    Then I should see "Migration complete!"
    When I visit the application at "ec2-50-17-248-148.compute-1.amazonaws.com"
    Then I should see table
      | People |
      | Dr Nic |
      | Danish |
  
  
  
  
  