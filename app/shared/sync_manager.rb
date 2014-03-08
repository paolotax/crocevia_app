class SyncManagerResult
  
  attr_accessor :operation, :object, :error

  def initialize(operation, responseObject, error)
    self.operation = operation
    self.object = responseObject
    self.error = error
  end

  def success?
    !failure?
  end

  def failure?
    !!error
  end

  def body
    if operation && operation.responseString
      operation.responseString
    end
  end
end


class SyncManager

  def self.default
    @default ||= SyncManager.new
  end

  # importa_...  I love metaprogramming
  # da eliminare il primo metodo
  TABLES.each do |table|

    define_method("importa_#{table}:") do |parameters, &callback|

      token = CredentialStore.default.token
      Store.shared.client.setDefaultHeader("Authorization", value: "Bearer #{token}")

      Store.shared.backend.getObjectsAtPath("api/v1/#{table}",
                           parameters: parameters,
                              success: lambda do |operation, responseObject|
                                                result = SyncManagerResult.new(operation, responseObject, nil)
                                                NSLog "#{table}: #{result.object.array.count}"
                                                callback.call(result) 
                                              end,
                              failure: lambda do |operation, error|
                                                result = SyncManagerResult.new(operation, nil, error)
                                                callback.call(result)
                                                "TSMessageNotification".post_notification(self, message: {title:"Errore importazione #{table}", subtitle:"#{error.localizedDescription}"})
                                              end)
    end
        
    define_method("importa_#{table}:withNotification:success:failure:") do |parameters, notification, success, failure|

      processSuccessBlock = lambda do
        success.call
      end
      
      processFailureBlock = lambda do
        failure.call
        # if (operation.HTTPRequestOperation.response.statusCode == 500)
        #   failure.call("Something went wrong!")
        # else
        #   errorMessage = self.errorMessageForResponse operation
        #   failure.call(errorMessage)
        # end
      end

      token = CredentialStore.default.token
      Store.shared.client.setDefaultHeader("Authorization", value: "Bearer #{token}")

      Store.shared.backend.getObjectsAtPath("/api/v1/#{table}",
                                 parameters:parameters,
                                    success: lambda do |operation, responseObject|
                                      result = SyncManagerResult.new(operation, responseObject, nil)
                                      userDefaults = NSUserDefaults.standardUserDefaults.setObject Time.now, forKey:"last_#{table}_sync"
                                      userDefaults.synchronize                          
                                      NSLog "#{table}: #{result.object.array.count}"
                                      processSuccessBlock.call
                                    end,
                                    
                                    failure: lambda do |operation, error|
                                      puts "status=#{operation.HTTPRequestOperation.response.statusCode}"
                                      if (operation.HTTPRequestOperation.response.statusCode == 401)
                                        CredentialStore.default.token = nil
                                        auth = UserAuthenticator.new
                                        auth.refreshTokenAndRetryOperation(operation,
                                             withNotification:notification,
                                                      success:lambda do
                                                        processSuccessBlock.call
                                                      end,
                                                      failure:lambda do
                                                        processFailureBlock.call
                                                      end)
                                      else
                                        processFailureBlock.call
                                        "TSMessageNotification".post_notification(self, message: {title:"Errore importazione #{table}", subtitle:"#{error.localizedDescription}"})
                                      end
                                    end)
    end
  end


  def errorMessageForResponse(operation)
    puts operation.HTTPRequestOperation.responseString
    # jsonData = operation.HTTPRequestOperation.responseString.dataUsingEncoding(NSUTF8StringEncoding)
    # json = NSJSONSerialization.JSONObjectWithData(jsonData, options:0, error:nil)
    # errorMessage = json.objectForKey "error"
    # errorMessage
  end


  def objectsToSync(entity_name, sinceDate:last_sync_date)
    
    context = Store.shared.context

    request = NSFetchRequest.alloc.init
    entity = NSEntityDescription.entityForName(entity_name, inManagedObjectContext:context)
    request.setEntity(entity)
    
    if last_sync_date
      predicate = NSPredicate.predicateWithFormat("remote_id == 0 or updated_at > %@", argumentArray:[last_sync_date])
      request.setPredicate(predicate)
    end

    request.sortDescriptors = ["updated_at"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }

    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end


  def synchronize(success, failure:failure)
    
    if Store.shared.isReachable? == true && @is_synching.nil?
      

      UserAuthenticator.shared.login(-> {


          @is_synching = true

          client = Store.shared.client
          client.operationQueue.maxConcurrentOperationCount = 1
          client.operationQueue.suspended = true  

          sync_operations = []

          [ "Cliente", "Appunto"].each do |entity_name|
            
            last_sync_date = NSUserDefaults.standardUserDefaults.objectForKey "last_#{entityToTable(entity_name)}_sync"
            if last_sync_date.blank?
              last_sync_date = NSUserDefaults.standardUserDefaults.objectForKey "last_#{entityToTable(entity_name)}_get"
            end

            data = objectsToSync(entity_name, sinceDate:last_sync_date)

            for entity in data do

              sync_operations << entity.syncOperation(nil,
                            tableName:"#{entityToTable(entity_name)}",
                              success:lambda do
                                  userDefaults = NSUserDefaults.standardUserDefaults.setObject entity.updated_at, forKey:"last_#{entityToTable(entity_name)}_sync"
                                  userDefaults.synchronize
                                end, 
                              failure:lambda do
                                  userDefaults = NSUserDefaults.standardUserDefaults.setObject last_sync_date, forKey:"last_#{entityToTable(entity_name)}_sync"
                                  userDefaults.synchronize
                                end
                              )         
            end

          end
           
          Store.shared.backend.enqueueBatchOfObjectRequestOperations(sync_operations,
               progress: ->(numberOfFinishedOperations, totalNumberOfOperations ) {
                  puts "#{numberOfFinishedOperations} #{totalNumberOfOperations}"
                },
             completion: ->(operations) {
                  getTables(success, failure:failure)                  
                }
          )
        
          client.operationQueue.suspended = false

        },
        failure:->{}
      )
    end
  end


  def getTableOperation(table_name, lastSync:last_sync_date)

    client = Store.shared.client
    token = CredentialStore.default.token
    client.setDefaultHeader("Authorization", value: "Bearer #{token}")

    if last_sync_date
      params = { updated_at: last_sync_date }
    else
      params = nil
    end

    manager = Store.shared.backend
    operation = manager.appropriateObjectRequestOperationWithObject(nil, method:RKRequestMethodGET, path:"api/v1/#{table_name}", parameters: params)

    operation.setCompletionBlockWithSuccess( -> (operation, mappingResult) { 
          now = Time.now
          userDefaults = NSUserDefaults.standardUserDefaults.setObject now, forKey:"last_#{table_name}_get"
          #userDefaults = NSUserDefaults.standardUserDefaults.setObject now, forKey:"last_#{table_name}_sync"
          userDefaults.synchronize
          NSLog("Success") 
          NSLog("#{table_name} - #{mappingResult.count} rec.")
        },
      failure:-> (operation, error) { 

          userDefaults = NSUserDefaults.standardUserDefaults.setObject last_sync_date, forKey:"last_#{table_name}_get"
          userDefaults.synchronize
          NSLog("Failure: %@", error) 
        }
    )
    operation
  end


  def getTables(success, failure:failure)

    get_operations = []

    [ "libri", "clienti", "appunti"].each do |table_name|      
      last_get_date = NSUserDefaults.standardUserDefaults.objectForKey "last_#{table_name}_get"
      get_operations << getTableOperation(table_name, lastSync:last_get_date)    
    end
     
    Store.shared.backend.enqueueBatchOfObjectRequestOperations(get_operations,
         progress: ->(numberOfFinishedOperations, totalNumberOfOperations ) {
            puts "#{numberOfFinishedOperations} #{totalNumberOfOperations}"
          },
       completion: ->(operations) {
            success.call if success
            @is_synching = nil                   
          }
    )
  end

  def entityToTable(entity_name)

    if entity_name == "Appunto"
      table = "appunti"
    elsif entity_name == "Cliente"
      table = "clienti"
    elsif entity_name == "Libro"
      table = "libri"
    end
  end

      

end