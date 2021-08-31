#
# Be sure to run `pod lib lint TPPush-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TPPush-Swift'
  s.version          = '1.0.0'
  s.summary          = 'iOS 远程推送库 操作封装 Swift版'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Topredator/TPPush-Swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Topredator' => 'luyanggold@163.com' }
  s.source           = { :git => 'https://github.com/Topredator/TPPush-Swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.static_framework = true
  s.source_files = 'TPPush-Swift/Classes/**/*'
  s.pod_target_xcconfig = {
      'SWIFT_INCLUDE_PATHS' => [
            '$(PODS_ROOT)/TPPush-Swift/Module',
            '$(PODS_TARGET_SRCROOT)/TPPush-Swift/Module'
      ],
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.preserve_paths = [
        'TPPush-Swift/Module/module.modulemap',
        'TPPush-Swift/Module/BridgeHeader.h'
  ]
  s.dependency 'GTSDK'
#  s.pod_target_xcconfig = {
##      'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/TPPush-Swift/ThirdParty/*.framework/Headers',
##      'LD_RUNPATH_SEARCH_PATHS' => '$(PODS_ROOT)/TPPush-Swift/ThirdParty/',
##      'OTHER_LDFLAGS' => '-ObjC',
#      "SWIFT_INCLUDE_PATHS" => ['$(PODS_ROOT)/TPPush-Swift/Module', '$(PODS_TARGET_SRCROOT)/TPPush-Swift/Module']
#  }
#  s.preserve_paths = ['TPPush-Swift/Module/module.modulemap', 'TPPush-Swift/Module/TPPush_Swift.h']
#  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
  s.dependency 'TPFoundation-Swift'
  
end
