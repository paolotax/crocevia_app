class CDQManagedObject


  def syncOperation(parameters, tableName:tableName, success:success, failure:
    failure)


    processSuccessBlock = lambda do
      success.call
    end
    
    processFailureBlock = lambda do
      failure.call
    end

    successBlock = lambda do |operation, responseObject|
      result = SyncManagerResult.new(operation, responseObject, nil)
      NSLog "Postato #{self.entity.managedObjectClassName} #{self.remote_id}"
      processSuccessBlock.call
    end

    failureBlock = lambda do |operation, error|
      NSLog "status=#{operation.HTTPRequestOperation.response.statusCode}"
      if (operation.HTTPRequestOperation.response.statusCode == 401)
        CredentialStore.default.token = nil
        auth = UserAuthenticator.new
        auth.refreshTokenAndRetryOperation(operation,
             withNotification:notification,
                      success:-> { processSuccessBlock.call },
                      failure:-> { processFailureBlock.call }
                      )
      else
        processFailureBlock.call
      end
    end

    client = Store.shared.client
    token = CredentialStore.default.token
    client.setDefaultHeader("Authorization", value: "Bearer #{token}")

    if remote_id == 0
      method = RKRequestMethodPOST
      path = "api/v1/#{tableName}"
    else
      method = RKRequestMethodPUT
      path = "api/v1/#{tableName}/#{remote_id}"
    end

    manager = Store.shared.backend
    operation = manager.appropriateObjectRequestOperationWithObject(self, method:method, path:path, parameters: parameters)

    operation.setCompletionBlockWithSuccess( -> (operation, mappingResult) { 
          successBlock.call(operation, mappingResult)
        },
      failure:-> (operation, error) { 
          failureBlock.call(operation, error) 
        }
    )
    puts operation
    operation
  end


end