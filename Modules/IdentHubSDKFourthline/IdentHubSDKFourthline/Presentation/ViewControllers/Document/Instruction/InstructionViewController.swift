//
//  InstructionViewController.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore

internal struct InstructionState: Equatable {
    var title: String = ""
}

internal enum InstructionEvent {
    case triggerQuit
    case triggerContinue
}

class InstructionViewController: UIViewController, Updateable {
    
    typealias ViewState = InstructionState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<InstructionEvent>?
    private var colors: Colors
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var continueBtn: ActionRoundedButton!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<InstructionEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: InstructionState) {
        continueBtn.setAppearance(.inactive, colors: colors)
    }
    
    // MARK: - Actions methods -

    @IBAction func didClickQuit(_ sender: UIButton) {
        eventHandler?.handleEvent(.triggerQuit)
    }

    @IBAction func didClickContinue(_ sender: UIButton) {
        eventHandler?.handleEvent(.triggerContinue)
    }

}

// MARK: - Internal methods -

extension InstructionViewController {

    private func configureUI() {

        typealias InfoText = Localizable.DocumentScanner.Healthcard

        titleLbl.text = InfoText.title
        titleLbl.setLabelStyle(.title)
        descriptionLbl.text = InfoText.description
        descriptionLbl.setLabelStyle(.subtitle)
        continueBtn.setAppearance(.primary, colors: colors)
        continueBtn.setTitle(Localizable.Common.continueBtn, for: .disabled)
    }
    
}
