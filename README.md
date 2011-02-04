# Salesforce Heroku to Engine Yard AppCloud migration tool

**DO NOT OPEN SOURCE** until management of passwords/credentials for testing + CI is figured out and the codebase cleaned up + passwords possibly changed.

## Heroku Addons

### Cron [todo]

Examples:

    heroku addons:add cron:daily
    heroku addons:add cron:hourly

Heroku's `cron` addon ran your `rake cron` task, either daily or hourly.

A corresponding cron job will be created for you on AppCloud:

    cd /data/appname/current && RAILS_ENV=production rake cron

## Development

### Credentials

For the test Heroku + AppCloud accounts, the email is `ossgrants+heroku2ey@engineyard.com` and password `heroku2ey`.


