module PrintDelegate


  def print_appunti(appunti_ids)

    if Store.shared.isReachable? == true
      data = { appunto_ids: appunti_ids }
      SVProgressHUD.showWithStatus("preparazione stampa")

      Store.shared.client.setDefaultHeader "Accept", value: "application/pdf"
      Store.shared.client.setDefaultHeader "Authorization", value: "Bearer #{CredentialStore.default.token}"
      Store.shared.client.putPath("/api/v1/appunti/print_multiple",
                             parameters:data,
                                success:lambda do |operation, responseObject|

                                  resourceDocPath = NSString.alloc.initWithString(NSBundle.mainBundle.resourcePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("Documents"))
                                  filePath = resourceDocPath.stringByAppendingPathComponent("Sovrapacchi.pdf")
                                  responseObject.writeToFile(filePath, atomically:true)
                                  
                                  url = NSURL.fileURLWithPath(filePath)
                                  if (url) 
                                    @documentInteractionController = UIDocumentInteractionController.interactionControllerWithURL(url)
                                    @documentInteractionController.setDelegate(self)
                                    @documentInteractionController.presentPreviewAnimated(true)
                                  end

                                  SVProgressHUD.dismiss
                                end,
                                failure:lambda do |operation, error|
                                  SVProgressHUD.dismiss
                                  App.alert "#{error[0].localizedMessage}"
                                end)
      
      Store.shared.client.setDefaultHeader "Accept", value: "application/json"
    else
      App.alert "#Dispositivo non connesso. Ritenta"
    end
    
  end


#pragma mark - Document Interaction Controller Delegate Methods


  def documentInteractionControllerViewControllerForPreview(controller)
    self
  end

end