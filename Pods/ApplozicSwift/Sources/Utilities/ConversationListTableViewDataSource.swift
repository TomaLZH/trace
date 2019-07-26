//
//  TableViewDataSource.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 29/11/18.
//

import Foundation
import Applozic

public class ConversationListTableViewDataSource: NSObject, UITableViewDataSource {

    /// A closure to configure tableview cell with the message object
    public typealias CellConfigurator = (ALKChatViewModelProtocol, UITableViewCell) -> Void
    public var cellConfigurator: CellConfigurator

    var viewModel: ALKConversationListViewModelProtocol

    public init(viewModel: ALKConversationListViewModelProtocol, cellConfigurator: @escaping CellConfigurator) {
        self.viewModel = viewModel
        self.cellConfigurator = cellConfigurator
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel.chatFor(indexPath: indexPath) as? ALMessage else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cellConfigurator(message, cell)
        return cell
    }

}
