class LibriController < UITableViewController


  attr_accessor :delegate
  

  def self.new(args = {})    
    self.alloc.initWithStyle(UITableViewStylePlain)
  end


  def viewDidLoad
    super
    rmq.stylesheet = LibriControllerStylesheet

    tableView.tap do |tv|
      
      @search_bar = rmq.append(UISearchBar, :search_bar).get
      @search_controller = UISearchDisplayController.alloc.initWithSearchBar(@search_bar, contentsController:self).tap do |sc|
        sc.delegate = self
        sc.searchResultsDataSource = self
        sc.searchResultsDelegate = self
      end
      tv.tableHeaderView = @search_bar

      @refresh = rmq(tv).append(UIRefreshControl).on(:value_changed) do
        loadFromBackend
      end.get 

      rmq(tv).apply_style :table_view
    end
  end


  def reload
    @controller = nil
    self.tableView.reloadData
  end


  def close
    self.dismissViewControllerAnimated(true, completion:nil)
  end


  def controller
    @controller ||= FetchControllerQuery.controllerWithQuery Libro.sort_by(:titolo)
  end


# pragma mark - UITableView Delegate


  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    @controller = nil
    @controller = FetchControllerQuery.controllerWithQuery Libro.sort_by(:titolo).where("titolo contains[cd] '#{searchString}'").or("settore contains[cd] '#{searchString}'").or("ean contains[cd] '#{searchString}'").or("cm contains[cd] '#{searchString}'")  
    true
  end

  def searchDisplayControllerDidEndSearch(controller)
    reload
  end


# pragma mark - UITableView Delegate


  def numberOfSectionsInTableView(tableView)
    controller.sections.size
  end

  
  def tableView(tableView, numberOfRowsInSection:section)
    @controller.sections[section].numberOfObjects
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    cell = self.tableView.dequeueReusableCellWithIdentifier('libriCell') || begin
      puts "created"
      rmq.create(LibriCell, :libri_cell, cell_identifier: "libriCell").get
    end
    cell.update({
      titolo: @controller.objectAtIndexPath(indexPath).titolo,
      prezzo_copertina: @controller.objectAtIndexPath(indexPath).prezzo_copertina,
      image_url: @controller.objectAtIndexPath(indexPath).image_url
    })

    cell
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    libro = @controller.objectAtIndexPath(indexPath)

    self.delegate.libriController(self, didSelectLibro:libro)
  end
  

  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath) 
    # tableView.deselectRowAtIndexPath(indexPath, animated:true)
    # libro = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)

    # lvc = LibroFormController.alloc.initWithStyle(UITableViewStyleGrouped)
    # lvc.load_data libro
    # lvc.isNew = false
    # self.navigationController.pushViewController lvc, animated:true
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    50
  end


  private


    def loadFromBackend      
      if Store.shared.isReachable? == false
        @refresh.endRefreshing unless @refresh.nil?
        App.alert "Dispositivo non connesso alla rete. Riprova più tardi"
        return
      end
      DataImporter.default.importa_libri(nil) do |result|
        @refresh.endRefreshing unless @refresh.nil?
        if result.success?
          reload
        end          
      end
    end



end
