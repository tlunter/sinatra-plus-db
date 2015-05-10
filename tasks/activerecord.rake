require 'erb'
load 'active_record/railties/databases.rake'

seed_loader = Class.new do
  def load_seed
    load "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/seeds.rb"
  end
end

ActiveRecord::Tasks::DatabaseTasks.tap do |config|
  config.root                   = Rake.application.original_dir
  config.env                    = ENV["APP_ENV"] || "development"
  config.db_dir                 = "db"
  config.migrations_paths       = ["db/migrate"]
  config.fixtures_path          = "test/fixtures"
  config.seed_loader            = seed_loader.new
  config.database_configuration = ActiveRecord::Base.configurations
end

Rake::Task["db:seed"].enhance(["db:load_config"])

# define Rails' tasks as no-op
namespace :db do
  task :load_config  do
    database_file = "#{Dir.pwd}/config/database.yml"
    spec = YAML.load(ERB.new(File.read(database_file)).result) || {}
    environment = ENV['APP_ENV'].to_sym

    spec.symbolize_keys[environment]

    ActiveRecord::Base.configurations = spec.stringify_keys
  end

  task connect: :load_config do
    environment = ENV['APP_ENV'].to_sym
    ActiveRecord::Base.establish_connection(environment)
  end

  desc "Create a migration (parameters: NAME, VERSION)"
  task :create_migration do
    unless ENV["NAME"]
      puts "No NAME specified. Example usage: `rake db:create_migration NAME=create_users`"
      exit
    end

    name    = ENV["NAME"]
    version = ENV["VERSION"] || Time.now.utc.strftime("%Y%m%d%H%M%S")

    ActiveRecord::Migrator.migrations_paths.each do |directory|
      next unless File.exist?(directory)
      migration_files = Pathname(directory).children
      if duplicate = migration_files.find { |path| path.basename.to_s.include?(name) }
        puts "Another migration is already named \"#{name}\": #{duplicate}."
        exit
      end
    end

    filename = "#{version}_#{name}.rb"
    dirname  = ActiveRecord::Migrator.migrations_path
    path     = File.join(dirname, filename)

    FileUtils.mkdir_p(dirname)
    File.write path, <<-MIGRATION.strip_heredoc
      class #{name.camelize} < ActiveRecord::Migration
        def change
        end
      end
    MIGRATION

    puts path
  end
end
