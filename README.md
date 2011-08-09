Chicken Soup... for the Deployment Soul
================================
Even more opinionated than Capistrano itself, Chicken Soup adds a lot of useful tasks
specifically for those who want to DRY up deploying their Rails applications.

Interface
------------------------
Whether deploying to Heroku or your own servers, Chicken Soup gives you one command
interface to do it all.

Capabilities
------------------------
Chicken Soup makes it easy to only use the functionality you need.  Out of the box it
comes with:

  * Heroku
  * Unix Server
  * Apache
  * Nginx
  * RVM
  * Bundler
  * Isolate (coming soon)
  * Git
  * Subversion (partial)
  * Passenger
  * Postgres
  * MySQL

Notifiers
------------------------
Executing items to notify upon a successful deployment is a breeze.  Chicken Soup comes
loaded with:

  * Email
  * Git Tagging

Installation
------------------------
    gem install chicken_soup

or

    gem chicken_soup, :require => false

in your Gemfile.

Run the included generator to create Rake tasks that Chicken Soup will need to do awesome stuff
on the server.

    rails generate chicken_soup:add_ingredients

This will also modify your Capfile (or create it if you don't have one) and install a file in
`lib/recipes/` which will load Chicken Soup when you invoke Capistrano.

Getting Started
------------------------
Chicken Soup is all about sensible defaults.  Any of which can be overridden in your deploy.rb
file.

Let's take a common example.  You're deploying to your Unix server and you have your code
repository stored on Github.  You use Bundler to handle all of your gem needs and RVM is installed
to manage your Ruby versions.  Instead of remembering all kinds of random configurations such
as `default_run_options[:pty] = true` or where you need to include the Capistrano helpers for Bundler,
you can put this in your deploy.rb file:

    set :application,     'myapplication'
    set :capabilities,    [:unix, :github, :bundler, :rvm]

    set :deployment_type, :unix

And you can deploy with:

    cap <staging|production> deploy

Want to add automatic Nginx integration?  Just add :nginx to your capabilities list and your deployment
will do the right thing.

Wnat to migrate your application's DB automatically during deployment?  Add :mysql or :postgres to your
capabilities list.

Issues
------------------------
If you have problems, please create a [Github issue](https://github.com/jfelchner/chicken_soup/issues).

Credits
-------------------------
![thekompanee](http://www.thekompanee.com/public_files/kompanee-github-readme-logo.png)

chicken_soup is maintained by [The Kompanee, Ltd.](http://www.thekompanee.com)

The names and logos for The Kompanee are trademarks of The Kompanee, Ltd.

License
-------------------------
chicken_soup is Copyright &copy; 2011 The Kompanee. It is free software, and may be redistributed under the terms specified in the LICENSE file.

