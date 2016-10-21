# Allowances::Fencable

Allowances is an easy way to implement authorization in your Rails application.
It is designed to work with roles, known as "Personas" and with Users individually as well.
It can be use to create an allowance row per allowable_type (polymorphic relationship to User or Personas) wich tranlates to a list of permissions (bolean fields) on the actions.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'allowances'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install allowances

## Requirments

Base project most contain models:
```ruby
'User'
'Persona' # user roles
'User_persona'
'Allowance'
```

Base projecto most be `Ruby -> 2.0` or higher

## Usage

In your `User` model you should add:

```ruby
include Allowances::Fencable

has_many :personas, :through => :user_personas
```

The `Allowance` module has to include a list of permissions, which will be an allowance row per allowable_type.
For instance:
```ruby
class Allowance < ActiveRecord::Base
    allowable

    attr_accessible :absence_create, :absence_create_all, :absence_reports,
        :absence_show, :ad_hoc_attendance, :administration, :advanced_search,
        :advanced_search_gpa_filter, :advanced_search_personal_info,
        :advising_appointment_create

end
```

The `Persona` Model should have:
```ruby
class Persona < ActiveRecord::Base
      has_many :user_personas, :dependent => :delete_all
      has_many :users, :through => :user_personas
      has_one :allowance, :as => :allowable, :dependent => :delete
end
```

The `UserPersona` model should look like:
```ruby
class UserPersona < ActiveRecord::Base
  belongs_to :user
  belongs_to :persona

  validates_presence_of :persona_id, :user_id

  attr_accessible :persona, :persona_id, :user, :user_id
end
```
Finally and most importantly, an example usage would be:
```ruby
if current_user.is_allowed_to?(:advising_appointment_create)
    # your code here
end
```
## Development

After checking out the repo, run bin/setup to install dependencies. You can also run bin/console for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run bundle exec rake install. To release a new version, update the version number in version.rb, and then run bundle exec rake release, which will create a git tag for the version, push git commits and tags, and push the .gem file to rubygems.org.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/IsabelGAP/gem_allowances. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

## License

The gem is available as open source under the terms of the MIT License.
