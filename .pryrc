Pry.config.editor="emacsclient"

Pry::Commands.command "test" do |dir|
  pid=Kernel.fork do
    r=Rails.root
    dir ||= "models"
    Dir.chdir(File.join(r,"test"))
    $:.push(".")
    Dir.glob("#{dir}/*_test.rb").each do |f|
      load f
    end
  end
  Process.wait(pid)
end
if Kernel.const_defined?("Rails") then
  warn [:rails]
  require File.join(Rails.root,"config","environment")
  require 'rails/console/app'
  require 'rails/console/helpers'
  Pry::RailsCommands.instance_methods.each do |name| 
    Pry::Commands.command name.to_s do 
      Class.new.extend(Pry::RailsCommands).send(name)
    end
  end
end

