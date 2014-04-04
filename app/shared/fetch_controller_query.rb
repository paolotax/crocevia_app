class FetchControllerQuery


  def self.controllerWithQuery(query)

    fetch_request = query.fetch_request
    fetch_request.fetchBatchSize = 20
    context = query.context

    error_ptr = Pointer.new(:object)
    controller = NSFetchedResultsController.alloc.initWithFetchRequest(
      fetch_request, 
      managedObjectContext: context, 
      sectionNameKeyPath: nil, 
      cacheName: nil
    )      
    
    unless controller.performFetch(error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}"
    end   
    controller
  end

end