Pod::Spec.new do |s|
  s.name         = "MoblicoSDK"
  s.version      = "2.0.1"
  s.summary      = "Moblico SDK for iOS"
  s.homepage     = "https://github.com/Moblico/MoblicoSDK-iOS"
  s.author    = "Moblico Solutions"
  s.license      = "Apache License 2.0"
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/Moblico/MoblicoSDK-iOS.git", :tag => "v2.0.1" }
  s.source_files  = "MoblicoSDK/*.{h,m}"
end
