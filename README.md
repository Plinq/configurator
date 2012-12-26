# Configurator
## Add simple configuration to any Ruby class

### Installation
1. Add `gem 'configurator'` to your Gemfile
2. Run `bundle`
3. Profit

### Usage

#### Mix into any Ruby class and add options
```ruby
class Application
  extend Configurator
  option :api_url, "https://www.myapp.com/api/v1"
  options :format, :mode, :whatevs
end
```

This will add `Application.config.api_url`, which will be overridable but default
to `https://www.myapp.com/api/v1`. It also adds a number of options without
defaults, namely `format`, `mode`, and `whatevs`.

Every call to `option` or `options` adds getters and setters for these options,
but you can also use the alternate syntax by ommitting the equals sign when setting
an option.

#### Configure your class
Configurator supports three different interfaces and two setter methods:

##### Block configuration with implicit configuration object
```ruby
Application.config do
  api_url "https://www.some.other.app/api/v2"
  format :json
end
```

##### Block configuration with passed configuration object
```ruby
Application.config do |config|
  config.api_url = "https://www.some.other.app/api/v2"
  config.format = :json
end
```

##### Direct configuration
```ruby
Application.config.api_url = "https://www.some.other.app/api/v2"
Application.config.format = :json
```

OR omit the equals operators:

```ruby
Application.config.mode :production
```

#### Sub-configurations
Adding a sub-configuration is simple, too, like so:

```ruby
class Application
  extend Configurator
  option :smtp_server do
    options :host, :port, :password, :username
  end
end
```

Now, you can refer to an Application's smtp_server configuration like so:

```ruby
Application.config.smtp_server.host
Application.config.smtp_server.port
# etc
```

You can also configure a group of configuration options as a hash:

```ruby
Application.config.smtp_server = {
  host: "smtp.host.com",
  port: "3306",
  username: "user",
  password: "pass"
}
```

#### Observe your users' configuration choices later

Just refer to a class or module's configuration setting later, pretty simply:

```ruby
if Application.config.smtp_server.host
  Mailer.send_email_with_options(Application.config.smtp_server)
end
```

Or whatever.
