//
//  ModuleFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public class ModuleFactoryMock: ModuleFactory {
    
    public var coreMock: CoreCoordinatorFactoryMock?
    public var qesMock: QESCoordinatorFactoryMock?
    public var bankMock: BankCoordinatorFactoryMock?
    
    public init() {}
    
    public func makeCore(serviceLocator: IdentHubSDKCore.ModuleServiceLocator) -> IdentHubSDKCore.CoreCoordinatorFactory? {
        coreMock
    }

    public func makeQES(serviceLocator: ModuleServiceLocator) -> QESCoordinatorFactory? {
        qesMock
    }

    public func makeBank(serviceLocator: IdentHubSDKCore.ModuleServiceLocator) -> IdentHubSDKCore.BankCoordinatorFactory? {
        bankMock
    }
}
