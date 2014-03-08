class UserAuthenticator

  def self.shared
    # Our store is a singleton object.
    @shared ||= UserAuthenticator.new
  end
  
  def login(success, failure:failure)
    puts "login"
    self.loginWithUsername(CredentialStore.default.username, 
                      password:CredentialStore.default.password, 
                      success:lambda do
                        success.call if success
                      end, 
                      failure:lambda do
                        failure.call if failure
                      end)
  end


  def loginWithUsername(username, password:password, success:success, failure:failure)
    puts "loginWIthUsername"
    params = {
      grant_type: 'password',
      client_id: APP_ID,
      client_secret: SECRET,
      username: username,
      password: password
    }

    puts "loginWIthUsername #{params}"
    
    Store.shared.client.postPath("oauth/token",
                           parameters:params,
                              success:lambda do |operation, responseObject|

                                token = responseObject.objectForKey "access_token"

                                CredentialStore.default.token = token
                                CredentialStore.default.username = username
                                CredentialStore.default.password = password

                                #Store.shared.set_token_header
                                success.call if success
                              end,
                              failure:lambda do |operation, error|
                                NSLog "failure login"
                                failure.call if failure
                                "TSMessageNotification".post_notification(self, message: {title:"Errore login", subtitle:"#{error.localizedDescription}"})
                                # if (operation.response.statusCode == 500)
                                #    failure.call("Something went wrong!")
                                # else
                                #   failure.call(self.errorMessageForResponse(operation))
                                # end
                              end
    )
  end    


  def refreshTokenAndRetryOperation(operation, withNotification:notification, 
                                                        success:success, 
                                                        failure:failure)

    username = CredentialStore.default.username
    password = CredentialStore.default.password
    
    self.loginWithUsername(username,
                   password:password,
                    success:lambda do 
                      NSLog("RETRYING REQUEST #{operation}")
                      
                      retryOperation = self.retryOperationForOperation(operation.HTTPRequestOperation)
                      #retryOperation.setCompletionBlockWithSuccess(lambda do success.call end, failure:lambda do failure.call end)
                      # retryOperation.start
                      # success.call
                      
                      "#{notification}".post_notification if notification

                    end,
                    failure:lambda do
                      failure.call
                    end)
  end


  def retryOperationForOperation(operation)
    request = operation.request.mutableCopy
    request.addValue(nil, forHTTPHeaderField:"Authorization")
    request.addValue("Bearer #{CredentialStore.default.token}", forHTTPHeaderField:"Authorization")   
    retryOperation = AFHTTPRequestOperation.alloc.initWithRequest(request)
    retryOperation
  end


  def errorMessageForResponse(operation)
    jsonData = operation.responseString.dataUsingEncoding(NSUTF8StringEncoding)
    json = NSJSONSerialization.JSONObjectWithData(jsonData, options:0, error:nil)
    errorMessage = json.objectForKey "error"
    errorMessage
  end


end
