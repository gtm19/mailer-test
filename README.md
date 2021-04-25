# Mailer test

This repo contains the bare minimum code to enable `:confirmable` with Devise, to use Letter Opener to preview emails during development, and to make the Devise mailer templates available at <http://localhost:3000/rails/mailers/>.

## Setup

### Rails app

Firstly, set up a new rails app using the Devise [template from Le Wagon](https://github.com/lewagon/rails-templates):

```
rails new \
  --database postgresql \
  --webpack \
  -m https://raw.githubusercontent.com/lewagon/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
  ```

### Letter opener

Add the [letter_opener](https://github.com/ryanb/letter_opener) gem to your gemfile:

```
bundle add --development letter_opener
```

Then add the following to your [config/environments/development.rb](config/environments/development.rb) file:

```rb
# config/environments/development.rb

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true

```

### Devise

More information about how to set up Devise to send user confirmation emails can be found [here](https://github.com/heartcombo/devise/wiki/How-To:-Add-:confirmable-to-Users).

Firstly, we need to add `:confirmable` to the [`User` model](app/models/user.rb):

```rb
# app/models/user.rb

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
end

```

Then create a migration to add the required bits to the User model in the database:

```
rails g migration add_confirmable_to_devise
```

Then add the following to the migration file:

```rb
# db/migrate/YYYYMMDDxxx_add_confirmable_to_devise.rb

class AddConfirmableToDevise < ActiveRecord::Migration
  # Note: You can't use change, as User.update_all will fail in the down migration
  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    # add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :users, :confirmation_token, unique: true
    # User.reset_column_information # Need for some types of updates, but not for update_all.
    # To avoid a short time window between running the migration and updating all existing
    # users as confirmed, do the following
    User.update_all confirmed_at: DateTime.now
    # All existing user accounts should be able to log in after this.
  end

  def down
    remove_index :users, :confirmation_token
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # remove_columns :users, :unconfirmed_email # Only if using reconfirmable
  end
end
```

Then run the migration (and restart the server):

```
rails db:migrate
```

Finally (unless you enabled `:reconfirmable` in the migration above), add the following to [config.initializers/devise.rb](config.initializers/devise.rb):

```rb
# config.initializers/devise.rb

config.reconfirmable = false
```

### Mailer previews

In order to be able to preview the Devise mailers at <http://localhost:3000/rails/mailers/>, create the following file:

```
touch test/mailers/previews/devise_mailer_preview.rb
```

and put the following inside it:

```rb
# test/mailers/previews/devise_mailer_preview.rb

class DeviseMailerPreview < ActionMailer::Preview

  USER = User.new(email: "hello@test.com")

  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(USER, {})
  end

  def unlock_instructions
    Devise::Mailer.unlock_instructions(USER, "faketoken")
  end

  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(USER, "faketoken")
  end
end

```
