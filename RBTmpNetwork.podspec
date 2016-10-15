
Pod::Spec.new do |s|

  s.name         = "RBTmpNetwork"
  s.version      = "1.0.2"
  s.summary      = "A lightweight iOS networking framework based on AFNetworking"

  s.homepage     = "https://github.com/mcmengchen/RBTmpNetwork.git"
  s.license      = "MIT "
  
  s.author        = { "baxiang" => "baxiang@roboo.com" }
  s.source       = { :git => "https://github.com/mcmengchen/RBTmpNetwork.git", :tag => s.version.to_s }
  s.source_files  = "RBTmpNetwork/Classes/*.{h,m}"
  s.requires_arc  = true
  s.ios.deployment_target = "7.0"
  s.dependency 'AFNetworking'
  s.dependency 'YYKit'
end
