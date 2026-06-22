platform :ios, '16.6'
use_frameworks!

target 'BubbleShooter' do
  # Official Skillz install — pulls Kochava, OpenTelemetry, Rive, AppLovin, etc.
  # Skillz 2025.0.50 matches GeocomplySDKs from skillz_ios_2025050 in Vendor/.
  # After downloading Skillz 2026 SDK zip, run Scripts/update_geocomply_from_skillz_sdk.sh
  # and switch back to: pod 'Skillz', '~> 2026.0'
  pod 'Skillz', '2025.0.50'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.6'
    end
  end

  # Skillz ships a Swift module built with an older toolchain; we call Skillz via ObjC bridging header.
  swiftmodule = File.join(installer.sandbox.root, 'Skillz/Skillz.framework/Modules/Skillz.swiftmodule')
  disabled = "#{swiftmodule}.disabled"
  if Dir.exist?(swiftmodule) && !Dir.exist?(disabled)
    FileUtils.mv(swiftmodule, disabled)
  end
end
