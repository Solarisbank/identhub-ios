//
//  DocumentTypeCell.swift
//  IdentHubSDK
//

import UIKit

class DocumentTypeCell: UITableViewCell {

    // MARK: - Properties -
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var selectStateImage: UIImageView!
    @IBOutlet var documentName: UILabel!
    @IBOutlet var documentLogo: UIImageView!

    // MARK: - Public methods -

    func configureCell(with data: ScanDocumentType) {
        documentName.text = data.name
        documentLogo.image = data.logo

        contentView.backgroundColor = .clear
        backgroundColor = .clear
        backgroundView = nil
    }

    // MARK: - Override methods -

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let alpha: CGFloat = selected ? 1 : 0.5

        UIView.animate(withDuration: 0.4) {[weak self] in
            guard let `self` = self else { return }

            self.selectStateImage.isHighlighted = selected
            self.documentName.alpha = alpha
            self.documentLogo.alpha = alpha
            self.viewContainer.alpha = selected ? 1 : 0.75
        }
    }
}
