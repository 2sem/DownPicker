//
//  File.swift
//  
//
//  Created by 영준 이 on 10/20/24.
//

import UIKit

public class UIDownPicker : UITextField {
    public var downPicker : DownPicker!

    public init(data: [AnyObject]?) {
        super.init(frame: .zero)
        self.downPicker = .init(textField: self, data: data)
    }
    
    convenience init() {
        self.init(data: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
