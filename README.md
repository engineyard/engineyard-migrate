# Salesforce Heroku to Engine Yard AppCloud migration tool

**DO NOT OPEN SOURCE** until management of passwords/credentials for testing + CI is figured out and the codebase cleaned up + passwords possibly changed.

## Installation

Currently, it is only installable from source.

    bundle
    rake install

## Usage

The tool is simple to use. If you need to do something, it will tell you.

    ey-migrate migrate path/to/heroku/app

## Migration from Salesforce Heroku

### Database

Your SQL database is automatically migrated to your AppCloud application via `ey-migrate migrate`.

A MySQL database is created automatically for you for each AppCloud application. On a 1 instance environment it runs on the same instances as your web application. For dedicated databases, use a 2+ instance environment with a dedicated database instance.

### Workers

Heroku documentation on their workers/background jobs - [http://devcenter.heroku.com/articles/delayed-job](http://devcenter.heroku.com/articles/delayed-job)

### Custom domains

Example:

    custom_domains:basic, wildcard    

There are no restrictions on domains associated with your AppCloud account.

### Cron [todo]

Examples:

    heroku addons:add cron:daily
    heroku addons:add cron:hourly

Heroku's `cron` addon ran your `rake cron` task, either daily or hourly.

A corresponding cron job will be created for you on AppCloud:

    cd /data/appname/current && RAILS_ENV=production rake cron

### Logging

Example:

    logging:advanced, basic, expanded 

AppCloud implements its own logging system.

### Memcached

Example:

    memcache:100mb, 10gb, 1gb, 250mb, 50gb...

AppCloud applications automatically have memcached enabled.

### New Relic

Example:

    newrelic:bronze, gold, silver     

You can enable New Relic for your AppCloud account through the https://cloud.engineyard.com dashboard.

### Release management

Example:

    releases:basic, advanced

AppCloud implements its release management system.

### SSL

Example:

    ssl:hostname, ip, piggyback, sni  

There is no cost for installing SSL for your AppCloud application through the https://cloud.engineyard.com dashboard.

### Other addons

The remaining known Heroku addons are:

    amazon_rds                        
    apigee:basic                      
    apigee_facebook:basic             
    bundles:single, unlimited
    cloudant:argon, helium, krypton...
    cloudmailin:test
    custom_error_pages                
    deployhooks:basecamp, campfire... 
    exceptional:basic, premium        
    heroku-postgresql:baku, fugu, ika...
    hoptoad:basic, plus               
    indextank:plus, premium, pro...   
    mongohq:free, large, micro, small 
    moonshadosms:basic, free, max, plus...
    pandastream:duo, quad, sandbox, solo
    pgbackups:basic, plus             
    pusher:test                       
    redistogo:large, medium, mini, nano...
    sendgrid:free, premium, pro       
    websolr:gold, platinum, silver... 
    zencoder:100k, 10k, 1k, 20k, 2k, 40k, 4k...
    zerigo_dns:basic, tier1, tier2    

    --- beta ---
    chargify:test                     
    docraptor:test                    
    heroku-postgresql:...             
    jasondb:test                      
    memcached:basic                   
    pgbackups:daily, hourly           
    recurly:test                      
    releases:advanced
    ticketly:test                     


## Development

### Running tests

Then to run tests:

    bundle
    rake

This will install `.ssh/config` required for your SSH credentials to run the test suite.

### Credentials

To run the integration tests, you either need access to the [credentials repository](https://github.com/engineyard/ey-migrate-test-credentials)

Please send a Github message to `drnic` requesting the test keys/

### Dependencies

`engineyard ~> 1.3.15pre` is specifically to include pull request https://github.com/engineyard/engineyard/pull/107


