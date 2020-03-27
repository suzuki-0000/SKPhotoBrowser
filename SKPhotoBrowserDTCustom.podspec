Pod::Spec.new do |s|
  s.name                = "SKPhotoBrowserDTCustom"
  s.version             = "6.1.2"
  s.summary             = "Simple PhotoBrowser/Viewer iwritten by pure swift. inspired by facebook, twitter photo browsers."
  s.homepage            = "https://github.com/AsTao/SKPhotoBrowser"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { "astao" => "236048180@qq.com" }
  s.source              = { :git => "https://github.com/AsTao/SKPhotoBrowser.git", :tag => s.version }
  s.platform            = :ios, "10.0"
  s.source_files        = "SKPhotoBrowser/**/*.{h,swift}"
  s.resources           = "SKPhotoBrowser/SKPhotoBrowser.bundle"
  s.requires_arc        = true
  s.frameworks          = "UIKit"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
end
