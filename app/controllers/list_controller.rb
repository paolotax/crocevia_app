class ListController < UIViewController


  def viewDidLoad
    super

    rmq.stylesheet = ListControllerStylesheet
    rmq(self.view).apply_style :root_view

    # Create your views here
    init_nav
  end


  def init_nav
    self.title = 'List'

    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAction, target: self, action: :nav_left_button)
    end
  end

  def nav_left_button
    self.sideMenuViewController.openMenuAnimated true, completion:nil
    #self.sideMenuViewController.setMainViewController self, animated:true, closeMenu:true
    #navigationController.toggle_bureau
  end


  # Remove if you are only supporting portrait
  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskAll
  end

  # Remove if you are only supporting portrait
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    rmq.all.reapply_styles
  end
end


__END__

# You don't have to reapply styles to all UIViews, if you want to optimize, 
# another way to do it is tag the views you need to restyle in your stylesheet, 
# then only reapply the tagged views, like so:
def logo(st)
  st.frame = {t: 10, w: 200, h: 96}
  st.centered = :horizontal
  st.image = image.resource('logo')
  st.tag(:reapply_style)
end

# Then in willAnimateRotationToInterfaceOrientation
rmq(:reapply_style).reapply_styles
