source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

target 'FlickSKK' do
  pod 'NorthLayout'
  pod 'Alamofire', '~> 4.0.0'
  pod '※ikemen'
end

target 'FlickSKKKeyboard' do
  pod 'NorthLayout'
  pod 'Alamofire', '~> 4.0.0'
  pod '※ikemen'
end

target 'FlickSKKTests' do
  pod 'Quick'
  pod 'Nimble'
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r(
    'Pods/Target Support Files/Pods-FlickSKK/Pods-FlickSKK-Acknowledgements.plist',
    'FlickSKK/Settings.bundle/Acknowledgements.plist',
    remove_destination: true)

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

plugin 'cocoapods-app_group'
