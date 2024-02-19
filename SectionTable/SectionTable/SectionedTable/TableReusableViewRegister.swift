//
//  TableReusableViewRegister.swift
//  SectionTable
//
//  Created by Dao Van Nha on 17/02/2024.
//

import Foundation
import UIKit

public protocol TableReusableViewRegister {
    func register(for table: UITableView)
}

public enum TableReusableRegistration {
    case cell(UITableViewCell.Type)
    case cellClass(UITableViewCell.Type)
    case cellInBundle(UITableViewCell.Type, Bundle)
    case headerFooter(UITableViewHeaderFooterView.Type)
    case headerFooterInBundle(UITableViewHeaderFooterView.Type, Bundle)
    case headerFooterClass(UITableViewHeaderFooterView.Type)
}

extension TableReusableRegistration: TableReusableViewRegister {
    public func register(for table: UITableView) {
        switch self {
        case .cell(let uITableViewCell):
            table.registerNib(for: uITableViewCell)
        case .cellClass(let uITableViewCell):
            table.registerClass(for: uITableViewCell)
        case .cellInBundle(let uITableViewCell, let bundle):
            table.registerNib(for: uITableViewCell, bundle: bundle, reuseId: uITableViewCell.reuseId)
        case .headerFooter(let uITableViewHeaderFooterView):
            table.registerNib(forHeaderFooter: uITableViewHeaderFooterView)
        case .headerFooterInBundle(let uITableViewHeaderFooterView, let bundle):
            table.registerNib(forHeaderFooter: uITableViewHeaderFooterView, reuseId: uITableViewHeaderFooterView.reuseId, bundle: bundle)
        case .headerFooterClass(let uITableViewHeaderFooterView):
            table.registerClass(forHeaderFooter: uITableViewHeaderFooterView)
        }
    }
}

extension UIView {
    
    static var reuseId: String {
        String(describing: self)
    }
    
    static func nib(from bundle: Bundle) -> UINib {
        UINib(nibName: String(describing: self), bundle: bundle)
    }
}

extension UITableView {
    func registerNib(for cellClass: UITableViewCell.Type, bundle: Bundle, reuseId: String) {
        register(cellClass.nib(from: bundle), forCellReuseIdentifier: reuseId)
    }
    
    func registerNib(for cellClass: UITableViewCell.Type) {
        registerNib(for: cellClass,
                    bundle: .main,
                    reuseId: cellClass.reuseId)
    }
    
    func registerClass(for cellClass: UITableViewCell.Type, reuseId: String) {
        register(cellClass, forCellReuseIdentifier: reuseId)
    }
    
    func registerClass(for cellClass: UITableViewCell.Type) {
        registerClass(for: cellClass, reuseId: cellClass.reuseId)
    }
    
    func registerClass(forHeaderFooter aClass: UITableViewHeaderFooterView.Type, reuseId: String) {
        register(aClass, forHeaderFooterViewReuseIdentifier: reuseId)
    }
    
    func registerClass(forHeaderFooter aClass: UITableViewHeaderFooterView.Type) {
        registerClass(forHeaderFooter: aClass, reuseId: aClass.reuseId)
    }
    
    func registerNib(forHeaderFooter aClass: UITableViewHeaderFooterView.Type, reuseId: String, bundle: Bundle) {
        register(aClass.nib(from: bundle), forCellReuseIdentifier: reuseId)
    }
    
    func registerNib(forHeaderFooter aClass: UITableViewHeaderFooterView.Type) {
        registerNib(forHeaderFooter: aClass,
                    reuseId: aClass.reuseId,
                    bundle: .main)
    }
    
    func registerNibs<T: UITableViewCell>(for cellClasses: [T.Type]) {
        for cellClass in cellClasses {
            registerNib(for: cellClass)
        }
    }
}
