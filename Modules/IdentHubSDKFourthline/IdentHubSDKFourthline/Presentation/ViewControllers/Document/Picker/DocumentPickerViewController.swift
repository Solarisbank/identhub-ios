//
//  DocumentPickerViewController.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore
import FourthlineCore

internal struct DocumentPickerState: Equatable {

    enum State: Equatable {
        case loadDocument
        case updateSelectedDocument
    }
    var state: State = .loadDocument
    var documentsContent: [ScanDocumentType] = []
    var documentTypeDDM: DocumentTypesDDM?
    var obtainTableHeight: CGFloat = 0
    var selectedDocument: DocumentType?
    
    static func == (lhs: DocumentPickerState, rhs: DocumentPickerState) -> Bool {
        return lhs.selectedDocument == rhs.selectedDocument
    }
}

internal enum DocumentPickerEvent {
    case configureDocumentsTable(table: UITableView)
    case selectDocument
    case quit
}

final internal class DocumentPickerViewController: UIViewController, Updateable {
    
    typealias ViewState = DocumentPickerState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<DocumentPickerEvent>?
    private var colors: Colors

    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var continueBtn: ActionRoundedButton!
    @IBOutlet var documentTypesTable: UITableView!
    @IBOutlet var tableShadow: UIImageView!
    @IBOutlet var tableViewConstraint: NSLayoutConstraint!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<DocumentPickerEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func updateView(_ state: DocumentPickerState) {
        
        switch state.state {
        case .loadDocument:
            eventHandler?.handleEvent(.configureDocumentsTable(table: documentTypesTable))
            tableViewConstraint.constant = state.obtainTableHeight
            tableShadow.isHidden = (tableViewConstraint.constant == 0)
        case .updateSelectedDocument:
            self.continueBtn.currentAppearance = .primary
        }
    }
    
    // MARK: - Action methods -

    @IBAction func didClickContinue(_ sender: UIButton) {
        eventHandler?.handleEvent(.selectDocument)
    }

    @IBAction func didClickQuit(_ sender: UIButton) {
        eventHandler?.handleEvent(.quit)
    }

    // MARK: - Internal methods -
    
    private func configureUI() {
        eventHandler?.handleEvent(.configureDocumentsTable(table: documentTypesTable))
        
        titleLbl.text = Localizable.DocumentScanner.title
        titleLbl.setLabelStyle(.title)
        descriptionLbl.text = Localizable.DocumentScanner.description
        descriptionLbl.setLabelStyle(.subtitle)
        continueBtn.setTitle(Localizable.Common.continueBtn, for: .normal)
        continueBtn.setAppearance(.inactive, colors: colors)
        quitBtn.setTitle(Localizable.Common.quit, for: .normal)
        quitBtn.setBtnTitleStyle()
    }
    
}
