//
//  ViewController.m
//  SimpleTouchID
//
//  Created by Cain Luo on 7/10/16.
//  Copyright © 2016年 Cain Luo. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)touchIDCheck:(UIButton *)sender {
    
    // 初始化上下文对象
    LAContext *context = [[LAContext alloc] init];
    
    // 错误对象
    NSError *error = nil;
    NSString *result = @"Authentication is needed to access your notes.";
    
    // 首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        // 支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:result
                          reply:^(BOOL success, NSError *error) {
                              
                              if (success) {
                                  
                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"校验成功"
                                                                                      message:@"指纹校验成功"
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"确定"
                                                                            otherButtonTitles:nil, nil];
                                  
                                  [alertView show];
                                  
                              } else {
                                  
                                  NSLog(@"%@",error.localizedDescription);
                                  
                                  switch (error.code) {
                                          
                                      case LAErrorSystemCancel: {
                                          
                                          NSLog(@"Authentication was cancelled by the system");
                                          
                                          // 切换到其他APP，系统取消验证Touch ID
                                          break;
                                      }
                                          
                                      case LAErrorUserCancel: {
                                          
                                          NSLog(@"Authentication was cancelled by the user");
                                          
                                          // 用户取消验证Touch ID
                                          break;
                                      }
                                          
                                      case LAErrorUserFallback: {
                                          
                                          NSLog(@"User selected to enter custom password");
                                          
                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                              // 用户选择输入密码，切换主线程处理
                                          }];
                                          break;
                                      }
                                          
                                      case LAErrorTouchIDLockout: { // iOS 9之后才会有的
                                          // 多次指纹校验失败, 需要输入密码解锁
                                          NSLog(@"Passcode is required to unlock Touch ID");
                                          
                                          break;
                                      }
                                      case LAErrorAppCancel: { // iOS 9之后才会有的
                                          // 当前软件被挂起取消了授权, 这个挂起是APP挂起, 和LAErrorSystemCancel不太一样
                                          NSLog(@"Authentication was canceled by application");
                                          
                                          break;
                                      }
                                          
                                      case LAErrorInvalidContext: { // iOS 9之后才会有的
                                          // LAContext对象被释放掉了，造成的授权失败
                                          NSLog(@"LAContext passed to this call has been previously invalidated");
                                          
                                          break;
                                      }
                                          
                                      default: {
                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                              // 其他情况，切换主线程处理
                                          }];
                                          break;
                                      }
                                  }
                              }
                          }];
    } else {
        // 不支持指纹识别，LOG出错误详情
        
        switch (error.code) {
                
            case LAErrorTouchIDNotEnrolled: {
                NSLog(@"TouchID is not enrolled");
                break;
            }
                
            case LAErrorPasscodeNotSet: {
                NSLog(@"A passcode has not been set");
                break;
            }
                
            default: {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}

@end
