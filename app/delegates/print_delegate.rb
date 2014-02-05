module PrintDelegate


  def print_appunti(appunti_ids)

    puts "print #{appunti_ids}"

    data = { appunto_ids: appunti_ids }
    
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
                              end,
                              failure:lambda do |operation, error|

                                App.alert "#{error[0].localizedMessage}"

                              end)
    
    Store.shared.client.setDefaultHeader "Accept", value: "application/json"
  end


#pragma mark - Document Interaction Controller Delegate Methods


  def documentInteractionControllerViewControllerForPreview(controller)
    self
  end

end