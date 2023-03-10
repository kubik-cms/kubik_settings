# Kubik Settings

Editable application settings

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'kubik_settings'
```

And then execute:
```bash
$ bundle
```

Run the generator to add the necessary migration
```bash
$ bundle exec rails g kubik_settings:install
```

Add your schema into an initializer
```ruby
KubikSettings.configure do |config|
  config.settings = {
    email: {
      default: 'hello@your-business.com',
      input: :string,
      type: ActiveRecord::Type::String
    },
    telephone: {
      default: '0131 XXX XXXX',
      input: :string,
      type: ActiveRecord::Type::String
    },
    facebook: {
      default: 'https://www.facebook.com/your-account',
      input: :string,
      type: ActiveRecord::Type::String
    },
  }
end
```

Fetch your settings from your base controller

```ruby
class KubikController < ApplicationController
  before_action :fetch_kubik_settings

  def fetch_kubik_settings
    @kubik_settings = Kubik::Setting.cached
  end
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
