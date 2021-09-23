
source 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

pod 'FourthlineSDK', '2.5.0'

# Comment the next line if you're not using document scanner with MRZ detection
pod 'SwiftyTesseract', '2.2.3'

# Comment the next line if you're not going to create ZIP file
pod 'ZIPFoundation'

target 'IdentHubSDK' do
end

target 'IdentHubSDKTests' do
end

target 'Sample' do
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    config.build_settings['ENABLE_BITCODE'] = 'YES'
    config.build_settings['SWIFT_VERSION'] = '5.4'
  end
end
