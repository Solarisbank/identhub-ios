//
//  TableViewDataSource.swift
//  IdentHubSDKCore
//

import UIKit

public class TableViewDataSource<Element, Cell: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {

    public var elements: [Element] = [] {
        didSet {
            onUpdate?()
        }
    }
    
    public var onSelect: ((Element, Cell) -> Void)?

    private static var cellIdentifier: String {
        String(describing: Cell.self)
    }

    private var onConfigure: (Element, Cell) -> Void
    private var onUpdate: (() -> Void)?

    public init(configure: @escaping (Element, Cell) -> Void) {
        self.onConfigure = configure
    }

    public func register(on tableView: UITableView, bundle: Bundle) {
        let cellNib = UINib(nibName: Self.cellIdentifier, bundle: bundle)
        tableView.register(cellNib, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        onUpdate = {
            tableView.reloadData()
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as? Cell else {
            print("Warning: Couldn't deque cell \(Cell.self). Call register(on:) method.")
            return UITableViewCell()
        }

        onConfigure(elements[indexPath.row], cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? Cell {
            onSelect?(elements[indexPath.row], cell)
        }
    }
}
