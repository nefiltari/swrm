task :default => :spec

namespace :doc do
  desc "Generate YARD documentation (for developers)"
  task :all do
    puts "Generating developer documentation in doc/"
    system "yardoc --protected --private lib/**/*.rb"
  end
  
  desc "Generate YARD documentation (for users)"
  task :simple do
    puts "Generating simple documentation in doc/"
    system "yardoc lib/**/*.rb"
  end
  
  desc "Remove generated documentation"
  task :cleanup do
    puts "Removing generated documentation"
    system "rm -rf doc/*"
  end
end

desc "Run all specification tests (default task)"
task :spec do
  system "cd #{File.dirname(__FILE__)} && spec -c spec"
end
