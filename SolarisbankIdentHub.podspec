#
#  Be sure to run `pod spec lint SolarisbankIdentHub.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = "SolarisbankIdentHub"
  spec.version      = "0.3.0"
  spec.summary      = "iOS SDK for Solarisbank IdentHub."

  spec.description  = <<-DESC
  iOS SDK for Solarisbank IdentHub.

  It provides an easy way to integrate identification provided by Solarisbank into your iOS app.
  DESC

  spec.homepage     = "https://www.solarisbank.com/en/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license	= { :type => 'Copyright', :text => <<-LICENSE
                  Copyright © 2021 Solarisbank AG. All rights reserved.
                  LICENSE
                }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "Solarisbank Mobile Team" => "Jan.Ehrhardt@solarisbank.de" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.3"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source       = { :git => "https://github.com/Solarisbank/identhub-ios.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files  = "Framework/**/*.{h,m,swift}", 'fixup_project_structure'
  spec.resources     = "Framework/**/*.{png,xib,storyboard,xcassets}", 'fixup_project_structure'

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.dependency 'FourthlineSDK', '~> 2.2.8'

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
