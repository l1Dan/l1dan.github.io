---
layout: post
title: Swift闭包
tags: 
    - Swift
categories: 
    - iOS
date: 2016-06-16 23:11:24
updated: 2016-10-30 19:51:00
description: 闭包是自包含的函数代码块，可以在代码中被传递和使用。闭包可以捕获和存储其所在上下文中任意常量和变量的引用。这就是所谓的闭合并包裹着这些常量和变量，俗称闭包。
---

<!-- 这里的日期要注意不能大于今天 -->

### 概念

闭包是自包含的函数代码块，可以在代码中被传递和使用。闭包可以捕获和存储其所在上下文中任意常量和变量的引用。这就是所谓的闭合并包裹着这些常量和变量，俗称闭包。

### 语法

```swift
// 闭包的表达式
{ (parameters) -> returnType in
	statements
}
```

我们一起做几个例子来加深对闭包的了解。首先做个简单的加法`+`，一般这么写：

```swift
func adder(_ a: Double, _ b: Double) -> Double {
    return a + b
}
adder(4, 9)
```

其实两个数相加的目的已经达到，但我们还不满足它只能做加`+`运算。希望还可以计算减`-`、乘`x`、除`÷`运算。

```swift
func calculate(_ op1: Double, _ op2: Double, symbol: String) -> Double {
    switch symbol {
    case "+": return op1 + op2
    case "-": return op1 - op2
    case "x": return op1 * op2
    case "÷": return op1 / op2
    default : return 0;
    }
}
calculate(9, 3, symbol: "-")
calculate(9, 3, symbol: "÷")
```

这段糟糕的代码看起还不错，但这真的是我们想要的么？美观？但不实用，简洁？却不优雅。因为它并不能明确告诉我们有几种计算方式，况且字符串与数学计算结合到一起也不是什么好的注意，我相信没有人会喜欢的，因此还需要继续优化它。

```swift
func calculate(_ op1: Double, _ op2: Double, symbol: (Double, Double) -> Double) -> Double {
    return symbol(op1, op2)
}
calculate(9, 3, symbol: adder) // 需要借助之前的 adder(_:_:)
```

看起来是好了很多，却增加了外部函数的依赖，比起之前的写法确实要好一些，但并不 Swift，我们可以把`adder(_:_:)`方法的表达式写到`调用者参数`中：

```swift
// 如果是这样写的，编译器会很遗憾地告诉你这是错误的写法
calculate(9, 3, symbol: adder(_ a: Double, _ b: Double) -> Double {
    return a + b
})
// 正确的写法应该是这样子的
calculate(9, 3, symbol: { (a: Double, b: Double) -> Double in
    return a + b
})
```

第二种写法为什么正确？首先闭包表达式是一个匿名闭包，不能有函数名。所以我们需要去掉函数名将表达式用`{}`括起来，还需要用`in`关键字将参数、返回值与函数体分开便于编译器区分，而第二种写法正是这么做的。

Swift 的闭包非常神奇，可以有多种写法，这些写法都是有规律可寻的。</br>

1. 利用上下文推断参数和返回值类型</br>
2. 隐式返回单表达式闭包，即单表达式闭包可以省略 return 关键字</br>
3. 参数名称缩写</br>
4. 尾随（Trailing）闭包语法

```swift
// 最后可以写成下面这样的， 其中的变换也不难
calculate(3, 9) { $0 * $1 }
// Swift标准库中已经实现`*`函数所以我们还可以直接调用函数`*`
calculate(3, 9, *)
```

但是还有一种比上面更优雅的写法（23333）

```swift
func calculate<T>(res: T) -> T { return res }
6$ calculate(3 > 9) // 看到这里是不是感到有种被耍的感觉
7$ let res = 3 > 9  // 好吧！其实这个才是我想说的。 如果上面的理解了，理解这个应该不难。

// 还有下面这些`一元运算符`、`二元运算符`、`三元运算符`都可以用闭包实现
var optionalValue: String?
let res2 = optionalValue ?? "defaultValue"
let res3 = optionalValue == nil ? "defaultValue" : optionalValue!
...
```

### 思考

这道题是我从[唐巧的技术博客][1]中看到的。题目：我们需要构造一个工厂函数，这个函数接受两个函数作为参数，返回一个新的函数。新函数是两个函数参数的叠加作用效果。
举一个具体的例子，假如我们有一个 `+2` 的函数，有一个 `+3` 的函数，那用这个工厂函数，我们可以得到一个 `+5` 的函数。
又比如我们有一个 `*2` 的函数，有一个 `*5` 的函数，用这个工厂函数，我们就可以得到一个 `*10` 的函数。

```swift
func funcBuild(_ f: @escaping (Int) -> Int, _ g: @escaping (Int) -> Int) -> (Int) -> Int {
	return {
		f(g($0))
	}
}

let f1 = funcBuild({$0 + 2}, {$0 + 3})
f1(0) // 得到 5
let f2 = funcBuild({$0 * 2}, {$0 * 5})
f2(1) // 得到 10
```

因为这里面只有最终的结果，并没有推导的过程，所以开始看的时候很吃力，并且有两个地方不太明白，函数的实现部分的闭包调用与函数调用时参数的闭包调用。为什么是这样的`f(g($0))`和这样的`{$0 + 2}`。后来自己推导了一番也就明白了。我觉得这中间推导的过程很有意思，有必要和大家分享一下。

```swift
// 推导过程我就只写函数体，这样对比看起来要比较清晰。函数的调用部分也是一个匿名闭包这里就不讨论了。
// 变形一
...
// 表示函数 g(_:)
func adder1(x: Int) -> Int { return g(x) }
// 表示函数 f(_:)
func adder2(y: Int) -> Int { return f(y) }
// 上面两个函数其实没有必要写，放在这里知识方便理解

func sum(z: Int) -> Int {
	let res = adder1(z)
	return adder2(res)
}
return sum
...

// 变形二
...
func sum(z: Int) -> Int {
	let res = g(z)
	return f(res)
}
return sum
...

// 变形三
...
func sum(z: Int) -> Int {
	return f(g(z))
}
return sum
...

// 变形四
...
return { (z: Int) -> Int in
	return f(g(z))
}
...

// 最终
...
return { f(g($0)) }
...
```

写这篇文章的目的是我想用 Swift 这门语言以 Swift 的编程方式来思考问题。其实这里的推导过程也是从其他语言编程方式慢慢转向 Swift 语言编程方式的过程，而这个过程往往是最容易忽视的，希望我以后更加注重这个过程。恩，祝大家玩的开心！有问题下面可以留言，我会及时回复的 😁。

[1]: http://blog.devtang.com/2016/02/27/swift-gym-2-function-argument/
