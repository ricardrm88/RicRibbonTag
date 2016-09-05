Pod::Spec.new do |s|
  s.name         = "RicRibbonTag"
  s.version      = "1.0.7"
  s.summary      = "Library for adding tags shaped as ribbons to existing views"
  s.description  = <<-DESC
  						Library for adding tags shaped as ribbons to existing views, can be used on top
  						of any UIView. It allows corner ribbons as well as horizontal and vertical ones.
  						It can be customized easily to fit multiple designs.
                   DESC

  s.homepage     = "https://github.com/ricardrm88/RicRibbonTag"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Ricard"
  s.platform     = :ios
  s.ios.deployment_target = "8.1"
  s.requires_arc = true  
  s.source       = { :git => "https://github.com/ricardrm88/RicRibbonTag.git", :tag => s.version }

  s.source_files  = "RicRibbonTag/*.swift"
end
