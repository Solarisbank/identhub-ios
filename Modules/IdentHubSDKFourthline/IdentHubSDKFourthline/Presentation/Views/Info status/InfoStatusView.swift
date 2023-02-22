//
//  InfoStatusView.swift
//  IdentHubSDKFourthline
//

import UIKit

final class InfoStatusView: UIView {

    enum InfoStatus {
        case success
        case loading
        case error
    }

    // MARK: - Properties -
    @IBOutlet var contentView: UIView!
    @IBOutlet var statusImage: UIImageView!
    @IBOutlet var statusIndicator: UIActivityIndicatorView!
    @IBOutlet var statusDescription: UILabel!
    @IBOutlet var statusTitle: UILabel!

    var status: InfoStatus = InfoStatus.success {
        didSet {
            satusViewUpdate()
        }
    }

    // MARK: - Init methods -

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Public methods -

    /// Method activated indicator animation and updates title and description labels
    /// - Parameters:
    ///   - title: text of the status title
    ///   - description: text of the status description
    ///   -
    func didUpdateStatus(_ title: String, description: String, status: InfoStatus) {

        self.status = status
        statusTitle.text = title
        statusDescription.text = description
    }

    func setDescriptionText(_ text: String) {
        statusDescription.text = text
    }

    // MARK: - Internal methods -

    private func setup() {

        Bundle(for: Self.self).loadNibNamed("InfoStatusView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds

        status = .loading
    }

    private func satusViewUpdate() {
        UIView.animate(withDuration: 0.4) {[weak self] in

            self?.statusImage.image = self?.status.image
            self?.status == .loading ? self?.statusIndicator.startAnimating() : self?.statusIndicator.stopAnimating()
        }
    }
}

fileprivate extension InfoStatusView.InfoStatus {

    var image: UIImage? {
        switch self {
        case .success:
            return UIImage(named: "info_success_icon", in: Bundle(for: InfoStatusView.self), compatibleWith: nil)
        case .error:
            return UIImage(named: "error_icon", in: Bundle(for: InfoStatusView.self), compatibleWith: nil)
        default:
            return nil
        }
    }
}
