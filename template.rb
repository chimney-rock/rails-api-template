
# Prompts the user with a question & default.
#
# @param [String] question Question to ask.
# @param [Object] default Default to return if nothing is entered by the user.
# @return [Object]
def prompt(question, default: nil)
  answer = ask(question) 
  answer.empty? ? default_answer : answer
end

# Copies a single file from the github repository.
#
# @param [String] filename File to copy.
# @param [String] destination File destination.
def copy_from_github(filename, destination: filename)
  source = "https://raw.githubusercontent.com/chimney-rock/rails-api-template/master/#{filename}"
  remove_file(destination)
  get(source, destination)
rescue OpenURI::HTTPError
  puts "ERROR: Unable to obtain file `#{source}`"
end

git(:init)

uses_db? = yes?('Does this API need a database connection?')
# uses_rabbitmq? = yes?('Will this API connect to RabbitMQ?')

####################################################################
# Gems
####################################################################
# gem 'sneakers', '~> 2.11' if uses_rabbitmq?
gem 'pg', '~> 1.1' if uses_db?
gem 'graphql', '~> 1.9'

gem 'annotate', '~> 2.7', group: :development
gem_group :development, :test do
  gem 'database_cleaner' if uses_db?
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

run('bundle install')

####################################################################
# Cleanup files & directories that are unused for APIs
####################################################################
remove_file 'app/channels'
remove_file 'app/mailers'
remove_file 'app/jobs'
remove_file 'app/views'

####################################################################
# Copy template files
####################################################################
copy_from_github('app/controllers/application_controller.rb')
copy_from_github('app/controllers/graphql_controller.rb')
copy_from_github('config/database.yml') if uses_db?
copy_from_github('app/graphql/api_schema.rb')
copy_from_github('lib/tasks/graphql.rake')
copy_from_github('docker-compose.yml')
copy_from_github('Dockerfile')
copy_from_github('.editorconfig')

# Copy base GraphQL types
%w[base_enum base_field base_input_object base_interface base_object base_scalar base_union query_type uuid_type].each do |file|
  copy_from_github("app/graphql/types/#{file}.rb")
end

# Lines to add to the .env file
environment_file = []

if uses_db?
  db_host     = prompt('Database host? [localhost]',    default: 'localhost')
  db_user     = prompt('Database username? [postgres]', default: 'postgres') 
  db_password = prompt('Database password? [postgres]', default: 'postgres')

  environment_file << "DB_HOST=#{db_host}"
  environment_file << "DB_USERNAME=#{db_user}"
  environment_file << "DB_PASSWORD=#{db_password}"
end

file('.env', environment_file.join("\n"))
append_to_file('.gitignore', '.env')
append_to_file('.gitignore', '/vendor/bundle/*')

application('config.active_record.default_timezone = :utc')
application('config.active_record.schema_format = :sql')
application('config.api_only = true')

####################################################################
# Routes
####################################################################
route("root to: 'graphql#index'")
route("post '/graphql', to: 'graphql#execute'")


# generate('annotate:install')


git(add: '.')
git(commit: "-a -m 'Initial commit'")
