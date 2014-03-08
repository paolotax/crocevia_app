module AppuntoFormDelegate


#pragma mark -  UITableViewDelegate

  
  def numberOfSectionsInTableView(tableView)
    5
  end


  def tableView(tableView, numberOfRowsInSection:section)
    if (section == 1)
      @righe.array.count > 0 ? @righe.array.count + 2 : 1
    elsif section == 0
       6
    else
      1
    end
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    if indexPath.section == 0

      if indexPath.row == 0

        cellID = "clienteNomeCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        
        cell.textLabel.text = "cliente"
        cell.detailTextLabel.text = @appunto.valueForKey('cliente').nome
      
      elsif indexPath.row == 2

        tableView.dequeueReusableCellWithIdentifier('noteCell', forIndexPath: indexPath).tap do |cell|
          rmq.build(cell) unless cell.reused
          #cell.delegate = self
          cell.update({
            text_view: @appunto.valueForKey('note')
          })
        end

      else
        
        case indexPath.row
        when 1
          column = 'destinatario'
        when 3
          column = 'status'
        when 4
          column = 'email'
        when 5
          column = 'telefono'
        end

        cellID = "#{column}Cell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        value = @appunto.valueForKey(column)
        if column == 'status'
          value = value.split("_").join(" ")
        end
        cell.textLabel.text = column
        cell.detailTextLabel.text = value
      end

    elsif indexPath.section == 1

      if indexPath.row == 0
        # add riga
        cell = tableView.dequeueReusableCellWithIdentifier("addRigaCell") || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"addRigaCell")
        end
        cell.textLabel.color = self.tableView.tintColor
        cell.textLabel.text = "Aggiungi riga"
        cell.textLabel.textAlignment = NSTextAlignmentCenter
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

      elsif indexPath.row == @righe.array.count + 1
        # totali
        cell = tableView.dequeueReusableCellWithIdentifier("totaliCell") || begin
          rmq.create(TotaliCell, :totali_cell, cell_identifier: "totaliCell").get
        end
        cell.update({
          importo: @appunto.calc_importo,
          copie: @appunto.calc_copie
        })

      else
        # riga
        cell = tableView.dequeueReusableCellWithIdentifier("rigaCell") || begin
          rmq.create(RigaCell, :riga_cell, cell_identifier: "rigaCell").get
        end
        riga = @righe.array[indexPath.row - 1]   
        cell.update({
          titolo: riga.libro.titolo,
          quantita: riga.quantita,
          prezzo_unitario: riga.calc_prezzo,
          image_url: riga.libro.image_url
        })

      end
    
    elsif indexPath.section == 2

      cellID = "scanBarcodeCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      cell.textLabel.color = self.tableView.tintColor
      cell.textLabel.text = "Scan barcode"
      cell.textLabel.textAlignment = NSTextAlignmentCenter
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    elsif indexPath.section == 3

      cellID = "addReminderCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      cell.textLabel.color = self.tableView.tintColor
      cell.textLabel.text = "Aggiungi promemoria"
      cell.textLabel.textAlignment = NSTextAlignmentCenter
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    elsif indexPath.section == 4

      cellID = "deleteCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      cell.textLabel.text = "Elimina"
      cell.textLabel.color = UIColor.redColor
      cell.textLabel.textAlignment = NSTextAlignmentCenter

    end   
    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 0 && indexPath.row == 2
      97
    elsif indexPath.section == 1 && indexPath.row != 0
      50
    else
      44
    end
  end


  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    if indexPath.section == 1 && indexPath.row > 0 && indexPath.row <= @appunto.righe.count 
      true
    else
      false
    end
  end


  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    if indexPath.section == 1 && indexPath.row > 0
      
      riga = @righe.array.objectAtIndex(indexPath.row - 1)     
      Store.shared.context.deleteObject(riga)
      tableView.beginUpdates
      if  @righe.array.count == 0

        ip = [1,2].nsindexpath        
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
        tableView.deleteRowsAtIndexPaths([ip], withRowAnimation:UITableViewRowAnimationFade)
      else
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
        # ricalcola i totali
        totali_cell = tableView.cellForRowAtIndexPath([1, @righe.array.count + 2].nsindexpath)
        if totali_cell
          totali_cell.update({
            importo: @appunto.calc_importo,
            copie: @appunto.calc_copie
          })
        end
      end
      tableView.endUpdates  
    end
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    if indexPath.section == 0 

      if indexPath.row == 0
        # cliente
           
      elsif indexPath.row == 1
        # destinatario
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        edit_controller.load_data("#{@appunto.destinatario}", withLabel:"Inserisci il destinatario")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @appunto.destinatario = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true
      
      elsif indexPath.row == 2
        # note
        edit_controller = EditTextViewController.new
        edit_controller.load_data("#{@appunto.note}")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = tableView.cellForRowAtIndexPath(path)
          cell.update({ note: text })
          @appunto.note = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 3
        # status
        listController = EditListController.alloc.initWithItems(STATUSES)
        listController.value = @appunto.status.split("_").join(" ")
        listController.delegate = self
        self.navigationController.pushViewController listController, animated:true

      elsif indexPath.row == 4
        # email
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeEmail)
        edit_controller.load_data("#{@appunto.email}", withLabel:"Inserisci l'email")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @appunto.email = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 5
        # telefono
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypePhone)
        edit_controller.load_data("#{@appunto.telefono}", withLabel:"Inserisci il telefono")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @appunto.telefono = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      end
    
    elsif indexPath.section == 1

      if indexPath.row != 0 && indexPath.row < @righe.array.count + 1
        # edit riga
        riga = @righe.array[indexPath.row - 1]  
        controller = RigaFormController.alloc.initWithRiga(riga)
        self.navigationController.pushViewController controller, animated:true
    
      elsif indexPath.row == 0
        # add riga
        controller = LibriController.new
        controller.delegate = self
        self.navigationController.pushViewController controller, animated:true

      end


    
    elsif indexPath.section == 4
      cell = tableView.cellForRowAtIndexPath(indexPath)
      @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                              delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:"Elimina",
                                          otherButtonTitles:nil)

      @actionSheet.showFromRect(cell.frame, inView:self.view, animated:true)
    
    elsif indexPath.section == 2
      cell = tableView.cellForRowAtIndexPath(indexPath)

      scanVC = UINavigationController.alloc.initWithRootViewController ScanController.alloc.initWithAppunto(@appunto)
      self.presentViewController scanVC, animated:true, completion:nil
    end
  end

end