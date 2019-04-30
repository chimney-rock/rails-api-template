require 'fileutils'
require 'shellwords'
require 'awesome_print'

def apply_template!
  assert_valid_options!
  add_template_to_source_path

  template('Gemfile.tt', force: true)

  # uses_rabbitmq = yes?('Will this API connect to RabbitMQ?')

  ####################################################################
  # File stuff
  ####################################################################
  remove_file('app/channels')
  remove_file('app/mailers')
  remove_file('app/views')
  remove_file('app/jobs')

  copy_from_github('docker/scripts/base_packages.sh')
  copy_from_github('docker/scripts/build_unit.sh')
  copy_from_github('docker/unit/conf.json')
  copy_from_github('docker-compose.yml')
  copy_from_github('Dockerfile')

  copy_from_github('app/controllers/application_controller.rb')
  copy_from_github('app/controllers/graphql_controller.rb')
  copy_from_github('app/graphql/api_schema.rb')
  copy_from_github('lib/tasks/graphql.rake')
  copy_from_github('.editorconfig')

  comment_lines('config/application.rb', /active_job/)
  comment_lines('config/application.rb', /active_storage/)
  comment_lines('config/application.rb', /action_mailbox/)
  comment_lines('config/application.rb', /action_mailer/)
  comment_lines('config/application.rb', /action_view/)
  comment_lines('config/application.rb', /action_cable/)
  comment_lines('config/application.rb', /action_text/)

  # Copy base GraphQL types
  %w(base_enum base_field base_input_object base_interface base_object base_scalar base_union query_type uuid_type).each do |file|
    copy_from_github("app/graphql/types/#{file}.rb")
  end

  template('config/database.yml.tt', force: true)

  template('.env.tt')
  append_to_file('.gitignore', '.env')
  append_to_file('.gitignore', '/vendor/bundle/*')

  application('config.active_record.default_timezone = :utc')
  application('config.active_record.schema_format = :sql')

  ####################################################################
  # Routes
  ####################################################################
  route("root to: 'graphql#index'")
  route("post '/graphql', to: 'graphql#execute'")

  run('bundle install')
  run('docker-compose build')

  git(:init)
  git(add: '.')
  git(commit: "-a -m 'Initial commit'")
end


def add_template_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-api-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/chimney-rock/rails-api-template.git',
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-api-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def assert_valid_options!
  valid_options = {
    skip_gemfile:      false,
    skip_bundle:       false,
    skip_action_cable: true,
    skip_sprockets:    true,
    skip_javascript:   true,
    skip_turbolinks:   true,
    skip_test:         true
  }

  valid_options.each do |key, expected|
    next unless options.key?(key)
    actual = options[key]
    unless actual == expected
      fail Rails::Generators::Error, "Unsupported option: #{key}=#{actual}"
    end
  end
end

# Prompts the user with a question & default.
#
# @param [String] question Question to ask.
# @param [Object] default Default to return if nothing is entered by the user.
# @return [Object]
def prompt(question, default: nil)
  answer = ask(question) 
  answer.empty? ? default : answer
end

# Copies a single file from the github repository.
#
# @param [String] filename File to copy.
# @param [String] destination File destination.
def copy_from_github(filename, destination: filename)
  source = "https://raw.githubusercontent.com/chimney-rock/rails-api-template/master/#{filename}"
  remove_file(destination) if File.exists?(destination)
  get(source, destination)
rescue OpenURI::HTTPError
  puts "ERROR: Unable to obtain file `#{source}`"
end

apply_template!
