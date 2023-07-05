//
//  PBURLProtocol.m

// 使用anti-debug技术
#import <sys/types.h>
#import <sys/sysctl.h>
#import "PBURLProtocol.h"


BOOL isDebuggerAttached(void) {
    int                 name[4];
    struct kinfo_proc   info;
    size_t              size = sizeof(info);
    info.kp_proc.p_flag = 0;
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    if (sysctl(name, sizeof(name) / sizeof(*name), &info, &size, NULL, 0) == -1) {
        perror("sysctl");
        exit(EXIT_FAILURE);
    }
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

#define protocolKey @"SessionProtocolKey"

@interface PBURLProtocol()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLResponse *currentResponse;

@end

@implementation PBURLProtocol

+(instancetype)sharedInstance {
    static PBURLProtocol *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

+(BOOL)canInitWithRequest:(NSURLRequest *)request{
    if ([NSURLProtocol propertyForKey:protocolKey inRequest:request]) {
        return NO;
    }
    NSString * url = request.URL.absoluteString;
    return [self isUrl:url] && [PBURLProtocol sharedInstance].requestBlock;
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return [[PBURLProtocol sharedInstance] requestBlockForRequst:request];
}

-(void)startLoading{
    NSMutableURLRequest *request = [self.request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:protocolKey inRequest:request];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.session = [PBURLProtocol sharedInstance].sessionBlock ? [PBURLProtocol sharedInstance].sessionBlock(session) : session;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}

-(void)stopLoading {
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark - NSURLSessionDataDelegate
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    self.currentResponse = response;
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSData *currentData = [PBURLProtocol sharedInstance].responseBlock ? [PBURLProtocol sharedInstance].responseBlock(self.currentResponse, data) : data;
    [self.client URLProtocol:self didLoadData:currentData];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
    completionHandler(proposedResponse);
}

#pragma mark private
+(BOOL)isUrl:(NSString *)url{
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [urlTest evaluateWithObject:url];
}

-(NSURLRequest *)requestBlockForRequst:(NSURLRequest *)request{
    NSURLRequest *currentRequest = self.requestBlock ? self.requestBlock(request) : request;
    return currentRequest;
}
@end
