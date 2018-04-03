require 'nokogiri'
require 'json'
require 'optparse'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'here is help messages of the command line tool.'

  options["api-key"] = nil
  opts.on('--api-key api-key', 'api key') do |value|
    options["api-key"] = value
  end

  options["format"] = nil
  opts.on("--format type",'format') do |value|
    options["format"] = value
  end

end.parse!

unless (options["api-key"] =~ /(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,}/)
    puts 'Invalid API Key, operation abort...'  
    exit
end

@gatewayMap = JSON.parse(File.read('./sms_mms_gateway.json'))

def get_sms_carrier(record)
    smsMap=@gatewayMap["sms_carriers"]
    email=record["email"].gsub(/^.*(?=@)/, "{number}")
    str=""
    smsMap.each do |key1, hash1|
        hash1.each do |key2,arr2|
            if arr2[1] == email
                str= "#{@gatewayMap["countries"][key1]}: #{arr2[0]}"
            end
        end
    end
    return str
end

def get_mms_carrier(record)
   smsMap=@gatewayMap["mms_carriers"]
    email=record["email"].gsub(/^.*(?=@)/, "{number}")
    str=""
    smsMap.each do |key1, hash1|
        hash1.each do |key2,arr2|
            if arr2[1] == email
                str= "#{@gatewayMap["countries"][key1]}: #{arr2[0]}"
            end
        end
    end
    return str
end

doc = Nokogiri.XML(open('./emails.xml'))
output = []
doc.css("record").each do |node|
    hash={}
    node.children.each do |node|
        hash[node.name] = node.text;
    end
    output << hash
end

if ARGV.first=='list'
    str="";
    for i in 0..20
        output[i]["sms_carrier"]=get_sms_carrier(output[i]);
        output[i]["mms_carrier"]=get_mms_carrier(output[i]); 
        if(options["format"]=='oneline')
            str += output[i].to_json +',';
        else
            str += JSON.pretty_generate(output[i])+",\n";
        end
    end
    puts str;
else
    unless output[0]
        return
    end
    output[0]["sms_carrier"]=get_sms_carrier(output[0]);
    output[0]["mms_carrier"]=get_mms_carrier(output[0]); 
    if(options["format"]=='oneline')
        puts output[0].to_json;
    else
        puts JSON.pretty_generate(output[0]);
    end
end
   


