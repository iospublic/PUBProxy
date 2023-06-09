//
//  PBRequestBlock.m


#import "PBRequestBlock.h"
#import <objc/runtime.h>
#import "PBURLProtocol.h"
#import "PBGetIP.h"
#import "NSURLSession+PBProxy.h"
static BOOL isCancelAllReq;
static BOOL isEnableHttpDns;

@implementation PBRequestBlock
+(void)addRequestBlock{
    [self injectNSURLSessionConfiguration];
    [NSURLProtocol registerClass:[PBURLProtocol class]];
}
+(void)removeRequestBlock{
    [NSURLProtocol unregisterClass:[PBURLProtocol class]];
}
+(void)handleRequest:(requestBlock)requestBlock{
    [self handleRequest:requestBlock responseBlock:nil];
}
+(void)handleRequest:(requestBlock)requestBlock responseBlock:(responseBlock)responseBlock{
    [self handleRequest:requestBlock responseBlock:responseBlock sessionBlock:nil];
}
+(void)handleRequest:(requestBlock)requestBlock responseBlock:(responseBlock)responseBlock sessionBlock:(sessionBlock)sessionBlock {
    PBURLProtocol *urlProtocol = [PBURLProtocol sharedInstance];
    NSAssert(!urlProtocol.requestBlock, @"您已添加过handleRequest，再次添加会导致之前代码设置的handleRequest失效，请更改设计策略，在同一个handleRequestBlock作统一处理！");
    [self addRequestBlock];
    urlProtocol.requestBlock = ^NSURLRequest *(NSURLRequest *request) {
        if(isCancelAllReq){
            return nil;
        }
        NSURLRequest *newRequest = requestBlock(request);
        if(isEnableHttpDns){
            NSString *handleUrlStr = request.URL.absoluteString;
            if([self isValidIP:handleUrlStr]){
                return newRequest;
            }
            NSString *ipStr = [PBGetIP getIPArrFromLocalDnsWithUrlStr:newRequest.URL.host];
            NSMutableURLRequest * mutableReq = [newRequest mutableCopy];
            [mutableReq setValue:ipStr forHTTPHeaderField:@"host"];
            return mutableReq;
        }
        return newRequest;
    };
    urlProtocol.responseBlock = responseBlock;
    urlProtocol.sessionBlock = sessionBlock;
}
+(void)disableRequestWithUrlStr:(NSString *)urlStr{
    [self handleRequest:^NSURLRequest *(NSURLRequest *request) {
        NSString *handleUrlStr = request.URL.absoluteString;
        if([handleUrlStr.uppercaseString containsString:urlStr.uppercaseString]){
            return nil;
        }else{
            return request;
        }
    }];
}
+(void)cancelAllRequest{
    isCancelAllReq = YES;
    [self blockRequest];
}
+(void)resumeAllRequest{
    isCancelAllReq = NO;
    [self blockRequest];
}
+(void)blockRequest{
    if(![PBURLProtocol sharedInstance].requestBlock){
        [self handleRequest:^NSURLRequest *(NSURLRequest *request) {
             return isCancelAllReq ? nil : request;
        }];
    }
}
+(id)disableHttpProxy{
    id httpProxy = [self fetchHttpProxy];
    [NSURLSession disableHttpProxy];
    return httpProxy;
}
+(void)enableHttpProxy{
    [NSURLSession enableHttpProxy];
}

+(void)enableHttpDns{
    isEnableHttpDns = YES;
}
+(void)disableHttpDns{
    isEnableHttpDns = NO;
}

#pragma mark - Private
#pragma mark 是否是ip地址
+ (BOOL)isValidIP:(NSString *)ipStr {
    if (nil == ipStr) {
        return NO;
    }
    NSArray *ipArray = [ipStr componentsSeparatedByString:@"."];
    if (ipArray.count == 4) {
        for (NSString *ipnumberStr in ipArray) {
            int ipnumber = [ipnumberStr intValue];
            if (!(ipnumber >= 0 && ipnumber <= 255)) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark 获取网络代理
+(id)fetchHttpProxy{
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    NSString *proxy = (__bridge NSString *)proxyCFstr;
    return proxy;
}

///来源：https://www.jianshu.com/p/25f2d36eb637 ，感谢！！
+ (void)injectNSURLSessionConfiguration{
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    Method originalMethod = class_getInstanceMethod(cls, @selector(protocolClasses));
    Method stubMethod = class_getInstanceMethod([self class], @selector(protocolClasses));
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses{
    return @[[PBURLProtocol class]];
}

@end
