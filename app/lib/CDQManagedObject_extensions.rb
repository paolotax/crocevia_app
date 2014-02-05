class CDQManagedObject

  
  def save_to_backend(parameters, withNotification:notification, success:success, failure:
    failure)

    processSuccessBlock = lambda do
      success.call
    end
    
    processFailureBlock = lambda do
      failure.call
    end

    successBlock = lambda do |operation, responseObject|
      result = DataImporterResult.new(operation, responseObject, nil)
      NSLog "Postato #{self.entity.managedObjectClassName} #{self.remote_id}"
      processSuccessBlock.call
    end

    failureBlock = lambda do |operation, error|
      puts "status=#{operation.HTTPRequestOperation.response.statusCode}"
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

    token = CredentialStore.default.token
    Store.shared.client.setDefaultHeader("Authorization", value: "Bearer #{token}")

    # if remote_id == 0
    #   method = "postObject:path:parameters:success:failure:"
    # else
    #   method = "patchObject:path:parameters:success:failure:"
    # end
    #
    # Store.shared.backend.send( method, self, nil, parameters, successBlock, failureBlock)

    if remote_id == 0
      Store.shared.backend.postObject(self,
                                    path:nil,
                              parameters:parameters,
                                 success:successBlock,
                                 failure:failureBlock)
    else
      Store.shared.backend.putObject(self,
                                    path:nil,
                              parameters:parameters,
                                 success:successBlock,
                                 failure:failureBlock)
    end
  end
    


end