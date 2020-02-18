
Pod::Spec.new do |spec|
  spec.name         = "LGYSegmentView"
  spec.version      = "1.1.1"
  spec.summary      = "导航菜单栏."

  spec.description  = <<-DESC
                        低耦合简单易用的导航菜单栏
                   DESC

  spec.homepage     = "https://github.com/Coderplayer/LGYSegmentView"
  spec.license      = "MIT"

  spec.author             = { "L.G.Y." => "" }
    spec.platform     = :ios, "8.0"

  spec.source       = { :git => "https://github.com/Coderplayer/LGYSegmentView.git", :tag => "#{spec.version}" }

  spec.source_files  = "SegmentView/*.{h,m}"

end
