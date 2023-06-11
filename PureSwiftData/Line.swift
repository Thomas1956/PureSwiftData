//
//  Line.swift
//  PureSwiftData
//
//  Created by Thomas on 11.06.23.
//

import Foundation
import SwiftData


//--------------------------------------------------------------------------------------------
// MARK: - ModelData for Line

@Model final public class Line {
    var active: Bool
    var name: String
    
    init(name: String, active: Bool) {
        self.name = name
        self.active = active
    }
}

extension Line: Hashable {
    public static func == (lhs: Line, rhs: Line) -> Bool {
        lhs.name == rhs.name && lhs.active == rhs.active
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(active)
    }
}
