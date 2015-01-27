# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

require 'ruby_motion_query'

Motion::Project::App.setup do |app|

  app.name = 'youpropapp'
  app.identifier = 'com.taxsoft.youpropapp'
  app.short_version = '0.1.0'
  app.version = app.short_version

  app.sdk_version = '8.1'
  app.deployment_target = '8.1'

  # app.icons = ["icon-40@2x.png", "icon-60@2x.png", "icon-76@2x.png"]

  # prerendered_icon is only needed in iOS 6
  #app.prerendered_icon = true

  app.device_family = [:iphone]
  app.interface_orientations = [:portrait] #, :landscape_left, :landscape_right, :portrait_upside_down]

  app.files += Dir.glob(File.join(app.project_dir, 'lib/**/*.rb'))

  #app.provisioning_profile = '/Users/paolotax/Library/MobileDevice/Provisioning Profiles/4E9FFB4B-DEBF-4264-9C8D-815106B7FFDA.mobileprovision'   
  
  app.provisioning_profile = '/Users/paolotax/Downloads/youpropa_profile.mobileprovision'
  app.codesign_certificate = 'iPhone Developer: Paolo Tassinari (9L6JUZD52Q)' 

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  app.frameworks << 'QuartzCore'
  app.frameworks << 'MapKit'
  app.frameworks << 'CoreLocation'
  app.frameworks << 'AVFoundation'
  app.frameworks << 'AudioToolbox'

  # Use `rake config' to see complete project settings, here are some examples:
  #
  # app.fonts = ['Oswald-Regular.ttf', 'FontAwesome.otf'] # These go in /resources
  # app.frameworks = %w(QuartzCore CoreGraphics MediaPlayer MessageUI CoreData)
  #
  # app.vendor_project('vendor/Flurry', :static)
  # app.vendor_project('vendor/DSLCalendarView', :static, :cflags => '-fobjc-arc') # Using arc
  #
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
