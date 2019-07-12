# VOF Tracker

[![CircleCI](https://circleci.com/gh/andela/vof-tracker.svg?style=svg&circle-token=6888dc0dbea6168e65f34217b753d239b2ab4b0f)](https://circleci.com/gh/andela/vof-tracker)
[![Maintainability](https://api.codeclimate.com/v1/badges/b324f472a099365e0b68/maintainability)](https://codeclimate.com/repos/5c3ee1e75541a8029c0088f0/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b324f472a099365e0b68/test_coverage)](https://codeclimate.com/repos/5c3ee1e75541a8029c0088f0/test_coverage)

Before joining the Fellowship, every candidate must exhibit their proficiency when measured against their
Value Alignment, Output Quality and Feedback (V.O.F).

The VOF Tracker helps to automate this process by empowering the Bootcamp Facilitators, Facilitator's Assistants
and the Talent team to continue to identify the top 1% as Andela scales its recruitment process.

## External Dependencies

This web application is written with Ruby using the Ruby on Rails framework and a PostgreSQL database. You need Ruby version 2.4.1 for the application to work

* To install rvm , visit [RVM](https://rvm.io/rvm/install)
* To install this ruby version, you can run the command below but you can use other channels to install it as well e.g. `rbenv`.
    ```bash
    rvm install ruby-2.4.1
    ```
* To install PostgreSQL, run
    ```bash
    brew install postgres
    ```

*To know more about Ruby or Rails visit [Ruby Lang](https://www.ruby-lang.org) or [Ruby on Rails](http://rubyonrails.org/).*

## Installation

Please make sure you have **Ruby(v 2.4.1) and PostgreSQL** installed. Take the following steps to setup the application on your local machine:

1. Run `git clone https://github.com/andela/vof-tracker.git` to clone this repository

2. Run `bundle install` to install all required gems

3. Run `cp config/application.yml.sample config/application.yml` to create the `application.yml` file.

*Note* Update the postgres username and password if you have one

```yml
POSTGRES_USER: 'your-postgres-username'
POSTGRES_PASSWORD: 'your-postgres-password'
```

## Database

### Production database dump

* Go to the `#vof-db-backups` slack channel

* Download the latest database dump file. It should be in this format `vof-production-db-backup-2018-09-16`. This should automatically be downloaded to your download folder if you didn't change your download path.

### Configuring the database

* After creating your `config/application.yml`, you need to create these 2 databases `vof-tracker` and `vof_tracker_test`. To create them, run:

    ```bash
    rake db:create
    ```

* To copy data from the dump into the database you just created, run the below code with relevant details. if your download folder is `Downloads`, use `~/Downloads/name-of-file` as the path and just update the name of the file.

    ```bash
    psql -f path_to_db_dump_file vof-tracker
    ```

* Next run the code below to migrate schemas that might have not been added to the database

    ```bash
    rake db:migrate
    ```

#### Running Redis

* Download [Redis](https://redis.io/) `$ brew install redis`

* Set `REDIS_URL` environment variable as `"redis://localhost:6379/0/cache"`

* Start Redis server `$ redis-server`

* To check that cache is being set and retrieved `$ redis-cli monitor`

## Configuring Host

* On Mac, run `sudo nano /etc/hosts`.

* Edit the terminal and include `127.0.0.1 vof-tracker-dev.andela.com` to the list of hosts.

* Save changes and exit the terminal

* Run `rails s` to start the application

* Visit: http://vof-tracker-dev.andela.com:3000

## Tests

* Run test with `rspec spec`

## Limitations

* VOF Tracker is still in development

## Coding Style

Refer to this links below for our coding style:

* https://github.com/bbatsov/ruby-style-guide
* https://github.com/bbatsov/rails-style-guide

## How to Contribute

* Fork this repository
* Clone it.
* Create your feature branch on your local machine with `git checkout -b your-feature-branch`
* Push your changes to your remote branch with `git push origin your-feature-branch` ensure you avoid redundancy in your commit messsage.
* Open a pull request to the `develop` branch and describe how your feature works
* Refer to this wiki for proper [GIT CONVENTION](https://github.com/andela/engineering-playbook/blob/master/5.%20Developing/Conventions/readme.md)
