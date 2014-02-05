class RigaFormController < UITableViewController


  attr_accessor :delegate
 

  def initWithRiga(riga)
    initWithStyle(UITableViewStyleGrouped).tap do
      @undo = Store.shared.undo_manager
      @undo.beginUndoGrouping
      @riga = riga
    end
  end


  def initWithAppunto(appunto, andLibro:libro)
    initWithStyle(UITableViewStyleGrouped).tap do
      @undo = Store.shared.undo_manager
      @undo.beginUndoGrouping
      @riga = Riga.create(
          appunto:appunto, 
          appunto_id:appunto.remote_id, 
          libro:libro,
          libro_id:libro.remote_id,
          quantita: 1
      )
      @riga.set_default_conditions
    end
  end

  
  def viewDidLoad
    super
    rmq.stylesheet = RigaFormControllerStylesheet
    rmq(self.tableView).apply_style :root_view

    init_nav
  end


#pragma mark - Initialization 


  def init_nav
    self.navigationItem.tap do |nav|
      nav.rightBarButtonItem = UIBarButtonItem.save do 
        save
      end
      nav.leftBarButtonItem = UIBarButtonItem.cancel do 
        cancel
      end
    end

  end

#pragma mark -  Actions


  def save   
    @undo.endUndoGrouping
    @riga.appunto.updated_at = Time.now   
    self.navigationController.popViewControllerAnimated(true)
  end


  def cancel
    @undo.endUndoGrouping
    @undo.undoNestedGroup
    self.navigationController.popViewControllerAnimated(true)
  end


#pragma mark -  UITableViewDelegate

  
  def numberOfSectionsInTableView(tableView)
    3
  end


  def tableView(tableView, numberOfRowsInSection:section)
    if section == 1
      3
    else
      1
    end
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    if indexPath.section == 0
      # titolo
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:"libroCell")
      cell.textLabel.text = @riga.libro.titolo
      cell.detailTextLabel.text = "prezzo copertina #{@riga.libro.prezzo_copertina.string_with_style(:currency)}"
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      
    elsif indexPath.section == 1

      if indexPath.row == 0
        # quantita
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:"quantitaCell")
        cell.textLabel.text = "quantità"
        cell.detailTextLabel.text = "#{@riga.quantita}"
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      
      elsif indexPath.row == 1
        # prezzo e sconto
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:"prezzoCell")
        cell.textLabel.text = "prezzo"
        cell.detailTextLabel.text = "#{@riga.prezzo_unitario.string_with_style(:currency)}"
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

      elsif indexPath.row == 2
        # prezzo e sconto
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:"scontoCell")
        cell.textLabel.text = "sconto"
        cell.detailTextLabel.text = "#{@riga.sconto.round(2)} %"

      end

    elsif indexPath.section == 2
      # importo
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:"importoCell")
      cell.textLabel.text = "importo"
      cell.detailTextLabel.text = "#{@riga.calc_importo.string_with_style(:currency)}"
    
    end

    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if (indexPath.section == 0)
      88
    else
      44
    end
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    if indexPath.section == 0
      # titolo
      
    elsif indexPath.section == 1 && indexPath.row == 0
      # quantita
      controller = EditTextFieldController.alloc.initWithType(TextFieldTypeDecimal)
      controller.load_data("#{@riga.quantita}", withLabel:"Inserisci la quantità")
      controller.text_changed_block = lambda do |text, error|
        @riga.quantita = text.to_i
        tableView.reloadData
      end    
      self.navigationController.pushViewController controller, animated:true
      
    elsif indexPath.section == 1 && indexPath.row >= 1
      # prezzo e sconto
      controller = EditPrezzoController.alloc.initWithRiga(@riga)
      controller.prezzo_changed_block = lambda do |prezzo, sconto, error|
        @riga.prezzo_unitario = prezzo
        @riga.sconto = sconto
        tableView.reloadData
      end
      
      self.navigationController.pushViewController controller, animated:true
    end
  end

  
end