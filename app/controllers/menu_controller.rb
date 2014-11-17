class MenuController < UIViewController 


  #attr_accessor :nel_baule_controller, :da_fare_controller, :in_sospeso_controller, :cronologia_controller


  def viewDidLoad
    super
    puts "didLoad"
    # non capisco
    @nel_baule_controller = UINavigationController.alloc.initWithRootViewController ClientiController.alloc.initWithCDQQuery(Cliente.per_provincia.nel_baule, andTitle:'nel baule', andColor:COLORS[0])

    rmq.stylesheet = MenuControllerStylesheet
    rmq(self.view).apply_style :root_view

    @data = ["Nel baule", "Da fare", "In sospeso", "Cronologia", "Mappa"]
    @clienti = []

    init_background

    @search_bar = rmq.append(UISearchBar, :search_bar).get
    @search_controller = UISearchDisplayController.alloc.initWithSearchBar(@search_bar, contentsController:self).tap do |sc|
      sc.delegate = self
      sc.searchResultsDataSource = self
      sc.searchResultsDelegate = self
    end      
    @menu_table_view = rmq.append(UITableView, :menu_table_view).get
    @menu_table_view.delegate = self
    @menu_table_view.dataSource = self

    self.sideMenuViewController.delegate = self
  end


#pragma mark - view controllers


  def nel_baule_controller
    @nel_baule_controller || begin
      puts "load nel baule" 
      @nel_baule_controller = UINavigationController.alloc.initWithRootViewController ClientiController.alloc.initWithCDQQuery(Cliente.per_provincia.nel_baule, andTitle:'nel baule', andColor:COLORS[0])
    end
  end
    

  def da_fare_controller
    @da_fare_controller || begin   
      @da_fare_controller = UINavigationController.alloc.initWithRootViewController ClientiController.alloc.initWithCDQQuery(Cliente.per_provincia.da_fare, andTitle:'da fare', andColor:COLORS[1])
    end
  end


  def in_sospeso_controller  
    @in_sospeso_controller ||= UINavigationController.alloc.initWithRootViewController ClientiController.alloc.initWithCDQQuery(Cliente.per_provincia.in_sospeso, andTitle:'in sospeso', andColor:COLORS[2])
  end


  def cronologia_controller 
    @cronologia_controller || begin
      @cronologia_controller = UINavigationController.alloc.initWithRootViewController AppuntiController.alloc.initWithCDQQuery(Appunto.cronologia, andTitle:"cronologia", andColor:nil)
      @cronologia_controller.topViewController.init_nav
      @cronologia_controller.topViewController.show_cliente = true
      @cronologia_controller
    end
  end
  

  def map_controller  
    @map_controller ||= UINavigationController.alloc.initWithRootViewController MapController.new
  end


  def init_background

    self.view.backgroundColor = UIColor.grayColor    
    @backgroundImageView = UIImageView.alloc.initWithImage UIImage.imageNamed("galaxy")
    @backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    
    imageViewRect = UIScreen.mainScreen.bounds
    imageViewRect.size.width += 589
    @backgroundImageView.frame = imageViewRect;
    @backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view.addSubview @backgroundImageView

    viewDictionary = { "imageView" => @backgroundImageView }
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]", options:0, metrics:nil, views:viewDictionary))

    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]", options:0, metrics:nil, views:viewDictionary))
  
  end


  def resetImage(originalImage)

    newSize = CGSizeMake(38, 38)
    imageRect = CGRectMake( 0, 0, newSize.width, newSize.height)

    UIGraphicsBeginImageContext(newSize)
    originalImage.drawInRect(imageRect)
    theImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return theImage
  end


#pragma mark - sideMenuViewControllerDelegates


  def sideMenuViewControllerDidCloseMenu(sideMenuViewController)
    controller = sideMenuViewController.mainViewController
    
    if controller.topViewController.is_a? AppuntiController
      controller.topViewController.reload
    end    
    
    if controller.topViewController.respond_to? :load_province
      puts "side #{controller.topViewController}"
      controller.topViewController.load_province
    end

    controller.view.hidden = false
  end


#pragma mark - tableViewDelegates


  def tableView(tableView, numberOfRowsInSection: section)
    if tableView == @menu_table_view
      @data.count
    else
      @clienti.count
    end
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    
    if tableView == @menu_table_view
      @menuIdentifier ||= "menu_cell"
      cell = tableView.dequeueReusableCellWithIdentifier(@menuIdentifier)
      unless cell
        cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:@menuIdentifier)
      end
      cell.textLabel.color = COLORS[indexPath.row]
      cell.textLabel.text = @data[indexPath.row]
      cell.imageView.image = resetImage "#{MENU_IMAGES[indexPath.row]}-on35".uiimage
      cell.backgroundColor = UIColor.clearColor
    else
      @clienteIdentifier ||= "cliente_cell"
      cell = tableView.dequeueReusableCellWithIdentifier(@clienteIdentifier)
      unless cell
        cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@clienteIdentifier)
      end
      cell.textLabel.text = @clienti[indexPath.row].nome
    end
    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    50
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    tableView.deselectRowAtIndexPath(indexPath, animated:false)
    cell = tableView.cellForRowAtIndexPath indexPath

    if tableView == @menu_table_view
      
      if indexPath.row == 0
        controller = nel_baule_controller
      elsif indexPath.row == 1
        controller = da_fare_controller
      elsif indexPath.row == 2
        controller = in_sospeso_controller
      elsif indexPath.row == 3
        controller = cronologia_controller
      elsif indexPath.row == 4
        controller = map_controller     
      end
    else

      cliente = @clienti[indexPath.row]

      controller = UINavigationController.alloc.initWithRootViewController ClienteAppuntiController.alloc.initWithCliente(cliente)
      controller.topViewController.init_nav
      
    end

    if @old == controller
      self.sideMenuViewController.closeMenuAnimated(true, completion:nil)
    else
      #rmq(self.sideMenuViewController.mainViewController.view).animations.fade_out(duration: 1.5)
      self.sideMenuViewController.setMainViewController controller, animated:true, closeMenu:true 
    end

    @old = controller
    @search_controller.active = false
  end


#pragma mark - searchDisplayDelegates
 

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    query = Cliente.per_provincia.where("nome contains[cd] '#{searchString}'").or("comune contains[cd] '#{searchString}'").or("frazione contains[cd] '#{searchString}'")
    
    @clienti = query
    true
  end


  def searchDisplayControllerWillBeginSearch(controller)
    rmq(self.sideMenuViewController.mainViewController.view).animations.fade_out    
  end


  def searchDisplayControllerDidEndSearch(controller)
    rmq(self.sideMenuViewController.mainViewController.view).animations.fade_in
  end


end



