WORKSPACE="FlickSKK.xcworkspace"
SCHEME = "FlickSKK"
PROVISIONING_PROFILE = ENV['PROVISIONING_PROFILE'] || "FlickSKK AppStore"
TMP = "tmp"
ARCHIVE = "#{TMP}/#{SCHEME}"
IPA = "#{ARCHIVE}.ipa"
PRETTY = (%x(which xcpretty); $?) == 0 ? "xcpretty -c" : "cat"
ALTOOL = "$(xcode-select -p)/../Applications/Application\\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool"

task :clean do
    puts "cleaning..."
    sh "rm -rf #{TMP} && mkdir #{TMP}"
end

task :archive => :clean do
    puts "archiving..."
    sh "xcodebuild archive -workspace #{WORKSPACE} -scheme #{SCHEME} -archivePath #{ARCHIVE} | #{PRETTY}"
end

task :ipa => :archive do
    puts "creating ipa..."
    sh "xcodebuild -exportArchive -archivePath #{ARCHIVE}.xcarchive -exportPath #{ARCHIVE} -exportFormat ipa -exportProvisioningProfile '#{PROVISIONING_PROFILE}' | #{PRETTY} && exit ${PIPESTATUS[0]}"
end

task :submit => :ipa do
    puts "submitting to TestFlight..."

    require 'io/console'
    print "iTunes Connect ID or Email: "
    user = STDIN.gets.strip
    print "iTunes Connect Password: "
    password = STDIN.noecho(&:gets).strip
    puts ""

    sh "#{ALTOOL} --upload-app --file #{IPA} --username #{user} --password #{password}", verbose: false
end

