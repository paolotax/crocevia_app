class AppuntoFormController < UITableViewController


  include PrintDelegate
  include AppuntoFormDelegate

  
  attr_accessor :delegate


  def initWithAppunto(appunto)    
    initWithStyle(UITableViewStyleGrouped).tap do
      @undo = Store.shared.undo_manager
      @undo.beginUndoGrouping

      @appunto = appunto
      @cliente = appunto.cliente
      @righe = appunto.righe.sort_by("libro.titolo")
    end
  end


  def initWithCliente(cliente)
    initWithStyle(UITableViewStyleGrouped).tap do
      @undo = Store.shared.undo_manager
      @undo.beginUndoGrouping

      @cliente = cliente
      @appunto = Appunto.create cliente: @cliente, cliente_id: @cliente.remote_id, status: "da_fare", uuid: BubbleWrap.create_uuid.downcase, created_at:Time.now
      @righe = @appunto.righe.sort_by("libro.titolo")
    end
  end


  def viewDidLoad
    super

    rmq.stylesheet = AppuntoFormControllerStylesheet

    tableView.tap do |tv|
      tv.registerClass(TextViewCell, forCellReuseIdentifier:'noteCell')
    end

    init_nav
  end


  def viewWillAppear(animated)
    super
    tableView.reloadData
  end


#pragma mark - Initialization


  def init_nav

    self.navigationItem.tap do |nav|
      
      nav.leftBarButtonItem = UIBarButtonItem.cancel { cancel }
      nav.rightBarButtonItem = UIBarButtonItem.done { save }
    
    end
  end


#pragma mark - Notifications


#pragma mark - Actions


  def cancel
    @undo.endUndoGrouping
    @undo.undoNestedGroup
    self.dismissViewControllerAnimated(true, completion:nil)
  end
  

  def save

    @appunto.updated_at = Time.now
    @undo.endUndoGrouping

    cdq.save
    Store.shared.persist

    self.delegate.appuntoFormController(self, didSaveAppunto:@appunto)
    
  end


#pragma mark -   libriController delegate
  

  def libriController(controller, didSelectLibro:libro)
    
    riga_controller = RigaFormController.alloc.initWithAppunto(@appunto, andLibro:libro)
    controller.navigationController.pushViewController(riga_controller, animated:true)

  end


#pragma mark -   editListController delegate
  

  def editListController(controller, didSelectItem:item)
    cell = tableView.cellForRowAtIndexPath([0, 3].nsindexpath)
    cell.detailTextLabel.text = item.split('_').join(' ')
    @appunto.status = item
    self.navigationController.popViewControllerAnimated(true)
  end



#pragma mark - ActionSheet delegate


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex
      
      @appunto.deleted_at = @appunto.updated_at = Time.now
      cdq.save
      Store.shared.persist
      self.delegate.appuntoFormController(self, didSaveAppunto:@appunto)

    end
    @actionSheet = nil
  end



end