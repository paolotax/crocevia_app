class AppuntiCollectionController < UICollectionViewController
  # In app_delegate.rb or wherever you use this controller, just call .new like so:
  #   @window.rootViewController = AppuntiController.new
  #
  # Or if you're adding using it in a navigation controller, do this
  #  main_controller = AppuntiController.new
  #  @window.rootViewController = UINavigationController.alloc.initWithRootViewController(main_controller)

  APPUNTI_CELL_ID = "AppuntiCollectionCell"

  attr_accessor :query
  
  def initWithQuery(query, andColor:color)
    layout = UICollectionViewFlowLayout.alloc.init
    initWithCollectionViewLayout(layout).tap do
      @query = query
      @controller = FetchControllerQuery.controllerWithQuery(@query)
      @color = color
    end
  end

  def viewDidLoad
    super

    rmq.stylesheet = AppuntiCollectionControllerStylesheet

    collectionView.tap do |cv|
      cv.registerClass(AppuntiCollectionCell, forCellWithReuseIdentifier: APPUNTI_CELL_ID)
      cv.delegate = self
      cv.dataSource = self
      cv.allowsSelection = true
      cv.allowsMultipleSelection = false
      rmq(cv).apply_style :collection_view
    end

    init_nav_color
  end


#pragma mark - Initialization 
  

  def init_nav_color
    self.title = "Cronologia"
    self.navigationController.navigationBar.setBarTintColor @color
    self.navigationController.navigationBar.setTintColor rmq.color.white
  end


  def init_nav
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.imaged('001-menu-gray') do
        self.sideMenuViewController.openMenuAnimated true, completion:nil
      end
    end
  end


#pragma mark - collectionView delegates 


  def numberOfSectionsInCollectionView(view)
    @controller.sections.size
  end
 
  def collectionView(view, numberOfItemsInSection: section)
    @controller.sections[section].numberOfObjects
  end
    
  def collectionView(view, cellForItemAtIndexPath: indexPath)
    

    view.dequeueReusableCellWithReuseIdentifier(APPUNTI_CELL_ID, forIndexPath: indexPath).tap do |cell|
      rmq.build(cell) unless cell.reused

      appunto = @controller.objectAtIndexPath(indexPath)
      cell.update(
        cliente_nome: appunto.cliente.nome,
        destinatario: appunto.destinatario,
        note: appunto.note_e_righe,
        status: appunto.status,
        nel_baule: appunto.cliente.nel_baule
      )
    end
  
  end

  def collectionView(view, didSelectItemAtIndexPath: index_path)
    cell = view.cellForItemAtIndexPath(index_path)
    puts "Selected at section: #{index_path.section}, row: #{index_path.row}"
  end

end
