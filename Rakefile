# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

require 'ruby_motion_query'

Motion::Project::App.setup do |app|

  app.name = 'youpropapp'
  app.identifier = 'com.youpropa.youpropapp'
  app.short_version = '1.1.0'
  app.version = app.short_version

  app.sdk_version = '8.2'
  app.deployment_target = '8.2'

  app.device_family = [:iphone]
  app.interface_orientations = [:portrait]

  app.files += Dir.glob(File.join(app.project_dir, 'lib/**/*.rb'))
  
  app.provisioning_profile = '/Users/paolotax/Downloads/youpropapp_profile.mobileprovision'
  app.codesign_certificate = 'iPhone Developer: Paolo Tassinari (9L6JUZD52Q)' 

  app.release do
    app.entitlements['beta-reports-active'] = true
  end
  
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  app.frameworks << 'QuartzCore'
  app.frameworks << 'MapKit'
  app.frameworks << 'CoreLocation'
  app.frameworks << 'AVFoundation'
  app.frameworks << 'AudioToolbox'

  app.pods do
    pod 'TWTSideMenuViewController'
    pod 'RestKit', '0.23.1'
    pod 'LBBlurredImage'
    pod 'TSMessages', '0.9.10'
    pod 'SWTableViewCell'
    pod 'SVProgressHUD'
    pod 'MHPrettyDate'
  end

  app.development do
    app.pods do
      pod "Reveal-iOS-SDK"
    end
  end
 
end
task :"build:simulator" => :"schema:build"
