## Test Service API
The purpose of this API is to receive text messages from users, forward them to an SMS Provider and store the provider response for user consumption. See the [Text Messaging SPA](https://github.com/Natasha08/texting-service-spa) for a UI to login, send messages and view the responses.

When you interact with the API via a client, i.e. [Text Messaging SPA](https://github.com/Natasha08/texting-service-spa), the API will automatically push updates to the client via Web Sockets when the SMS Provider updates the API.

[![CircleCI](https://circleci.com/gh/Natasha08/texting-service/tree/main.svg?style=shield&circle-token=fd48b96294fe267e44625c3ec162f43208fe6623)](https://circleci.com/gh/Natasha08/texting-service/tree/main)

## Technology and Stack
- [PostgreSQL 14.1](https://www.postgresql.org/docs/current/)
- [ruby](https://www.ruby-lang.org/en/news/2021/07/07/ruby-3-0-2-released/) (see `.ruby-version` for version)
- [rails](http://guides.rubyonrails.org/v6.1/) (see `Gemfile` for version)

#### Testing
- [rspec](http://rspec.info/documentation/)
- [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails)
- [ffaker](https://github.com/ffaker/ffaker)

## Setup
1. `bundle install` - Install dependencies
3. `cp config/application.example.yml config/application.yml` - Edit local config as necessary.
4. `cp config/database.example.yml config/database.yml` - Edit to match your database configuration.
5. `bundle exec rails db:setup` - Create Postgres database and create tables from schema.

## Development server
- `bundle exec rails server`
- View site at `http://localhost:3000/`

## Testing
- `bundle exec rspec`

## Deployment
- CI/CD on Heroku
