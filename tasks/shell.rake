desc 'Open a Pry console with the application loaded and database set'
task shell: :environment do
  Pry.config.prompt_name = 'catfood'
  Pry.start
end
