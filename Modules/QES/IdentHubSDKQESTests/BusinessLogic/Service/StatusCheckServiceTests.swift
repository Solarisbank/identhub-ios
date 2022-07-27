//
//  StatusCheckServiceTests.swift
//  IdentHubSDKQESTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore
import IdentHubSDKTestBase

final class StatusCheckServiceTests: XCTestCase {
    private let uid = "c4bd19319a6f4b258c03687be2773a14avi"
    
    private var verificationService: VerificationServiceMock!
    private var timerFactory: TimerFactoryMock!
    
    override func setUp() {
        super.setUp()
        
        verificationService = VerificationServiceMock()
        timerFactory = TimerFactoryMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        verificationService = nil
        timerFactory = nil
    }
    
    // MARK: - setupNewCodeTimer
    
    func test_setupNewCodeTimer_callsTimerFactory() {
        let sut = makeSut()
        
        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { interval, repeats, _ in
                XCTAssertEqual(interval, 1.0)
                XCTAssertTrue(repeats)
                
                expectation.fulfill()
                
                return TimerMock(tickCount: 1) { _ in }
            }
            
            sut.setupNewCodeTimer { _ in }
        }
    }
    
    func test_setupNewCodeTimer_callsCallbackWithExpectedValue() {
        let expectedValue = 10
        
        let sut = makeSut(newCodeTimout: expectedValue)
        
        assertAsync { expectation in
            sut.setupNewCodeTimer { value in
                XCTAssertEqual(value, expectedValue)
                expectation.fulfill()
            }
        }
    }
    
    func test_setupNewCodeTimer_timerIsCalledMultipleTimes_callsCallbackWithExpectedValues_invalidatesTimer() {
        let expectedCallbackCount = 10
        var expectedCallbackValue = 10
        var timer: TimerMock?
        
        let sut = makeSut(newCodeTimout: expectedCallbackCount)
        
        assertAsync { expectation in
            expectation.expectedFulfillmentCount = expectedCallbackCount + 1
            
            timerFactory.scheduledTimerReturnClosure = { _, _, block in
                timer = TimerMock(tickCount: UInt(expectedCallbackCount + 10), completion: block)
                
                return timer!
            }
            
            sut.setupNewCodeTimer { value in
                XCTAssertEqual(value, expectedCallbackValue)
                
                expectedCallbackValue -= 1
                
                expectation.fulfill()
            }
        }
        
        XCTAssertTrue(timer?.isInvalidated ?? false)
    }
    
    // MARK: - setupStatusVerificationTimer
    
    func test_setupStatusVerificationTimer_callsTimerFactory() {
        let sut = makeSut()

        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { interval, repeats, _ in
                XCTAssertEqual(interval, 3.0)
                XCTAssertTrue(repeats)
                
                expectation.fulfill()
                
                return TimerMock(tickCount: 1) { _ in }
            }
            
            sut.setupStatusVerificationTimer(identificationUID: uid) { _ in }
        }
    }
    
    func test_setupStatusVerificationTimer_timerTicks_callsVerificationService() {
        let sut = makeSut()
        
        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { _, _, block in
                return TimerMock(tickCount: 1) { timer in
                    block(timer)
                    
                    expectation.fulfill()
                }
            }
            
            sut.setupStatusVerificationTimer(identificationUID: uid) { _ in }
        }
        
        XCTAssertEqual(verificationService.getIdentificationCallsCount, 1)
        XCTAssertEqual(verificationService.getIdentificationArguments.last?.identificationUID, uid)
    }
    
    func test_setupStatusVerificationTimer_timerTicks_responseStatusIsSuccess_callsCallback_invalidatesTimer() {
        let expectedId = "Identification_id"
        var timer: TimerMock?
        let sut = makeSut()
        
        verificationService.getIdentificationResult = .success(.mock(id: expectedId, status: .success))
        
        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { _, _, block in
                timer = TimerMock(tickCount: 2, completion: block)
                
                return timer!
            }
            
            sut.setupStatusVerificationTimer(identificationUID: uid) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedId)
                
                self.verificationService.getIdentificationResult = .success(.mock(status: .success))
                
                expectation.fulfill()
            }
        }
        
        XCTAssertTrue(timer?.isInvalidated ?? false)
    }
    
    func test_setupStatusVerificationTimer_timerTicks_responseStatusIsConfirmed_callsCallback_invalidatesTimer() {
        let expectedId = "token"
        var timer: TimerMock?
        let sut = makeSut()
        
        verificationService.getIdentificationResult = .success(.mock(id: expectedId, status: .confirmed))
        
        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { _, _, block in
                timer = TimerMock(tickCount: 2, completion: block)
                
                return timer!
            }
            
            sut.setupStatusVerificationTimer(identificationUID: uid) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedId)
                
                expectation.fulfill()
            }
        }
        
        XCTAssertTrue(timer?.isInvalidated ?? false)
    }
    
    func test_setupStatusVerificationTimer_timerTicks_responseStatusIsOtherThanConfirmedOrSuccess_callsCallback_invalidatesTimer() {
        let expectedError = APIError.authorizationFailed
        let statuses = Status.allCases.filter { $0 != .confirmed && $0 != .success }
                
        statuses.forEach { status in
            var timer: TimerMock?
            let sut = makeSut()
            
            verificationService.getIdentificationResult = .success(.mock(status: status))
            
            assertAsync { expectation in
                timerFactory.scheduledTimerReturnClosure = { _, _, block in
                    timer = TimerMock(tickCount: 2, completion: block)
                    
                    return timer!
                }
                
                sut.setupStatusVerificationTimer(identificationUID: uid) { result in
                    XCTAssertResultIsFailure(result, expectedError: expectedError)
                    
                    expectation.fulfill()
                }
            }
            
            XCTAssertTrue(timer?.isInvalidated ?? false)
        }
    }
    
    func test_setupStatusVerificationTimer_timerTicks_resultIsFailure_callsCallback_invalidatesTimer() {
        let expectedError = APIError.unknownError
        var timer: TimerMock?
        let sut = makeSut()
        
        verificationService.getIdentificationResult = .failure(.init(.unknownError))
        
        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { _, _, block in
                timer = TimerMock(tickCount: 2, completion: block)
                
                return timer!
            }
            
            sut.setupStatusVerificationTimer(identificationUID: uid) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
        
        XCTAssertTrue(timer?.isInvalidated ?? false)
    }
    
    // MARK: - invalidateNewCodeTimer
    
    func test_invalidateNewCodeTimer_invalidatesCreatedTimer() {
        var timer: TimerMock?
        let sut = makeSut()
        
        assertAsync { expectation in
            timerFactory.scheduledTimerReturnClosure = { _, _, _ in
                timer = TimerMock(tickCount: 2, completion: { _ in })
                
                return timer!
            }
            
            sut.setupNewCodeTimer { _ in
                expectation.fulfill()
            }
        }
        
        XCTAssertFalse(timer?.isInvalidated ?? true)
        
        sut.invalidateNewCodeTimer()
        
        XCTAssertTrue(timer?.isInvalidated ?? false)
    }
    
    // MARK: - deinit
    
    func test_sutIsDeinitialized_timersAreInvalidated() {
        var timers: [TimerMock] = []
        var sut: StatusCheckServiceImpl? = makeSut()
        
        timerFactory.scheduledTimerReturnClosure = { _, _, _ in
            let timer = TimerMock(tickCount: 0, completion: { _ in })
            
            timers.append(timer)
            
            return timer
        }
        
        sut?.setupNewCodeTimer { _ in }
        sut?.setupStatusVerificationTimer(identificationUID: uid) { _ in }
        
        sut = nil
        
        XCTAssertEqual(timers.count, 2)
        
        timers.forEach { timer in
            XCTAssertTrue(timer.isInvalidated)
        }
    }
    
    private func makeSut(newCodeTimout: Int = 2) -> StatusCheckServiceImpl {
        let service = StatusCheckServiceImpl(
            verificationService: verificationService,
            newCodeTimeout: newCodeTimout,
            timerFactory: timerFactory
        )
        
        trackForMemoryLeaks(service)
        
        return service
    }
}
