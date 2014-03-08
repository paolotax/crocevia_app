class AppuntiController < UITableViewController

  
  include NSFetchedResultsControllerDelegate
  include FetchProvince
  include PrintDelegate
  include SwipeAppuntoDelegate


  attr_accessor :show_cliente


  def initWithCDQQuery(query, andTitle:title, andColor:color)
    init
    @query = query
    @title = title
    @color = color
    @controller = FetchControllerQuery.controllerWithQuery @query
    @controller.delegate = self
    self
  end


  def viewDidLoad
    super

    rmq.stylesheet = AppuntiControllerStylesheet

    tableView.tap do |cv|
      cv.delegate = self
      cv.dataSource = self
      rmq(cv).apply_style :table_view
    end

    init_nav_color
  end


#pragma mark - Initialization 
  

  def init_nav_color
    self.title =  "#{@title} (#{@controller.fetchedObjects.count})"

    if @color
      self.navigationController.navigationBar.setBarTintColor @color
      self.navigationController.navigationBar.setTintColor rmq.color.white
    end
  end


  def init_nav
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.imaged('001-menu-gray') do
        #@controller = nil
        self.sideMenuViewController.openMenuAnimated true, completion:nil
      end

      nav.rightBarButtonItem = UIBarButtonItem.titled('Clienti') do
        self.navigationController.popViewControllerAnimated(true)
        self.navigationController.topViewController.load_province
      end
    end
  end


#pragma mark - actions


  def reload
    @controller = nil
    @controller = FetchControllerQuery.controllerWithQuery @query
    @controller.delegate = self 
    self.title =  "#{@title} (#{@controller.fetchedObjects.count})" 
    tableView.reloadData 
  end


#pragma mark - AppuntoFormController delegate 
  

  def appuntoFormController(appuntoFormController, didSaveAppunto:appunto)

    appuntoFormController.dismissViewControllerAnimated(true, completion:nil)
    SyncManager.default.synchronize(lambda do
                  #reload
                end,
                failure:lambda do
                  App.alert "Impossibile salvare dati sul server"
                end) 

  end


#pragma mark - TableView delegates 

  
  def numberOfSectionsInTableView(tableView)
    @controller.sections.size
  end

  
  def tableView(tableView, numberOfRowsInSection:section)
    @controller.sections[section].numberOfObjects
  end


  def left_utility_buttons
    left_utility_buttons = []
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[0], icon:"icon-nel_baule-on35".uiimage   
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[1], icon:"icon-da_fare-on35".uiimage
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[2], icon:"icon-in_sospeso-on35".uiimage
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[3], icon:"icon-completato-on35".uiimage
    left_utility_buttons
  end


  def right_utility_buttons
    right_utility_buttons = []
    right_utility_buttons.sw_addUtilityButtonWithColor UIColor.redColor, title:"elimina"
    right_utility_buttons.sw_addUtilityButtonWithColor UIColor.lightGrayColor, title:"altro"
    right_utility_buttons
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    
    cell = tableView.dequeueReusableCellWithIdentifier('appuntoCell') || begin
      rmq.create(AppuntoCell, :appunto_cell, cell_identifier: "appuntoCell").get
    end

    cell.delegate = self
    cell.containingTableView = tableView
    cell.setCellHeight cell.frame.size.height
    
    cell.leftUtilityButtons  = left_utility_buttons
    cell.rightUtilityButtons = right_utility_buttons
    
    configureCell(cell, atIndexPath:indexPath)
    cell
  end


  def configureCell(cell, atIndexPath:indexPath)
    
    unless cell.nil?
      appunto = @controller.objectAtIndexPath(indexPath)
      cell.update(
        cliente_nome: appunto.cliente.nome,
        destinatario: appunto.destinatario,
        note: appunto.note_e_righe,
        status: appunto.status,
        nel_baule: appunto.cliente.nel_baule,
        created_at: appunto.created_at,
        updated_at: appunto.updated_at,
        telefono: appunto.telefono,
        email: appunto.email,
        show_cliente: show_cliente
      )
    end

    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    90
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
    
    appunto = @controller.objectAtIndexPath(indexPath)
    controller = UINavigationController.alloc.initWithRootViewController(AppuntoFormController.alloc.initWithAppunto(appunto))
    controller.topViewController.delegate = self
    self.presentViewController(controller, animated:true, completion:nil)
  end

end
