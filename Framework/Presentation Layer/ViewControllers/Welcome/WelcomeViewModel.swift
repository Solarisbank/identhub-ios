//
//  WelcomeViewModel.swift
//  IdentHubSDK
//

import UIKit

/// Welcome screen view model class
/// Class used for preparing displaying data, connect UI components with adapter and DDM
final internal class WelcomeViewModel {

    // MARK: - Properties -
    private var flowCoordinator: FourthlineIdentCoordinator
    private var pageScrollerDDM: WelcomeScrollerDDM?
    private var scrollerContent: [WelcomePageContent]
    private var pageController: UIPageControl?
    private var logoAnimator: WelcomeLogoAnimator?
    private var identificationMethod: IdentificationStep?

    // MARK: - Init -

    /// Init method with flow coordinator
    /// - Parameter flowCoordinator: identification process flow coordinator
    init(flowCoordinator: FourthlineIdentCoordinator, identMethod: IdentificationStep) {
        self.flowCoordinator = flowCoordinator
        self.identificationMethod = identMethod
        self.scrollerContent = WelcomeViewModel.configureContent()
    }

    // MARK: - Public methods -

    /// Method configured welcome page scroller compoent. Set default UI parameters and assigned datasource and delegate object
    /// Also method initialized DDM object used as DDM
    /// - Parameter pageScroller: UICollectionView object used as page scroll component
    func configurePageScroller(_ pageScroller: UICollectionView) {
        let cellNib = UINib(nibName: "WelcomePageCell", bundle: Bundle(for: WelcomeViewModel.self))
        pageScroller.register(cellNib, forCellWithReuseIdentifier: "welcomePageCellID")
        pageScroller.backgroundView = nil
        pageScroller.backgroundColor = .clear

        pageScrollerDDM = WelcomeScrollerDDM(scrollerContent, delegate: self)

        pageScroller.dataSource = pageScrollerDDM
        pageScroller.delegate = pageScrollerDDM
    }

    /// Set page controller component for updating dots on screen
    /// - Parameter pageController: controller component used as opened page indicator
    func setPageController(_ pageController: UIPageControl) {
        self.pageController = pageController
    }

    /// Sets welcome page logos animator object.
    /// Also starts first logo animation with after 150 miliseconds
    /// - Parameter animator: logo animator used updating logo images and animate them
    func setLogoAnimator(_ animator: WelcomeLogoAnimator) {
        self.logoAnimator = animator

        DispatchQueue.main.asyncAfter(deadline: 200.milliseconds.fromNow) { [weak self] in
            if let pageData = self?.scrollerContent.first {
                self?.logoAnimator?.updateImageData(pageData)
            }
        }
    }

    func didTriggerStart() {
        if identificationMethod == .fourthline || identificationMethod == .fourthlineSigning {
            flowCoordinator.perform(action: .documentPicker)
        } else {
            flowCoordinator.perform(action: .fetchData)
        }
    }

    // MARK: - Internal methods -

    /// Method initialized welcome screen display content
    /// - Returns: array with fulfill content objects
    static func configureContent() -> [WelcomePageContent] {

        let cameraPage = WelcomePageContent(title: Localizable.Welcome.cameraTitle, description: Localizable.Welcome.cameraDesc, pageLogoName: "face", type: .camera, pageLogoFrameName: "camera_frame")

        let documentPage = WelcomePageContent(title: Localizable.Welcome.documentTitle, description: Localizable.Welcome.documentDesc, pageLogoName: "document_icon", type: .document, pageLogoFrameName: "camera_frame")

        let locationPage = WelcomePageContent(title: Localizable.Welcome.locationTitle, description: Localizable.Welcome.locationDesc, pageLogoName: "pin_map", type: .location, pageLogoFrameName: nil)

        return [
            documentPage,
            cameraPage,
            locationPage
        ]
    }
}

extension WelcomeViewModel: WelcomeScrollerDDMDelegate {

    func didMovedToPage(_ page: Int) {
        pageController?.currentPage = page

        logoAnimator?.updateImageData(scrollerContent[page])
    }
}
