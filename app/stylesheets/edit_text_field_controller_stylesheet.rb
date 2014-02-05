class EditTextFieldControllerStylesheet < ApplicationStylesheet
  # Add your view stylesheets here. You can then override styles if needed, example:
  # include FooStylesheet

  def setup
    # Add sytlesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  
  def root_view(st)
    st.background_color = color.dark_gray_color
  end

  def image_view(st)
    st.frame = { l: 0, t:0, w:320, h:568 }
  end
  
  def text_label(st)
    st.frame = {t: 80, w: 320, h: 25}
    st.view.textAlignment = UITextAlignmentCenter
    st.color = color.white
  end


  def text_field(st)
    st.frame = {l: 40, t: 110, w: 240, h: 30}
    st.view.delegate = self
    st.view.borderStyle = UITextBorderStyleRoundedRect

    fieldType = rmq.view_controller.fieldType
    if fieldType == TextFieldTypeDecimal
      st.view.keyboardType = UIKeyboardTypeDecimalPad 
      st.view.textAlignment = UITextAlignmentRight
    elsif fieldType == TextFieldTypeEmail
      st.view.keyboardType = UIKeyboardTypeEmailAddress
    elsif fieldType == TextFieldTypePhone
      st.view.keyboardType = UIKeyboardTypePhonePad
    end
  end
end
