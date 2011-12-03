## CloudComfort-web



## INSTALLING

- Install ruby
- Install memcached 1.4+ to localhost
    $ sudo port install memcached
- Clone from git
- Install gems
    $ bundle install
- Run the app
    $ rackup
- Open browser
    $ open http://localhost:9292/
   
## Deploying to Heroku
- clone the repo
- create new Heroku instance
    $ heroku create <app_name>
- add Memcached
    $ heroku addons:add memcache
- Apply Pusher.com credentials to local dev env (shell)
    $ export PUSHER_APP_ID=xxxxx
    $ export PUSHER_KEY=yyyyyyy
    $ export PUSHER_SECRET=zzzzzz
- Apply Pusher.com credentials to Heroku
    $ heroku config:add PUSHER_APP_ID=$PUSHER_APP_ID \
    PUSHER_KEY=$PUSHER_KEY \
    PUSHER_SECRET=$PUSHER_SECRET
- Push to Heroku
    $ git push heroku master
