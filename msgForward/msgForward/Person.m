//
//  Person.m
//  msgForward
//
//  Created by 张潮 on 16/5/16.
//  Copyright © 2016年 nvshengpai. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>
#import "Car.h"

@implementation Person

/*
 消息转发是按照1-2-3的顺序执行的，如果前面实现了就不会走后面的转发
 */

// 1、动态方法解析
// 在运行时动态添加方法
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(run)) {
        class_addMethod([self class], sel, (IMP)functionForRun, "v@:");
    }
    
    return [super resolveInstanceMethod:sel];
}

void functionForRun(id self, SEL _cmd)
{
    NSLog(@"Person run");
}


// 2、备用接收者
// 转发给别的对象
// 这个对象不能是nil也不能是self，并且对象必须实现方法
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (aSelector == @selector(run)) {
        return [Car new];
    }
    return [super forwardingTargetForSelector:aSelector];
}


// 3、完整转发
// 必须先生成签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if (aSelector == @selector(run)) {
        // 为转发方法手动生成签名
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = [anInvocation selector];
    // 新建转发的对象
    Car *car = [Car new];
    if ([car respondsToSelector:selector]) {
        // 调用对象激活方法
        [anInvocation invokeWithTarget:car];
    }
    
}

@end
