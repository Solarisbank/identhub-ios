//
//  ProgressCellObject.swift
//  IdentHubSDK
//

import Foundation

struct ProgressCellObject {

    /// Title of the progress cell
    let title: String

    /// Loading status of the uploading process
    var loading: Bool

    /// Visible cell state
    var visible: Bool

    /// Completion task state
    var complete: Bool

    /// Bool state of the visibility of top cell separator view
    let visibleSeparator: Bool

    // MARK: - Init method -

    init(title: String, visibleSeparator: Bool) {
        self.title = title
        self.visibleSeparator = visibleSeparator
        self.loading = false
        self.visible = false
        self.complete = false
    }

    // MARK: - Public methods -

    mutating func updateLoadingStatus(_ status: Bool) {
        loading = status
        visible = status
        complete = !status
    }

    mutating func updateCompletionStatus(_ status: Bool) {
        complete = status
        loading = !status
    }
}
