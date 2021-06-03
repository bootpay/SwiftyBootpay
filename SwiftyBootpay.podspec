#
# Be sure to run `pod lib lint SwiftyBootpay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
  s.name             = 'SwiftyBootpay'
  s.version          = '3.4.3'
  s.summary          = 'Bootpay PG Plugin For Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
 

  s.homepage         = 'https://github.com/bootpay/SwiftyBootpay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bootpay' => 'bootpay.co.kr@gmail.com' }
  s.source           = { :git => 'https://github.com/bootpay/SwiftyBootpay.git', :tag => s.version.to_s, :branch => 'main' }
  
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'SwiftyBootpay/Classes/**/*'

  
  s.resource_bundles = {
    'SwiftyBootpay' => ['SwiftyBootpay/*.xcassets']
  }
 
  s.static_framework = true
  s.dependency 'CryptoSwift'  
  s.dependency 'Alamofire',  '~> 5.2.2'
  s.dependency 'ObjectMapper'
  s.dependency 'SwiftOTP'
  s.dependency 'SnapKit', '~> 5.0.0'
  s.dependency 'JGProgressHUD'
   
  
end
