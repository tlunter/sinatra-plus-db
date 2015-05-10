task :bundle_environment do
  ENV['APP_ENV'] ||= 'development'

  Bundler.require(:default, ENV['APP_ENV'].to_sym)
  $LOAD_PATH << File.expand_path('app', '.')
end

task :app_environment do
  Dir['app/*'].each do |folder|
    if File.directory?(folder)
      Dir["#{folder}/**/*"].each do |file|
        file_name = File.basename(file).split('.')[0]
        autoload file_name.camelize.to_sym, file.gsub(/^app\//, '')
      end
    end
  end
end

task environment: %w(bundle_environment app_environment db:connect)
