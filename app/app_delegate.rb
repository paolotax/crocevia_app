class AppDelegate


  include CDQ
  
    
  attr_reader :window, :store
  attr_accessor :url_session


  def application(application, didFinishLaunchingWithOptions:launchOptions)


    #cdq.setup(context: Store.shared.context) # don't set up model or store coordinator
    
    Store.shared.setupReachability

    sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration
    @url_session = NSURLSession.sessionWithConfiguration(sessionConfig)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true
    
    menuViewController = MenuController.new
    
    mainViewController = menuViewController.nel_baule_controller

    # create a new side menu
    sideMenuViewController = TWTSideMenuViewController.alloc.initWithMenuViewController menuViewController, mainViewController:mainViewController

    sideMenuViewController.shadowColor = UIColor.blackColor
    sideMenuViewController.edgeOffset = UIOffsetMake(20.0, 0.0)
    sideMenuViewController.zoomScale = 0.5634
    sideMenuViewController.animationType = TWTSideMenuAnimationTypeFadeIn
    sideMenuViewController.animationDuration = 0.3
    sideMenuViewController.openMenuAnimated true, completion:nil

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = sideMenuViewController
    @window.makeKeyAndVisible

    if CredentialStore.default.token.blank?
      @login = LoginController.alloc.init
      @window.rootViewController.presentViewController(@login, animated:false, completion:nil)
    end

    # UIApplication.sharedApplication.setStatusBarStyle UIStatusBarStyleLightContent
    # UINavigationBar.appearance.setTitleTextAttributes(NSForegroundColorAttributeName => UIColor.whiteColor)

    true
  end
end

