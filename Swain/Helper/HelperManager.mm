//
//  HelperManager.mm
//  Swain
//
//  Created by Jinwoo Kim on 2/4/24.
//

#if !SANDBOXED
#import "HelperManager.hpp"
#import <Security/Security.h>
#import <ServiceManagement/ServiceManagement.h>
#import <xpc/xpc.h>
#import <CoreFoundation/CoreFoundation.h>
#import <array>
#import <algorithm>

__attribute__((objc_direct_members))
@interface HelperManager () {
    xpc_session_t _helperSession;
    SMAppService *_appService;
    dispatch_queue_t _queue;
    AuthorizationRef _authRef;
    CFDataRef _authData;
}
@property (assign, nonatomic, readonly) xpc_session_t helperSession;
@property (retain, nonatomic, readonly) SMAppService *appService;
@property (retain, nonatomic, readonly) dispatch_queue_t queue;
@end

@implementation HelperManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HelperManager *object;
    
    dispatch_once(&onceToken, ^{
        object = [HelperManager new];
    });

    return object;
}

- (void)dealloc {
    [_appService release];
    
    if (_queue) {
        dispatch_release(_queue);
    }
    
    if (_authRef) {
        AuthorizationFree(_authRef, 0);
    }
    
    if (_authData) {
        CFRelease(_authData);
    }
    
    [super dealloc];
}

- (void)installHelperWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    dispatch_async(self.queue, ^{
        [self setupAuthorization];
        
        SMAppService *appService = self.appService;
        
        NSError * _Nullable error = nil;
        [appService registerAndReturnError:&error];
        
        completionHandler(error);
    });
}

- (void)uninstallHelperWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    dispatch_async(self.queue, ^{
        SMAppService *appService = self.appService;
        
        NSError * _Nullable error = nil;
        [appService unregisterAndReturnError:&error];
        
        [self clearAuthorization];
        completionHandler(error);
    });
}

- (SMAppService *)appService {
    if (auto appService = _appService) return appService;
    
    SMAppService *appService = [SMAppService daemonServiceWithPlistName:@"com.pookjw.Swain.Helper.plist"];
    
    _appService = [appService retain];
    return appService;
}

- (dispatch_queue_t)queue {
    if (auto queue = _queue) return queue;
        
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY);
    dispatch_queue_t queue = dispatch_queue_create("HelperManager", attr);
    _queue = queue;
    
    return queue;
}

- (xpc_session_t)helperSession {
    if (auto helperSession = _helperSession) return helperSession;
    
    xpc_rich_error_t richError = NULL;
    
    xpc_session_t helperSession = xpc_session_create_mach_service("com.pookjw.Swain.Helper",
                                                                  NULL,
                                                                  XPC_SESSION_CREATE_MACH_PRIVILEGED,
                                                                  &richError);
    
    if (richError) {
        const char *description = xpc_rich_error_copy_description(richError);
        NSString *string = [NSString stringWithCString:description encoding:NSUTF8StringEncoding];
        delete description;
        
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:string userInfo:nil];
    }
    
    _helperSession = helperSession;
    return helperSession;
}

- (void)installPackageWithURL:(NSURL *)packageURL completionHandler:(void (^)(NSError * _Nullable))completionHandler {
    dispatch_async(self.queue, ^{
        const std::array<const char *, 3> keys = {
            "action",
            "authorization_external_form",
            "package_path"
        };
        
        const std::array<xpc_object_t, 3> values {
            xpc_string_create("install_package"),
            xpc_data_create(CFDataGetBytePtr(_authData), CFDataGetLength(_authData)),
            xpc_string_create([packageURL.absoluteString cStringUsingEncoding:NSUTF8StringEncoding])
        };
        
        xpc_object_t message = xpc_dictionary_create(keys.data(), values.data(), keys.size());
        
        std::for_each(values.cbegin(), values.cend(), [](auto value) {
            xpc_release(value);
        });
        
        xpc_session_send_message_with_reply_async(self.helperSession,
                                                  message,
                                                  ^(xpc_object_t  _Nullable reply, xpc_rich_error_t  _Nullable error) {
            const char *description = xpc_copy_description(reply);
            NSLog(@"%s", description);
            delete description;
        });
        
        xpc_release(message);
    });
}

- (void)setupAuthorization __attribute__((objc_direct)) {
    OSStatus status_1 = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, 0, &_authRef);
    assert(status_1 == errAuthorizationSuccess);
    
    AuthorizationExternalForm extForm;
    OSStatus status_2 = AuthorizationMakeExternalForm(_authRef, &extForm);
    assert(status_2 == errAuthorizationSuccess);
    
    _authData = CFDataCreate(kCFAllocatorDefault,
                             reinterpret_cast<const UInt8 *>(&extForm),
                             sizeof(extForm));
    
    OSStatus status_3 = AuthorizationRightGet("Swain", NULL);
    
    if (status_3 == errAuthorizationDenied) {
        CFStringRef rightDefinition = CFSTR(kAuthorizationRuleAuthenticateAsAdmin);
        CFStringRef descriptionKey = CFSTR("TEST");
        CFBundleRef bundle = CFBundleGetMainBundle();
        
        OSStatus status_4 = AuthorizationRightSet(_authRef,
                                                  "Swain",
                                                  rightDefinition,
                                                  descriptionKey,
                                                  bundle,
                                                  NULL);
        
        CFRelease(rightDefinition);
        CFRelease(descriptionKey);
        CFRelease(bundle);
        
        assert(status_4 == errAuthorizationSuccess);
    }
}

- (void)clearAuthorization __attribute__((objc_direct)) {
    if (_authRef == NULL) return;
    
    OSStatus status = AuthorizationRightRemove(_authRef, "Swain");
    assert(status == errAuthorizationSuccess);
    
    if (_authRef) {
        AuthorizationFree(_authRef, 0);
    }
    
    if (_authData) {
        CFRelease(_authData);
    }
}

@end
#endif
