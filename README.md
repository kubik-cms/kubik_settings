# Kubik Settings

Editable application settings with configurable table names and customizable Active Admin interface.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'kubik_settings'
```

And then execute:
```bash
$ bundle
```

Run the generator to add the necessary migration and customizable Active Admin resource:
```bash
$ bundle exec rails g kubik_settings:install
```

## Configuration

### Basic Settings Configuration
Add your schema into an initializer:

```ruby
# config/initializers/kubik_settings.rb
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

### Table Name Configuration
By default, the gem uses `kubik_settings` as the table name. You can customize this to avoid conflicts:

```ruby
KubikSettings.configure do |config|
  config.table_name = 'my_custom_settings'
  # ... your settings configuration
end
```

### Active Admin Menu Customization
You can customize the Active Admin menu positioning and nesting:

```ruby
KubikSettings.configure do |config|
  config.menu_options = {
    label: 'Site Settings',
    priority: 1,
    parent: 'Configuration'
  }
  # ... your settings configuration
end
```

### Active Admin Customization
You can extend the Active Admin functionality by adding custom blocks:

```ruby
KubikSettings.configure do |config|
  config.add_active_admin_block do
    # Add custom sidebar
    sidebar "Additional Information", only: :show do
      ul do
        li "Custom sidebar content"
      end
    end
    
    # Add custom action
    action_item :custom_action, only: :show do
      link_to 'Custom Action', '#'
    end
  end
  # ... your settings configuration
end
```

### Full Active Admin Override
For complete customization, you can override the entire Active Admin resource by editing the generated file:

```ruby
# app/admin/kubik_settings.rb
ActiveAdmin.register Kubik::Setting do
  # Customize menu
  menu label: 'Global Settings', priority: 10, parent: 'Admin'
  
  # Add custom tabs
  show do
    tabs do
      tab "Settings" do
        # ... existing settings tab
      end
      tab "Custom Tab" do
        panel "Custom Content" do
          para "Your custom content here"
        end
      end
    end
  end
  
  # Add custom controller methods
  controller do
    def custom_action
      # Your custom action logic
    end
  end
end
```

## Usage

Fetch your settings from your base controller:

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
