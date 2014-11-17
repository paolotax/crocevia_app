class AppuntoPageController < UIPageViewController


  def initWithAppunti(appunti, index:index)
    initWithTransitionStyle(UIPageViewControllerTransitionStyleScroll, navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal, options:nil).tap do
      @appunti = appunti
      @index = index
    end
  end  

  def viewDidLoad
    super

    rmq.stylesheet = AppuntoPageControllerStylesheet
    rmq(self.view).apply_style :root_view

    appuntoVC = AppuntoController.new
    appuntoVC.appunto = @appunti[@index]
    appuntoVC.index = @index
    self.setViewControllers( [appuntoVC],
         direction:UIPageViewControllerNavigationDirectionForward,
          animated:false,
        completion:nil
    )
    
    self.dataSource = self
    init_nav
  end

  def init_nav

    self.navigationItem.tap do |nav|
      
      nav.leftBarButtonItem = UIBarButtonItem.titled("Chiudi") do
        self.dismissViewControllerAnimated(true, completion:nil)
      end

      nav.title = "Appunto"
      
      nav.rightBarButtonItem = UIBarButtonItem.imaged("icon-pencil", :plain) do
        index = self.viewControllers.lastObject.index
        appunto = @appunti[index]

        controller = UINavigationController.alloc.initWithRootViewController(AppuntoFormController.alloc.initWithAppunto(appunto))
        controller.topViewController.delegate = self
        self.presentViewController(controller, animated:true, completion:nil)
      end 
    end
  end

#pragma mark - AppuntoFormController delegate 
  

  def appuntoFormController(appuntoFormController, didSaveAppunto:appunto)

    self.viewControllers.lastObject.update

    appuntoFormController.dismissViewControllerAnimated(true, completion:nil)
    SyncManager.default.synchronize(lambda do
                  #reload
                end,
                failure:lambda do
                  App.alert "Impossibile salvare dati sul server"
                end) 

  end


  def pageViewController(pageViewController, viewControllerAfterViewController:viewController)

    oldVC = viewController
    newIndex = oldVC.index + 1
    return nil if (newIndex > @appunti.count - 1) 
    
    newVC = AppuntoController.new
    newVC.appunto = @appunti[newIndex]
    newVC.index = newIndex
   
    return newVC
  end

  def presentationCountForPageViewController(pageViewController)
    @appunti.size
  end

  def presentationIndexForPageViewController(pageViewController)
    @index
  end

  def pageViewController(pageViewController, viewControllerBeforeViewController:viewController)

    oldVC = viewController
    newIndex = oldVC.index - 1
    return nil if (newIndex < 0) 
  
    newVC = AppuntoController.new
    newVC.appunto = @appunti[newIndex]
    newVC.index = newIndex

    return newVC
  end



end
