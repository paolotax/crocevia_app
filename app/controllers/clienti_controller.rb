class ClientiController < UITableViewController


  include NSFetchedResultsControllerDelegate
  include FetchProvince
  

  def initWithCDQQuery(query, andTitle:title, andColor:color)
    init

    @flipAnimationController = FlipAnimationController.new

    @query = query
    @title = title
    @color = color
    @controller = FetchControllerQuery.controllerWithQuery @query
    @controller.delegate = self

    self
  end

  
  def viewDidLoad
    super

    rmq.stylesheet = ClientiControllerStylesheet
    rmq(self.view).apply_style :root_view

    @refresh = rmq(tableView).append(UIRefreshControl).on(:value_changed) do
      loadFromBackend
    end.get
    
    tableView.tap do |tv|
      tv.registerClass(ClienteCell, forCellReuseIdentifier: "clienteCell")
    end

    if @color
      self.tableView.setTintColor @color
      self.navigationController.navigationBar.setBarTintColor @color
      self.navigationController.navigationBar.setTintColor rmq.color.white
      self.navigationController.toolbar.setTintColor @color   
      # self.navigationController.navigationBar.setTitleTextAttributes(NSForegroundColorAttributeName => rmq.color.white)
    end
    
    self.navigationController.delegate = self

    load_province
    init_nav
  end


  def viewWillAppear(animated)
    super
    self.title = "#{@title} (#{@controller.fetchedObjects.count})"
    "TSMessageNotification".add_observer(self, 'show_message:', nil)
  end

  
  def viewWillDisappear(animated)
    super
    "TSMessageNotification".remove_observer(self, nil)
  end


#pragma mark - Transition


  def navigationController(navigationController, animationControllerForOperation:operation, fromViewController:fromVC, toViewController:toVC)
    
    # if operation == UINavigationControllerOperationPush
    #   @interactionController.wireToViewController toVC 
    # end

    if ((toVC.is_a? AppuntiController) &&  (fromVC.is_a? ClientiController)) || ((toVC.is_a? ClientiController) &&  (fromVC.is_a? AppuntiController))
      @flipAnimationController.reverse = operation == UINavigationControllerOperationPop
      @flipAnimationController
    end
  end


#pragma mark - Actions


  def reload
    @controller = nil
    @controller = FetchControllerQuery.controllerWithQuery @query
    self.tableView.reloadData
  end


  def show_message(notification)
    message = notification.userInfo[:message]
    
    # TSMessage.showNotificationInViewController self,
    #                                title:message[:title],
    #                             subtitle:message[:subtitle],
    #                                 type:TSMessageNotificationTypeError,
    #                             duration:TSMessageNotificationDurationAutomatic,
    #                             callback:nil,
    #                          buttonTitle:nil,
    #                       buttonCallback:nil,
    #                           atPosition:TSMessageNotificationPositionTop,
    #                  canBeDismisedByUser:true
  end


  def add_cliente
    form = ClienteFormController.alloc.initWithCliente(nil)
    form.delegate = self
    controller = UINavigationController.alloc.initWithRootViewController form
    self.presentViewController controller, animated:true, completion:nil
  end


#pragma mark - Initialization 


  def init_nav
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.imaged('001-menu-gray') do
        self.sideMenuViewController.openMenuAnimated true, completion:nil
      end

      nav.rightBarButtonItem = UIBarButtonItem.titled('Appunti') do
        
        query = Appunto.per_localita.send("a_#{@title.split(" ").join("_")}")
        controller = AppuntiController.alloc.initWithCDQQuery(query, andTitle:@title, andColor:nil)
        controller.show_cliente = true
        
        self.navigationController.pushViewController(controller, animated:true)
        controller.init_nav
        controller.load_province
      end
    end
  end


#pragma mark - ClienteCell delegate


  def clienteCellDidTapBaule(cell)
  
    cliente = @controller.objectAtIndexPath(tableView.indexPathForCell(cell))   
    cliente.toggle_baule   
    cdq(cliente).save
    Store.shared.persist
    cell.nel_baule.nel_baule = cliente.nel_baule
  end


#pragma mark - ClienteFormController delegate 
  

  def clienteFormController(clienteFormController, didSaveCliente:cliente)
    clienteFormController.dismissViewControllerAnimated(true, completion:nil)
    if cliente
      SyncManager.default.synchronize(lambda do
                    #reload
                  end,
                  failure:lambda do
                    App.alert "Impossibile salvare dati sul server"
                  end)
    end
  end


#pragma mark - TableView delegates 

  
  def numberOfSectionsInTableView(tableView)
    @controller.sections.size
  end

  
  def tableView(tableView, numberOfRowsInSection:section)
    @controller.sections[section].numberOfObjects
  end


  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    
    tableView.dequeueReusableCellWithIdentifier('clienteCell', forIndexPath: indexPath).tap do |cell|
      rmq.build(cell) unless cell.reused
      cell.delegate = self

      cell.update({
        nome: @controller.objectAtIndexPath(indexPath).nome,
        citta: @controller.objectAtIndexPath(indexPath).citta,
        nel_baule: @controller.objectAtIndexPath(indexPath).nel_baule,
        color: @color
      })
    end

  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    tableView.deselectRowAtIndexPath(indexPath, animated:false)
    
    cliente = @controller.objectAtIndexPath(indexPath)

    controller = ClienteAppuntiController.alloc.initWithCliente cliente
    self.navigationController.pushViewController controller, animated:true

  end


  private
      

    def loadFromBackend
      if Store.shared.isReachable? == false
        @refresh.endRefreshing unless @refresh.nil?
        App.alert "Dispositivo non connesso alla rete. Riprova più tardi"
        return
      end

      UserAuthenticator.alloc.login( lambda do
          SyncManager.default.importa_clienti(nil) do |result|
            reload if result.success?
            @refresh.endRefreshing unless @refresh.nil?  
          end
        end,
        failure:->{ @refresh.endRefreshing unless @refresh.nil? }
      )

    end

end