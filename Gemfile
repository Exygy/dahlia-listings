source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
ruby '2.2.3'

gem 'rails', '~> 4.2.4'
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Slim templates generator for Rails 3 and 4
gem 'slim-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
gem 'puma'

group :development do
  gem 'rubocop', require: false
  gem 'rails_best_practices'
  gem 'overcommit'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# takes care of importing javascript dependencies
# see /bower.json for more info
gem 'bower-rails'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Adds HTML templates into Angular's $templateCache using asset pipeline.
gem 'angular-rails-templates'
# NOTE: angular-rails-templates not yet compatible with sprockets > 3.0
# https://github.com/pitr/angular-rails-templates/issues/93
gem 'sprockets', '~> 2.12.4'

group :test do
  gem 'codeclimate-test-reporter'
end

gem 'rails_12factor', group: :production

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-core'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails', require: false
  gem 'awesome_print'
  gem 'dotenv-rails'
  gem 'jasmine', github: 'pivotal/jasmine-gem'
  gem 'jasmine-jquery-rails'
  gem 'pry'
  gem 'quiet_assets'
  gem 'thor-rails'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
