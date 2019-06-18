# Dahlia

[![Code Climate](https://codeclimate.com/github/Exygy/dahlia-listings/badges/gpa.svg)](https://codeclimate.com/github/Exygy/dahlia-listings)
[![Test Coverage](https://codeclimate.com/github/Exygy/dahlia-listings/badges/coverage.svg)](https://codeclimate.com/github/Exygy/dahlia-listings/coverage)
[![Build Status](https://semaphoreci.com/api/v1/exygy/dahlia-listings-full/branches/master/badge.svg)](https://semaphoreci.com/exygy/dahlia-listings)


Cross-browser testing done with <a href="https://www.browserstack.com/"><img src="./Browserstack-logo@2x.png?raw=true" height="30" ></a>

## Purpose

Regional DAHLIA is an affordable housing portal for cities and counties. It is a fork of the DAHLIA project originally spearheaded by the City and County of San Francisco. This application streamlines the process of searching and applying for affordable housing, making it easier to rent and stay in financially-challenging areas.

## Technical Architecture

This repository contains the source code for sites such as [smc.housingbayarea.org](https://smc.housingbayarea.org), which is the user-facing web application of the DAHLIA platform. It is a [Ruby on Rails](http://rubyonrails.org/) application that serves up a single page [AngularJS](https://angularjs.org/) app. The web application connects to a PostgreSQL backend controlled by the DAHLIA Partners admin app [(see repo here)](https://github.com/Exygy/dahlia-admin), which is where the listings are created and administered. Both apps use a common set of data models via a Ruby gem [(see repo here)](https://github.com/Exygy/dahlia_data_models).

## Dependencies

Before you install DAHLIA, your system should have the following:

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) 2.5.3 (Use [RVM](https://rvm.io/rvm/install) or [rbenv](https://github.com/rbenv/rbenv))
- [Bundler](https://github.com/bundler/bundler) `gem install bundler`
- [Homebrew](http://brew.sh)
- [PostgreSQL](https://postgresapp.com/)
- Use Node v12.1.x (npm v6.9.x) — If you need to manage multiple Node versions on your dev machine, [install NVM]((https://github.com/nvm-sh/nvm)) and run `nvm use`

## Getting started

1. Make sure your PostgreSQL server is running (e.g. using [Postgres.app](https://postgresapp.com/) listed above)
1. Open a terminal window
1. `git clone https://github.com/Exygy/dahlia-listings.git` to create the project directory
1. `cd dahlia-listings` to open the directory
1. `bundle install` to download all necessary gems
    - see [here](https://stackoverflow.com/a/19850273/260495) if you have issues installing `pg` gem with Postgres.app, you may need to use: `gem install pg -v 1.1.4 -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config
1. `yarn install` to install Angular and other JS dependancies.
1. `overcommit --install` to install git hooks into the repo
1. `rails g dahlia_data_models:install` to generate migrations from the dahlia_data_models gem
1. `rails db:create && rails db:migrate` to create the dev and test databases and run migrations
1. `rails s` to start the server, which will now be running at http://localhost:3000 by default

## Running Tests

To run Ruby tests:
- `rails spec`

To run Javascript unit tests:
- `rails jasmine:ci` to run in terminal
- `rails jasmine` to then run tests interactively at http://localhost:8888/

To run E2E tests:
- Installation (needs to be run once): `./node_modules/protractor/bin/webdriver-manager update` to get the selenium webdriver installed
- On one tab have your Rails test server running: `yarn rails-setup-test`
- On another tab, run `yarn protractor` to run the selenium webdriver and protractor tests. A Chrome browser will pop up and you will see it step through each of the tests.

Note: These tests will run on Semaphore (our CI) as well for every review app and QA deploy.

## Importing pattern library styles

We currently manually transfer the application's CSS from [our pattern library](https://github.com/Exygy/sf-dahlia-pattern-library) using Grunt.

To update this app with the latest PL styles:

1. [Clone the PL repository in the same parent directory as this one.](https://github.com/Exygy/sf-dahlia-pattern-library)
2. Optional: switch to the PL branch you want to import styles from.
3. `cd` to your `dahlia-listings` folder
4. Run `grunt`

We use `grunt-clean` and `grunt-copy` to transfer the CSS, and `grunt-replace` to replace relative background image paths with Rails asset URLs.

### Acceptance/Feature Apps

Temporary "acceptance" apps are created upon opening a pull request for a feature branch. After the pull request is closed, the acceptance app is automatically spun down. See [this Heroku article](https://devcenter.heroku.com/articles/github-integration-review-apps) for details.


### Code style and quality

#### Javascript

Javascript code quality is ensured by two npm packages: JsHint and JSCS. They will run automatically as a pre-commit hooks. Follow the [Airbnb JavaScript Style guide](http://nerds.airbnb.com/our-javascript-style-guide/).

#### Ruby
[Rubocop](https://github.com/bbatsov/rubocop) is configured in `.rubocop.yml` to enforce code quality and style standards based on the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) and runs every time you commit using a pre-commit hook. Refer to the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) for all Ruby style questions.
To identify and have Rubocop automatically correct violations when possible, run:

* `rubocop -a [path_to_file]` for individual files
* `rubocop -a` for all Ruby files

### Changing the Style Guide settings
Any changes to Rubocop, JSCS, etc. affect the entire team, so it should be a group decision before commiting any changes. Please don't commit changes without discussing with the team first.