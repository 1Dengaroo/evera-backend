# Evera Backend

## Dependencies

- Ruby: ruby-3.1.2
- Postgres (`brew/apt-get install postgresql` or [Postgres.app](https://postgresapp.com/))
- Redis (`brew/apt-get install redis`)

## Environment variables

Generate the required `.env` file by running the following:

```
cp .sample.env .env
```

You should also copy the `database.yml` from the example file:

```
cp config/database.yml.example config/database.yml
```

## Regular Setup

Make sure you're using the correct Ruby version (check the Gemfile for that)

Install dependencies using bundler:

```
bundle install
```

Setup your database:

```
bundle exec rails db:create db:migrate
```

Currently we don't use Redis cache but in the future toggle Redis cache on:

```
rails dev:cache
```

Facing issues installing `pg` during the bundle (change `~/.zshrc` to your terminal configuration path):

```
brew/apt-get install libpq

echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

## Spec

```
bundle exec rspec
```

## Lint

```
bundle exec rubocop
```

## Seed

```
bundle exec rails db:seed
```
