module TotaliCellStylesheet

  def totali_cell(st)

  end

  def importo(st)
    st.frame = {l: 143, t: 0, w: 143, h: 50}
    st.font = font.medium
    st.view.textAlignment = NSTextAlignmentRight
    st.color = rmq.root_view.tintColor
  end  

  def copie(st)
    st.frame = {l: 43, t: 0, w: 100, h: 50}
    st.font = font.medium
    st.color = color.gray
  end

end
