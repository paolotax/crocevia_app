module ClienteFormDelegate


  #pragma mark -  UITableViewDelegate

  
  def numberOfSectionsInTableView(tableView)
    3
  end


  def tableView(tableView, numberOfRowsInSection:section)
    if section == 0
      7
    elsif section == 1
      2
    elsif section == 2
      3
    end
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    if indexPath.section == 0

      if indexPath.row == 0

        cell = tableView.dequeueReusableCellWithIdentifier('nomeCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'nomeCell')
        end
        cell.textLabel.text = "nome"
        cell.detailTextLabel.text = @cliente.valueForKey('nome')
      
      elsif indexPath.row == 1

        cell = tableView.dequeueReusableCellWithIdentifier('tipoCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'tipoCell')
        end
        cell.textLabel.text = "tipo"
        cell.detailTextLabel.text = @cliente.valueForKey('cliente_tipo')

      elsif indexPath.row == 2

        cell = tableView.dequeueReusableCellWithIdentifier('indirizzoCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'indirizzoCell')
        end
        cell.textLabel.text = "indirizzo"
        cell.detailTextLabel.text = @cliente.valueForKey('indirizzo')
        cell.detailTextLabel.numberOfLines = 2
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap

      elsif indexPath.row == 3

        cell = tableView.dequeueReusableCellWithIdentifier('capCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'capCell')
        end
        cell.textLabel.text = "cap"
        cell.detailTextLabel.text = @cliente.valueForKey('cap')

      elsif indexPath.row == 4

        cell = tableView.dequeueReusableCellWithIdentifier('comuneCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'comuneCell')
        end
        cell.textLabel.text = "comune"
        cell.detailTextLabel.text = @cliente.valueForKey('comune')

      elsif indexPath.row == 5

        cell = tableView.dequeueReusableCellWithIdentifier('frazioneCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'frazioneCell')
        end
        cell.textLabel.text = "frazione"
        cell.detailTextLabel.text = @cliente.valueForKey('frazione')

      elsif indexPath.row == 6

        cell = tableView.dequeueReusableCellWithIdentifier('provinciaCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'provinciaCell')
        end
        cell.textLabel.text = "provincia"
        cell.detailTextLabel.text = @cliente.valueForKey('provincia')

      end
    
    elsif indexPath.section == 1

      if indexPath.row == 0
        #telefono
        cell = tableView.dequeueReusableCellWithIdentifier('telefonoCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'telefonoCell')
        end
        cell.textLabel.text = "telefono"
        cell.detailTextLabel.text = @cliente.valueForKey('telefono')
        #email
      elsif indexPath.row == 1

        cell = tableView.dequeueReusableCellWithIdentifier('emailCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'emailCell')
        end
        cell.textLabel.text = "email"
        cell.detailTextLabel.text = @cliente.valueForKey('email')

      end

    elsif indexPath.section == 2

      if indexPath.row == 0
        #ragione_sociale
        cell = tableView.dequeueReusableCellWithIdentifier('ragione_socialeCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'ragione_socialeCell')
        end
        cell.textLabel.text = "ragione sociale"
        cell.detailTextLabel.text = @cliente.valueForKey('ragione_sociale')
        cell.detailTextLabel.numberOfLines = 2
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap
              
      elsif indexPath.row == 1
        #partita_iva
        cell = tableView.dequeueReusableCellWithIdentifier('partita_ivaCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'partita_ivaCell')
        end
        cell.textLabel.text = "partita iva"
        cell.detailTextLabel.text = @cliente.valueForKey('partita_iva')

      elsif indexPath.row == 2
        #codice_fiscale
        cell = tableView.dequeueReusableCellWithIdentifier('codice_fiscaleCell') || begin
          UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:'codice_fiscaleCell')
        end
        cell.textLabel.text = "codice fiscale"
        cell.detailTextLabel.text = @cliente.valueForKey('codice_fiscale')

      end

    end
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell   
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    44
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    if indexPath.section == 0 

      if indexPath.row == 0
        # nome
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeCapitalize)
        edit_controller.load_data("#{@cliente.nome}", withLabel:"Inserisci il nome")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.nome = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true
   
      elsif indexPath.row == 1
        # cliente_tipo
        listController = EditListController.alloc.initWithItems(TIPI_CLIENTI)
        listController.value = @cliente.cliente_tipo
        listController.delegate = self
        self.navigationController.pushViewController listController, animated:true      

      elsif indexPath.row == 2
        # indirizzo
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        edit_controller.load_data("#{@cliente.indirizzo}", withLabel:"Inserisci l' indirizzo")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.indirizzo = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 3
        # cap
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        edit_controller.load_data("#{@cliente.cap}", withLabel:"Inserisci il cap")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.cap = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 4
        # comune
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        edit_controller.load_data("#{@cliente.comune}", withLabel:"Inserisci il comune")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.comune = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 5
        # frazione
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        edit_controller.load_data("#{@cliente.frazione}", withLabel:"Inserisci la frazione")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.frazione = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 6
        # provincia
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeCapitalize)
        edit_controller.load_data("#{@cliente.provincia}", withLabel:"Inserisci la provincia")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.provincia = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      end

    elsif indexPath.section == 1

      if indexPath.row == 0
        # telefono
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypePhone)
        edit_controller.load_data("#{@cliente.telefono}", withLabel:"Inserisci il telefono")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.telefono = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true
      
      elsif indexPath.row == 1
        # email
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeEmail)
        edit_controller.load_data("#{@cliente.email}", withLabel:"Inserisci l'indirizzo email")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.email = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      end

    elsif indexPath.section == 2

      if indexPath.row == 0
        # ragione_sociale
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        edit_controller.load_data("#{@cliente.ragione_sociale}", withLabel:"Inserisci la ragione sociale")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.ragione_sociale = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true
      
      elsif indexPath.row == 1
        # partita_iva
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeDecimal)
        edit_controller.load_data("#{@cliente.partita_iva}", withLabel:"Inserisci la partita iva")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.partita_iva = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      elsif indexPath.row == 2
        # codice_fiscale
        edit_controller = EditTextFieldController.alloc.initWithType(TextFieldTypeCapitalize)
        edit_controller.load_data("#{@cliente.codice_fiscale}", withLabel:"Inserisci il codice fiscale")
        edit_controller.text_changed_block = lambda do |text, error|
          path = NSIndexPath.indexPathForRow(indexPath.row, inSection:indexPath.section)
          cell = self.tableView.cellForRowAtIndexPath(path)
          cell.detailTextLabel.text = text
          @cliente.codice_fiscale = text
          return true
        end    
        self.navigationController.pushViewController edit_controller, animated:true

      end

    end
  end


#pragma mark -   editListController delegate
  

  def editListController(controller, didSelectItem:item)
    cell = tableView.cellForRowAtIndexPath([0, 1].nsindexpath)
    cell.detailTextLabel.text = item
    @cliente.cliente_tipo = item
    self.navigationController.popViewControllerAnimated(true)
  end


end
