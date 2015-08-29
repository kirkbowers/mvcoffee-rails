desc 'Convert the README.txt file into markdown for github'
task 'README.md' => 'README.txt' do
  puts "Converting README.txt to README.md"
  readme = File.open("README.txt").read
  File.open('README.md', 'w') do |file| 
    file.write(Rdoc2md::Document.new(readme).to_md)
  end
end

desc 'Convert the README.md file (generated from README.txt) into html to view locally'
task 'REAMDE.html' => 'README.md' do
  puts "Converting README.md to README.html"
  sh 'Markdown.pl README.md > README.html'
end
