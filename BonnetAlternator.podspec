
Pod::Spec.new do |s|
  s.name             = 'BonnetAlternator'
  s.version          = '0.1.9'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.summary          = 'Elegant way to connect your users with a large platform of chargers'
  s.homepage         = 'https://www.joinbonnet.com/home-header-b'
  s.author           = { 'Bonnet LTD' => 'ana@joinbonnet.com' }
  s.source           = { :git => 'git@github.com:bonnet-electric/BonnetAlternatoriOS.git', :tag => s.version }
  
  s.ios.deployment_target = '14.0'
  
  s.swift_version    = "5.0"
  s.source_files     = 'Sources/BonnetAlternator/**/*.{h,m,swift,pch}'
  s.vendored_frameworks = 'artifacts/BFSecurity.xcframework'
end
