//
//  DocumentInfoViewController.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore

internal struct DocumentInfoState: Equatable {
    enum State: Equatable {
        case reloadTable
        case didUpdatedContent
    }
    var state: State = .reloadTable
    var continueBtnEnable: Bool = false
}

internal enum DocumentInfoEvent {
    case configureDocumentsInfoTable(table: UITableView)
    case triggerBack
    case triggerContinue
}

final internal class DocumentInfoViewController: UIViewController, Updateable {
        
    typealias ViewState = DocumentInfoState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<DocumentInfoEvent>?
    private var colors: Colors

    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var docInfoTable: UITableView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var continueBtn: ActionRoundedButton!
    @IBOutlet var warningLbl: UILabel!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<DocumentInfoEvent>) {
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

    override var prefersStatusBarHidden: Bool {
        true
    }
    
    func updateView(_ state: DocumentInfoState) {
        
        switch state.state {
        case .didUpdatedContent:
            if state.continueBtnEnable {
                self.continueBtn.currentAppearance = .primary
            } else {
                self.continueBtn.currentAppearance = .inactive
            }
        case .reloadTable:
            self.docInfoTable.reloadData()
        }
    }

    // MARK: - Actions methods -

    @IBAction func didClickBack(_ sender: UIButton) {
        eventHandler?.handleEvent(.triggerBack)
    }

    @IBAction func didClickContinue(_ sender: UIButton) {
        eventHandler?.handleEvent(.triggerContinue)
    }
}

// MARK: - Internal methods -

extension DocumentInfoViewController {

    private func configureUI() {
        eventHandler?.handleEvent(.configureDocumentsInfoTable(table: docInfoTable))

        typealias InfoText = Localizable.DocumentScanner.Information

        titleLbl.text = InfoText.title
        warningLbl.text = InfoText.warning
        quitBtn.setTitle(Localizable.Common.back, for: .normal)
        continueBtn.setAppearance(.inactive, colors: colors)
        continueBtn.setTitle(Localizable.Common.continueBtn, for: .disabled)
    }
    
}
