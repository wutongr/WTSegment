Pod::Spec.new do |s|
  s.name         = "WTSegment"
  s.version      = "0.2.3"
  s.summary      = "GUOTAIJUNAN YDPT Lib"
  s.description  = "GJYD components...GUOTAIJUNAN YDPT Lib"
  s.homepage     = "http://www.wutongr.com"
  s.license      = 'MIT'
  s.author       = { "wutongr" => "zc_and_zc@aliyun.com" }
  s.platform     = :ios, '7.0'
<<<<<<< Updated upstream
  s.source       = { :git => "https://github.com/wutongr/WTSegment.git", :tag => "v0.2.3" }
=======
  s.source       = { :git => "https://github.com/wutongr/WTSegment.git", :tag => s.version }
>>>>>>> Stashed changes
  s.requires_arc = true
  s.source_files = 'WTSegment/WTSegment/{WTSegment}*.{h,m}'
  s.frameworks   = 'QuartzCore'

end