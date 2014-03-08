class ClienteFormController < UITableViewController


  include ClienteFormDelegate
  

  attr_accessor :delegate


  def initWithCliente(cliente)    
    initWithStyle(UITableViewStyleGrouped).tap do
      @undo = Store.shared.undo_manager
      @undo.beginUndoGrouping

      if cliente then
        @cliente = cliente
      else
        @cliente = Cliente.create(uuid: BubbleWrap.create_uuid.downcase, created_at:Time.now)
      end
    end
  end


  def viewDidLoad
    super

    rmq.stylesheet = ClienteFormControllerStylesheet
    init_nav

    didChange = NSManagedObjectContextObjectsDidChangeNotification
    didChange.add_observer(self, "changes:", Store.shared.context)

    didSave = NSManagedObjectContextDidSaveNotification
    didSave.add_observer(self, "didSave:", Store.shared.context)
  end


  def viewWillAppear(animated)
    super
    #tableView.reloadData
  end


  def viewWillDisappear(animated)
    super
  end


#pragma mark - Notifications


  def changes(sender) 
    puts "---changes--- "
    if @cliente.valid?
      unless @button_save
        @button_save = UIBarButtonItem.save { save }
        self.navigationItem.rightBarButtonItem = @button_save
      end
    elsif @button_save
      self.navigationItem.rightBarButtonItem = nil
      @button_save = nil
    end
  end


  def didSave(sender)
    puts "---didSave--- "
  end


#pragma mark - Initialization


  def init_nav
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.cancel { cancel }
    end
  end


#pragma mark - Actions


  def cancel
    @undo.endUndoGrouping
    @undo.undoNestedGroup

    remove_observers

    self.delegate.clienteFormController(self, didSaveCliente:nil)
  end
  

  def save

    @cliente.updated_at = Time.now
    @undo.endUndoGrouping

    Store.shared.save
    Store.shared.persist

    remove_observers

    self.delegate.clienteFormController(self, didSaveCliente:@cliente)    
  end


  def remove_observers
    puts "remove_observers"
    NSNotificationCenter.defaultCenter.removeObserver self
    # didChange = NSManagedObjectContextObjectsDidChangeNotification
    # didChange.remove_observer(self, "changes:")
    # didSave = NSManagedObjectContextDidSaveNotification
    # didSave.remove_observer(self, "didSave:")
  end


end