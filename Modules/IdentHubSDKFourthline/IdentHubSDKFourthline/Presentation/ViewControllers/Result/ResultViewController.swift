//
//  ResultViewController.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore

internal struct ResultState: Equatable {
    var title: String = ""
    var description: String = ""
    var image: UIImage?
}

internal enum ResultEvent {
    case showResult
    case triggerDone
}

/// UIViewController for managing Result screen UI components for Fourthline flow.
final internal class ResultViewController: UIViewController, Updateable {
 
    typealias ViewState = ResultState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<ResultEvent>?
    private var colors: Colors
    
    // MARK: - Outlets -
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var resultImage: UIImageView!
    @IBOutlet var quitBtn: ActionRoundedButton!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<ResultEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler?.handleEvent(.showResult)
    }
    
    // MARK: - Action methods -

    @IBAction func didClickQuit(_ sender: UIButton) {
        eventHandler?.handleEvent(.triggerDone)
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: ResultState) {
        titleLbl.text = state.title
        descriptionLbl.text = state.description
        resultImage.image = state.image
        quitBtn.setAppearance(.primary, colors: colors)
        quitBtn.setTitle(Localizable.Common.quit, for: .normal)
    }

}

