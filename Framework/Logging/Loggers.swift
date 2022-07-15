//
//  Loggers.swift
//  IdentHubSDK
//

// TODO: Move loggers to appropriate modules

/// Logger related to navigation events
internal let navLog = SBLog.standard.withCategory(.nav)
/// Logger related to KYCInfo data processing
internal let kycLog = SBLog.standard.withCategory(.other("KYC"))
/// Logger related to InitialIdentificationCoordinator
internal let identLog = SBLog.standard.withCategory(.other("IDENT"))
/// Logger related to FourthlineIdentCoordinator
internal let fourthlineLog = SBLog.standard.withCategory(.other("FOURTHLINE"))
/// Logger related to BankIdCoordinator
internal let bankLog = SBLog.standard.withCategory(.other("BANK"))
/// Logger related to backend API requests events
internal let apiLog = SBLog.standard.withCategory(.api)
