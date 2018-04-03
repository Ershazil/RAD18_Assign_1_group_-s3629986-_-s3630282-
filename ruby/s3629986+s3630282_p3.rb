require 'nokogiri'
require 'json'
require 'optparse'
require 'Time'
def getTime(dateStr)
    begin
        return Time.parse(dateStr)
    rescue => exception
        date,time= dateStr.split(" ")
        date.sub!(/\//,"-")
        y,mo, d = date.split("-")
        if time 
            h,m,sAms = time.split(":")
            s,ms = sAms.split(".")
        end
       
        return Time.local(y ,mo || 1,d || 1, h || 0,m||0 ,s||0,ms||0 )
    end
end

options = {}
option_parser = OptionParser.new do |opts|
  # 这里是这个命令行工具的帮助信息
  opts.banner = 'here is help messages of the command line tool.'

  options["ip"] = nil
  opts.on('--ip IP', 'search by ip') do |value|
    # 这个部分就是使用这个Option后执行的代码
    options["ip"] = value
  end
  
  options["name"] = nil
  opts.on('--name Name', 'search by name') do |value|
    # 这个部分就是使用这个Option后执行的代码
    options["name"] = value
  end
  
  options["email_body"] = nil
  opts.on('--email-body EmailBody', 'search by EmailBody') do |value|
    # 这个部分就是使用这个Option后执行的代码
    options["email_body"] = value
  end

  options["before"] = nil
  opts.on('--before Date', 'search the data before Date') do |value|
    # 这个部分就是使用这个Option后执行的代码
    options['before'] = getTime(value)
  end

  options["after"] = nil
  opts.on('--after Date', 'search the data after Date') do |value|
    # 这个部分就是使用这个Option后执行的代码
    options['after'] = getTime(value)
  end

  options["day"] = nil
  opts.on('--day Day', 'search by Day') do |value|
    # 这个部分就是使用这个Option后执行的代码
    options['day'] = Date.parse(value).cwday
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
    output = output.select { |item| item.fetch("email_body") == options["email_body"] }
end

if(options["before"] != nil)
    output = output.select { |item| Time.xmlschema(item.fetch("send_date")) <= options["before"] }
end

if(options["after"] != nil)
    if(options["before"] !=nil && options["before"]>options["after"] )
        raise 'before Time bigger than after Time'  
    end
    output = output.select { |item| Time.xmlschema(item.fetch("send_date")) > options["after"] }
end

if(options["day"] != nil)
    output = output.select { |item| Date.xmlschema(item.fetch("send_date")).cwday == options["day"] }
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
   


