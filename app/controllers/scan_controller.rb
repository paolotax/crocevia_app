class ScanController < UIViewController


  attr_accessor :appunto


  def initWithAppunto(appunto)
    init
    @appunto = appunto
    @righe = appunto.righe.sort_by("libro.titolo")
    self
  end


  def viewDidLoad
    super

    @light_is_on = false

    #per i barcode letti
    @barcodes = NSMutableDictionary.new

    
    rmq.stylesheet = ScanControllerStylesheet
    rmq(self.view).apply_style :root_view

    @preview_view = rmq.append(UIView, :preview_view).get

    @rect_of_interest_view = rmq.append(UIView, :rect_of_interest_view).get
    tap = UITapGestureRecognizer.alloc.initWithTarget(self, action:"torchButtonAction:")
    @rect_of_interest_view.addGestureRecognizer(tap)

    @tableView = rmq.append(UITableView.grouped, :tableView).get.tap do |tv|
      tv.delegate = self
      tv.dataSource = self
    end

    setupCaptureSession()
    @previewLayer.frame = @preview_view.bounds
    @preview_view.layer.addSublayer @previewLayer

    willEnterForeground = UIApplicationWillEnterForegroundNotification
    willEnterForeground.add_observer(self, "applicationWillEnterForeground:")

    didEnterBackground = UIApplicationDidEnterBackgroundNotification
    didEnterBackground.add_observer(self, "applicationDidEnterBackground:")

    "didFindBook".add_observer(self, "displayBook:", nil)
    
    init_nav

  end


  def viewWillAppear(animated)
    super
    self.startRunning
    @output.rectOfInterest = @previewLayer.metadataOutputRectOfInterestForRect(@rect_of_interest_view.frame)
  end


  def viewWillDisappear(animated)
    super
    self.stopRunning
  end


#pragma mark - subViews

  
  def init_nav
    self.navigationController.navigationBar.setTintColor COLORS[3]
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.titled("Chiudi") do
        self.dismissViewControllerAnimated(true, completion:nil)
      end

      nav.rightBarButtonItem = UIBarButtonItem.imaged('171-sun') do
        @device.lockForConfiguration nil
        if @light_is_on == false
          @device.setTorchMode AVCaptureTorchModeOn
        else
          @device.setTorchMode AVCaptureTorchModeOff
        end
        @device.unlockForConfiguration
        @light_is_on = !@light_is_on
      end
    end  
  end


#pragma mark - Notifications


  def applicationWillEnterForeground(notification)
    self.startRunning
  end


  def applicationDidEnterBackground(notification)
    self.stopRunning
  end

  
  def displayBook(notification)
    book = notification.userInfo[:book]

    bc = LibroAddController.alloc.init
    bc.book = book
    self.presentViewController(bc, animated:true, completion:nil)
    #bc.loadData(book)
  end


#pragma mark - Video stuff


  def startRunning

    return if @running == true

    if @light_is_on == true
      @device.lockForConfiguration nil
      @device.setTorchMode AVCaptureTorchModeOn
      @device.unlockForConfiguration
    end

    @session.startRunning
    @output.metadataObjectTypes = [ AVMetadataObjectTypeEAN13Code ]
    @running = true
  end


  def stopRunning
    return if @running == false
    @session.stopRunning
    @running = false
  end


  def setupCaptureSession

    return if @session   
    @running = false

    @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo  
    if !@device
      NSLog "No video camera on this device!"
      return
    end

    @session = AVCaptureSession.alloc.init
    @session.sessionPreset = AVCaptureSessionPresetHigh

    @error = Pointer.new('@')
    @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: @error
    if (@session.canAddInput @input)
      @session.addInput @input
    end

    @previewLayer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
    @previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

    @queue = Dispatch::Queue.new('camQueue')    

    @output = AVCaptureMetadataOutput.alloc.init
    @output.setMetadataObjectsDelegate self, queue: @queue.dispatch_object 
    if (@session.canAddOutput @output)
      @session.addOutput @output
    end

  end


#pragma mark -


  def processMetadataObject(code)
    
    barcode = @barcodes[code.stringValue]
    
    if (!barcode)
      barcode = Barcode.new
      @barcodes[code.stringValue] = barcode
    end
    
    barcode.metadataObject = code
    barcode.boundingBoxPath = UIBezierPath.bezierPathWithRect(code.bounds)
    barcode
  end


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

 
  def captureOutput(captureOutput, didOutputMetadataObjects: metadataObjects, fromConnection: connection)
    
    originalBarcodes = NSSet.setWithArray @barcodes.allValues
    foundBarcodes = NSMutableSet.new
    metadataObjects.enumerateObjectsUsingBlock(
      lambda do |obj, idx, stop|        
        if (obj.isKindOfClass AVMetadataMachineReadableCodeObject)
          code = @previewLayer.transformedMetadataObjectForMetadataObject obj
          barcode = self.processMetadataObject code
          foundBarcodes.addObject barcode
        end 
      end)

    newBarcodes = foundBarcodes.mutableCopy
    newBarcodes.minusSet originalBarcodes
    
    goneBarcodes = originalBarcodes.mutableCopy
    goneBarcodes.minusSet foundBarcodes
    
    goneBarcodes.enumerateObjectsUsingBlock( 
      lambda do |barcode, stop|
        @barcodes.removeObjectForKey barcode.metadataObject.stringValue
      end)

    Dispatch::Queue.main.async do

      allSublayers = @preview_view.layer.sublayers.copy     
      allSublayers.enumerateObjectsUsingBlock(
        lambda do |layer, idx, stop|
          if (layer != @previewLayer)
            layer.removeFromSuperlayer
          end
        end)
        
      foundBarcodes.enumerateObjectsUsingBlock(
        lambda do |barcode, stop|
          boundingBoxLayer = CAShapeLayer.new
          boundingBoxLayer.path = barcode.boundingBoxPath.CGPath
          boundingBoxLayer.lineWidth = 2.0
          boundingBoxLayer.strokeColor = UIColor.greenColor.CGColor
          boundingBoxLayer.fillColor = UIColor.colorWithRed(0, green:1.0, blue:0.0, alpha:0.5).CGColor          
          @preview_view.layer.addSublayer boundingBoxLayer
        end )

      newBarcodes.enumerateObjectsUsingBlock(
        lambda do |barcode, stop|
          AudioServicesPlaySystemSound (KSystemSoundID_Vibrate)
          libro = Libro.where(:ean).eq(barcode.metadataObject.stringValue).array
          unless libro.empty?
            Riga.addToAppunto(@appunto, withLibro:libro[0])
            @tableView.reloadData
          else
            App.alert("Codice EAN non trovato")
            # GoogleBook.search(barcode.metadataObject.stringValue)
          end   
        end)
    end 
  end


#pragma mark -  UITableViewDelegate
  

  def numberOfSectionsInTableView(tableView)
    1
  end 

  def tableView(tableView, numberOfRowsInSection:section)
    @righe.count
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)  
    # riga
    cell = tableView.dequeueReusableCellWithIdentifier("rigaCell") || begin
      rmq.create(RigaCell, :riga_cell, cell_identifier: "rigaCell").get
    end
    riga = @righe.array[indexPath.row]   
    cell.update({
      titolo: riga.libro.titolo,
      quantita: riga.quantita,
      prezzo_unitario: riga.calc_prezzo,
      image_url: riga.libro.image_url
    })

    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    50
  end


  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    true
  end


  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    riga = @righe.array[indexPath.row]    
    Store.shared.context.deleteObject(riga)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    # edit riga
    riga = @righe.array[indexPath.row]  
    controller = RigaFormController.alloc.initWithRiga(riga)
    self.navigationController.pushViewController controller, animated:true
  end



end