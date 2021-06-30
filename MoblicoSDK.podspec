Pod::Spec.new do |s|
  s.name         = "MoblicoSDK"
  s.version      = "2.1.0"
  s.summary      = "Moblico SDK for iOS"
  s.homepage     = "https://github.com/Moblico/MoblicoSDK-iOS"
  s.author    = "Moblico Solutions"
  s.license      = "Apache License 2.0"
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/Moblico/MoblicoSDK-iOS.git", :tag => "v2.1.0" }
  s.source_files  = "MoblicoSDK/*.{h,m}"
end
