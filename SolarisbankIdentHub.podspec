Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name    = "SolarisbankIdentHub"
  spec.version = "1.1.3"
  spec.summary = "iOS SDK for Solarisbank IdentHub."

  spec.description = <<-DESC
  iOS SDK for Solarisbank IdentHub.

  It provides an easy way to integrate identification provided by Solarisbank into your iOS app.
  DESC

  spec.homepage = "https://www.solarisbank.com/en/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license	= { :type => 'Copyright', :text => <<-LICENSE
                  Copyright © 2021 Solarisbank AG. All rights reserved.
                  LICENSE
                }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author = { "Solarisbank Mobile Team" => "Jan.Ehrhardt@solarisbank.de" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.ios.deployment_target = "12.0"
  spec.swift_version         = "5.5"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source = { :git => "https://github.com/Solarisbank/identhub-ios.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files = "Framework/**/*.{h,m,swift}", 'fixup_project_structure'
  spec.resources = "Framework/**/*.{png,xib,storyboard,xcassets}", "Localization/**/*.{lproj,strings}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.dependency 'FourthlineSDK', '~> 2.8.1'
  spec.dependency 'ZIPFoundation', '0.9.11'
  spec.dependency 'InputMask', '~> 6.1.0'
  spec.dependency 'lottie-ios'

  spec.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
