require "bundler/gem_tasks"

require "rdoc2md"


desc 'Run all the tests in the test_rails_project'
task :test do
  cd 'test_rails_project' do
    sh 'rake test'
  end
end

desc 'Build the js files in the sibling mvcoffee project'
task :mvcoffee_js do
  puts "cd-ing to sibling mvcoffee project"
  cd '../mvcoffee' do 
    puts 'Building mvcoffee.js'
    sh 'cake minify'
  end
end

desc 'Copy the js files from the sibling mvcoffee project'
task :copy_js => :mvcoffee_js do
  puts 'Copying mvcoffee.js into assets'
  cp Dir['../mvcoffee/lib/mvcoffee.*'], 'app/assets/javascripts/'
end

task :build => :copy_js

task 'install:local' => :build

desc 'Build it, and install it locally'
task :default => 'install:local'

desc 'Build it, install it locally, and test it'
task :all => ['install:local', :test]
