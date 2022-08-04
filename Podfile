source 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git'
source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
workspace 'IdentHubSDK'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!
inhibit_all_warnings!

target 'IdentHubSDK' do
pod 'FourthlineSDK', '2.13.1'

# Fourthline dependencies
pod 'ZIPFoundation', '0.9.11'
pod 'lottie-ios'

# Comment the next line if you're not using BANK verification
pod 'InputMask', '6.1.0'

end

target 'IdentHubSDKTests' do
end

target 'IdentHubSDKTestBase' do
  project 'Modules/Core/Core'
  pod 'SnapshotTesting', '~> 1.9.0'
end

target 'IdentHubSDKCoreTests' do
  project 'Modules/Core/Core'
  pod 'SnapshotTesting', '~> 1.9.0'
end

target 'IdentHubSDKQESTests' do
  project 'Modules/QES/QES'
  pod 'SnapshotTesting', '~> 1.9.0'
end

target 'IdentHubSDKQESSnapshotTests' do
  project 'Modules/QES/QES'
  pod 'SnapshotTesting', '~> 1.9.0'
end

target 'Sample' do
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    end
  end
end
