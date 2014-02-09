class ClientiController < UITableViewController
end

module FetchProvince


  def load_province
    
    if @query

      if @segmentedProvince
        @segmentedProvince.removeFromSuperview
        @segmentedProvince = nil
      end
      
      items = ["tutte"] + lista_province(@query)

      @segmentedProvince = UISegmentedControl.alloc.initWithItems(items)
      @segmentedProvince.addTarget(self, action:"changeProvincia:", forControlEvents:UIControlEventValueChanged)
      @segmentedProvince.delegate = self
      
      segItem = UIBarButtonItem.alloc.initWithCustomView(@segmentedProvince) 
      sep =  UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
      self.toolbarItems = [sep, segItem, sep]
      self.navigationController.toolbarHidden = false
            
      (0..@segmentedProvince.numberOfSegments-1).each do |index|
        if @provincia == @segmentedProvince.titleForSegmentAtIndex(index)
          @segmentedProvince.setSelectedSegmentIndex(index)
          return
        end
      end
    end
  end


  def lista_province(query)
    entity_name = query.fetch_request.entity.name
    if entity_name == "Cliente"
      lista_province = query.all.map { |c| c.provincia }.uniq
    else
      lista_province = query.all.map { |a| a.cliente.provincia }.uniq
    end
    lista_province.sort
  end

 
  def changeProvincia(sender)
    
    provincia = @segmentedProvince.titleForSegmentAtIndex sender.selectedSegmentIndex
    
    if provincia != "tutte"
      if self.is_a? ClientiController
        new_query = @query.where(:provincia).eq(provincia)
      else
        new_query = @query.where("cliente.provincia = '#{provincia}'")
      end
    else
      new_query = @query
    end

    @controller = nil
    @controller = FetchControllerQuery.controllerWithQuery new_query
    @controller.delegate = self 
    self.title =  "#{@title} (#{@controller.fetchedObjects.count})" 
    tableView.reloadData 
  end

end