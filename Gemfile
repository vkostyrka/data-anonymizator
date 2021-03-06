# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

gem 'devise'
gem 'jbuilder', '~> 2.7'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'react-rails'
gem 'sassc', '~> 2.1.0'
gem 'sass-rails', '>= 6'
gem 'sequel'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 5.0'

gem 'carrierwave'
gem 'data-anonymization', git: 'https://github.com/vkostyrka/data-anonymization', branch: 'update_rails_6.1'
gem 'haml-rails'
gem 'listen', '~> 3.3'
gem 'rack-mini-profiler', '~> 2.0'
gem 'rubocop'
gem 'rubocop-rails'
gem 'spring'

gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
  gem 'sqlite3', '~> 1.4'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
