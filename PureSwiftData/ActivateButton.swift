//
//  ActivateButton.swift
//  PureSwiftData
//
//  Created by Thomas on 11.06.23.
//

import UIKit
import SwiftData


//--------------------------------------------------------------------------------------------
// MARK: - ActivateButton - Button with an option for select

class ActivateButton: UIButton {

    var identifier: PersistentIdentifier?
    
    /// Property for checkmark
    var isActive = false {
        didSet {
            var config = self.configuration
            config?.image = UIImage(systemName: isActive ? "checkmark.square" : "square")
            self.configuration = config
        }
    }

    convenience init(identifier: PersistentIdentifier?) {
        self.init(frame: .zero)
        self.identifier = identifier
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: isActive ? "checkmark.square" : "square")
        config.buttonSize = .medium
        configuration = config
    }
}

