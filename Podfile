source 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git'
source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
workspace 'IdentHubSDK'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!
inhibit_all_warnings!

def fourthline_pods
  pod 'FourthlineSDK', '2.26.0'
end

target 'IdentHubSDK' do
end

target 'IdentHubSDKTests' do
end

target 'IdentHubSDKTestBase' do
  project 'Modules/Core/Core'
end

target 'IdentHubSDKCoreTests' do
  project 'Modules/Core/Core'
end

target 'IdentHubSDKQESTests' do
  project 'Modules/QES/QES'
end

target 'IdentHubSDKQESSnapshotTests' do
  project 'Modules/QES/QES'
end

target 'IdentHubSDKFourthline' do
  project 'Modules/IdentHubSDKFourthline/Fourthline'
  fourthline_pods
end

target 'IdentHubSDKFourthlineTests' do
  project 'Modules/IdentHubSDKFourthline/Fourthline'
  fourthline_pods
end

target 'IdentHubSDKBank' do
  project 'Modules/IdentHubSDKBank/Bank'
end

target 'IdentHubSDKBankTests' do
  project 'Modules/IdentHubSDKBank/Bank'
end

target 'Sample' do
  fourthline_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    end
  end
end
