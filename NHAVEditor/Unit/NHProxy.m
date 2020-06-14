//
//  NHProxy.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHProxy.h"

@interface NHProxy ()
@property (weak, nonatomic) id target;

@end

@implementation NHProxy

+ (id)proxyWithTarget:(id)target {
  NHProxy *proxy = [NHProxy alloc];
  proxy.target = target;
  return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  
  return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  
  [invocation invokeWithTarget:_target];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
  return [_target isEqual:object];
}

- (NSUInteger)hash {
  return [_target hash];
}

- (Class)superclass {
  return [_target superclass];
}

- (Class)class {
  return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
  return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
  return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
  return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
  return YES;
}

- (NSString *)description {
  return [_target description];
}

- (NSString *)debugDescription {
  return [_target debugDescription];
}

@end
