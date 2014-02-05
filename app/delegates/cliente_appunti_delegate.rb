module ClienteAppuntiDelegate


#pragma mark - TableView delegate


  def numberOfSectionsInTableView(tableView)
    if @cliente 
      4
    else
      0
    end
  end

  
  def tableView(tableView, numberOfRowsInSection:section)
    if @cliente
      if section == 0
        1
      elsif section == 1
        appunti_da_fare.count
      elsif section == 2
        appunti_in_sospeso.count > 0 ? 1 : 0
      elsif section == 3
        appunti_completati.count > 0 ? 1 : 0
      end
    else
      0
    end
  end


  def left_utility_buttons
    left_utility_buttons = []
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[1], title:"da fare"
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[2], title:"sospeso"
    left_utility_buttons.sw_addUtilityButtonWithColor COLORS[3], title:"fatto"
    left_utility_buttons
  end


  def right_utility_buttons
    right_utility_buttons = []
    right_utility_buttons.sw_addUtilityButtonWithColor UIColor.redColor, title:"elimina"
    right_utility_buttons.sw_addUtilityButtonWithColor UIColor.lightGrayColor, title:"altro"
    right_utility_buttons
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)
   
    if indexPath.section == 0
      
      cell = tableView.dequeueReusableCellWithIdentifier("cellCliente")
      unless cell
        cell = UITableViewCell.alloc.initWithStyle( UITableViewCellStyleSubtitle, reuseIdentifier:"cellCliente")
      end

      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.textLabel.text = @cliente.nome
      cell.detailTextLabel.text = @cliente.comune

    elsif indexPath.section == 1

      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto", forIndexPath:indexPath)

      cell.containingTableView = tableView
      cell.setCellHeight cell.frame.size.height

      cell.leftUtilityButtons  = left_utility_buttons
      cell.rightUtilityButtons = right_utility_buttons
      
      cell.delegate = self

      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
      cell.fill_data(appunto, withCliente:false)
    
    else

      @reuseIdentifier ||= "cellGrouped"
      cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
      unless cell
        cell = UITableViewCell.alloc.initWithStyle( UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
      end

      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

      if indexPath.section == 2
        cell.textLabel.text = "#{appunti_in_sospeso.count} appunti"      
        cell.detailTextLabel.text = appunti_in_sospeso.inject(0) {|sum, a| sum + a.totale_importo.round(2)}.string_with_style(NSNumberFormatterCurrencyStyle)

      elsif indexPath.section == 3
        cell.textLabel.text = "#{appunti_completati.count} appunti"
        cell.detailTextLabel.text = appunti_completati.inject(0) {|sum, a| sum + a.totale_importo.round(2)}.string_with_style(NSNumberFormatterCurrencyStyle)
      end
    end    

    cell
  end
  

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
    
    if indexPath.section == 1
      appunto = appunti_da_fare.objectAtIndex(indexPath.row)
      controller = UINavigationController.alloc.initWithRootViewController(AppuntoFormController.alloc.initWithAppunto(appunto))
      controller.topViewController.delegate = self
      self.presentViewController(controller, animated:true, completion:nil)

    elsif indexPath.section == 2
      controller = AppuntiController.alloc.initWithCDQQuery(Appunto.where(cliente: @cliente).a_in_sospeso.cronologia, andTitle:@cliente.nome, andColor:COLORS[2])
      controller.show_cliente = false
      self.navigationController.pushViewController(controller, animated:true)

    elsif indexPath.section == 3
      controller = AppuntiController.alloc.initWithCDQQuery(Appunto.where(cliente: @cliente).a_completato.cronologia, andTitle:@cliente.nome, andColor:COLORS[3])
      controller.show_cliente = false
      self.navigationController.pushViewController(controller, animated:true)
    end
  end



  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 1
      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto")
      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
      cell.get_height(appunto)
    elsif indexPath.section == 0
      80
    else
      44
    end
  end


  def tableView(tableView, titleForHeaderInSection:section)
    if section == 1
      "da fare"
    elsif section == 2
      "in sospeso"
    elsif section == 3
      "completati"
    end
  end


  def tableView(tableView, estimatedHeightForRowAtIndexPath:indexPath)
    if indexPath.section == 1
      200
    else
      44
    end
  end


  def tableView(tableView, heightForHeaderInSection:section)
    section == 0 ? 0.1 : 44
  end

  
  def tableView(tableView, heightForFooterInSection:section)
    1
  end

  
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)    
    #self.performSegueWithIdentifier("editAppunto", sender:tableView.cellForRowAtIndexPath(indexPath))
  end

end
