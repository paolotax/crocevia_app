module BarsCellStylesheet
  
  def bars_cell_height
    80
  end

  def bars_cell(st)
    # Style overall cell here
    st.background_color = color.random
  end

  def cell_label(st)
    st.color = color.black
  end
end
