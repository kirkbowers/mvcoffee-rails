require "bundler/gem_tasks"

require "rdoc2md"

task :readme do
  readme = File.open("README.txt").read
  File.open('README.md', 'w') do |file| 
    file.write(Rdoc2md::Document.new(readme).to_md)
  end
end