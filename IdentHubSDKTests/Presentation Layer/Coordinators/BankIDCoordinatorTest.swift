//
//  BankIDCoordinatorTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore
import IdentHubSDKTestBase

class BankIDCoordinatorTest: BaseTestCase {

    var bankIDCoordinator: BankIDCoordinator?
    var presenter: RouterMock!
    
    override func setUpWithError() throws {
        resetStorage()
        let appDependencies = AppDependencies(sessionToken: "", presenter: PresenterMock())
        presenter = RouterMock()
        self.bankIDCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: self.presenter)
    }

    func testPerformUnspecifiedStep() throws {
        
        /// If the coordinator is called with a step of type .unspecified:
        /// - check that the result handler gets called with the correct failure step
        /// - check that the presenter is dismissed
        
        let presenterExpectation = XCTestExpectation(description: "Presenter is dismissed")
        presenter.closure = {
            presenterExpectation.fulfill()
        }

        let resultExpectation = XCTestExpectation(description: "Result handler gets called")
        bankIDCoordinator?.perform(step: .unspecified) { result in
            guard case .failure(let apiError) = result else {
                return XCTFail("Expected to be a failure but got a success with \(result)")
            }
            
            if case .unsupportedResponse = apiError {} else {
                XCTFail("Expected unsupportedResponse but got \(apiError)")
            }
            resultExpectation.fulfill()
        }
        
        wait(for: [resultExpectation, presenterExpectation], timeout: 1.0)
    }
    
    func testPerformPartnerFallbackStep() throws {
        let presenterExpectation = XCTestExpectation(description: "Presenter is dismissed")
        presenter.closure = {
            presenterExpectation.fulfill()
        }

        let resultExpectation = XCTestExpectation(description: "Result handler gets called")
        bankIDCoordinator?.perform(step: .partnerFallback) { result in
            guard case .failure(let apiError) = result else {
                return XCTFail("Expected to be a failure but got a success with \(result)")
            }
            
            if case .identificationNotPossible = apiError {} else {
                XCTFail("Expected identificationNotPossible but got \(apiError)")
            }
            resultExpectation.fulfill()
        }
        
        wait(for: [resultExpectation, presenterExpectation], timeout: 1.0)
    }

}

class RouterMock: Router {
    var closure: (() -> Void)?

    var navigationController: UINavigationController
    var rootViewController: UIViewController?
    var topShowable: Showable { rootViewController ?? navigationController }

    init() {
        navigationController = UINavigationController()
    }
    
    func dismissModule(animated: Bool, completion: (() -> Void)?) {
        closure?()
    }
    
    func present(_ module: Showable, animated: Bool) {}
    func push(_ module: Showable, animated: Bool, completion: (() -> Void)?) {}
    func pop(animated: Bool) {}
    
    func pop(_ showable: Showable, animated: Bool) { }
}
