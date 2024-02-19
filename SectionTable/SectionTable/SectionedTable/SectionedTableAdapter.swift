//
//  SectionedTableAdapter.swift
//  SectionTable
//
//  Created by Dao Van Nha on 17/02/2024.
//

import Foundation
import UIKit

public class SectionedTableAdapter: NSObject {
    
    
    private var tableview: UITableView
    
    private var sections: ContiguousArray<TableSection> = [] {
        didSet {
            attachedSections = sections.filter({ $0.isAttached})
        }
    }
    
    private var attachedSections: ContiguousArray<TableSection> = []
    
    private var cachedRowHeights: [IndexPath: CGFloat] = [:]
    
    public init(tableview: UITableView) {
        self.tableview = tableview
        super.init()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        self.tableview.estimatedRowHeight = 100
    }
    
    public func addSection(section: TableSection) {
        if let exited = sections.first(where: { $0.id == section.id}) {
            fatalError("Id: \(section.id) already exists for section : \(String(describing: type(of: exited)))")
        }
        
        section.adapter = self
        register(section: section)
        sections.append(section)
        
        if !section.isAttached {
            return
        }
        
        if tableview.window == nil {
            return
        }
        
        if attachedSections.count <= 1 {
            tableview.reloadData()
        } else {
            tableview.insertSections(IndexSet(integer: attachedSections.count - 1),
                                     with: .none)
        }
    }
    
    public func addSectionIfNotExist(section: TableSection) -> Bool {
        if sections.contains(where: { $0.id == section.id}) {
            return false
        }
        
        addSection(section: section)
        return true
    }
    
    
    public func reloadSection(id: AnyHashable, animated: Bool = true) {
        if let index = attachedSections.firstIndex(where: { $0.id == id }) {
            tableview.reloadSections(IndexSet(integer: index),
                                     with: animated ? .automatic : .none)
        }
    }
    
    public func reloadRows(rows: Set<Int>, sectionId: AnyHashable, animated: Bool = true) {
        if let index = attachedSections.firstIndex(where: { $0.id == sectionId}) {
            tableview.reloadRows(at: rows.map({ IndexPath(row: $0, section: index)}),
                                 with: animated ? .automatic : .none)
        }
    }
    
    public func insertRows(rows: Set<Int>, sectionId: AnyHashable, animated: Bool = true) {
        if let index = attachedSections.firstIndex(where: { $0.id == sectionId}) {
            tableview.insertRows(at: rows.map({ IndexPath(row: $0, section: index)}),
                                 with: animated ? .automatic : .none)
        }
    }
    
    /// If a single section is attached/detached, it's not really a batch update,
    /// but when multiple sections are attached/detached simultaneously
    /// then it can causes `tableView.numberOfSections` to be different from
    /// dataSource's `numberOfSections(in:)` and cause index-out-of-bound
    /// (as stated in Apple docs, `tableView.numberOfSections` is internally cached, that's maybe the reason).
    /// So we always perform a batch update here to avoid the crash.
    
    public func notifyAttched(id: AnyHashable) {
        attachedSections = sections.filter({ $0.isAttached})
        if let index  = attachedSections.firstIndex(where: { $0.id == id}) {
            tableview.performBatchUpdates {
                tableview.insertSections(IndexSet(integer: index),
                                         with: .fade)
            }
        }
    }
    
    public func notifyDetach(id: AnyHashable) {
        if let index = attachedSections.firstIndex(where: { $0.id == id}) {
            tableview.performBatchUpdates {
                attachedSections.remove(at: index)
                tableview.deleteSections(IndexSet(integer: index),
                                         with: .fade)
            }
        }
    }
    
    public func notifyHeightChanged(id: AnyHashable) {
        guard attachedSections.contains(where: { $0.id == id}) else { return }
        
        tableview.performBatchUpdates {
            
        }
    }
    
    public func register(section: TableSection) {
        for register in section.reusableViewRegisters {
            register.register(for: tableview)
        }
    }
}

extension SectionedTableAdapter: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        attachedSections[indexPath.section].didSelectRow(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        attachedSections[section].header(for: tableView)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        attachedSections[section].footer(for: tableView)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        attachedSections[section].headerSpacing.value
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        attachedSections[section].footerSpacing.value
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        cachedRowHeights[indexPath] ?? tableView.estimatedRowHeight
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cachedRowHeights[indexPath] = cell.frame.height
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        attachedSections[indexPath.section].heightForRow(at: indexPath.row).value
    }
}

extension SectionedTableAdapter: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        attachedSections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attachedSections[section].numberOfItems
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        attachedSections[indexPath.section].cellForRow(at: indexPath, table: tableView)
    }
    
}
