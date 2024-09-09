# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'devise'
gem 'devise-jwt'
gem 'jsonapi-serializer'
gem 'pg', '~> 1.5'
gem 'puma', '>= 5.0'
gem 'rack-attack', '~> 6.6', '>= 6.6.1'
gem 'rack-cors'
gem 'rails', '~> 7.2.0'
gem 'redis', '~> 5.0'
gem 'sendgrid-ruby'
gem 'sidekiq'
gem 'sinatra'
gem 'stripe'
gem 'tzinfo-data', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw], require: 'debug/prelude'
  gem 'dotenv-rails', '~> 2.8'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers', '~> 5.0'
end
