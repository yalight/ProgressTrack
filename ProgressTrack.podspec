Pod::Spec.new do |s|
  s.name             = "ProgressTrack"
  s.version          = "1.0.0"
  s.summary          = "A progress track like the one used in SoundCloud.com."
  s.homepage         = "https://github.com/yalight/ProgressTrack"
  s.license          = "MIT"
  s.author           = { "yalight" => "yalight@gmail.com" }
  s.source           = { :git => "https://github.com/yalight/ProgressTrack.git", :tag => s.version.to_s }
  s.source_files     = "ProgressTrack/*.{swift}"
  s.platform         = :ios, "8.0"
  s.requires_arc     = true
  s.frameworks       = "UIKit"
end

