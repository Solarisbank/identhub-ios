//
//  QuitPopUpViewController.swift
//  IdentHubSDK
//

import UIKit

/// PopUpWindowViewController which displays quit flow.
public final class QuitPopUpViewController: PopUpWindowViewController {

    /// Quit action.
    public var quitAction: (() -> Void)?

    /// Cancel action
    public var cancelAction: (() -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(Localizable.Quiting.title)
        setDescription(Localizable.Quiting.description)
        setPrimaryButtonTitle(Localizable.Common.quit)
        setPrimaryButtonAction { [weak self] in
            self?.quitAction?()
        }
        setSecondaryButtonTitle(Localizable.Quiting.stay)
        setSecondaryButtonAction { [weak self] in
            self?.cancelAction?()
            self?.dismiss(animated: false)
        }
    }
}
