//
//  DocumentScannerViewController.swift
//  IdentHubSDK
//

import UIKit

class DocumentScannerViewController: UIViewController {

    // MARK: - Init methods -
    private var viewModel: DocumentScannerViewModel

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: DocumentScannerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "DocumentScannerViewController", bundle: Bundle(for: DocumentScannerViewController.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Action methods -
    @IBAction func didClickQuit(_ sender: UIButton) {

        viewModel.dismissScanner()
    }
}
