#
# Be sure to run `pod lib lint Ripples.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Ripples'
  s.version          = '0.1.0'
  s.summary          = 'Ripple animation for iOS. '
  s.description      = 'Ripple animation for iOS. It is very useful for bluetooth app.'
  s.homepage         = 'https://github.com/catchzeng/Ripples'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'catchzeng' => '891793848@qq.com' }
  s.source           = { :git => 'https://github.com/catchzeng/Ripples.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Ripples/Classes/**/*'
  s.frameworks = 'UIKit'
end
