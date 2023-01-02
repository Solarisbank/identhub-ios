Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name    = "SolarisbankIdentHubCore"
  spec.module_name = "IdentHubSDKCore"
  spec.version = "1.4.0"
  spec.summary = "Solaris IdentHub SDK for iOS - Core Module"

  spec.description = <<-DESC
    Core functionalities of the Solaris IdentHub SDK for iOS.
  DESC

  spec.homepage = "https://www.solarisbank.com/en/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license    = { :type => 'Copyright', :text => <<-LICENSE
                  Copyright © 2022 Solarisbank AG. All rights reserved.
                  LICENSE
                }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author = { "Solaris Identity Team" => "matthew.aberdein@solarisgroup.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.ios.deployment_target = "12.0"
  spec.swift_version         = "5.5"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source = { :git => "https://github.com/Solarisbank/identhub-ios.git", :tag => "#{spec.version}" }
  
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  spec.source_files = "Modules/Core/IdentHubSDKCore/**/*.{h,m,swift}", 'fixup_project_structure'
  spec.resources = "Modules/Core/IdentHubSDKCore/**/*.{png,xib,storyboard,xcassets,lproj,strings}","Shared/Colors.xcassets"
  spec.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) MARKETING_VERSION=#{spec.version}" }
end

