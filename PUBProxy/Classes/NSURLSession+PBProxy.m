//
//  NSURLSession+PBProxy.m


#import "NSURLSession+PBProxy.h"
#import "PBURLProtocol.h"
#import <objc/runtime.h>
static BOOL isDisableHttpProxy = NO;
@implementation NSURLSession (PBProxy)
+(void)load{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLProtocol registerClass:[PBURLProtocol class]];
        Class class = [NSURLSession class];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:") swiSel:NSSelectorFromString(@"function_oo_sessionWithConfiguration:")];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:delegate:delegateQueue:") swiSel:NSSelectorFromString(@"function_oo_sessionWithConfiguration:delegate:delegateQueue:")];
    });
}
+(void)disableHttpProxy{
    isDisableHttpProxy = YES;
}
+(void)enableHttpProxy{
    isDisableHttpProxy = NO;
}
+(NSURLSession *)function_oo_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                    delegate:(nullable id<NSURLSessionDelegate>)delegate
                               delegateQueue:(nullable NSOperationQueue *)queue{
    if (!configuration){
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    if(isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self function_oo_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+(NSURLSession *)function_oo_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    if (configuration && isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self function_oo_sessionWithConfiguration:configuration];
}

+(void)swizzingMethodWithClass:(Class)cls orgSel:(SEL) orgSel swiSel:(SEL) swiSel{
    Method orgMethod = class_getClassMethod(cls, orgSel);
    Method swiMethod = class_getClassMethod(cls, swiSel);
    method_exchangeImplementations(orgMethod, swiMethod);
}

@end

