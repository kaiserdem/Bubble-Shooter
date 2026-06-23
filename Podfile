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
      # iOS 18+ simulators are arm64-only; Skillz is linked only on device (MockSkillzService on sim).
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = ''
    end
  end

  # Skillz.framework: x86_64 simulator + arm64 device — no arm64 simulator slice.
  %w[debug release].each do |name|
    xcconfig_path = File.join(
      installer.sandbox.root,
      "Target Support Files/Pods-BubbleShooter/Pods-BubbleShooter.#{name}.xcconfig"
    )
    next unless File.exist?(xcconfig_path)

    xcconfig = File.read(xcconfig_path)
    xcconfig.gsub!('EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64', 'EXCLUDED_ARCHS[sdk=iphonesimulator*] = ')
    xcconfig.gsub!(/-framework "Skillz"\s*/, '')
    File.write(xcconfig_path, xcconfig)
  end

  frameworks_script = File.join(
    installer.sandbox.root,
    'Target Support Files/Pods-BubbleShooter/Pods-BubbleShooter-frameworks.sh'
  )
  if File.exist?(frameworks_script)
    content = File.read(frameworks_script)
    unless content.include?('skip_skillz_on_arm64_simulator')
      skillz_helper = <<~'SH'

        skip_skillz_on_arm64_simulator() {
          if [[ "${EFFECTIVE_PLATFORM_NAME}" == "-iphonesimulator" ]] && [[ "${ARCHS}" == *arm64* ]]; then
            echo "note: Skipping Skillz.framework on arm64 simulator (MockSkillzService)"
            return 0
          fi
          install_framework "${PODS_ROOT}/Skillz/Skillz.framework"
        }
      SH
      content.sub!(
        /if \[\[ "\$CONFIGURATION" == "Debug" \]\]; then\n/,
        "#{skillz_helper}\nif [[ \"$CONFIGURATION\" == \"Debug\" ]]; then\n"
      )
      content.gsub!(
        'install_framework "${PODS_ROOT}/Skillz/Skillz.framework"',
        'skip_skillz_on_arm64_simulator'
      )
      File.write(frameworks_script, content)
    end
  end

  # Skillz ships a Swift module built with an older toolchain; we call Skillz via ObjC bridging header.
  swiftmodule = File.join(installer.sandbox.root, 'Skillz/Skillz.framework/Modules/Skillz.swiftmodule')
  disabled = "#{swiftmodule}.disabled"
  if Dir.exist?(swiftmodule) && !Dir.exist?(disabled)
    FileUtils.mv(swiftmodule, disabled)
  end
end
