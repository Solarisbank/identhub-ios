//
//  ModuleFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public class ModuleFactoryMock: ModuleFactory {
    
    public var coreMock: CoreCoordinatorFactoryMock?
    public var qesMock: QESCoordinatorFactoryMock?
    public var bankMock: BankCoordinatorFactoryMock?
    public var fourthlineMock: FourthlineCoordinatorFactoryMock?
    
    public init() {}
    
    public func makeCore(serviceLocator: ModuleServiceLocator) -> CoreCoordinatorFactory? {
        coreMock
    }

    public func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory? {
        qesMock
    }

    public func makeBank(serviceLocator: ModuleServiceLocator) -> BankCoordinatorFactory? {
        bankMock
    }
    
    public func makeFourthline(serviceLocator: ModuleServiceLocator) -> FourthlineCoordinatorFactory? {
        fourthlineMock
    }
}
