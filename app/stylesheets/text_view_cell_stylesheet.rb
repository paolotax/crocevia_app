module TextViewCellStylesheet
  
  def text_view_cell(st)
    #st.frame = {l: 0, t: 0, w: 320, h: 20}
    st.background_color = color.white
    st.view.accessoryType  = UITableViewCellAccessoryDisclosureIndicator
    #st.view.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
  end


  def text_view(st)
    st.frame = {l: 10, t: 5, w: 270, h: 86}
    st.view.userInteractionEnabled = false
    st.background_color = color.clear
  end

end