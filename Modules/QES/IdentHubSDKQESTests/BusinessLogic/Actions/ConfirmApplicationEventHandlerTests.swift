//
//  ConfirmApplicationEventHandlerTests.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
@testable import IdentHubSDKCore
import XCTest
import IdentHubSDKTestBase

final class ConfirmApplicationEventHandlerTests: XCTestCase {
    private var verificationService: VerificationServiceMock!
    private var documentExporter: DocumentExporterMock!
    private var alertsService: AlertsServiceMock!
    
    private let identificationUID = "identification_uid"
    
    override func setUp() {
        super.setUp()
        
        verificationService = VerificationServiceMock()
        documentExporter = DocumentExporterMock()
        alertsService = AlertsServiceMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        verificationService = nil
        documentExporter = nil
        alertsService = nil
    }
    
    func test_perform_updatesViewWithExpectedState() {
        let input = ConfirmApplicationInput(identificationUID: "identification_uid")
        let expectedState = ConfirmApplicationState(
            hasQuitButton: true,
            documents: [],
            hasTermsAndConditionsLink: true
        )
        
        assertAsync { expectation in
            expectation.isInverted = true
            
            let showable = makeShowableWithSut(input: input) { _ in
                expectation.fulfill()
            }

            XCTAssertNotNil(showable.eventHandler)
            XCTAssertEqual(showable.updateViewCallsCount, 1)
            XCTAssertEqual(showable.updateViewArguments.last, expectedState)
        }
    }
    
    // MARK: - loadDocuments
    
    func test_loadDocuments_completesWithFailure_callsGetIdentification_doesNotUpdateState() throws {
        let input = ConfirmApplicationInput(identificationUID: identificationUID)
        
        let showable = makeShowableWithSut(input: input)
        
        showable.eventHandler?.handleEvent(.loadDocuments)
        
        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            expectation.isInverted = true

            showable.updateViewCompletion = {
                expectation.fulfill()
            }
            
            getIdentificationCompletion(.failure(ResponseError(.unauthorizedAction)))
        }
    }
    
    func test_loadDocuments_completesWithSuccessWithNoDocuments_callsGetIndentification_doesNotUpdateState() throws {
        let input = ConfirmApplicationInput(identificationUID: identificationUID)
        
        let showable = makeShowableWithSut(input: input)
        
        showable.eventHandler?.handleEvent(.loadDocuments)

        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            expectation.isInverted = true
            
            showable.updateViewCompletion = {
                expectation.fulfill()
            }
            
            getIdentificationCompletion(.success(Identification.mock(documents: nil)))
        }
    }
    
    func test_loadDocuments_completesWithSuccessWithEmptyDocuments_callsGetIndentification_updatesState() throws {
        let input = ConfirmApplicationInput(identificationUID: identificationUID)
        let expectedState = ConfirmApplicationState(
            hasQuitButton: true,
            documents: [],
            hasTermsAndConditionsLink: true
        )
        
        let showable = makeShowableWithSut(input: input)

        showable.eventHandler?.handleEvent(.loadDocuments)

        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            showable.updateViewCompletion = { [weak showable] in
                XCTAssertEqual(showable?.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            getIdentificationCompletion(.success(Identification.mock(documents: [])))
        }
    }
    
    func test_loadDocuments_completesWithSuccessWithSomeDocuments_callsGetIdentification_updatesState() throws {
        let input = ConfirmApplicationInput(identificationUID: identificationUID)
        let expectedDocuments: [ContractDocument] = [
            .mock(id: "first"),
            .mock(id: "second")
        ]
        let expectedState = ConfirmApplicationState(
            hasQuitButton: true,
            documents: expectedDocuments.map { LoadableDocument(isLoading: false, document: $0) },
            hasTermsAndConditionsLink: true
        )
        
        let showable = makeShowableWithSut(input: input)

        showable.eventHandler?.handleEvent(.loadDocuments)

        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, identificationUID)
        
        let getIdentificationCompletion = try XCTUnwrap(verificationService.getIdentificationArguments.last?.completionHandler)
        
        assertAsync { expectation in
            showable.updateViewCompletion = { [weak showable] in
                XCTAssertEqual(showable?.updateViewArguments.last, expectedState)
                
                expectation.fulfill()
            }

            getIdentificationCompletion(.success(Identification.mock(documents: expectedDocuments)))
        }
    }
    
    // MARK: - quit
    
    func test_quit_callsCallbackWithExpectedResult() {
        let input = ConfirmApplicationInput(identificationUID: identificationUID)
        
        assertAsync { expectation in
            let showable = makeShowableWithSut(input: input) { result in
                XCTAssertEqual(result, .quit)
                
                expectation.fulfill()
            }
            
            showable.eventHandler?.handleEvent(.quit)
        }
    }
    
    // MARK: - signDocuments
    
    func test_signDocuments_callsCallbackWithExpectedResult() {
        let input = ConfirmApplicationInput(identificationUID: identificationUID)
        
        assertAsync { expectation in
            let showable = makeShowableWithSut(input: input) { result in
                XCTAssertEqual(result, .confirmedApplication)
                
                expectation.fulfill()
            }
            
            showable.eventHandler?.handleEvent(.signDocuments)
        }
    }
    
    // MARK: - downloadDocument
    
    func test_downloadDocument_completesWithSuccess_callsDownloadAndSaveDocument_callsPresentExporter() throws {
        let expectedUrl = URL(string: "https://solarisbank.de")!
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationInput(identificationUID: identificationUID)

        let showable = makeShowableWithSut(input: input)

        showable.eventHandler?.handleEvent(.loadDocuments)
        
        verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
        
        showable.eventHandler?.handleEvent(.downloadDocument(withId: documentId))
        
        XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
        XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                
        let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
        
        downloadAndSaveCompletion(.success(expectedUrl))

        assertOnMainThread {
            XCTAssertEqual(self.documentExporter.presentExporterCallsCount, 1)
            XCTAssertEqual(self.documentExporter.presentExporterArguments.last?.documentURL, expectedUrl)
        }

        self.documentExporter.clear()
    }
    
    func test_downloadDocument_completesWithFailure_callsDownloadAndSaveDocument_doesNotCallPresentExporter() throws {
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationInput(identificationUID: identificationUID)

        let showable = makeShowableWithSut(input: input)

        showable.eventHandler?.handleEvent(.loadDocuments)

        verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
        
        showable.eventHandler?.handleEvent(.downloadDocument(withId: documentId))
        
        XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
        XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                
        let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
        
        downloadAndSaveCompletion(.failure(.fileDownloadError(NSError.mock)))

        assertOnMainThread {
            XCTAssertEqual(self.documentExporter.presentExporterCallsCount, 0)
            XCTAssertEqual(self.alertsService.presentAlertCallsCount, 1)
            XCTAssertEqual(
                self.alertsService.presentAlertLastArguments?.title,
                Localizable.SignDocuments.ConfirmApplication.documentFetchErrorTitle
            )

            XCTAssertEqual(
                self.alertsService.presentAlertLastArguments?.message,
                String(format: Localizable.SignDocuments.ConfirmApplication.documentFetchErrorMessage, document.name)
            )
        }
    }
    
    // MARK: - previewDocument
    
    func test_previewDocument_completesWithSuccess_callsDownloadAndSaveDocument_callsPresentPreviewer() throws {
        let expectedUrl = URL(string: "https://solarisbank.de")!
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationInput(identificationUID: "identification_uid")

        let showable = makeShowableWithSut(input: input)

        showable.eventHandler?.handleEvent(.loadDocuments)
        
        verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
        
        showable.eventHandler?.handleEvent(.previewDocument(withId: documentId))
        
        XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
        XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                
        let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
        
        downloadAndSaveCompletion(.success(expectedUrl))
        
        assertOnMainThread {
            XCTAssertEqual(self.documentExporter.presentPreviewerCallsCount, 1)
            XCTAssertEqual(self.documentExporter.presentPreviewerArguments.last?.documentURL, expectedUrl)
        }

        self.documentExporter.clear()
    }
    
    func test_previewDocument_completesWithFailure_callsDownloadAndSaveDocument_doesNotCallPresentPreviewer() throws {
        let documentId = "documentId"
        let document = ContractDocument.mock(id: documentId)
        let identification = Identification.mock(documents: [document])
        let input = ConfirmApplicationInput(identificationUID: "identification_uid")

        let showable = makeShowableWithSut(input: input)
        showable.eventHandler?.handleEvent(.loadDocuments)
        
        verificationService.getIdentificationArguments.last?.completionHandler(.success(identification))
        
        showable.eventHandler?.handleEvent(.previewDocument(withId: documentId))
        
        XCTAssertEqual(verificationService.downloadAndSaveDocumentCallsCount, 1)
        XCTAssertEqual(verificationService.downloadAndSaveDocumentArguments.last?.id, documentId)
                
        let downloadAndSaveCompletion = try XCTUnwrap(verificationService.downloadAndSaveDocumentArguments.last?.completion)
        
        downloadAndSaveCompletion(.failure(.fileDownloadError(NSError.mock)))

        assertOnMainThread {
            XCTAssertEqual(self.documentExporter.presentPreviewerCallsCount, 0)
            XCTAssertEqual(self.alertsService.presentAlertCallsCount, 1)
            XCTAssertEqual(
                self.alertsService.presentAlertLastArguments?.title,
                Localizable.SignDocuments.ConfirmApplication.documentFetchErrorTitle
            )

            XCTAssertEqual(
                self.alertsService.presentAlertLastArguments?.message,
                String(format: Localizable.SignDocuments.ConfirmApplication.documentFetchErrorMessage, document.name)
            )

        }
    }
    
    private func makeShowableWithSut(input: ConfirmApplicationInput, callback: @escaping ConfirmApplicationCallback = { _ in }) -> UpdateableShowableMock {
        let sut = ConfirmApplicationEventHandlerImpl<UpdateableShowableMock>(
            verificationService: verificationService,
            alertsService: alertsService,
            documentExporter: documentExporter,
            input: input,
            callback: callback
        )
        let showable = UpdateableShowableMock()
        showable.eventHandler = sut.asAnyEventHandler()
        sut.updatableView = showable
        
        trackForMemoryLeaks(showable)
        trackForMemoryLeaks(sut)

        return showable
    }
}

private class UpdateableShowableMock: UpdateableShowable {
    var eventHandler: AnyEventHandler<ConfirmApplicationEvent>?

    var toShowableCallsCount = 0
    var toShowableReturnValue = UIViewController()
    
    var updateViewCallsCount = 0
    var updateViewArguments: [ConfirmApplicationState] = []
    var updateViewCompletion: (() -> Void)?
    
    func toShowable() -> UIViewController {
        toShowableCallsCount += 1
        
        return toShowableReturnValue
    }
    
    func updateView(_ state: ConfirmApplicationState) {
        updateViewCallsCount += 1
        
        updateViewArguments.append(state)
        
        updateViewCompletion?()
    }
}
