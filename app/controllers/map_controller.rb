class MapController < UIViewController

  
  def viewDidLoad
    super

    rmq.stylesheet = MapControllerStylesheet
    rmq(self.view).apply_style :root_view

    # Create your views here
    @map = rmq.append(MKMapView, :map).get
    @map.delegate = self
    @map.frame = self.view.bounds;
    @map.autoresizingMask = self.view.autoresizingMask

    @search_bar = rmq.append(UISearchBar, :search_bar).get
    @search_controller = UISearchDisplayController.alloc.initWithSearchBar(@search_bar, contentsController:self).tap do |sc|
      sc.delegate = self
      sc.searchResultsDataSource = self
      sc.searchResultsDelegate = self
    end
    self.searchDisplayController.displaysSearchBarInNavigationBar = true

    reload

    init_nav
  end


  def viewWillAppear(animated)
    super
    reload
    if @clienti.count > 0
      region = self.coordinateRegionForItems(@clienti, @clienti.count-1)
      @map.setRegion(region)
    end    
  end

  
  def init_nav
    self.navigationItem.tap do |nav|
      
      nav.title = "Mappa"

      nav.leftBarButtonItem = UIBarButtonItem.imaged('001-menu-gray') do
        #@controller = nil
        self.sideMenuViewController.openMenuAnimated true, completion:nil
      end
      nav.rightBarButtonItem = MKUserTrackingBarButtonItem.alloc.initWithMapView(@map)
    end
  end


# pragma mark - UITableView Delegate


  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    # @controller = nil
    # @controller = FetchControllerQuery.controllerWithQuery Libro.sort_by(:titolo).where("titolo contains[cd] '#{searchString}'").or("settore contains[cd] '#{searchString}'").or("ean contains[cd] '#{searchString}'").or("cm contains[cd] '#{searchString}'")  
    true
  end

  def searchDisplayControllerDidEndSearch(controller)
    #reload
  end


  def reload
    @fetch_clienti = nil

    @map.removeAnnotations(@clienti)
    @clienti = fetch_clienti.select {|c| !c.latitude.nil? && !c.longitude.nil?}
    @map.addAnnotations(@clienti)
  end


# pragma mark -  MapKit methods

  
  def coordinateRegionForItems(items, itemsCount)
    r = MKMapRectNull
    (0..itemsCount).each do |i|
      p = MKMapPointForCoordinate(items[i].coordinate)
      r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0.0, 0.0))
    end
    region = MKCoordinateRegionForMapRect(r)

    puts region 

    region.span.latitudeDelta  = region.span.latitudeDelta + region.span.latitudeDelta * 0.5
    region.span.longitudeDelta = region.span.longitudeDelta + region.span.longitudeDelta * 0.8

    puts region.span.latitudeDelta 
    puts region.span.longitudeDelta
    region
  end


  # MapView dlegates


  def mapView(mapView, viewForAnnotation:annotation)

    return nil if annotation.is_a?(MKUserLocation) 
    
    view = mapView.dequeueReusableAnnotationViewWithIdentifier("spot")
    if (!view)
      view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:"spot")
      view.enabled = true
      view.canShowCallout = true
      view.centerOffset = CGPointMake(7, -15)
      view.calloutOffset = CGPointMake(-8, 0)
    end

    if annotation.nel_baule == 1
      view.image = "pin-purple".uiimage
    elsif annotation.appunti_da_fare && annotation.appunti_da_fare > 0
      view.image = "pin-red".uiimage
    elsif annotation.appunti_in_sospeso && annotation.appunti_in_sospeso > 0
      view.image = "pin-green".uiimage
    elsif annotation.cliente_tipo == "Scuola Primaria"
      
      if annotation.fatto == 1
        view.image = "pin-black".uiimage
      else
        view.image = "pin-orange".uiimage
      end
      
    else
      view.image = "pin-gray".uiimage
    end

    if annotation.nel_baule == 1
      btnImage = "07-map-marker-purple".uiimage
    else
      btnImage = "07-map-marker".uiimage
    end

    leftBtn = UIButton.alloc.initWithFrame(CGRectMake(0, 1, 26, 26))
    leftBtn.setBackgroundImage(btnImage, forState:UIControlStateNormal)

    view.rightCalloutAccessoryView = UIButton.detail_disclosure
    view.leftCalloutAccessoryView = leftBtn
    view
  end

  
  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)

    @pippo = nil
    @selectedAnnotation = view
    
    @selectedCliente = view.annotation
    mapView.deselectAnnotation(view.annotation, animated:true)

    if control.buttonType == UIButtonTypeDetailDisclosure

      cliente = @selectedCliente

      controller = ClienteAppuntiController.alloc.initWithCliente cliente
      self.navigationController.pushViewController controller, animated:true

    else
      #{}"annotation_did_change".post_notification(self, cliente: @selectedCliente)
    end

  end


  private


    def fetch_clienti
      
      @fetch_clienti ||= begin
        error_ptr = Pointer.new(:object)
        fetch_controller.delegate = self
        unless fetch_controller.performFetch(error_ptr)
          raise "Error performing fetch: #{error_ptr[2].description}"
        end
        fetch_controller.fetchedObjects
      end
    end


    def fetch_controller
      @nel_baule ||= Cliente.nel_baule.sort_by(:remote_id)
      @fetch_controller ||= NSFetchedResultsController.alloc.initWithFetchRequest(
        @nel_baule.fetch_request,
        managedObjectContext: @nel_baule.context,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
    end

end


__END__

# You don't have to reapply styles to all UIViews, if you want to optimize, 
# another way to do it is tag the views you need to restyle in your stylesheet, 
# then only reapply the tagged views, like so:
def logo(st)
  st.frame = {t: 10, w: 200, h: 96}
  st.centered = :horizontal
  st.image = image.resource('logo')
  st.tag(:reapply_style)
end

# Then in willAnimateRotationToInterfaceOrientation
rmq(:reapply_style).reapply_styles
