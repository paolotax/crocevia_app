# class VenditeController < UIViewController


#   ORDER_LIBRO   = ["libro.titolo"]
#   ORDER_CLIENTE = ["appunto.cliente.nome", "libro.titolo"]
#   ORDER_DATA    = ["appunto.created_at", "libro.titolo"]
#   ORDER_COMUNE  = ["appunto.cliente.provincia", "appunto.cliente.comune", "appunto.cliente.nome", "libro.sigla"]

#   GROUP_LIBRO   = ["libro.titolo"]
#   GROUP_CLIENTE = ["appunto.cliente.nome"]
#   GROUP_DATA    = ["appunto.data"]
#   GROUP_COMUNE  = ["appunto.cliente.provincia_e_comune"]


#   def viewDidLoad
#     super

#     #load_data

#     rmq.stylesheet = VenditeControllerStylesheet

#     @tableView = rmq.append(UITableView.grouped, :table_view).get.tap do |tv|
#       tv.delegate = self
#       tv.dataSource = self
#       tv.registerClass(RigaCell, forCellReuseIdentifier:"rigaCell")
#       tv.registerClass(RigaHeaderView, forHeaderFooterViewReuseIdentifier:"rigaHeaderView")
#       tv.sectionHeaderHeight = 44
#     end
 
    
#     @esandi   = true
#     @group_by = GROUP_LIBRO
#     @order_by = ORDER_LIBRO
#     @status   = "da_fare"
#     @sectionsOpened = []

#     true
#   end


#   def viewWillAppear(animated)
#     super
#     reload
#   end
  
#   def fetchControllerForTableView(tableView)
    
#     @controller ||= begin
#       context = Store.shared.context
#       request = NSFetchRequest.alloc.init
#       request.entity = NSEntityDescription.entityForName("Riga", inManagedObjectContext:context)

#       pred = nil
#       predicates = [] 
      
#       dateStr = "20130501" 
#       # Convert string to date object
#       dateFormat = NSDateFormatter.alloc.init
#       dateFormat.setDateFormat("yyyyMMdd")
#       startDate = dateFormat.dateFromString(dateStr)
 
#       predicates << NSPredicate.predicateWithFormat("(appunto.created_at >= %@)", argumentArray:[startDate])
      
#       if @search_text
#         predicates << NSPredicate.predicateWithFormat("appunto.cliente.nome contains[cd] '#{@search_text}' or libro.titolo contains[cd] '#{@search_text}' or appunto.cliente.comune contains[cd] '#{@search_text}'")
#       end

#       if @status
#         predicates << NSPredicate.predicateWithFormat("appunto.status = '#{@status}'")
#       end
#       pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      
#       request.predicate = pred
#       request.sortDescriptors = @order_by.collect { |sortKey|
#         NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
#       }
      
#       error_ptr = Pointer.new(:object)
#       @controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:"#{@group_by.firstObject}", cacheName:nil)      
#       unless @controller.performFetch(error_ptr)
#         raise "Error when fetching data: #{error_ptr[0].description}"
#       end
#       @controller
#     end    
#   end

#   def reload
#     @controller = nil
#     @tableView.reloadData
#     self.title = "Vendite: #{@controller.fetchedObjects.valueForKeyPath("@sum.quantita").to_i}"
#   end


#   def toggle_esandi(sender)
    
#     if @esandi == false
#       setEsandiTutto
#     else
#       setComprimiTutto
#     end
    
#     reload  
#   end

#   def setEsandiTutto
#     @esandi = true
#     self.btnEsandi.title = 'contrai'
#     @sectionsOpened.clear
#     @controller.sections.each_with_index {|s, i| @sectionsOpened << i }
#   end

#   def setComprimiTutto
#     @esandi = false
#     self.btnEsandi.title = 'esandi'
#     @sectionsOpened.clear
#   end

#   def groupSegmentSwitch(sender)
    
#     segmentedControl = sender
#     selectedSegment = segmentedControl.selectedSegmentIndex
#     if (selectedSegment == 0)
#       @group_by = GROUP_LIBRO
#       @order_by = ORDER_LIBRO
#     elsif (selectedSegment == 1)
#       @group_by = GROUP_CLIENTE
#       @order_by = ORDER_CLIENTE 
#     elsif (selectedSegment == 2)
#       @group_by = GROUP_DATA
#       @order_by = ORDER_DATA   
#     elsif (selectedSegment == 3)
#       @group_by = GROUP_COMUNE
#       @order_by = ORDER_COMUNE    
#     end
#     setComprimiTutto
#     reload
#   end

#   def statusSegmentSwitch(sender)
    
#     segmentedControl = sender
#     selectedSegment = segmentedControl.selectedSegmentIndex

#     if (selectedSegment == 0)
#       @status = "da_fare"
#     elsif (selectedSegment == 1)
#       @status = "preparato"
#     elsif (selectedSegment == 2)
#       @status = "in_sospeso"
#     elsif (selectedSegment == 3)
#       @status = nil
#     end
#     setComprimiTutto
#     reload
#   end

#   def printMultiple

#     righeToPrint = []
#     @sectionsOpened.each do |i|
#       @controller.sections[i].objects.each do |o|
#         righeToPrint << o.appunto.remote_id.to_s
#       end
#     end

#     return if righeToPrint.count == 0    
#     ids = righeToPrint.uniq.sort

#     ## using @distinctUnionOfObjects
    
#     # @sectionsOpened.each do |i|
#     #   @controller.sections[i].objects.each do |o|
#     #     righeToPrint << o
#     #   end
#     # end

#     # return if righeToPrint.count == 0
    
#     # ids = righeToPrint.valueForKeyPath("@distinctUnionOfObjects.appunto.remote_id")
#     # ids = ids.map { |i| i.to_s }


#     data = { appunto_ids: ids }

#     AFMotion::Client.shared.setDefaultHeader("Accept", value:"application/pdf")
#     AFMotion::Client.shared.setDefaultHeader("Authorization", value: "Bearer #{Store.shared.token}")
    
#     AFMotion::Client.shared.put("/api/v1/appunti/print_multiple", data) do |result|
#       if result.success?
        
#         resourceDocPath = NSString.alloc.initWithString(NSBundle.mainBundle.resourcePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("Documents"))
#         filePath = resourceDocPath.stringByAppendingPathComponent("Sovrapacchi.pdf")
#         result.object.writeToFile(filePath, atomically:true)
#         url = NSURL.fileURLWithPath(filePath)
#         if (url) 
#           @documentInteractionController = UIDocumentInteractionController.interactionControllerWithURL(url)
#           @documentInteractionController.setDelegate(self)
#           @documentInteractionController.presentPreviewAnimated(true)
#         end
#       else

#         App.alert("babbeo")
#       end
#     end
#     Store.shared.login {} 

#   end





#   # tableView delegates

#   def numberOfSectionsInTableView(tableView)
#     self.fetchControllerForTableView(tableView).sections.size
#   end
  
#   def tableView(tableView, numberOfRowsInSection:section)   
#     isOpened = @sectionsOpened.include? section
#     if isOpened == true
#       self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
#     else
#       0
#     end
#   end

#   def tableView(tableView, cellForRowAtIndexPath:indexPath)
#     cell = tableView.dequeueReusableCellWithIdentifier("rigaCell")
#     if @group_by == GROUP_LIBRO
#       cell.label = @controller.objectAtIndexPath(indexPath).appunto.cliente.nome
#     elsif @group_by == GROUP_CLIENTE
#       cell.label = @controller.objectAtIndexPath(indexPath).libro.titolo
#     elsif @group_by == GROUP_DATA
#       cell.label = "#{@controller.objectAtIndexPath(indexPath).appunto.cliente.nome} #{@controller.objectAtIndexPath(indexPath).libro.sigla}"
#     elsif @group_by == GROUP_COMUNE
#       cell.label = "#{@controller.objectAtIndexPath(indexPath).appunto.cliente.nome} #{@controller.objectAtIndexPath(indexPath).libro.sigla}"
#     end
#     cell.quantita = @controller.objectAtIndexPath(indexPath).quantita
#     cell
#   end
    
#   def tableView(tableView, viewForHeaderInSection:section)

#     sectionHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("rigaHeaderView")
    
#     isOpened = @sectionsOpened.include?(section)
#     sectionHeaderView.disclosureButton.selected = isOpened

#     if @group_by == GROUP_DATA
              
#       unless @monthSymbols
#         formatter = NSDateFormatter.alloc.init
#         formatter.setCalendar(NSCalendar.currentCalendar)
#         @monthSymbols = formatter.monthSymbols
#       end
      
#       tmpTitle = self.fetchControllerForTableView(tableView).sections[section].name
#       day = tmpTitle[6..7]
#       month = tmpTitle[4..5]
#       year = tmpTitle[0..3]
#       # 20130520
#       # 01234567
#       sectionHeaderView.titolo = "#{day} #{@monthSymbols[month.to_i-1]} #{year}"
#     else 
#       sectionHeaderView.titolo   = self.fetchControllerForTableView(tableView).sections[section].name
#     end
#     sectionHeaderView.quantita = self.fetchControllerForTableView(tableView).sections[section].objects.valueForKeyPath("@sum.quantita").to_i.to_s
    
#     sectionHeaderView.contentView.backgroundColor = UIColor.darkGrayColor 
#     sectionHeaderView.section = section
#     sectionHeaderView.delegate = self
    
#     sectionHeaderView
#   end


#   def tableView(tableView, didSelectRowAtIndexPath:indexPath)
#     tableView.deselectRowAtIndexPath(indexPath, animated:true) unless Device.ipad?
#     if Device.ipad?
#       riga = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
#       "pushAppuntoController".post_notification(self, appunto: riga.appunto)
#     else
#     end
#   end






#   # select rigaHeaderView delegates

#   def rigaHeaderView(rigaHeaderView, sectionOpened:sectionOpened)

#     @sectionsOpened << sectionOpened
#     countOfRowsToInsert = self.fetchControllerForTableView(tableView).sections[sectionOpened].numberOfObjects
    
#     indexPathsToInsert = []
#     for i in 0..countOfRowsToInsert-1 do
#       indexPathsToInsert.addObject(NSIndexPath.indexPathForRow(i, inSection:sectionOpened))
#     end

#     insertAnimation = UITableViewRowAnimationTop

#     @tableView.beginUpdates
#     @tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation:insertAnimation)
#     #@tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation:deleteAnimation)
#     @tableView.endUpdates

#   end


#   def rigaHeaderView(rigaHeaderView, sectionClosed:sectionClosed)

#     @sectionsOpened.delete sectionClosed 

#     countOfRowsToDelete = self.fetchControllerForTableView(tableView).sections[sectionClosed].numberOfObjects

#     indexPathsToDelete = []
#     for i in 0..countOfRowsToDelete-1 do
#       indexPathsToDelete.addObject(NSIndexPath.indexPathForRow(i, inSection:sectionClosed))
#     end

#     @tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation:UITableViewRowAnimationTop)
#   end

#   #pragma mark -
#   #pragma mark Document Interaction Controller Delegate Methods
#   def documentInteractionControllerViewControllerForPreview(controller)
#     self
#   end

#   #pragma mark -
#   #pragma mark SearchBar Delegate Methods

#   def searchBarTextDidBeginEditing(searchBar)
    
#     @searchBar = searchBar
#     # if @searchPopover == nil
#     #   nav = UINavigationController.alloc.initWithRootViewController(@searchController)
#     #   popover = UIPopoverController.alloc.initWithContentViewController(nav)
#     #   @searchPopover = popover
#     #   @searchPopover.delegate = self
#     #   popover.passthroughViews = [@searchBar]
#     #   @searchPopover.presentPopoverFromRect(@searchBar.bounds,
#     #                                                      inView:@searchBar,
#     #                                    permittedArrowDirections:UIPopoverArrowDirectionAny,
#     #                                                    animated:true)
#     # end
#   end                                                    

#   def searchBarTextDidEndEditing(searchBar)
#     # if @searchPopover != nil
#     #   nav = @searchPopover.contentViewController
#     #   searchesController = nav.topViewController
#     #   #if (searchesController.confirmSheet == nil)
#     #     @searchPopover.dismissPopoverAnimated(true)
#     #     @searchPopover = nil
#     #   #end
#     # end
#     searchBar.resignFirstResponder
#   end

#   def searchBar(searchBar, textDidChange:searchText)
#     if searchText == ""
#       @search_text = nil
#     else
#       @search_text = searchBar.text
#     end
#     reload
#   end

#   def searchBarCancelButtonClicked(searchBar)
#     searchBar.text = ""
#     @search_text = nil
#     reload
#     searchBar.resignFirstResponder
#   end

#   def searchBarSearchButtonClicked(searchBar)
#     @search_text = searchBar.text
#     # searchController addToRecentSearches:searchString];
#     self.finishSearchWithString(@search_text)
#     reload
#   end

#   def finishSearchWithString(searchString)
#     #@searchPopover.dismissPopoverAnimated(true)
#     #@searchPopover = nil
#     @searchBar.resignFirstResponder
#     @searchBar = nil
#   end
  
  
# end