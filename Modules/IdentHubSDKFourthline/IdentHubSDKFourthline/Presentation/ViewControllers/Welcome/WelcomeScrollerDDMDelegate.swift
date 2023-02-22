//
//  WelcomeScrollerDDMDelegate.swift
//  IdentHubSDKFourthline
//

import UIKit

/// Welcome scroller data display manager delegate
/// Used for updating number of the visible page
protocol WelcomeScrollerDDMDelegate: AnyObject {

    /// Update display data on the opened page
    /// - Parameter page: number of opened page
    func didMovedToPage(_ page: Int)
}

/// Class used as datasource and delegate of the welcome page scroller component
final internal class WelcomeScrollerDDM: NSObject, UICollectionViewDataSource {

    // MARK: - Properties -
    private var content: [WelcomePageContent]?
    private weak var delegate: WelcomeScrollerDDMDelegate?

    /// Init main properties of the class
    /// - Parameters:
    ///   - content: array with displayed content objects
    ///   - delegate: object conforms delegate methods
    convenience init(_ content: [WelcomePageContent], delegate: WelcomeScrollerDDMDelegate) {
        self.init()

        self.content = content
        self.delegate = delegate
    }

    // MARK: - Collection View datasource methods -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "welcomePageCellID", for: indexPath as IndexPath) as? WelcomePageCell

        cell?.backgroundColor = .clear

        if let data = content?[indexPath.row] {
            cell?.configureScreen(data)
        }

        return cell ?? UICollectionViewCell()
    }
}

extension WelcomeScrollerDDM: UICollectionViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = ceil(scrollView.contentOffset.x / scrollView.bounds.width)
        delegate?.didMovedToPage(Int(pageNumber))
    }
}

extension WelcomeScrollerDDM: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
