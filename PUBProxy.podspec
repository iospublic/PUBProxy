#
# Be sure to run `pod lib lint PUBProxy.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PUBProxy'
  s.version          = '0.0.1'
  s.summary          = 'A short description of PUBProxy.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/iospublic/PUBProxy'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iospublic' => 'which_name@163.com' }
  s.source           = { :git => 'https://github.com/iospublic/PUBProxy.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target           = '11.0'
  # 允许静态库安装
  s.static_framework = true
  # swift 编译版本
  s.swift_version = '5.0'
  # 公开头文件
  s.public_header_files = 'PUBProxy/Classes/**/*.h'
  s.source_files = 'PUBProxy/Classes/**/*'
  # 第三方依赖
  s.dependency 'TDFModuleKit', '1.0.6'
end
