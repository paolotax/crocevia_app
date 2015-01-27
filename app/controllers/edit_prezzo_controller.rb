class EditPrezzoController < UITableViewController


  SCONTI = [10, 15, 18, 20, 23, 25, 30, 43, 0.25]
  

  attr_accessor :prezzo_changed_block

  
  def initWithRiga(riga)
    initWithStyle(UITableViewStyleGrouped)
    @riga = riga
    self
  end


  def viewDidLoad
    super
    rmq.stylesheet = EditPrezzoControllerStylesheet
  end


#pragma mark - Actions


  def handleButtonDone
    
    error = Pointer.new(:object)

    @edit_sconto.text.blank? ? sconto = 0 : sconto = @edit_sconto.text.gsub(/,/, ".").to_f.round(2)
    @edit_prezzo.text.blank? ? prezzo = @riga.libro.prezzo_copertina : prezzo = @edit_prezzo.text.gsub(/,/, ".").to_f.round(2)
          
    success = @prezzo_changed_block.call(prezzo, sconto, error)
    if (success) 
      self.navigationController.popViewControllerAnimated(true)
      return true
    else
      alertView = UIAlertView.alloc.initWithTitle("Error", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
      alertView.show
      return false
    end

  end


  def showDoneButton
    navigationItem.rightBarButtonItem = UIBarButtonItem.done { handleButtonDone }
  end


#pragma mark - tableView delegates

  
  def numberOfSectionsInTableView(tableView)
    1
  end


  def tableView(tableView, numberOfRowsInSection:section)
    4 + SCONTI.count
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    if indexPath.row >= 4
      # sconti
      sconto = SCONTI[indexPath.row - 4] 
      cell = UITableViewCell.value1("sconto#{sconto}Cell", 
        text: "sconto #{sconto}%",
        detail:  ((@riga.libro.prezzo_copertina * (100 - sconto) / 100).to_f.string_with_style(:currency))
      ) 

    elsif indexPath.row == 0
      # indica prezzo
      cell = UITableViewCell.value1("prezzoCell", 
        text: 'indica il prezzo'
      )
      @edit_prezzo = rmq(cell.contentView).append(UITextField, :edit_prezzo).on(:editing_changed) do 
        showDoneButton
      end.get

    elsif indexPath.row == 1
      # indica sconto
      cell = UITableViewCell.value1("scontoCell", 
        text: 'indica lo sconto'
      )
      @edit_sconto = rmq(cell.contentView).append(UITextField, :edit_sconto).on(:editing_changed) do 
        showDoneButton
      end.get

    elsif indexPath.row == 2
      # consigliato
      cell = UITableViewCell.value1("consigliatoCell", 
        text: 'prezzo consigliato',
        detail:  @riga.libro.prezzo_consigliato.to_f.string_with_style(:currency)
      )    

    elsif indexPath.row == 3
      # omaggio
      cell = UITableViewCell.value1("omaggioCell", 
        text: 'omaggio',
        detail:  "GRATIS"
      ) 
    end

    cell
  end


  def tableView(tableView, titleForHeaderInSection:section)
    "Scegli il prezzo o lo sconto"
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    if indexPath.row >= 2
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark

      if indexPath.row == 2
        prezzo = @riga.libro.prezzo_consigliato
        sconto = 0
      elsif indexPath.row == 3
        prezzo = @riga.libro.prezzo_copertina
        sconto = 100
      else
        prezzo = @riga.libro.prezzo_copertina
        sconto = SCONTI[indexPath.row - 4]
      end

      error = Pointer.new(:object)
      success = @prezzo_changed_block.call(prezzo, sconto, error)
      if (success) 
        self.navigationController.popViewControllerAnimated(true)
        return true
      else
        alertView = UIAlertView.alloc.initWithTitle("Error", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
        alertView.show
        return false
      end
    end

    if [0, 1].include?(indexPath.row)
      showDoneButton
    end

  end


  def scrollViewDidScroll(scrollView)
    @edit_sconto.resignFirstResponder if @edit_sconto
    @edit_prezzo.resignFirstResponder if @edit_prezzo
  end


end