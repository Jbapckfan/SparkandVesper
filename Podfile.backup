# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Spark&Vesper' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Spark&Vesper

  # Google AdMob for monetization
  pod 'Google-Mobile-Ads-SDK'

  # Firebase for analytics and crash reporting
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/RemoteConfig' # For A/B testing

  # Optional: Facebook Audience Network for additional ad inventory
  # pod 'FBAudienceNetwork'

  target 'Spark&VesperTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Spark&VesperUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end