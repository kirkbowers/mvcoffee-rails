require "bundler/gem_tasks"

require "rdoc2md"


desc 'Run all the tests in the test_rails_project'
task :test do
  cd 'test_rails_project'
  sh 'rake test'
  # Come back home in case another task runs after this one
  cd '..'
end

desc 'Build the js files in the sibling mvcoffee project'
task :mvcoffee_js do
  puts "cd-ing to sibling mvcoffee project"
  cd '../mvcoffee'
  puts 'Building mvcoffee.js'
  sh 'cake minify'
  # Come back home in case another task runs after this one
  cd '../mvcoffee-rails'
end

desc 'Copy the js files from the sibling mvcoffee project'
task :copy_js => :mvcoffee_js do
  puts 'Copying mvcoffee.js into assets'
  cp Dir['../mvcoffee/lib/mvcoffee.*'], 'app/assets/javascripts/'
end

task :build => :copy_js

task 'install:local' => :build

task :all => ['install:local', :test]
