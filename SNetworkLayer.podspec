#
# Be sure to run `pod lib lint SNetworkLayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SNetworkLayer'
  s.version          = '1.1.5'
  s.summary          = 'Example for requester layer RESTful of SNetworkLayer.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This my first pod, framework network requester with concurrency applied/classic
                       DESC

  s.homepage         = 'https://github.com/lucdiasdev/SNetworkLayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lucdiasdev' => 'lucrodrigs@gmail.com' }
  s.source           = { :git => 'https://github.com/lucdiasdev/SNetworkLayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'SNetworkLayer/Classes/**/*.swift'
  
  # s.resource_bundles = {
  #   'SNetworkLayer' => ['SNetworkLayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
