//
//  StoredKeys.swift
//  IdentHubSDKCore
//

import UIKit

/// UserDefaults stored keys
public enum StoredKeys: String {

    /// Stored initial step in UserDefaults string key
    case initialStep = "InitialSessionStepKey"

    /// Stored identification session method type key
    case identMethod = "IdentificationSessionMethodKey"

    /// Session token key
    case token = "SessionTokenKey"

    /// Mobile number of the identification user key
    case mobileNumber = "UserMobileNumberKey"

    /// Session identification value key
    case identUID = "IdentificationUIDKey"

    /// Session identification path value key
    case identPath = "IdentificationSessionPathKey"

    /// Fallback session identification path value key
    case identStep = "IdentificationSessionStepKey"

    /// Fallback session identification path value key
    case fallbackIdentStep = "FallbackIdentificationSessionStepKey"

    /// Retries IBAN registration amount
    case retriesCount = "IdentRetriesCountKey"

    /// Accepted state of the "Terms and Conditions" agreement
    case acceptedTC = "TermsAndConditionsAcceptedKey"

    /// Status of the phone verification
    case phoneVerified = "PhoneVerificationStatusKey"
    
    /// Accepted state of the "Terms and Conditions" agreement
    case performedTCAcceptance = "PerfomedTermsAndConditionsAcceptanceKey"

    /// Status of the phone verification
    case performedPhoneVerification = "PerformedPhoneVerificationKey"

    /// Personal data value key
    case personData = "IndentificationPersonDataKey"

    /// Fourthline provider data key
    case providerData = "FourthlineProviderDataKey"

    /// Device IP-address data key
    case ipAddressData = "IPAddressDataKey"

    /// Prepare users data
    case fetchDataStep = "FetchPersonDataProcessKey"

    /// Identification UI colors
    case styleColors = "IdentificationUIColorsKey"
    
    /// Remote logging value
    case remoteLogging = "RemoteLogging"
    
    /// Stored Core step
    case coreScreensStep = "CoreScreensStep"
    
    /// BankID identification session process step value key
    case bankIDStep = "BankIDIdentificationStepKey"
    
    /// Stored FourthlineStep step
    case fourthlineStep = "FourthlineScreensStep"
    
    /// Style colors keys enumeration
    public enum StyleColor: String {

        case primary = "PrimaryLightColorKey"

        case primaryDark = "PrimaryDarkColorKey"

        case secondary = "SecondaryLightColorKey"
    }
}
