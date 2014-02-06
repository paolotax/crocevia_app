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

    sideMenuViewController.shadowColor = UIColor.blackColor
    sideMenuViewController.edgeOffset = UIOffsetMake(20.0, 0.0)
    sideMenuViewController.zoomScale = 0.5634
    sideMenuViewController.animationType = TWTSideMenuAnimationTypeFadeIn
    sideMenuViewController.animationDuration = 0.3

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

