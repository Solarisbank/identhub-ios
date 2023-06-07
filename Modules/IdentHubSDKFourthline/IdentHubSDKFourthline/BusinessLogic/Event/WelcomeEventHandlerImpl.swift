//
//  WelcomeEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore

internal enum WelcomeOutput: Equatable {
    case nextStep(nextStep: FourthlineStep)
}

internal struct WelcomeInput {
    var identificationStep: IdentificationStep?
    let isDisplayNamirialTerms: Bool
}

// MARK: - Welcome events logic -

typealias WelcomeCallback = (WelcomeOutput) -> Void

final internal class WelcomeEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<WelcomeEvent>, ViewController.ViewState == WelcomeState {
    
    weak var updatableView: ViewController?
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: WelcomeState
    private var input: WelcomeInput
    private var callback: WelcomeCallback
    
    private var pageScrollerDDM: WelcomeScrollerDDM?
    private var scrollerContent: [WelcomePageContent]
    private var pageController: UIPageControl?
    private var logoAnimator: WelcomeLogoAnimator?
    
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: WelcomeInput,
        callback: @escaping WelcomeCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.callback = callback
        self.state = WelcomeState(isDisplayNamirialTerms: input.isDisplayNamirialTerms)
        self.scrollerContent = WelcomeEventHandlerImpl.configureContent()
    }
    
    func handleEvent(_ event: WelcomeEvent) {
        switch event {
        case .loadScreen:
            updateState { state in
                state.state = .loadScreen
            }
        case .triggerStart:
            if state.isDisplayNamirialTerms {
                updateState { state in
                    state.state = .namirialTCAccepted
                }
                acceptNamirialTermsConditions()
            } else {
                didTriggerStart()
            }
        case .configurePageScroller(let pageScroller):
            configurePageScroller(pageScroller)
        case .setPageController(let pageController):
            setPageController(pageController)
        case .setLogoAnimator(let animator):
            setLogoAnimator(animator)
        case .close(let error):
            self.callback(.nextStep(nextStep: .close(error: error)))
        }
    }
    
    private func acceptNamirialTermsConditions() {
        let documentid = KYCContainer.shared.getNamirialTermsConditions()?.documentid ?? ""
        verificationService.acceptNamirialTermsConditions(documentid: documentid, completionHandler: { [weak self] result in
            guard let self = self else { return }
            self.updateState { state in
                state.state = .none
            }
            switch result {
            case .success(_):
                self.didTriggerStart()
            case .failure(let error):
                self.updateState { state in
                    state.state = .error
                    state.onDisplayError = error
                }
                fourthlineLog.warn("Accept Namirial Terms and Conditions failure")
            }
        })
    }
    
    private func updateState(_ update: @escaping (inout WelcomeState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    // MARK: - Internal methods -
    
    private func didTriggerStart() {
        if input.identificationStep == .fourthline || input.identificationStep == .fourthlineSigning {
            callback(.nextStep(nextStep: .documentPicker))
        } else { /// In BankIdent+ first fetch user data -> Document Picker
            callback(.nextStep(nextStep: .fetchData))
        }
    }
    
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
    
    // MARK: - Public methods -
    
    /// Method configured welcome page scroller compoent. Set default UI parameters and assigned datasource and delegate object
    /// Also method initialized DDM object used as DDM
    /// - Parameter pageScroller: UICollectionView object used as page scroll component
    func configurePageScroller(_ pageScroller: UICollectionView) {
        let cellNib = UINib(nibName: "WelcomePageCell", bundle: Bundle(for: WelcomeEventHandlerImpl.self))
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
    
}

extension WelcomeEventHandlerImpl: WelcomeScrollerDDMDelegate {
    
    func didMovedToPage(_ page: Int) {
        pageController?.currentPage = page
        logoAnimator?.updateImageData(scrollerContent[page])
    }
}
