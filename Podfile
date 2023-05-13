platform :ios, '12.0'

use_frameworks!

target 'FlickSKK' do
  pod 'NorthLayout'
  pod '※ikemen'
end

target 'FlickSKKKeyboard' do
  pod 'NorthLayout'
  pod '※ikemen'
end

target 'FlickSKKTests' do
  pod 'NorthLayout'
  pod '※ikemen'
  pod 'Quick'
  pod 'Nimble'
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r(
    'Pods/Target Support Files/Pods-FlickSKK/Pods-FlickSKK-Acknowledgements.plist',
    'FlickSKK/Settings.bundle/Acknowledgements.plist',
    remove_destination: true)

  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      if Gem::Version.new('12.0') > Gem::Version.new(c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end

plugin 'cocoapods-app_group'
