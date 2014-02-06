class AppuntiController < UITableViewController

  
  include NSFetchedResultsControllerDelegate


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
      end
    end
  end


#pragma mark - AppuntoFormController delegate 
  

  def appuntoFormController(appuntoFormController, didSaveAppunto:appunto)

    appuntoFormController.dismissViewControllerAnimated(true, completion:nil)
    DataImporter.default.synchronize(lambda do
                  #reload
                end,
                failure:lambda do
                  App.alert "Impossibile salvare dati sul server"
                end) 

  end


#pragma mark - SWTableViewDelegate


  def swipeableTableViewCell(cell, didTriggerLeftUtilityButtonWithIndex:index)
    
    indexPath = tableView.indexPathForCell(cell)
    appunto = @controller.objectAtIndexPath(indexPath)   
    
    if index == 0
      appunto.cliente.toggle_baule
      cdq.save
      Store.shared.persist
      tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight
    else  
      case index
        when 1
          status = 'da_fare'
        when 2
          status = 'in_sospeso'
        when 3
          status = 'completato'
      end

      if appunto.status != status
        appunto.updated_at = Time.now
        appunto.status = status
        cdq.save
        Store.shared.persist
        # tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight

        DataImporter.default.synchronize( -> {}, 
          failure:lambda do
            App.alert "Impossibile salvare dati sul server"
          end) 

      else
        cell.hideUtilityButtonsAnimated true
      end
    end
  end


  def swipeableTableViewCell(cell, didTriggerRightUtilityButtonWithIndex:index)
    
    @current_index   = tableView.indexPathForCell(cell)
    @current_appunto = @controller.objectAtIndexPath(@current_index)   

    if index == 1
      print_appunti([@current_appunto.remote_id])
    else
      @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                              delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:"Elimina",
                                          otherButtonTitles:nil)

      @actionSheet.showFromRect(cell.frame, inView:self.view, animated:true)
    end

  end


#pragma mark - ActionSheet delegate


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex
      
      tableView.beginUpdates
      @current_appunto.deleted_at = @current_appunto.updated_at = Time.now      
      cdq.save
      Store.shared.persist
      #tableView.deleteRowsAtIndexPaths([@current_index], withRowAnimation:UITableViewRowAnimationLeft)
      tableView.endUpdates
      
      DataImporter.default.synchronize( -> {}, 
        failure:lambda do
          App.alert "Impossibile salvare dati sul server"
        end) 

    else
      cell = tableView.cellForRowAtIndexPath(@current_index)
      cell.hideUtilityButtonsAnimated true
    end
    @actionSheet = nil
    @current_appunto = nil
    @current_index = nil
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
