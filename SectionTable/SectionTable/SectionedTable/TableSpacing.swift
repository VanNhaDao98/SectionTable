//
//  TableSpacing.swift
//  SectionTable
//
//  Created by Dao Van Nha on 17/02/2024.
//

import Foundation
import UIKit

public struct TableSpacing {
    public var value: Double
}

public extension TableSpacing {
    
    // default
    static let header = TableSpacing(value: 16)
    static let footer = TableSpacing(value: 16)
    
    static let invisible = TableSpacing(value: .leastNormalMagnitude)
    
    static let auto = TableSpacing(value: UITableView.automaticDimension)
    
    static func custom(_ value: Double) -> TableSpacing {
        TableSpacing(value: value)
    }
}
