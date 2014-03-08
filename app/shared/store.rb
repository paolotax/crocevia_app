class Store


  include CDQ
  
  
  def client
    self.backend.HTTPClient
  end

  def baseURL
    BASE_URL
  end

  
  def setupReachability

    client.operationQueue.maxConcurrentOperationCount = 1
    client.operationQueue.suspended = true
    client.reachabilityStatusChangeBlock = lambda do |status| 
      if (status == AFNetworkReachabilityStatusNotReachable)
        puts "Not reachable"
      else
        client.operationQueue.suspended = false
        if CredentialStore.default.has_logged_in?
          SyncManager.default.synchronize( 
              lambda do
                "reload_clienti_and_views".post_notification(self, filtro: nil)
                "reload_cliente".post_notification
              end,
              failure:lambda do
                App.alert "Impossibile salvare dati sul server"
              end) 
        end
      end

      if status == AFNetworkReachabilityStatusReachableViaWiFi
        puts "on WiFi"
      end
    end 
  end


  def isReachable?
    #@reachability.isReachable == true
    (client.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable ) && CredentialStore.default.has_logged_in?
  end


  # NO NEED TO CHANGE ANYTHING BELOW THIS LINE
  
  
  def self.shared
    # Our store is a singleton object.
    #@shared ||= Store.new

    Dispatch.once { @instance ||= new }
    @instance

  end
  
  
  def context
    @context
  end

  
  def persistent_context
    @persistent_context
  end

  
  def store
    @store
  end

  
  def backend
    @backend
  end
  

  def undo_manager
    @undo_manager
  end

  
  def save
    error_ptr = Pointer.new(:object)
    unless @context.save(error_ptr)
      raise "Error when saving the model: #{error_ptr[0].description}"
    else
      persist
    end
    
    # Clear caches, they will be reloaded on demand
    # ManagedObjectClasses.each {|c| c.reset}
  end


  def persist
    error_ptr = Pointer.new(:object)
    unless @persistent_context.save(error_ptr)
      raise "Error when saving the model: #{error_ptr[0].description}"
    end
    
    # Clear caches, they will be reloaded on demand
    # ManagedObjectClasses.each {|c| c.reset}
  end

  
  def stats
    puts "context inserted: #{@context.insertedObjects.count}"
    puts "context updated: #{@context.updatedObjects.count}"
    puts "context deleted: #{@context.deletedObjects.count}"

    puts "persist inserted: #{@persistent_context.insertedObjects.count}"
    puts "persist updated: #{@persistent_context.updatedObjects.count}"
    puts "persist deleted: #{@persistent_context.deletedObjects.count}"
  end

  private

  def initialize

    url = NSURL.URLWithString(BASE_URL)
    @backend = RKObjectManager.managerWithBaseURL(url)

    formatter = NSDateFormatter.new
    formatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ssz")
    RKObjectMapping.addDefaultDateFormatter(formatter)

    @store = RKManagedObjectStore.alloc.initWithPersistentStoreCoordinator(cdq.stores.current)
    @backend.managedObjectStore = @store
    @backend.requestSerializationMIMEType = RKMIMETypeJSON

    @store.createManagedObjectContexts
    
    @persistent_context = @store.persistentStoreManagedObjectContext
    @context = @store.mainQueueManagedObjectContext

    cdq.contexts.push(@context)
    cdq.contexts.push(@persistent_context)

    @undo_manager = NSUndoManager.alloc.init
    @context.setUndoManager @undo_manager

    #RKlcl_configure_by_name("RestKit/Network", RKLogLevelTrace)
    #RKlcl_configure_by_name("RestKit/ObjectMapping", RKLogLevelTrace)

    MappingProvider.shared.init_mappings(@store, @backend)
  end

  


end