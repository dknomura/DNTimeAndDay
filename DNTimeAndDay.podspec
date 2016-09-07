#
# Be sure to run `pod lib lint DNTimeAndDay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DNTimeAndDay'
  s.version          = '0.1.0'
  s.summary          = 'A model struct to iterate through the time and day at a given interval.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A DNTimeAndDay object is initialized with a string value or int value for time and day along with 12/24hr time format. Developers can set an interval at which the object can be increased/decreased, default is 30 minutes.
                       DESC

  s.homepage         = 'https://github.com/dknomura/DNTimeAndDay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dnomnom' => 'dknomura@gmail.com' }
  s.source           = { :git => 'https://github.com/dknomura/DNTimeAndDay.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DNTimeAndDay/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DNTimeAndDay' => ['DNTimeAndDay/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
