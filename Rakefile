WORKSPACE="FlickSKK.xcworkspace"
SCHEME = "FlickSKK"
# unused: PROVISIONING_PROFILE = ENV['PROVISIONING_PROFILE'] || "FlickSKK AppStore"
TMP = "tmp"
ARCHIVE = "$(pwd)/#{TMP}/#{SCHEME}"
IPA = "#{ARCHIVE}.ipa"
has_xcpretty = (%x(which xcpretty); $?) == 0
PRETTY = has_xcpretty ? "xcpretty -c" : "cat"
TEST_TMP = "$(pwd)/#{TMP}/tests"
TEST_FORMATTER = has_xcpretty ? "xcpretty -c --report junit --output #{TEST_TMP}/results.xml --report html --output #{TEST_TMP}/results.html" : "cat"
TEST_SIMULATORS = ["iPhone 6"]
ALTOOL = "$(xcode-select -p)/../Applications/Application\\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool"

class String
    def bold; "\033[1m#{self}\033[22m" end
end

task :clean do
    puts "🚮  Cleaning...".bold
    sh "rm -rf #{TMP} && mkdir #{TMP}"
end

task :archive => :clean do
    puts "🔨  Archiving...".bold
    sh "xcodebuild archive -workspace #{WORKSPACE} -scheme #{SCHEME} -archivePath #{ARCHIVE} | #{PRETTY}"
end

task :ipa => :archive do
    puts "📦  Creating ipa...".bold
    sh "xcrun -sdk iphoneos PackageApplication #{ARCHIVE}.xcarchive/Products/Applications/#{SCHEME}.app -o #{IPA}"
    # exportArchiveだとarchived-expanded-entitlements.xcentがうまく処理されない??
    # sh "xcodebuild -exportArchive -archivePath #{ARCHIVE}.xcarchive -exportPath #{ARCHIVE} -exportFormat ipa -exportProvisioningProfile '#{PROVISIONING_PROFILE}' | #{PRETTY} && exit ${PIPESTATUS[0]}"
end

task :submit => :ipa do
    puts "🔌  Contacting to iTunes Connect...".bold

    require 'io/console'
    print "iTunes Connect ID or Email: "
    user = STDIN.gets.strip
    print "iTunes Connect Password: "
    password = STDIN.noecho(&:gets).strip
    puts ""

    puts "✈️  Submitting to TestFlight...".bold
    sh "#{ALTOOL} --upload-app --file #{IPA} --username #{user} --password #{password}", verbose: false

    puts "🎉  Submitted!".bold
end

task :clean_test_results do
    sh "rm -rf #{TEST_TMP}"
end

task :test => :clean_test_results do
    puts "🐬  Testing...".bold

    destinations = TEST_SIMULATORS.map{|d| "-destination \"name=#{d}\""}.join(' ')
    sh "xcodebuild test -workspace #{WORKSPACE} -scheme #{SCHEME} #{destinations} | #{TEST_FORMATTER} && exit ${PIPESTATUS[0]}"
end

