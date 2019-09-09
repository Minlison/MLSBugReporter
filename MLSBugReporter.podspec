Pod::Spec.new do |s|
  s.name         = 'MLSBugReporter'
  s.version      = '1.0.0'
  s.summary      = '禅道辅助插件'
  s.description  = <<-DESC
                    禅道辅助插件，提交Bug至禅道
                   DESC

  s.homepage     = 'https://github.com/Minlison/MLSBugReporter.git'
  s.license      = 'MIT'
  s.author       = { 'yuanhang' => 'yuanhang@minlison.com' }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/Minlison/MLSBugReporter.git", :tag => "v#{s.version}" }
  s.requires_arc = true
  s.default_subspecs = 'Core'
  s.static_framework = true
  s.frameworks = 'Foundation'
  s.libraries = 'c++', 'z'
  s.user_target_xcconfig = {
        'GCC_PREPROCESSOR_DEFINITIONS' => 'MLS_USE_BUG_REPORTER=1'
  }
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'MLSBugReporter/*.{h,m}', 'MLSBugReporter/Classes/**/*.{h,m}', 'MLSBugReporter/Api/*.{h,m}'
    ss.public_header_files = 'MLSBugReporter/MLSBugReporter.h', 'MLSBugReporter/MLSBugReporterManager.h'
    ss.dependency 'MLSUICore/MLSPopup'
    ss.dependency 'MLSUICore/Core'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIPopupContainerView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIDialogViewController'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIOrderedDictionary'
    ss.dependency 'MLSNetwork', '>= 1.0.0'
    ss.dependency 'MLSModel', '>= 1.0.0'
    ss.dependency 'hpple', '>= 0.2.0'
    ss.dependency 'matrix-minlison', '>= 0.5.2'
    ss.dependency 'SSZipArchive', '>= 2.1.5'
    ss.dependency 'MLSBugReporter/Buglife'
    ss.dependency 'MLSBugReporter/Aspects'
    ss.dependency 'MLSBugReporter/NetworkTrack'
    ss.dependency 'MLSBugReporter/SystemLog'
    ss.frameworks = 'CoreTelephony'
    
  end
  s.subspec 'NetworkTrack' do |tracker|
    tracker.source_files = 'MLSBugReporter/NetworkTrack/**/*.{h,m}'
    tracker.dependency 'CocoaLumberjack', '>= 3.5.2'
  end

  s.subspec 'SystemLog' do |systemlog|
    systemlog.source_files  = 'MLSBugReporter/SystemLog/**/*.{h,m}'
    systemlog.dependency 'CocoaLumberjack', '>= 3.5.2'
  end

  s.subspec 'Aspects' do |ss|
    ss.source_files  = 'MLSBugReporter/Aspects/*.{h,m}'
  end

  s.subspec 'Buglife' do |ss|
    ss.source_files   = 'MLSBugReporter/Buglife/**/*.{h,m,mm,c,cpp}'
  end
end
