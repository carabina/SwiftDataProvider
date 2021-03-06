//
//  Section.swift
//  SwiftDataProvider
//
//  Created by Martin Eberl on 23.10.18.
//

import Foundation

protocol SectionDelegate: class {
    func section(_ section: Section, needsReload: Bool)
    func didUpdateRows(for section: Section)
}

open class Section {
    open var header: Any?
    open var footer: Any?
    open var rows: [Any]
    
    public init(header: Any? = nil, footer: Any? = nil, rows: [Any] = []) {
        self.header = header
        self.footer = footer
        self.rows = rows
    }
    
    internal weak var delegate: SectionDelegate?
    internal var context = Modification()
    
    open func add<Content: Comparable>(row: Content) {
        rows.append(row)
        context.insert(at: rows.count - 1)
        delegate?.didUpdateRows(for: self)
    }
    
    open func insert<Content: Comparable>(row: Content, at index: Int) {
        rows.insert(row, at: index)
        context.insert(at: index)
        delegate?.didUpdateRows(for: self)
    }
    
    open func delete<Content: Comparable>(row: Content) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        self.rows.remove(at: index)
        context.delete(at: index)
        delegate?.didUpdateRows(for: self)
    }
    
    open func reload(at index: Int) {
        context.reload(at: index)
    }
    
    open func reload<Content: Comparable>(row: Content) {
        guard let index = rows.index(where: { ($0 as? Content) == row } ) else {
            return
        }
        reload(at: index)
    }
    
    open func content<Content>(where closure: @escaping ((Content) -> Bool)) -> Content? {
        return rows.first(where: { content in
            guard let content = content as? Content else {
                return false
            }
            return closure(content)
        }) as? Content
    }
    
    internal func indexPaths(for section: Int) -> (reload: [IndexPath]?, delete: [IndexPath]?, insert: [IndexPath]?)? {
        let reload = context.reload?.compactMap { IndexPath(row: $0, section: section) }
        let delete = context.delete?.compactMap { IndexPath(row: $0, section: section) }
        let insert = context.insert?.compactMap { IndexPath(row: $0, section: section) }
        
        if reload == nil && delete == nil && insert == nil {
            return nil
        }
        
        return (reload: reload, delete: delete, insert: insert)
    }
    
    open func clear() {
        context.clear()
    }
    
    open func setNeedsUpdate(_ needsUpdate: Bool) {
        delegate?.section(self, needsReload: needsUpdate)
    }
}
