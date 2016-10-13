
Pod::Spec.new do |s|

  s.name         = "RBNetwork"
  s.version      = "1.0.1"
  s.summary      = "A lightweight iOS networking framework based on AFNetworking"

  s.homepage     = "https://git.365jiating.com/baxiang1/RBNetwork.git"
  s.license      = "MIT "
  
  s.author        = { "baxiang" => "baxiang@roboo.com" }
  s.source       = { :git => "git@git.365jiating.com:baxiang1/RBNetwork.git", :tag => s.version.to_s }
  s.source_files  = "RBNetwork/*.{h,m}"
  s.requires_arc  = true

  s.ios.deployment_target = "7.0"
  s.dependency 'AFNetworking'
  s.dependency 'YYKit'
end
