class EditTextFieldController < UIViewController

  
  attr_accessor :text_changed_block, :fieldType


  def initWithType(fieldType)
    init
    self.fieldType = fieldType
    self
  end


  def viewDidLoad
    super

    rmq.stylesheet = EditTextFieldControllerStylesheet
    rmq(self.view).apply_style :root_view

    # imageView = rmq.append(UIImageView, :image_view).get
    # imageView.setImageToBlur(UIImage.imageNamed("galaxy"),
    #                     blurRadius:KLBBlurredImageDefaultBlurRadius,
    #                completionBlock:lambda do |error|
    #                    NSLog("The blurred image has been setted")
    #                end)

    @text_label = rmq.append(UILabel, :text_label).get
    @text_field = rmq.append(UITextField, :text_field).get


    navigationItem.leftBarButtonItem = UIBarButtonItem.cancel do |button|
      cancel(button) 
    end
    navigationItem.rightBarButtonItem = UIBarButtonItem.done do |button|
      done(button)
    end

  end


  def viewWillAppear(animated)
    super
    @text_field.text = @data
    @text_label.text = @label 
    @text_field.becomeFirstResponder
  end

  
  def load_data(data, withLabel:label)
    @data = data
    @label = label
  end


#pragma mark - Actions


  def handleTextCompletion

    text = @text_field.text
  
    error = Pointer.new(:object)
    success = @text_changed_block.call(text, error)
    if (success) 
      navigationController.popViewControllerAnimated(true)
      return true
    else
      alertView = UIAlertView.alloc.initWithTitle("Errore", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
      alertView.show
      return false
    end
  end 


  def done(sender)
    self.handleTextCompletion
  end
  

  def cancel(sender)
    navigationController.popViewControllerAnimated(true)
  end


#pragma mark - UITextFieldDelegate

 
  def textFieldShouldReturn(textField)
    handleTextCompletion
  end


  def textFieldDidBeginEditing(textField)
    
    if self.fieldType == TextFieldTypeDecimal
      textField.selectAll self
    end
    #textField.setSelectedTextRange(@text_field.textRangeFromPosition(@text_field.beginningOfDocument, toPosition:@text_field.endOfDocument))
  end




end

