Pod::Spec.new do |s|
  s.name         = "SKPhotoBrowser"
  s.version      = "3.1.0"
  s.summary      = "Simple PhotoBrowser/Viewer inspired by facebook, twitter photo browsers written by swift2.0."
  s.homepage     = "https://github.com/suzuki-0000/SKPhotoBrowser"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "suzuki_keishi" => "keishi.1983@gmail.com" }
  s.source       = { :git => "https://github.com/suzuki-0000/SKPhotoBrowser.git", :tag => s.version }
  s.platform     = :ios, "8.0"
  s.source_files = "SKPhotoBrowser/**/*.{h,swift}"
  s.resources    = "SKPhotoBrowser/SKPhotoBrowser.bundle"
  s.requires_arc = true
  s.frameworks   = "UIKit"
end
