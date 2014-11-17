class BarsController < UITableViewController

  BARS_CELL_ID = "BarsCell"

  def viewDidLoad
    super

    load_data

    rmq.stylesheet = BarsControllerStylesheet

    view.tap do |table|
      table.delegate = self
      table.dataSource = self
      rmq(table).apply_style :table
    end
  end

  def load_data
    @data = 0.upto(rand(100)).map do |i| # Test data
      {
        name: %w(Lorem ipsum dolor sit amet consectetur adipisicing elit sed).sample,
        num: rand(100),
      }
    end
  end

  def tableView(table_view, numberOfRowsInSection: section)
    @data.length
  end

  def tableView(table_view, heightForRowAtIndexPath: index_path)
    rmq.stylesheet.bars_cell_height
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    data_row = @data[index_path.row]

    cell = table_view.dequeueReusableCellWithIdentifier(BARS_CELL_ID) || begin
      rmq.create(BarsCell, :bars_cell, reuse_identifier: BARS_CELL_ID).get

      # If you want to change the style of the cell, you can do something like this:
      #rmq.create(BarsCell, :bars_cell, reuse_identifier: BARS_CELL_ID, cell_style: UITableViewCellStyleSubtitle).get
    end

    cell.update(data_row)
    cell
  end

  # Remove if you are only supporting portrait
  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskAll
  end

  # Remove if you are only supporting portrait
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    rmq.all.reapply_styles
  end
end
