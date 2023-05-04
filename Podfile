source 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git'
source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
workspace 'IdentHubSDK'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!
inhibit_all_warnings!

def fourthline_pods
  pod 'FourthlineSDK', '2.20.0'

  # Fourthline dependencies
  pod 'ZIPFoundation', '0.9.11'
  pod 'lottie-ios', '4.1.3'
end

def bank_pods
  pod 'InputMask', '6.1.0'
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
  bank_pods
end

target 'IdentHubSDKBankTests' do
  project 'Modules/IdentHubSDKBank/Bank'
  bank_pods
end

target 'Sample' do
  bank_pods
  fourthline_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    end
    if target.name == 'lottie-ios'
      target.build_configurations.each do |config|
        config.build_settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = "YES"
      end
    end
  end
end
