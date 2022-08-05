Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name    = "SolarisbankIdentHubQES"
  spec.module_name = "IdentHubSDKQES"
  spec.version = "1.2.8"
  spec.summary = "iOS QES Module for Solarisbank IdentHub SDK"

  spec.description = <<-DESC
    iOS QES Module for Solarisbank IdentHub SDK
  DESC

  spec.homepage = "https://www.solarisbank.com/en/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license    = { :type => 'Copyright', :text => <<-LICENSE
                  Copyright © 2022 Solarisbank AG. All rights reserved.
                  LICENSE
                }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author = { "Solarisbank Mobile Team" => "Jan.Ehrhardt@solarisbank.de" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.ios.deployment_target = "12.0"
  spec.swift_version         = "5.5"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source = { :git => "https://github.com/Solarisbank/identhub-ios.git", :tag => "#{spec.version}" }
  
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  spec.dependency 'SolarisbankIdentHubCore', "#{spec.version}"

  spec.source_files = "Modules/QES/IdentHubSDKQES/**/*.{h,m,swift}", 'fixup_project_structure'
  spec.resources = "Modules/QES/IdentHubSDKQES/**/*.{png,xib,storyboard,xcassets,lproj,strings}","Shared/Colors.xcassets"
  
end
