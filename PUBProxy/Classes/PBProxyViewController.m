//
//  PBProxyViewController.m
//  PUBProxy

#import "PBProxyViewController.h"

@interface PBProxyViewController ()

@property (nonatomic, copy) NSString *msg;

@end

@implementation PBProxyViewController
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //文本信息
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,500)];
    label.numberOfLines = 0;
    label.textColor = UIColor.redColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.text = self.msg?self.msg:@"非法操作，请您谨慎";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    label.center = self.view.center;
}

@end
