platform :ios, '17.0'

target 'remoteDesctop' do
  use_frameworks!

  # SSH接続用ライブラリ
  pod 'NMSSH', '~> 2.3.1'
  
  # VNC接続用ライブラリ
  pod 'CocoaAsyncSocket', '~> 7.6.5'
  
  # RDP接続用ライブラリ（FreeRDPのラッパー）
  # 注: FreeRDPはCocoaPodsで直接利用できないため、カスタムビルドが必要
  
  target 'remoteDesctopTests' do
    inherit! :search_paths
  end

  target 'remoteDesctopUITests' do
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end