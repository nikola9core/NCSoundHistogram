#
# Be sure to run `pod lib lint NCSoundHistogram.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NCSoundHistogram'
  s.version          = '0.1.7'
  s.summary          = 'Generates discrete histogram view from audio file.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Subclass of UIView that renders discrete histogram view for a given audio file.
                       DESC

  s.homepage         = 'https://github.com/nikola9core/NCSoundHistogram'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nikola Corlija' => 'nikola9core@yahoo.com' }
  s.source           = { :git => 'https://github.com/nikola9core/NCSoundHistogram.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/nikola9core'

  s.ios.deployment_target = '8.0'

  s.source_files = 'NCSoundHistogram/Classes/**/*'
  
#s.resource_bundles = {
#   'NCSoundHistogram' => ['NCSoundHistogram/Assets/*.m4a']
# }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
