//
//  File.swift
//
//
//  Created by 영준 이 on 10/20/24.
//

import UIKit

@objc
public class DownPicker : UIControl {
    var pickerView : UIPickerView!
    @IBOutlet var textField : UITextField!
    var dataArray : [Any] = [];
    var placeholder : String!
    var placeholderWhileSelecting : String?
    var toolbarDoneButtonText : String?
    var toolbarCancelButtonText : String?
    var toolbarStyle : UIBarStyle = .default
    
    var shouldDisplayCancelButton: Bool = false
    
    public var text : String? {
        /**
         Getter for text property.
         @return
         The value of the selected item or NIL NIL if nothing has been selected yet.
         */
        get {
            return self.textField.text
        }
        
        /**
         Setter for text property.
         @param txt
         The value of the item to select or NIL to clear selection.
         */
        set {
            let txt = newValue
            if txt != nil {
                let index = self.dataArray.firstIndex(where: { $0 as? String == txt })
                if (index != nil) { self.setValue(at: index ?? 0) }
            }
            else {
                self.textField.text = txt
            }
        }
    }
    
    public var selectedIndex : Int {
        /**
         Getter for selectedIndex property.
         @return
         The zero-based index of the selected item or -1 if nothing has been selected yet.
         */
        get {
            guard let index = self.dataArray.firstIndex(where: { $0 as? String == self.textField.text }) else {
                return -1
            }
            
            return index
        }
        
        /**
         Setter for selectedIndex property.
         @param index
         Sets the zero-based index of the selected item using the setValueAtIndex method: -1 can be used to clear selection.
         */
        set {
            self.setValue(at: newValue)
        }
    }
    
    private var _previousSelectedString: String?
    
    convenience init(textField tf: UITextField) {
        self.init(textField: tf, data: nil)
    }
    
    init(textField tf: UITextField, data: [AnyObject]?) {
        super.init(frame: .zero)
    
        self.textField = tf
        tf.delegate = self
        
        // set UI defaults
        self.toolbarStyle = .default
        
        // set language defaults
        self.placeholder = "Tap to choose..."
        self.placeholderWhileSelecting = "Pick an option..."
        self.toolbarDoneButtonText = "Done"
        self.toolbarCancelButtonText = "Cancel"
        
        // hide the caret and its blinking
        var textInputTraits : UITextInputTraits = textField.value(forKey: "textInputTraits") as! UITextInputTraits
        textInputTraits.passwordRules??.setValue(UIColor.clear, forKey: "insertionPointColor")
        
        // set the placeholder
        self.textField.placeholder = self.placeholder
        
        // setup the arrow image
        var img: UIImage? = .init(named: "downArrow.png") // non-CocoaPods
        if (img == nil) { img = .init(named: "DownPicker.bundle/downArrow.png") } // CocoaPods
        if (img != nil) { tf.rightView = UIImageView.init(image: img) }
        self.textField.rightView?.contentMode = .scaleAspectFit
        self.textField.rightView?.clipsToBounds = true
        
        // show the arrow image by default
        self.showArrowImage(true)
        
        // set the data array (if present)
        if let data {
            self.setData(data)
        }
        
        self.shouldDisplayCancelButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shouldAutorotateTo(_ interfaceOrientation: UIInterfaceOrientation) -> Bool {
        return interfaceOrientation == .portrait
    }
    
    @objc func doneClicked(_ sender: UIBarButtonItem) {
        //hides the pickerView
        textField.resignFirstResponder()
        
        if (self.textField.text?.isEmpty ?? true) || !self.dataArray.contains(where: { $0 as? String == self.textField.text }) {
            // self->textField.text = [dataArray objectAtIndex:0];
            self.setValue(at: -1)
            self.textField.placeholder = self.placeholder
        }
        /*
         else {
         if (![self->textField.text isEqualToString:_previousSelectedString]) {
         [self sendActionsForControlEvents:UIControlEventValueChanged];
         }
         }
         */
        self.sendActions(for: .valueChanged)
    }
    
    @objc func cancelClicked(_ sender: UIBarButtonItem) {
        self.textField.resignFirstResponder() //hides the pickerView
        if (_previousSelectedString?.isEmpty ?? true)  || !dataArray.contains(where: { $0 as? String == _previousSelectedString }) {
            self.textField.placeholder = self.placeholder
        }
        
        self.textField.text = _previousSelectedString
    }
    
    @IBAction func showPicker(_ sender: UIControl)
    {
        _previousSelectedString = self.textField.text
        
        self.pickerView = UIPickerView()
        self.pickerView.showsSelectionIndicator = true
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        //If the text field is empty show the place holder otherwise show the last selected option
        if (self.textField.text?.isEmpty ?? true) || !dataArray.contains(where: { $0 as? String == self.textField.text })
        {
            if self.placeholderWhileSelecting != nil {
                self.textField.placeholder = self.placeholderWhileSelecting
            }
            // 0.1.31 patch: auto-select first item: it basically makes placeholderWhileSelecting useless, but
            // it solves the "first item cannot be selected" bug due to how the pickerView works.
            self.selectedIndex = 0
        }
        else
        {
            if self.dataArray.contains(where: { $0 as? String == self.textField.text }) {
                self.pickerView.selectRow(self.dataArray.firstIndex(where: { $0 as? String == self.textField.text }) ?? 0,
                                          inComponent: 0,
                                          animated: true)
            }
        }
        
        var toolbar: UIToolbar = .init()
        toolbar.barStyle = self.toolbarStyle
        toolbar.sizeToFit()
        
        //space between buttons
        var flexibleSpace: UIBarButtonItem = .init(barButtonSystemItem: .flexibleSpace ,
                                                   target: nil,
                                                   action: nil)
        
        let doneButton: UIBarButtonItem = .init(title: self.toolbarDoneButtonText,
                                                style: .done,
                                                target: self,
                                                action: #selector(doneClicked))
        
        if self.shouldDisplayCancelButton {
            let cancelButton: UIBarButtonItem = .init(title: self.toolbarCancelButtonText,
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(cancelClicked))
            
            toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        } else {
            toolbar.setItems([flexibleSpace, doneButton], animated: false)
        }
        
        
        //custom input view
        textField.inputView = pickerView
        textField.inputAccessoryView = toolbar
    }
    
    func setArrowImage(_ image: UIImage)
    {
        let rightImage: UIImageView? = self.textField.rightView as? UIImageView
        rightImage?.image = image
    }
    
    func setPlaceholder(_ str: String)
    {
        self.placeholder = str
        self.textField.placeholder = self.placeholder
    }
    
    func setPlaceholderWhileSelecting(_ str: String)
    {
        self.placeholderWhileSelecting = str
    }
    
    func setAttributedPlaceholder(_ attributedString: NSAttributedString)
    {
        self.textField.attributedPlaceholder = attributedString
    }
    
    public func setToolbarDoneButtonText(_ str: String)
    {
        self.toolbarDoneButtonText = str
    }
    
    public func setToolbarCancelButtonText(_ str: String)
    {
        self.toolbarCancelButtonText = str
    }
    
    func setToolbarStyle(_ style: UIBarStyle)
    {
        self.toolbarStyle = style
    }
    
    func getPickerView() -> UIPickerView
    {
        return self.pickerView
    }
    
    func getTextField() -> UITextField
    {
        return self.textField
    }
    
    func getValue(at index: Int) -> String?
    {
        return (self.dataArray.count > index) ? self.dataArray[index] as? String : nil ;
    }
    
    func setValue(at index: Int)
    {
        if index >= 0 {
            self.pickerView(self.pickerView ?? UIPickerView(), didSelectRow: 0, inComponent: 0)
        }
        else {
            self.text = nil
        }
    }
    
    func setData(_ data: [AnyObject])
    {
        self.dataArray = data
    }
    
    func showArrowImage(_ b: Bool)
    {
        if(b){
            // set the DownPicker arrow to the right (you can replace it with any 32x24 px transparent image: changing size might give different results)
            self.textField.rightViewMode = .always
        } else {
            self.textField.rightViewMode = .never
        }
    }
}

extension DownPicker: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ aTextField: UITextField) -> Bool {
        if !self.dataArray.isEmpty {
            self.showPicker(aTextField)
            return true
        }
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.sendActions(for: .editingDidBegin)
    }
    
    public func textFieldDidEndEditing(_ aTextField: UITextField) {
        aTextField.isUserInteractionEnabled = true
        self.sendActions(for: .editingDidEnd)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension DownPicker: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray[row] as? String
    }
}

extension DownPicker: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = dataArray[row] as? String
        self.sendActions(for: .valueChanged)
    }
}
