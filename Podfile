source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

use_frameworks!

target 'FlickSKK' do
  link_with 'FlickSKK', 'FlickSKKKeyboard'
  pod 'NorthLayout'
  pod 'Alamofire'
end

target 'FlickSKKTests' do
  pod 'Quick', '~> 0.8.0'
  pod 'Nimble', '3.0.0'
  pod 'NorthLayout'
end

post_install do |installer|
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-FlickSKK/Pods-FlickSKK-Acknowledgements.plist', 'FlickSKK/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

plugin 'cocoapods-app_group'
