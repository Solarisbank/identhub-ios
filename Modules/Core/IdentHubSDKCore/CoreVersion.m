//
//  CoreVersionNumber.c
//  IdentHubSDKCore
//

#import <IdentHubSDKCore/IdentHubSDKCore-Swift.h>

#define PROCESSOR_STRING(x) PRE_PROCESSOR_STRING_LITERAL(x)
#define PRE_PROCESSOR_STRING_LITERAL(x) @#x

@interface CoreVersion(version)
@property (class) NSString *marketingVersion; // to access internal property
@end

@interface CoreVersionLoader: NSObject
@end

@implementation CoreVersionLoader

+ (void)load {
    dispatch_async(dispatch_get_main_queue(), ^{
#ifdef MARKETING_VERSION
        CoreVersion.marketingVersion = PROCESSOR_STRING(MARKETING_VERSION);
#else
        CoreVersion.marketingVersion = ""
#endif
    });
}

@end
