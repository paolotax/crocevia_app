module ClienteCellStylesheet


  def cliente_cell(st)
    #st.frame = {l: 0, t: 0, w: 320, h: 20}
    st.background_color = color.clear
    st.view.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton
    st.view.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
  end

  def nome(st)
    st.frame = {l: 50, t: 3, w: 200, h: 25}
    st.font = font.headline
  end

  def citta(st)
    st.frame = {l: 50, t: 22, w: 200, h: 20}
    st.font = font.subhead
  end

  def nel_baule(st)
    st.frame = {l: 5, t: 3, w: 40, h: 40}
  end


end
