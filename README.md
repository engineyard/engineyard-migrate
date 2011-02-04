# Salesforce Heroku to Engine Yard AppCloud migration tool

**DO NOT OPEN SOURCE** until management of passwords/credentials for testing + CI is figured out and the codebase cleaned up + passwords possibly changed.

## Heroku Addons

### Database

Example:

    shared-database:20gb, 5mb         

A MySQL database is created automatically. On a 1 instance environment it runs on the same instances as your web application. For dedicated databases, use a 2+ instance environment with a dedicated database instance.

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

### Credentials

For the test Heroku + AppCloud accounts, the email is `ossgrants+heroku2ey@engineyard.com` and password `heroku2ey`.


