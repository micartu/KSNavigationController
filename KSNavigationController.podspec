Pod::Spec.new do |s|
	s.osx.deployment_target = '10.10'
	s.name             = 'KSNavigationController'
	s.version          = '0.4.0'
	s.summary          = 'Mimics behaviour of UINavigationController but for OSX'
	s.requires_arc 	   = true

	s.description      = <<-DESC
Tries to behave itself like a UINavigationController
	DESC

	s.homepage         = 'https://github.com/micartu/KSNavigationController'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'micartu' => 'michael.artuerhof@gmail.com' }
	s.source           = { :git => 'https://github.com/micartu/ksnavigationcontroller.git', :tag => s.version.to_s }

	s.source_files = 'lib/**/*.{swift}'

	s.frameworks = 'AppKit'
	s.swift_version = "4.2"
end
