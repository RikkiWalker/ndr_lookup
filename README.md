# NdrLookup [![Build Status](https://travis-ci.org/PublicHealthEngland/ndr_lookup.svg?branch=master)](https://travis-ci.org/PublicHealthEngland/ndr_lookup)

This is the Public Health England (PHE) National Disease Registers (NDR) Lookup ruby gem,
providing:

1. an ArcGIS LocatorHub API client

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ndr_lookup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ndr_lookup

## Usage

### ArcGIS LocatorHub API Client

NdrLookup::LocatorHub::Client is a client to access the LocatorHub API to rectify given addresses.

The client isn't included by default, so add the following to your code:

```ruby
require 'ndr_lookup/locator_hub/client'
```

It requires some manual setup:

Configuration | Description
--- | ---
`domain` | A string of the authenicating domain name.
`username` | A string of the authenticating username.
`password` | A string of the authenticating password.

Within a Rails application, you should do this in an initializer, preferably using encrypted credentials, e.g.:

```ruby
# This file configures NdrLookup.
Rails.application.config.to_prepare do
  NdrLookup::LocatorHub::Client.domain = Rails.application.credentials.production[:locator_hub_api][:domain]
  NdrLookup::LocatorHub::Client.username = Rails.application.credentials.production[:locator_hub_api][:username]
  NdrLookup::LocatorHub::Client.password = Rails.application.credentials.production[:locator_hub_api][:password]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ndr_lookup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NdrLookup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ndr_lookup/blob/master/CODE_OF_CONDUCT.md).
