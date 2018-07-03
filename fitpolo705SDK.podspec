Pod::Spec.new do |s|
  s.name         = "fitpolo705SDK"    #存储库名称
  s.version      = "0.0.1"      #版本号，与tag值一致
  s.summary      = "fitpolo705 SDK"  #简介
  s.description  = "fitpolo705是703、705手环开发提供的SDK"  #描述
  s.homepage     = "https://github.com/Fitpolo/fitpolo703705-iOSDemo"      #项目主页，不是git地址
  s.license      = { :type => "MIT", :file => "LICENSE" }   #开源协议
  s.author             = { "lovexiaoxia" => "aadyx2007@163.com" }  #作者
  s.platform     = :ios, "8.0"                 #支持的平台和版本号
  s.ios.deployment_target = "8.0"
  s.frameworks   = "UIKit", "Foundation" #支持的框架
  s.source       = { :git => "https://github.com/Fitpolo/fitpolo703705-iOSDemo.git", :tag => "#{s.version}" }         #存储库的git地址，以及tag值
  s.requires_arc = true #是否支持ARC

  s.source_files = "fitpolo705SDK/**/*"

end