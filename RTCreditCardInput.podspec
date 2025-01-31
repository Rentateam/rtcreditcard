#
# Be sure to run `pod lib lint RTCreditCardInput.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RTCreditCardInput'
  s.version          = '1.0.11'
  s.summary          = 'A helper library to add card payment into your app'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
It is a library to add card payment ability into your application. It is used for convenient handling card input form, format and validate it. 
You can provide your own validation and error decoration logic.
See the embedded example in example folder.
                       DESC

  s.homepage         = 'https://github.com/Rentateam/rtcreditcard'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RentaTeam' => 'info@rentateam.ru' }
  s.source           = { :git => 'https://github.com/Rentateam/rtcreditcard.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'

  s.source_files = 'RTCreditCardInput/Classes/**/*'
  s.dependency 'CHRTextFieldFormatter', '~> 1.0.1'
end
