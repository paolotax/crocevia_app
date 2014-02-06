class ClienteAppuntiController < UIViewController

  
  include PrintDelegate
  include ClienteAppuntiDelegate
  
  # attr_accessor :cliente

  def initWithCliente(cliente)
    init
    @cliente = cliente
    self
  end


  def viewDidLoad
    super

    rmq.stylesheet = ClienteAppuntiControllerStylesheet

    self.view.backgroundColor = UIColor.clearColor

    @tableView = rmq.append(UITableView.grouped, :table_view).get.tap do |tv|
      tv.delegate = self
      tv.dataSource = self
    end

    @refresh = rmq(@tableView).append(UIRefreshControl).on(:value_changed) do
      loadFromBackend
    end.get
    
    self.navigationItem.tap do |nav|
      nav.rightBarButtonItem = UIBarButtonItem.add do
        controller = UINavigationController.alloc.initWithRootViewController(AppuntoFormController.alloc.initWithCliente(@cliente))
        controller.topViewController.delegate = self
        self.presentViewController(controller, animated:true, completion:nil)
      end
    end

    init_toolbar

  end


  def viewWillAppear(animated)
    super
    @tableView.setTintColor @cliente.color
    self.navigationController.navigationBar.setBarTintColor @cliente.color
    self.navigationController.navigationBar.setTintColor rmq.color.white
    self.navigationController.toolbar.setTintColor @cliente.color   

    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.add_observer(self, "contentSizeCategoryChanged:", nil)

    "TSMessageNotification".add_observer(self, "show_message:", nil )
    reload
  end


  def viewWillDisappear(animated)
    super
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.remove_observer(self, "contentSizeCategoryChanged:")
    "TSMessageNotification".remove_observer(self, nil )
  end


  def contentSizeCategoryChanged(notification)
    @tableView.reloadData
  end


#pragma mark - Initialization 


  def init_nav
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.imaged('001-menu-gray') do
        self.sideMenuViewController.openMenuAnimated true, completion:nil
      end
    end
  end


  def init_toolbar    
    items = [
      @mail_button = UIBarButtonItem.imaged('730-envelope') { sendEmail(nil) },
      UIBarButtonItem.flexible_space,
      @call_button = UIBarButtonItem.imaged('735-phone') { makeCall(nil) },
      UIBarButtonItem.flexible_space,
      @site_button = UIBarButtonItem.imaged('786-browser') { goToSite(nil) },
      UIBarButtonItem.flexible_space,
      @navigate_button = UIBarButtonItem.imaged('852-map') { navigate(nil) }
    ]
    self.setToolbarItems items, animated:false
    self.navigationController.toolbarHidden = false

    enable_toolbar_buttons
  end


  def enable_toolbar_buttons
    @mail_button.enabled = !@cliente.email.blank?
    @call_button.enabled = !@cliente.telefono.blank?
    @site_button.enabled = true
    @navigate_button.enabled = !@cliente.longitude.blank?    
  end


#pragma mark - Actions


  def show_message(notification)
    message = notification.userInfo[:message]
    
    TSMessage.showNotificationInViewController self.navigationController,
                                   title:message[:title],
                                subtitle:message[:subtitle],
                                    type:TSMessageNotificationTypeError,
                                duration:TSMessageNotificationDurationAutomatic,
                                callback:nil,
                             buttonTitle:nil,
                          buttonCallback:nil,
                              atPosition:TSMessageNotificationPositionTop,
                     canBeDismisedByUser:true
  end


  def navigate(sender)
    placemark = MKPlacemark.alloc.initWithCoordinate(@cliente.coordinate, addressDictionary:nil)
    mapItem = MKMapItem.alloc.initWithPlacemark(placemark)
    mapItem.name = @cliente.nome    
    mapItem.openInMapsWithLaunchOptions({ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving })
  end  


  def makeCall(sender)
    url = NSURL.URLWithString("tel://#{@cliente.telefono.split(" ").join}")
    UIApplication.sharedApplication.openURL(url);
  end  


  def sendEmail(sender)
    url = NSURL.URLWithString("mailto://#{@cliente.email}")
    UIApplication.sharedApplication.openURL(url);
  end 

  
  def goToSite(sender)
    url = NSURL.URLWithString("http://youpropa.com/clienti/#{@cliente.remote_id}")
    UIApplication.sharedApplication.openURL(url);
  end 


#pragma mark - data loading 


  def reload
    @sorted_appunti = nil
    @appunti_da_fare = nil
    @appunti_in_sospeso = nil
    @appunti_completati = nil
    @tableView.reloadData
  end


  def appunti_da_fare
    @appunti_da_fare ||= begin
      predicate = NSPredicate.predicateWithFormat("deleted_at == nil && status != 'completato' && status != 'in_sospeso'")
      @appunti_da_fare =  sorted_appunti.filteredArrayUsingPredicate(predicate)
      @appunti_da_fare
    end
  end


  def appunti_in_sospeso
    @appunti_in_sospeso ||= begin
      predicate = NSPredicate.predicateWithFormat("deleted_at == nil && status == 'in_sospeso'")
      @appunti_in_sospeso =  sorted_appunti.filteredArrayUsingPredicate(predicate)
      @appunti_in_sospeso
    end
  end


  def appunti_completati
    @appunti_completati ||= begin
      predicate = NSPredicate.predicateWithFormat("deleted_at == nil && status == 'completato'")
      @appunti_completati =  sorted_appunti.filteredArrayUsingPredicate(predicate)
      @appunti_completati
    end
  end


  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = @cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end


#pragma mark - AppuntoFormController delegate 
  

  def appuntoFormController(appuntoFormController, didSaveAppunto:appunto)

    appuntoFormController.dismissViewControllerAnimated(true, completion:nil)
    DataImporter.default.synchronize(lambda do
                  reload
                end,
                failure:lambda do
                  App.alert "Impossibile salvare dati sul server"
                end) 

  end


#pragma mark - SWTableViewDelegate


  def swipeableTableViewCell(cell, didTriggerLeftUtilityButtonWithIndex:index)
    
    indexPath = @tableView.indexPathForCell(cell)
    appunto = @appunti_da_fare[indexPath.row]   
    
    if index == 0
      appunto.cliente.toggle_baule
      cdq.save
      Store.shared.persist
      @tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight
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
        @tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight

        DataImporter.default.synchronize(lambda do
          #reload
        end,
        failure:lambda do
          App.alert "Impossibile salvare dati sul server"
        end) 

      else
        cell.hideUtilityButtonsAnimated true
      end
    end
  end


  def swipeableTableViewCell(cell, didTriggerRightUtilityButtonWithIndex:index)
    
    @current_index   = @tableView.indexPathForCell(cell)
    @current_appunto = @appunti_da_fare[@current_index.row]   

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
      
      @tableView.beginUpdates
      @current_appunto.deleted_at = @current_appunto.updated_at = Time.now      
      cdq.save
      Store.shared.persist
      @tableView.deleteRowsAtIndexPaths([@current_index], withRowAnimation:UITableViewRowAnimationLeft)
      reload
      @tableView.endUpdates
      
    else
      cell = @tableView.cellForRowAtIndexPath(@current_index)
      cell.hideUtilityButtonsAnimated true
    end
    @actionSheet = nil
    @current_appunto = nil
    @current_index = nil
  end


  private


    def loadFromBackend
      if Store.shared.isReachable? == false
        @refresh.endRefreshing unless @refresh.nil?
        App.alert "Dispositivo non connesso alla rete. Riprova più tardi"
        return
      end
      params = { cliente: @cliente.remote_id }

      UserAuthenticator.alloc.login( lambda do
          DataImporter.default.importa_appunti(params) do |result|
            reload if result.success?
            @refresh.endRefreshing unless @refresh.nil?
          end
        end,
        failure: -> { @refresh.endRefreshing unless @refresh.nil? }
      )

    end


end