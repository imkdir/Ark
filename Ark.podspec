#
#  Be sure to run `pod spec lint GLFeedKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.

Pod::Spec.new do |spec|

  spec.name         = "Ark"
  spec.version      = "0.0.1"
  spec.summary      = "Combine Texture and DeepDiff with iOS-13-DiffableDataSource-like API"
  spec.homepage     = "https://github.com/imkdir/Ark.git"
  spec.license      = "MIT"
  spec.author             = { "Dwight CHENG" => "dwight.cheng@glowing.com" }

  spec.platform     = :ios
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/imkdir/Ark.git", :tag => s.version.to_s }

  spec.source_files  = "Ark", "Ark/**/*.swift"
  # spec.exclude_files = "Classes/Exclude"

  spec.dependency "Texture", "~> 3.0"

end