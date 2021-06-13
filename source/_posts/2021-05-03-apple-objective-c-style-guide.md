---
title: Objective-C 样式指南
date: 2021-04-03 11:21:56
tags: 
    - Objective-C
categories: 
    - iOS
---

本样式指南概述了 iOS 团队使用的编码规范，使用 Objective-C 语言的开发人员都应按照本样式指南编写代码。

<!-- more -->

## 介绍

以下是 Apple 官方提供的有关样式指南的文档。如果此处未提及某些内容，下面的文档中也能找到详细介绍内容：

- [Objective-C 编程语言](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)
- [Cocoa 入门指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaFundamentals/Introduction/Introduction.html)
- [Cocoa 编码规范](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
- [Apple Developer 技术指南](https://developer.apple.com/documentation/technologies)

## 目录

- [可空性](#可空性)
- [点语法](#点语法)
- [代码宽度限制](#代码宽度限制)
- [代码组织](#代码组织)
- [空行与缩进](#空行与缩进)
- [括号](#括号)
- [条件语句](#条件语句)
- [三目运算符](#三目运算符)
- [错误处理](#错误处理)
- [方法](#方法)
- [枚举](#枚举)
- [属性](#属性)
- [命名](#命名)
- [下划线](#下划线)
- [注释](#注释)
- [协议](#协议)
- [Init & Dealloc](#init-and-dealloc)
- [instancetype vs id](#instancetype-vs-id)
- [alloc-init vs new](#alloc-init-vs-new)
- [字面量](#字面量)
- [CGRect 函数](#CGRect-函数)
- [常量](#常量)
- [私有属性](#私有属性)
- [私有头文件](#私有头文件)
- [布尔值](#布尔值)
- [代码块](#代码块)
- [单例](#单例)
- [Xcode 项目](#Xcode-项目)
- [代码格式化](#代码格式化)

---

## 可空性

从 Xcode 6.3 开始，Apple 已向 Objective-C 编译器引入了可空性注解。这允许开发者使用更具表现力的 API，也加强了 Swift 编译器理解 Objective-C 代码的能力，同时也提供给开发者更友好的编译器提示信息，我们希望对所有代码强制使用此注解。

注解的使用非常简单。我们采用的标准是在所有头文件使用 `NS_ASSUME_NONNULL_BEGIN` 和 `NS_ASSUME_NONNULL_END` 宏「Xcode 创建 Objective-C 文件时会自动添加」，然后标识可以为空的指针。

示例代码：

```objc
// XYZPerson.h

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XYZPersonGenderType) {
    XYZPersonGenderTypeMale,
    XYZPersonGenderTypeFemale
};

@class XYZPerson;
@protocol XYZPersonDelegate <NSObject>

- (void)person:(Person *)person sayHello:(nullable NSString *)greeting;

@end

@interface XYZPerson : NSObject

@property (nonatomic, copy) NSString *firstName; // 默认不为空
@property (nonatomic, copy, nullable) NSString *lastName; // 可以为空

@property (nonatomic, assign, readonly) XYZPersonGenderType genderType;

// 弱属性必须可以为空。如果程序员从未将其设置为 nil，编译器将不会提示警告。如果未标注为可为空，Runtime 最后还是会将属性设置为 nil。
@property (nonatomic, weak, nullable) id<XYZPersonDelegate> delegate;

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(nullable NSString *)lastName
                       genderType:(XYZPersonGenderType)genderType NS_DESIGNATED_INITIALIZER;

+ (instancetype)personWithFirstName:(NSString *)firstName
                           lastName:(nullable NSString *)lastName
                         genderType:(XYZPersonGenderType)genderType;

@end

NS_ASSUME_NONNULL_END

// XYZPerson.m

NS_ASSUME_NONNULL_BEGIN

// 不要忘记在 Extension 和 Category 中添加这一组宏
@interface XYZPerson ()

@property (nonatomic, copy) NSString *fullName;

@property (nonatomic, assign) GenderType genderType;

@end

NS_ASSUME_NONNULL_END

@implementation XYZPerson

- (instancetype)init {
    return [self initWithFirstName:@"" lastName:nil genderType:XYZPersonGenderTypeMale];
}

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(nullable NSString *)lastName
                       genderType:(XYZPersonGenderType)genderType {
    if (self = [super init]) {
        _firstName = firstName;
        _lastName = lastName;
        _genderType = genderType;
    }
    return self;
}

+ (instancetype)personWithFirstName:(NSString *)firstName
                           lastName:(nullable NSString *)lastName
                         genderType:(XYZPersonGenderType)genderType {
    return [[self alloc] initWithFirstName:firstName lastName:lastName genderType:genderType];
}

@end
```

注解方式并不复杂，但是有几点需要注意：

- 注解无法改变编写的代码的逻辑，仅仅是 IDE 提供编译器辅助开发者的一种手段，我们应当合理利用。
- `weak` 属性: 如果不设置为 `nullable`，那么 API 不能完整表达 `weak` 属性的意图，并且如果显示地将属性设置为 `nil` 时，编译器会提示警告。
- 在接口声明之外使用可空性注解几乎没有任何意义。

可空性只是编译器的特性。这也意味着运行时代码不会被更改。

```objc
NS_ASSUME_NONNULL_BEGIN

@interface ViewController : UIViewController
@property (nonatomic, copy) NSString *nonNullString;
@end

NS_ASSUME_NONNULL_END

// 使用
NSString *aString = [NSString stringWithFormat:@"helloworld %.1f",1.0];
aString = nil;
controller.nonNullString = aString; // 正常
controller.nonNullString = nil; // 警告
```

属性如果没有明确添加 `nonnull`，默认就是 `nonnull`。但是添加了 `nonnull` 的注解并不表示不能复制为 `nil`，虽然在代码中显示设置属性为 `nil` 时会提示警告信息，但是间接设置编译器却无法提示。为了保证运行的稳定，我们还是需要检查对象是否为 `nil`。

---

## 点语法

点语法应该**总是**用于访问和修改属性。另外的情况应该选择方括号「中括号」语法。

**推荐:**

```objc
view.backgroundColor = [UIColor orangeColor];
[UIApplication sharedApplication].delegate;
```

**不推荐:**

```objc
[view setBackgroundColor:[UIColor orangeColor]];
UIApplication.sharedApplication.delegate;
```

使用 Objective-C 语言，不推荐使用点语法来访问其他方法。点语法只是语法糖，因此这样调用方法也是可以正常运行的。

**不可取:**

```objc
UIApplication *application = UIApplication.sharedApplication
```

方括号「中括号」语法可以用来访问 [getter 方法](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html#//apple_ref/doc/uid/TP40011210-CH5-SW2):

```objc
@property (getter=isFinished) BOOL finished;

if ([operation isFinished]) // 推荐
if (operation.finished) // 推荐
if (operation.isFinished) // 不可取
```

## 代码宽度限制

虽然有业界约定俗成的代码宽度为 80 个字符，但这是因为早期很多 IDE 默认没有自动换行，或者换行之后有一些问题，故设置为 80 个字符比较适合。但是随着现在屏幕像素的不断提升，80 个字符的代码宽度确实有些浪费屏幕了。我们强制不规定代码的宽度，如果一定需要的话设置为 120 个字符会比较适合。

即使我们限制代码的宽度，也要需要注意代码宽度，方法调用和声明「因为 Objective-C 确实很冗长」太长也需要换行对齐，保持代码美观。

## 代码组织

- 使用预处理指令 `#pragma mark - ` 来分门别类，将功能划分不同的组，力求使用简短的描述性名称，并尽量不要省略名称「例如 #pragma mark - 」。
- 使用预处理指令 `#pragma mark ` 来处理分组里面更加详细的功能。
- Xcode 中使用 `Control + 6` 快捷键可以快速查看分组列表结构。

```objc
#pragma mark - Overwrite // 重写系统方法列表

#pragma mark Lifecycle // 生命周期方法列表「没有 “-” 连接符号」

- (instancetype)init {}
- (void)viewDidLoad {}
- (void)viewWillAppear:(BOOL)animated {}
- (void)didReceiveMemoryWarning {}
- (void)dealloc {}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {}

#pragma mark NSObject

- (NSString *)description {}

// 私有方法列表
#pragma mark - Private

- (void)privateMethod {}

// 协议、代理、数据源方法列表
#pragma mark - Protocol conformance
#pragma mark - UITextFieldDelegate
#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate

#pragma mark - Actions

- (IBAction)clickSubmitButton:(id)button { }

- (void)clickLoginButton:(id)button { }

- (void)networkStatusDidChangeNotification:(NSNotification *)notification { }

#pragma mark - Getter & Setter

- (void)setCustomProperty:(id)value {}
- (id)customProperty {}

// 公开方法列表
#pragma mark - Public

- (void)publicMethod {}
```

## 空白 & 缩进

- 使用 4 个空格缩进，禁止使用制表符缩进，只需保持 Xcode 偏好设置中默认缩进即可。
- 在方法之间应该有需要有一空行，以帮助提高代码可读性和代码组织性，每个方法之间禁止空出多个空白行。
- 指针类型的星号`*`应与变量名称相邻「指针符号靠右」，而不是靠近前面的类型。适用于所有使用到的地方，包括「属性，局部变量，常量，方法类型等」。

**推荐:**

```objc
NSString *message = NSLocalizedString(@"home.intro.message", nil);
```

**不可取:**

```objc
NSString* message = NSLocalizedString(@"home.intro.message", nil);
```

## 括号

花括号「大括号」在程序分支结构中的使用「`if`/`else`/`switch`/`while`」:

**推荐:**

```objc
if ([user isHappy]) {
    // ...
} else {
    // ...
}

- (void)myMethod {
    // ...
}
```

**不可取:**

```objc
if ([user isHappy]) {
    // ...
}
else {
    // ...
}

- (void)myMethod
{
    // ...
}
```

## 条件语句

即使代码体中是有一行代码也应始终使用括号包裹，以防止出错。这些错误包括添加第二行时，忘记加上括号包裹代码而导致。如果在 if 语句的代码体「第一行」被注释掉，那么下一行就成为 if 语句的一部分，这就会导致严重的错误。此外这个规则与所有其他条件一致，更便于维护代码。

**推荐:**

```objc
if (!error) {
    return success;
}
```

**不可取:**

```objc
if (!error)
    return success;
```

或者

```objc
if (!error) return success;
```

如果对于此规则无感，请参阅 [Apple SSL bug](https://www.imperialviolet.org/2014/02/22/applebug.html) 问题。

始终避免 [Yoda 条件](https://juejin.cn/post/6844903603778355214)

**推荐:**

```objc
if (number == 7) { }
if ([value isEqual:constant]) { ...
```

**不可取:**

```objc
if (7 == number) { }
if ([constant isEqual:value]) { ...
```

可以先处理复杂的表达式，将处理结果作为条件，便于提高可读性。

**_推荐:_**

```objc
BOOL stateForDismissalIsCorrect = [object something] && [object somethingElse] && ithinkSo;
if (stateForDismissalIsCorrect) {
}
```

**_重构:_**

```objc
if ([object something] && [object somethingElse] && ithinkSo) {
}
```

检查「@optional」方法时，不需要检查代理是否存在：

**推荐:**

```objc
if ([self.delegate respondsToSelector:@selector(...)]) {
    // ...
}
```

**不推荐:**

```objc
if (self.delegate && [self.delegate respondsToSelector:@selector(...)]) {
    // ...
}
```

## 三目运算符

三元运算符 `?`，可以增加清晰度和代码整洁度。通常用于判断单个条件。判断多个条件时可以重构使用 `if` 语句判断代码，这样逻辑会更加清晰易懂。

**推荐:**

```objc
result = a > b ? x : y;
string = fromServer ?: @"hardcoded";
```

**不推荐:**

```objc
result = a > b ? x = c > d ? c : d : y;
```

## 错误处理

当方法通过引用返回错误参数时，请使用接受的返回值作为判断依据，而不是使用错误变量判断。

**推荐:**

```objc
NSError *error;
if (![self trySomethingWithError:&error]) {
    // 错误处理
}
```

或者

```objc
NSError *error;
NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
if (data) {
     //...
}
```

**不推荐:**

```objc
NSError *error;
[self trySomethingWithError:&error];
if (error) {
    // 错误处理
}
```

在成功的情况下，某些 Apple 的 API 会将垃圾值写入错误参数「错误如果为非 NULL」，如果这样判断错误就会导致误报「可能会产生崩溃」。

## 方法

在方法签名中，作用域「-/+ 符号」后应有一个空格，形参与方法签名也有一个空格。

**推荐:**

```objc
- (void)setExampleText:(NSString *)text image:(UIImage *)image;
```

**不推荐:**

```objc
-(void)setExampleText: (NSString *)text image: (UIImage *)image;
```

私有方法没有特殊要求，可以将它们命名为常规方法，但不要使用下划线前缀，因为下划线 `_` 开头的方法是[保留给 Apple SDK 内部使用的](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/NamingMethods.html#//apple_ref/doc/uid/20001282-1003829-BCIBDJCA)。

在类实现中，方法与方法之间应该有空行，@implementation 前后应有空行。`#pragma mark` 前后都要有空行。

**_推荐:_**

```objc

@interface XYZPersonViewController ()

@property (nonatomic, weak) UIButton *settingsButton;

@end

@implementation XYZPersonViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    // ...
}

- (void)viewDidAppear:(BOOL)animated {
    // ...
}

#pragma mark - Settings

- (IBAction)goToSettings:(id)sender {
    // ...
}

@end

```

## 枚举

- 使用 Objective-C 2.0 风格，枚举应使用 `NS_ENUM` 宏声明。
- 此外，在编写 `NS_ENUM` case 名称时，请使用易于编译器自动推导的名称，这也符合 Apple 的命名习惯:

**_推荐:_**

```objc
typedef NS_ENUM(XYZCollectionViewLayoutMode, NSUInteger) {
     XYZCollectionViewLayoutModeGrid,
     XYZCollectionViewLayoutModeFullscreen
}
```

**_不可取:_**

```objc
typedef NS_ENUM(XYZCollectionViewLayoutMode, NSUInteger) {
     XYZCollectionViewLayoutGridMode,
     XYZCollectionViewLayoutFullscreenMode
}
```

## 属性

在处理 _state_ 而不是 _behaviour_ 时，更加倾向于使用属性而不是方法。

**推荐:**

```objc
@interface XYZProfileController : UIViewController

@property (nonatomic) XYZProfile *profile;

@end
```

**不推荐:**

```objc
@interface XYZProfileController : UIViewController

- (XYZProfile *)profile;
- (void)setProfile:(XYZProfile *)profile;

@end
```

- 属性声明的格式在 @property 之后应有空格:
  **推荐:**

```objc
@interface XYZPerson

@property (nonatomic, copy, readonly) NSString *identifier;

@end
```

**不推荐:**

```objc
@interface XYZPerson
@property(nonatomic,copy,readonly) NSString* identifier;
@end
```

- `@synthesize` 和 `@dynamic` 应该在单独一行上声明实现。

- 属性名称不要太冗长：不需要指定默认的属性，而应在需要时指定具体的属性，并且记住默认是使用原子属性 `atomic` 的，在 iOS 中 我们都应该显示指定使用非原子属性 `nonatomic`。

**推荐:**

```objc
@interface XYZPerson

@property (nonatomic) NSUInteger numberOfCommonPlaces;
@property (nonatomic) NSArray *commonPlaces;
@property (nonatomic, weak) id<XYZPersonDelegate> delegate;

@end
```

**不可取:**

```objc
@interface XYZPerson

@property (nonatomic, assign) NSUInteger numberOfCommonPlaces; // NSUInteger 默认使用 `assign`
@property (strong) NSArray *commonPlaces; // 除非确实需要，否则不应该是原子的，默认使用 `atomic`
@property (nonatomic) id<XYZPersonDelegate> delegate; // 代理需要使用 `weak`

@end
```

- 原子属性 `atomic` 使用时需要注意，需要显示标注，这样可以提高其他开发者对此属性性质的可读性和明白其意图。
- 在属性列表中，优先选择 `atomic`/`nonatomic`，放在第一位置，保持代码风格的一致性。
- 在 `dealloc` 和 `init` 方法实现中，我们应该使用 ivars 来访问和修改属性，因为对象在 `dealloc` 和 `init` 时，对象有些状态是不确定的。

```objc
@implementation XYZProfile

- (void)dealloc {
    [_updateTimer invalidate];
}

- (XYZTimer *)updateTimer {
    if (!_updateTimer) {
        _updateTimer = [[XYZTimer alloc] init];
        // ...
    }
    return _updateTimer;
}

@end

```

> 有关在 `init` 方法和 `dealloc` 方法中使用访问器 `Accessor` 方法的更多信息，请参见[此处](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-SW6)。

## 命名

应尽可能遵守 Apple 的命名约定，尤其是与[内存管理规则](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/MemoryMgmt.html)有关的约定时。和使用「NARC `new`、`alloc`、`retain`、`copy`」、`create` 关键字时，请时刻记住是否需要开发者手动给力内存。

变量名应尽可能取的有意义。除 `for()` 循环外，应避免单字母变量名称，长的描述性方法和变量名是被允许的。

**推荐:**

```objc
UIButton *settingsButton;
```

**不推荐:**

```objc
UIButton *setBut;
```

类名、分类「尤其是 `Cocoa` 的分类」和常量应始终使用三个字母的前缀。常数应为驼峰 `camel-case` 大小写，所有单词均以大写字母开头，并以相关的类名作为前缀，使其更加清晰。该前缀取决于代码所在的位置，可以是模块前缀也可以是所在层级的结构名称，比如：「PL，BLL，DAL 等」

**推荐:**

```objc
static const NSTimeInterval XYZProfileViewControllerNavigationFadeAnimationDuration = 0.4;

@interface NSAttributedString (XYZHTMLParsing)

- (void)XYZ_attributedStringFromHTML:(NSString *)string;

@end
```

**不推荐:**

```objc
static const NSTimeInterval fadetime = 0.2;

@interface NSAttributedString (HTMLParsing)

- (void)attributedStringFromHTML:(NSString *)string;

@end
```

- 属性和局部变量应为驼峰式 `camel-case`，首字母为小写。
- 实例变量应为驼峰式 `camel-case`，首字母为小写，并以下划线作为前缀。
- 这与 LLVM 自动合成的实例变量一致，如果**LLVM 可以自动合成该变量，则无需处理**。

**推荐:**

```objc
// 这行代码编译器会自动生成，但是如果我们需要手动生成，则正确写法为：
@synthesize descriptiveVariableName = _descriptiveVariableName;
```

**不可取:**

```objc
id varnm;
```

代理方法应始终将调用者 `caller` 作为第一个参数传递.

**推荐:**

```objc
- (void)lessonController:(LessonController *)lessonController didSelectLesson:(Lesson *)lesson;
- (void)lessonControllerDidFinish:(LessonController *)lessonController;
```

**不推荐:**

```objc
- (void)lessonControllerDidSelectLesson:(Lesson *)lesson;
```

## 下划线

使用属性时，应始终使用 `self.` 来访问和修改实例变量。这意味着所有属性看起来都比较醒目「IDE 关键字颜色」，因为它们都以 `self.`开头。局部变量不应包含下划线。还有一点值得注意的是使用懒加载技术时，`self.` 可以完成属性的初始化创建「调用 `getter` 方法」。

## 注释

当需要它们时，应使用注释来解释为什么这段代码会执行这些操作。注意编写注释时，不允许：

- 注释应该简洁明了、禁止表意不明或者注释滥用的情况。
- 不需要撰写评论的人的姓名，因为版本控制工具已经有记录说明。
- 不需要有 JIRA 需求链接、BUG 链接但是可以有技术文档链接。
- 不要注释任何代码，直接删除代码即可，因为这段代码将会在版本控制工具中进行跟踪。

通常应避免使用大量注释，因为代码应尽可能表明其意图，仅需要间歇性的几行注释即可「这不适用于生成文档的注释」。在一个方法中包含大量注释意味着开发人员编写的代码逻辑混乱、不严谨。那么首先应该考虑的是重构代码或者梳理代码逻辑，而不是编写大量的注释。

注释对于对外公共的 API 很重要，特别是应用程序平台 API 或可重用代码。这部分代码是提供给其他的开发者使用的，但是同样要记住编写注释的规范和原则。

使用系统 `NS_REQUIRES_SUPER`、`NS_DESIGNATED_INITIALIZER`、`DEPRECATED_MSG_ATTRIBUTE`、`DEPRECATED_ATTRIBUTE` API 时也需要添加注释。

### 文档注释

尽可能只在 .h 文件中使用 Doxygen / AppleDoc 语法完成文档注释。

**推荐:**

```objc
/// 启动连接并实现数据转模型，通过 Block 方式回调数据
/// 如果需要自定义数据解析，实现 JSONConvertible 方法即可
///
/// @param convert 可转换的模型对象
/// @param success 成功回调
/// @param failure 失败回调
- (void)startWithConvert:(Class)convert
                 success:(nullable ConnectTaskBlock)success
                 failure:(nullable ConnectTaskBlock)failure;

```

## 协议

协议语法和代理语法类型:

```objc
@protocol XYZPerson <NSObject>

- (BOOL)somethingProtocolMethod;

@end

@interface XYZMutualAttraction : NSObject <XYZPerson>

@end

@implementation XYZMutualAttraction

- (BOOL)somethingProtocolMethod {
 // ....
}

@end

```

优先使用[属性](#属性), 而不是协议中的[方法](#方法)。

**协议「Protocols」**和**[代理](#代理)「Delegates」** 语法是一致，但是它们还是有细微的区别:

- `协议` 倾向声明一系列的方法，遵守协议的类负责实现，协议和遵守协议方没有太多关系。
- `协议` 方法更多地选择`@required`。
- `代理` 则跟倾向于将自己负责处理的事情交给别的类来做，代理对象和被代理对象存在 `拥有` 的关系。
- `代理` 方法更多地选择`@optional`。
- 实际上在 Objective-C 中对此并没有严格限制，但是其中的一些命名规范还是需要遵守的。

## init and dealloc

`init` 方法应该放在实现的顶部，且在 `@synthesize` 和 `@dynamic` 语句之后。`dealloc` 应该直接放在类的 `init` 方法下面。

`init` 语法结构:

```objc
- (instancetype)init {
    if (self = [super init]) {
        // ...
    }

    return self;
}

- (void)dealloc {
    // ...
}

```

对于已声明的 `init` 方法，即使只有一个，所有类都应该调用 `NS_DESIGNATED_INITIALIZER` 标识的 `init` 方法以保证类的正确初始化。

## instancetype vs id

- 如果不知道 `instancetype` 是什么？请阅读[这份](https://nshipster.cn/instancetype/)和[这份](https://developer.apple.com/library/archive/releasenotes/ObjectiveC/ModernizationObjC/AdoptingModernObjective-C/AdoptingModernObjective-C.html#//apple_ref/doc/uid/TP40014150)文档。
- 对于 `init` 方法，我们应该使用 Objective-C 2.0 规范，因此请在 `init` 方法中 **_始终使用 instancetype_** 作为返回值类型。
- 对于工厂方法，有两种情况，这两种方式能够很好的表达便利构造函数。
  - 当工厂方法可以被子类化时: **_使用 instancetype_**
  - 当工厂方法不打算被子类化时: **_使用显示类型_**

## alloc-init vs new

Objective-C 的文件中
不要使用 `-new` 关键字初始化对象, 使用 `-alloc` 和 `-init` 链初始化对象:

在 Objective-C++ 的文件中
可以使用 `-new` 关键字初始化对象, 也可以使用 `-alloc` 和 `-init` 链初始化对象:

```objc
XYZPerson *person = [[XYZPerson alloc] init]; // 推荐
XYZPerson *person2 = [XYZPerson new]; // 不推荐
```

## 字面量

当创建这些不可变对象实例时，应该使用 `NSString`、`NSDictionary`、`NSArray` 和 `NSNumber` 字面量来初始化。要特别注意 `nil` 值不能被传递到 `NSArray` 和 `NSDictionary` 字面量中，因为这将会导致崩溃。

**推荐:**

```objc
NSArray *names = @[@"Brian", @"Matt", @"Chris", @"Alex", @"Steve", @"Paul"];
NSDictionary *productManagers = @{@"iPhone" : @"Kate", @"iPad" : @"Kamal", @"Mobile Web" : @"Bill"};
NSNumber *shouldUseLiterals = @YES;
NSNumber *buildingZIPCode = @10018;
```

**不可取:**

```objc
NSArray *names = [NSArray arrayWithObjects:@"Brian", @"Matt", @"Chris", @"Alex", @"Steve", @"Paul", nil];
NSDictionary *productManagers = [NSDictionary dictionaryWithObjectsAndKeys: @"Kate", @"iPhone", @"Kamal", @"iPad", @"Bill", @"Mobile Web", nil];
NSNumber *shouldUseLiterals = [NSNumber numberWithBool:YES];
NSNumber *buildingZIPCode = [NSNumber numberWithInteger:10018];
```

## CGRect 函数

当访问 `CGRect` 的 `x`、`y`、`width` 或 `height` 成员时，请使用[`CGGeometry` 函数](https://developer.apple.com/documentation/coregraphics/cggeometry) 而不是直接访问 struct 成员:

**推荐:**

```objc
CGRect frame = self.view.frame;

CGFloat x = CGRectGetMinX(frame);
CGFloat y = CGRectGetMinY(frame);
CGFloat width = CGRectGetWidth(frame);
CGFloat height = CGRectGetHeight(frame);
```

**不推荐:**

```objc
CGRect frame = self.view.frame;

CGFloat x = frame.origin.x;
CGFloat y = frame.origin.y;
CGFloat width = frame.size.width;
CGFloat height = frame.size.height;
```

## 常量

用常量替代 `#define` 宏定义，常量类型 IDE 可以检查类型，方便定位错误，也可以使用内联函数和类方法来替代宏定义。

**推荐:**

```objc
+ (CGFloat)thumbnailHeight {
    return 50.0;
}

+ (NSString *)nibName {
    return @"XYZDefaultProfileViewController";
}

static NSString * const XYZDefaultProfileViewControllerNibName = @"nibName";
static const CGFloat XYZImageThumbnailHeight = 50.0;

// C/C++
const char *kConcurrentQueueName = "com.example.concurrent.queue";

// Objective-C/Objective-C++
FOUNDATION_EXPORT NSInteger const ConnectTaskCacheNotFoundErrorCode;
UIKIT_EXTERN const CGSize UILayoutFittingCompressedSize;
UIKIT_EXTERN NSNotificationName const UIApplicationProtectedDataWillBecomeUnavailable;

```

**不可取:**

```objc
#define XYZDefaultProfileViewControllerNibName @"nibName"

#define XYZImageThumbnailHeight 50.0
```

## 私有属性

私有属性应该在类的实现文件的类扩展「匿名类别」中声明。

**推荐:**

```objc
@interface XYZAdvertisement ()

@property (nonatomic) GADBannerView *googleAdView;
@property (nonatomic) ADBannerView *iAdView;
@property (nonatomic) UIWebView *adXWebView;

@end
```

## 私有头文件

私有文件命名格式为：XYZPrivate.h 只能在其他文件的实现文件中引用私有头文件，不能在类的 .h 文件中引用。

**推荐:**

```objc
// Foo.h

@class Bar;
@protocol Baz;

@interface Foo : NSObject

@property (nonatomic, readonly) Bar *bar;
@property (nonatomic, weak) id<Baz> baz;

@end

// Foo_Private.h

#import "Foo.h"

#import "Bar.h"
#import "Baz.h"
#import "Qux.h"

@interface Foo ()

@property (nonatomic) Qux *qux;

@end

// Foo.m

#import "Foo_Private.h"
...

// FooTests.m

#import "Foo_Private.h"
...

```

## 布尔值

因为 `nil` 会被解析为 `NO` ，所以没有必要在条件中比较它。永远不要直接与 `YES` 进行比较，因为 `YES` 被定义为 1，而 `BOOL` 值最多可以为 8 位。这样可以保持代码的一致性，同样逻辑也更加清晰。

**推荐:**

```objc
if (!someObject) {
}
```

**不推荐:**

```objc
if (someObject == nil) {
}
```

---

**推荐:**

```objc
if (isAwesome)
if (![someObject boolValue])
```

**不可取:**

```objc
if (isAwesome == YES)
if ([someObject boolValue] == NO)
```

---

如果 `BOOL` 属性的名字表示为形容词，该属性可以省略 `is` 前缀，但是通常 `get` 方法前面会添加 `is` 前缀，例如:

```objc
@property (assign, getter=isEditable) BOOL editable;
```

示例来源于[Cocoa 编码规范](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/NamingIvarsAndTypes.html)。

## 代码块

使用 `block` 需要注意一些内存问题，从长远来看，这可能会导致应用程序内存泄漏。所以良好的代码风格可以反映出扎实的编码功底并有效地减少可能会出现的问题。当从 **任何的** `block` 中访问 `self` 时，**总是**声明一个弱引用 self。

**_推荐:_**

总是使用 self 的若引用，即使这里不会循环引用。

```objc
__weak typeof(self) weakSelf = self;
[UIView animateWithDuration:(animated ? 0.2 : 0.0) animations:^{
    weakSelf.inputView.hidden = hidden;
    weakSelf.inputView.userInteractionEnabled = !hidden;
    [weakSelf updateTableViewContentInsets];
    [weakSelf updateScrollIndicatorInsets];
}];
```

或者使用 `[libextobjc](https://github.com/jspahrsummers/libextobjc)` 库的宏可以非常方便地使用 `@weakify/@strongify`。

```objc
@weakify(self);
[UIView animateWithDuration:(animated ? 0.2 : 0.0) animations:^{
    @strongify(self);
    self.inputView.hidden = hidden;
    self.inputView.userInteractionEnabled = !hidden;
    [self updateTableViewContentInsets];
    [self updateScrollIndicatorInsets];
}];
```

**_禁止:_**

```objc
[UIView animateWithDuration:(animated ? 0.2 : 0.0) animations:^{
    self.inputView.hidden = hidden;
    self.inputView.userInteractionEnabled = !hidden;
    [self updateTableViewContentInsets];
    [self updateScrollIndicatorInsets];
}];
```

## 单例

通常尽可能避免使用它们，而应使用依赖项注入「NS_DESIGNATED_INITIALIZER 方法」。有必要的话所需的单例对象应使用线程安全模式来创建其共享实例

```objc
+ (instancetype)sharedInstance {
   static id sharedInstance = nil;

   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
   });

   return sharedInstance;
}
```

这么操作可以防止可能发生的崩溃，因为 `dispatch_once` 本身是多线程安全的。

## Xcode 项目

如果条件允许，请**始终**在 Target 的 “Build Settings” 中打开 “Treat Warnings as Errors”「GCC_TREAT_WARNINGS_AS_ERRORS」，并启用尽可能多的其他警告。如果您需要忽略特定警告，请使用 [Clang's pragma feature](http://clang.llvm.org/docs/UsersManual.html#controlling-diagnostics-via-pragmas)。

## 代码格式化

**始终**启用 clang-format 插件格式化代码。

```ruby
# 进入项目根目录下执行命令
sh "tools/spacecommander/format-objc-files-in-repo.sh" # 格式化整个项目
sh "tools/spacecommander/format-objc-files.sh -s" # 提交代码时格式化所有不符合规范的文件
sh "tools/spacecommander/format-objc-file.sh {#FILEPATH}" # 提交代码时格式化单个不符合规范的文件
```
