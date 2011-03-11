# Migrate your Rails application to Engine Yard AppCloud

Want to migrate your Ruby on Rails application from Heroku (or similar) up to Engine Yard AppCloud? This is the tool for you.

Currently supported: **Migrate Heroku to AppCloud**.

<img src="https://img.skitch.com/20110311-bbtk63ht5272jt2q2wsm3kh22c.png">

## Installation

Currently, it is only installable from source.

    bundle
    rake install

## Usage

The tool is simple to use. If you need to do something, it will tell you.

    ey-migrate heroku path/to/heroku/app

## Migration from Salesforce Heroku

The migration tool assumes you have:

* A running Heroku application with your data in its SQL database
* A Gemfile, rather than Heroku's deprecated .gems format
* Added `mysql2` to your Gemfile
* This upgraded application running on AppCloud without any of your data

### Database

Your SQL database is automatically migrated to your AppCloud application via `ey-migrate heroku`.

A MySQL database is created automatically for you for each AppCloud application. On a 1 instance environment it runs on the same instances as your web application. For dedicated databases, use a 2+ instance environment with a dedicated database instance.

### Workers

Automated support for setting up delayed_job workers is coming.

### Other add-ons

If you have specific Heroku Add-Ons you'd like to be automatically migrated to AppCloud, please leave a [note/request](https://github.com/engineyard/engineyard-migrate).

## Development of project

### Running tests

Then to run tests:

    bundle
    rake

This will install `.ssh/config` required for your SSH credentials to run the test suite.

### Credentials

To run the integration tests, you either need access to the [credentials repository](https://github.com/engineyard/ey-migrate-test-credentials)

Please send a Github message to `drnic` requesting access to the credentials. You'll then be able to run the test suite.

