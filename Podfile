pod 'Nimbus', '~> 1.2.0', :inhibit_warnings => true

post_install do |installer|
  # Disable "Application Extension API Only" flag in pods
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = "NO"
    end
  end
end


