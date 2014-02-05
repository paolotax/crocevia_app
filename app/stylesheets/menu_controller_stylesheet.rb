class MenuControllerStylesheet < ApplicationStylesheet

  def setup
    # Add sytlesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.white
  end


  def search_bar(st)
    st.frame = {t: 20, w: 320, h: 44}
    st.view.placeholder = "Cerca clienti"
    st.view.backgroundImage = UIImage.new
    st.view.translucent = true   
  end
  

  def menu_table_view(st)
    st.frame = {t: 150, w: 320, h: 200}
    st.view.backgroundColor = UIColor.clearColor
    #st.view.separatorStyle = UITableViewCellSeparatorStyleNone
    st.view.scrollEnabled = false
  end

end
