class LibriControllerStylesheet < ApplicationStylesheet

  include LibriCellStylesheet

  def setup

  end

  def table_view(st)
    # st.view.contentInset = [@margin, @margin, @margin, @margin]
    st.background_color = color.white

    # st.view.collectionViewLayout.tap do |cl|
    #   cl.itemSize = [cell_size[:w], cell_size[:h]]
    #   #cl.scrollDirection = UICollectionViewScrollDirectionHorizontal
    #   #cl.headerReferenceSize = [cell_size[:w], cell_size[:h]]
    #   cl.minimumInteritemSpacing = @margin 
    #   cl.minimumLineSpacing = @margin 
    #   #cl.sectionInsert = [0,0,0,0]
    # end
  end

  def search_bar(st)
    st.frame = {t: 0, w: 320, h: 44}
    st.view.placeholder = "Cerca libro"
    #st.view.backgroundImage = UIImage.new
    #st.view.translucent = true   
  end
end
