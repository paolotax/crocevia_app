module LibriCellStylesheet


  def libri_cell(st)
    st.view.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    st.view.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
  end

  
  def titolo(st)
    st.frame = {l: 43, t: 0, w: 243, h: 25}
    st.font = font.medium
    st.view.adjustsFontSizeToFitWidth = true
    #st.background_color = color.random
  end  


  def prezzo_copertina(st)
    st.frame = {l: 43, t: 25, w: 143, h: 15}
    st.font = font.small
    st.color = color.gray
    #st.background_color = color.random
  end


  def copertina(st)
    st.frame = {l: 0, t: 0, w: 35, h: 50}
    #st.background_color = color.random
  end  
end
