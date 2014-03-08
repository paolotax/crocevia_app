module SwipeAppuntoDelegate

  def swipeableTableViewCell(cell, didTriggerLeftUtilityButtonWithIndex:index)
    
    if @appunti_da_fare
      indexPath = @tableView.indexPathForCell(cell)
      appunto = @appunti_da_fare[indexPath.row]   
    else
      indexPath = tableView.indexPathForCell(cell)
      appunto = @controller.objectAtIndexPath(indexPath)   
    end

    if index == 0
      
      appunto.cliente.toggle_baule
      cdq.save
      Store.shared.persist

      if @appunti_da_fare
        @tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight
      else
        tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight
        self.tableView.reloadData # il reload è per gli altri nel baule
      end

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
        Store.shared.save
        Store.shared.persist

        if @appunti_da_fare
          @tableView.reloadRowsAtIndexPaths [indexPath],  withRowAnimation:UITableViewRowAnimationRight
        end

        SyncManager.default.synchronize( -> {}, 
          failure:lambda do
            App.alert "Impossibile salvare dati sul server"
          end) 

      else
        cell.hideUtilityButtonsAnimated true
      end
    end
  end


  def swipeableTableViewCell(cell, didTriggerRightUtilityButtonWithIndex:index)
    
    if @appunti_da_fare
      @current_index   = @tableView.indexPathForCell(cell)
      @current_appunto = @appunti_da_fare[@current_index.row]   
    else
      @current_index   = tableView.indexPathForCell(cell)
      @current_appunto = @controller.objectAtIndexPath(@current_index)   
    end

    if index == 1
      @sheet_altro = UIActionSheet.alloc.initWithTitle(nil,
                                                   delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:nil,
                                          otherButtonTitles:nil)

      @print_button = @sheet_altro.addButtonWithTitle('Stampa')
      unless @current_appunto.telefono.blank?
        @phone_button = @sheet_altro.addButtonWithTitle('Chiama')
      end 
      unless @current_appunto.email.blank? 
        @email_button = @sheet_altro.addButtonWithTitle('Scrivi')
      end      
      @sheet_altro.showFromRect(cell.frame, inView:self.view, animated:true)

    else
      @sheet_elimina = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                              delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:"Elimina",
                                          otherButtonTitles:nil)

      @sheet_elimina.showFromRect(cell.frame, inView:self.view, animated:true)
    end
  end


#pragma mark - ActionSheet delegate


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    
    if @appunti_da_fare
      cell = @tableView.cellForRowAtIndexPath(@current_index)
    else
      cell = tableView.cellForRowAtIndexPath(@current_index)
    end
    cell.hideUtilityButtonsAnimated true

    if actionSheet == @sheet_elimina

      if buttonIndex == @sheet_elimina.destructiveButtonIndex
        
        if @appunti_da_fare
          @tableView.beginUpdates
        else
          tableView.beginUpdates
        end

        @current_appunto.deleted_at = @current_appunto.updated_at = Time.now      
        Store.shared.save
        Store.shared.persist
        
        if @appunti_da_fare
          @tableView.deleteRowsAtIndexPaths([@current_index], withRowAnimation:UITableViewRowAnimationLeft)
          reload
          @tableView.endUpdates
        else
          tableView.endUpdates
        end
        
        SyncManager.default.synchronize( -> {}, 
          failure:lambda do
            App.alert "Impossibile salvare dati sul server"
          end) 
      end

    elsif actionSheet == @sheet_altro
      
      if buttonIndex == @print_button
        print_appunti([@current_appunto.remote_id])
      
      elsif buttonIndex == @phone_button
        url = NSURL.URLWithString("tel://#{@current_appunto.telefono.split(" ").join}")
        UIApplication.sharedApplication.openURL(url);
      
      elsif buttonIndex == @email_button
        url = NSURL.URLWithString("mailto://#{@current_appunto.email}")
        UIApplication.sharedApplication.openURL(url);

      end
    
    end



    @sheet_altro = nil
    @sheet_elimina = nil
    @current_appunto = nil
    @current_index = nil
  end


end
