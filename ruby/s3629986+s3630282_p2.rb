require 'nokogiri'
require 'json'
require 'optparse'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'here is help messages of the command line tool.'

  options["ip"] = nil
  opts.on('--ip IP', 'search by ip') do |value|
    options["ip"] = value
  end
  
  options["name"] = nil
  opts.on('--name Name', 'search by name') do |value|
    options["name"] = value
  end
  
  options["email_body"] = nil
  opts.on('--email-body EmailBody', 'search by EmailBody') do |value|
    options["email_body"] = value
  end

end.parse!

doc = Nokogiri.XML(open('./emails.xml'))
output = []
doc.css("record").each do |node|
    hash={}
    node.children.each do |node|
        hash[node.name] = node.text;
    end
    output << hash
end

if(options["ip"] != nil)
    output = output.select { |item| item.fetch("ip_address") == options["ip"] }
end

if(options["name"] != nil)
    output = output.select { |item| item.fetch("first_name") == options["name"] || item.fetch("last_name") == options["name"] }
end

if(options["email_body"] != nil)
    output = output.select { |item| item.fetch("email_body") == options["email_body"] || item.fetch("email_body") == options["email_body"] }
end

if ARGV.first=='list'
    output.each do |o|
        puts JSON.pretty_generate(o)+',';
    end
else
    if output[0]
        puts JSON.pretty_generate(output[0]);
    end
end
   


