class AppDelegate
  
  
  include CDQ

  
  attr_reader :window, :store
  attr_accessor :url_session


  def application(application, didFinishLaunchingWithOptions:launchOptions)


    cdq.setup(context: Store.shared.context) # don't set up model or store coordinator
    
    Store.shared.setupReachability

    sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration
    @url_session = NSURLSession.sessionWithConfiguration(sessionConfig)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true
    
    menuViewController = MenuController.new
    mainViewController = ImagesController.new

    # create a new side menu
    sideMenuViewController = TWTSideMenuViewController.alloc.initWithMenuViewController menuViewController, mainViewController:UINavigationController.alloc.initWithRootViewController(mainViewController)

    # specify the shadow color to use behind the main view controller when it is scaled down.
    sideMenuViewController.shadowColor = UIColor.blackColor

    # specify a UIOffset to offset the open position of the menu
    sideMenuViewController.edgeOffset = UIOffsetMake(20.0, 0.0)

    # specify a scale to zoom the interface — the scale is 0.0 (scaled to 0% of it's size) to 1.0 (not scaled at all). The example here specifies that it zooms so that the main view is 56.34% of it's size in open mode. 
    sideMenuViewController.zoomScale = 0.5634

    # set the side menu controller as the root view controller

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = sideMenuViewController
    @window.makeKeyAndVisible

    if CredentialStore.default.token.blank?
      @login = LoginController.alloc.init
      @window.rootViewController.presentModalViewController(@login, animated:false)
    end

    # UIApplication.sharedApplication.setStatusBarStyle UIStatusBarStyleLightContent
    # UINavigationBar.appearance.setTitleTextAttributes(NSForegroundColorAttributeName => UIColor.whiteColor)

    true
  end
end

