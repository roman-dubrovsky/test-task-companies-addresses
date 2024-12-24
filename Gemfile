# frozen_string_literal: true

source "https://rubygems.org"

gem "active_model_serializers"
gem "bootsnap", require: false
gem "dry-operation"
gem "dry-validation"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.1"
gem "smarter_csv"
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  gem "brakeman", require: false
  gem "datarockets-style", "~> 1.6.0"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"
  gem "rspec-rails", "~> 7.0.0"
  gem "shoulda-matchers", "~> 6.0"
end

group :test do
  gem "database_cleaner-active_record"
  gem "rspec-its"
end
