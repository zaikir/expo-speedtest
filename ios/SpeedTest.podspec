package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'SpeedTest'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = { :ios => '13.0', :tvos => '13.0' }
  s.swift_version  = '5.4'
  s.source         = { git: 'https://github.com/zaikir/expo-speed-test' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule'
  }

  s.source_files = "*.{h,m,mm,swift,hpp,cpp}"
  s.subspec 'Speedmeasure' do |ss|
    ss.source_files = "Speedmeasure.xcframework/lib/*.{h,m,mm,swift,hpp,cpp}"
    ss.vendored_frameworks = 'Speedmeasure.xcframework'
  end
end