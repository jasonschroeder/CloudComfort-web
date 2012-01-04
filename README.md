# CloudComfort-web #



## INSTALLING ##

- Install ruby
- Install "bundler" gem

      $ sudo ruby install bundler


- Install memcached 1.4+ to localhost

      $ sudo port install memcached

- Clone from git
- Install gems

      $ bundle install

- Run the app

      $ rackup

- Open browser

      $ open http://localhost:9292/
   
## Deploying to Heroku ##
- clone the repo
- create new Heroku instance

    $ heroku create <app_name>

- add `memcached`

    $ heroku addons:add memcache

- Push to Heroku

    $ git push heroku master
