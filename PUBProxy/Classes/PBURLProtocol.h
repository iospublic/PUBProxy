//
//  PBURLProtocol.h



#import <Foundation/Foundation.h>
@interface PBURLProtocol : NSURLProtocol
@property (nonatomic, copy) NSURLRequest *(^requestBlock)(NSURLRequest *request);
@property (nonatomic, copy) NSData *(^responseBlock)(NSURLResponse *response, NSData *data);
@property (nonatomic, copy) NSURLSession *(^sessionBlock)(NSURLSession *session);
+(instancetype)sharedInstance;
@end
