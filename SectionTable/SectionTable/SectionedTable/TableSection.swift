//
//  TableSection.swift
//  SectionTable
//
//  Created by Dao Van Nha on 17/02/2024.
//

import Foundation
import UIKit

public protocol TableSection: AnyObject {
    
    var id: AnyHashable { get }
    var numberOfItems: Int { get }
    
    var reusableViewRegisters: [TableReusableViewRegister] { get }
    
    func cellForRow(at indexPath: IndexPath, table: UITableView) -> UITableViewCell
    
    func heightForRow(at index: Int) -> TableSpacing
    
    func actionForRow(at indexPath: IndexPath) -> [UIContextualAction]
    
    func header(for table: UITableView) -> UIView?
    
    var headerSpacing: TableSpacing { get }
    
    func footer(for table: UITableView) -> UIView?
    
    var footerSpacing: TableSpacing { get }
    
    func didSelectRow(at indexPath: IndexPath)
    
    var isAttached: Bool { get }
    
    func updateAttached(_ isAttached: Bool, isNotiffy: Bool)
    
    var adapter: SectionedTableAdapter? { get set}
}

public class BaseTableSection<T>: TableSection {
    private var internalAttached: Bool = true
    
    public var data: T?
    
    public var itemSelectedAction: ((Int) -> Void)?
    
    weak open var adapter: SectionedTableAdapter?
    
    public init() {

    }
    
    public func updateData(data: T?, animated: Bool = true) {
        self.data = data
        guard isAttached else { return }
        self.adapter?.reloadSection(id: id, animated: animated)
    }
    
    public var id: AnyHashable {
        fatalError("Must be overriden")
    }
    
    public var numberOfItems: Int {
        fatalError("Must be overriden")
    }
    
    open var registTration: [TableReusableRegistration] {
        fatalError("Must be overriden")
    }
    
    public var reusableViewRegisters: [TableReusableViewRegister] {
        var regs = registTration
        regs.append(.headerFooterClass(BorderSpacingHeaderFooterView.self))
        return regs
    }
    
    public func cellForRow(at indexPath: IndexPath, table: UITableView) -> UITableViewCell {
        fatalError("Must be overriden")
    }
    
    public func heightForRow(at index: Int) -> TableSpacing {
        .auto
    }
    
    public func actionForRow(at indexPath: IndexPath) -> [UIContextualAction] {
        []
    }
    
    open var headerStyle: SpacingStyle {
        .none
    }
    
    open var footerStyle: SpacingStyle {
        .none
    }
    public var headerSpacing: TableSpacing {
        switch headerStyle {
        case .spacing:
            return .header
        case .none:
            return .invisible
        }
    }
    
    public var footerSpacing: TableSpacing {
        switch footerStyle {
        case .spacing:
            return .footer
        case .none:
            return .invisible
        }
    }
    
    public func footer(for table: UITableView) -> UIView? {
        switch footerStyle {
        case .spacing:
            return defaultHeaderFooter(for: table)
        case .none:
            return nil
        }
    }
    
    public func header(for table: UITableView) -> UIView? {
        switch headerStyle {
        case .spacing:
            return defaultHeaderFooter(for: table)
        case .none:
            return nil
        }
    }
    
    public func didSelectRow(at indexPath: IndexPath) {
        itemSelectedAction?(indexPath.row)
    }
    
    public var isAttached: Bool {
        get { return internalAttached }
        set { updateAttached(newValue, isNotiffy: true)}
    }
    
    public func updateAttached(_ isAttached: Bool, isNotiffy: Bool) {
        if isAttached == internalAttached {
            return
        }
        
        internalAttached = isAttached
        if isNotiffy {
            updateHeightChanged()
        }
    }
    
    private func updateHeightChanged() {
        if isAttached {
            self.adapter?.notifyAttched(id: id)
        } else {
            self.adapter?.notifyDetach(id: id)
        }
    }
}

public enum SpacingStyle {
    case spacing
    case none
}

extension BaseTableSection {
    public func defaultHeaderFooter(for table: UITableView, top: Bool = true, bottom: Bool = true) -> UIView {
        let view = table.dequeueReusableHeaderFooterView(withIdentifier: BorderSpacingHeaderFooterView.reuseId) as! BorderSpacingHeaderFooterView
        view.borderView.isTopBorderEnabled = top
        view.borderView.isBottomBorderEnabled = bottom
        return view
    }
    
    public func notifyHeightChanged() {
        adapter?.notifyHeightChanged(id: id)
    }
}
