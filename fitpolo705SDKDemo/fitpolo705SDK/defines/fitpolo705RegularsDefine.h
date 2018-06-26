
#pragma mark - 字符串、字典、数组等类的验证宏定义
//*************************************字符串、字典、数组等类的验证宏定义******************************************************

#define fitpolo705ValidStr(f)         (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define fitpolo705ValidDict(f)        (f!=nil && [f isKindOfClass:[NSDictionary class]] && [f count]>0)
#define fitpolo705ValidArray(f)       (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define fitpolo705ValidData(f)        (f!=nil && [f isKindOfClass:[NSData class]])

//*************************************字符串、字典、数组等类的验证宏定义******************************************************

//===================弱引用对象=====================================//
#define fitpolo705WS(weakSelf)          __weak __typeof(&*self)weakSelf = self;

