# usage:
#   cd  iTunesConnect/FlickSKK.itmsp
#   ruby ../../misc/screenshot.rb *3.5* *iPad* *4.0* *5.5* *4.7* > ~/tmp/screenshots.txt
TARGET = {
    'iPad' => 'iOS-iPad',
    'iPhone-3.5inch' => 'iOS-3.5-in',
    'iPhone-4.0inch' => 'iOS-4-in',
    'iPhone-4.7inch' => 'iOS-4.7-in',
    'iPhone-5.5inch' => 'iOS-5.5-in'
}

def target(name)
    TARGET.each do |key, value|
        if name =~ /#{key}/
            return value
        end
    end
end

def position(name)
    if name =~ /-(\d+)\.png/
        $1
    end
end

ARGV.each do |file|
    filename = File.basename file
    md5 = `md5 -q #{file}`.strip
    puts <<-XML
#{"    "*5}<software_screenshot display_target="#{target(filename)}" position="#{position(filename)}">
#{"    "*6}<size>#{File.size file}</size>
#{"    "*6}<file_name>#{filename}</file_name>
#{"    "*6}<checksum type="md5">#{md5}</checksum>
#{"    "*5}</software_screenshot>
    XML
end
