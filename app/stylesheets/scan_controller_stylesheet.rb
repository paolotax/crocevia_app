class ScanControllerStylesheet < ApplicationStylesheet
  
  
  include RigaCellStylesheet


  def root_view(st)
    st.background_color = color.white
  end


  def tableView(st)
    st.frame = { t: 200, w: 320, h: 324 }
  end

  
  def preview_view(st) 
    st.frame = { w: 320, h: 320 }
    st.background_color = UIColor.redColor
  end


  def rect_of_interest_view(st)
    st.frame = { l: 20, t: 20, w: 280, h: 180 }
    st.background_color = [0, 0, 0].uicolor(0.2)
    st.view.userInteractionEnabled = true
  end


  def button_dismiss(st)
    st.frame = { t: 524, w: 320, h: 44 }
    st.color = UIColor.blueColor
  end


end