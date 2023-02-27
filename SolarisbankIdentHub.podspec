Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name    = "SolarisbankIdentHub"
  spec.version = "1.5.0"
  spec.summary = "Solaris IdentHub SDK for iOS"

  spec.description = <<-DESC
  Solaris IdentHub SDK for iOS.
  
  The Solaris IdentHub SDKs provide an easy way to integrate the
  identification methods provided by Solarisbank into your iOS app.
  DESC

  spec.homepage = "https://www.solarisbank.com/en/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license	= { :type => 'Copyright', :text => <<-LICENSE
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


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files = "Framework/**/*.{h,m,swift}", 'fixup_project_structure'
  spec.resources = "Framework/**/*.{png,xib,storyboard,xcassets,lproj,strings}","Shared/Colors.xcassets"
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.dependency 'SolarisbankIdentHubCore', "#{spec.version}"

  spec.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
