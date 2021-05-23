---
title: Swift泛型
tags: Swift
categories: iOS
date: 2016-07-23 18:27:03
---

### 定义

泛型是程序设计语言的一种特性。它能够根据使用者自定义的需求编写出适用于任意类型并且灵活可复用的组件。使用泛型可以避免代码的重复编写，可以使代码更加清晰，能让使用者的想象发挥到极致。泛型是`Swift`的一个重要的特性，在`Swift`标准库中也大量运用了这个特性。比如我们经常使用的字典`Dictionary<Key : Hashable, Value>`还有数组`Array<Element>`，你可以使用任意类型来创建字典和数组，这就是泛型强大之处。

<!-- more -->

### 泛型与`Any AnyObject`区别

泛型根据我个人的理解其实就是一个未知类型、一个占位类型，只不过这种类型会经过 Swift 类型系统的严格检查，但是又不会去查找这种类型的真实类型，只有当函数调用的时候才会替换为真实类型。其实在 Swift 类型系统中还有几种类似泛型的`东西`--`Any`和`AnyObject`，Apple 官方对其的解释是：`Any`可以表示任意类型，而`AnyObject`可以表示任意实体。Swift 的安全特性一直都是 Apple 煽动开发者的一大亮点，那么`Any`和`AnyObject`是什么鬼？其实这是因为历史原因而导致 Swift 妥协的产物。这里我们暂且不讨论`Any`和`AnyObject`的区别，总之尽量不要使用这两个家伙，因为他们会避开 Swift 类型系统的检查，Swift 类型系统是我们好朋友我们不应该欺骗她。

#### 避免重复&函数泛型化

需求：交换两个值。我们用一个交换值的例子来引入泛型的概念。如果编写一个不使用泛型来交换两个值会是怎么样的呢？大概就是下面这样的：

```swift

func swapTwoInts(_ some: inout Int, _ other: inout Int) { (some, other) = (other, some) }
func swapTwoStrings(inout someString: String, inout anotherString: String) { (someString, anotherString) = (anotherString, someString) }
...
```

上面两种写法是非常痛苦的。假如还有`Double，Array...`呢？可能你会说我可以拷贝一份改一下入参不就可以了吗。如果你喜欢这么做我也不会反对，但是在所有编程准则里始终都应该要牢记一条原则：`不要重复自己(Don't Repeat Yourself，DRY)`,这是编程最基本的原则。所以我们还是考虑下否要优化这段代码。交换两个值的函数本该非常具有通用性，他们唯一不同的只是传入参数的类型。我们只要将入参用占位符替换就可以将函数写成一个非常具有通用型的泛型函数，这个函数类型替换的过程称之为：`函数泛型化`。假设我和你的想法是一致，那么应该会是下面这样的：

```swift
func swapTwoValues<T>(_ v1: inout T, _ v2: inout T) { (v1, v2) = (v2, v1) }
```

看起来没什么区别，唯一不同的是实际类型被`T`替换，这里的`T`是占位符，你可以根据自己的喜好而定，一般用`T`，`U`，`V`来标识类型占位符。`T`占位符不关心将来传入参数的类型。但是两者的传入参数必须保持一致，换句话说`v1`和`v2`类型必须是`T`。`inout`关键字说明传入的参数是一个地址。现在的`swapTwoValues(_:_:)`函数可以交换任意同一类型的两个值了，你甚至可以用这个泛型函数来定义上面两个非泛型函数。

```swift
func swapTwoInts(_ some: inout Int, _ other: inout Int) { swapTwoValues(&some, &other) }
func swapTwoStrings(_ some: inout String, _ other: inout String) { swapTwoValues(&some, &other) }
```

其实可以直接使用在 Swift 标准库中已经定义好的`swap(_:_:)`函数。这里并不建议定义自己的`swap(_:_:)`函数(`不要重复发明轮子`)，为的仅仅是方便引入泛型的概念。

#### 类型泛型化

Swift 是一门静态类型化语言。也就是说 Swift 编译器是非常清楚地知道正在处理的是什么类型，并不会像动态语言具有灵活型。这种严格的特性意味着失去了一定的灵活性。这时候泛型就该出场了。像字典`Dictionary<Key : Hashable, Value>`和`Array<Element>`就是类型泛型化的结果。创建泛型类型只需要这样`Tree<T>`就可以定义一个泛型`Tree`类型。我一般习惯用`T`来标识占位符。下面我们就以泛型对象`Tree<T>`为例:

```swift
struct Tree<T> {
	let value: T
	var children = [Tree<T>]()

	init(_ value: T) { self.value = value }

	mutating func addChildren(_ value: T) -> Tree {
		let newChild = Tree(value)
		children.append(newChild)
		return newChild
	}
}
```

一旦定义了泛型类型，就可以由它来创建一个具体类型的非泛型类型。例如创建一个`Int`类型和`String`类型版本：

```swift
var integerTree = Tree(5)
integerTree.addChildren(12)
var stringTree = Tree("Hello")
stringTree.addChildren("World")
```

在使用`Tree`类型时你甚至可以不用写类似`Tree<Int> Tree<String>`的代码，这是因为 Swift 可以从初始化的条件判断出`Tree`的真实类型。添加`addChildren(_:)`方法会改变结构体内部成员`children`，所以需要加上关键字`mutating`，好处就是当你看到这个结构体时会提醒你哪些地方是会被改变的，再一个就是如果想要在初始化完毕之后改变结构体内部的成员，那么就必须要在调用方法前面加上`mutating`关键字，否则无法编译通过。

### 泛型扩展

有时候我们需要为泛型类型扩充一些函数，使得泛型类型的功能更加强大，更加符合我们需求。当然这也是拒绝写重复代码的途径之一。在泛型类型中已经存在占位符，所以我们就不需要在扩展中重复定义占位符(`类型参数名`)，就算定义不一样的类型参数名也是不行的，Swift 扩展中是不允许这么做的。如果我们希望`Tree<T>`拥有移除最后一个元素的方法，那么可以这么定义：

```swift
extension Tree {
    mutating func removeLast() -> Tree<T> { return children.removeLast() }

    func printDescription<U: CustomStringConvertible>(input: U?) -> String {
        guard let input = input else { return "empty description."}
        return "\(input.description)description"
    }
}
```

`removeLast() -> Tree<T>`函数移除最后一个元素，并将`Tree<T>`返回，这里的`T`使用的就是在定义泛型类型时所使用的的类型参数名。可以看到在方法中我们没有重新定义类型参数名`T`，直接使用的是本类中的类型参数名。如果你想这么`extension Tree<T>`定义的话是会报错的。

### 类型约束&语法

```swift
// 语法
func someFunction<T: SomeClass, U: SomeProtocol>(someT: T, someU: U){
	statements
}
```

泛型包括的范围非常广泛，当需要限制泛型的使用范围时就可以使用类型约束。前面的`printDescription`函数中`input`的值就遵循`CustomStringConvertible`协议，意味着传入参数一定会有`description`方法。所以才可以使用`input`的`input.description`方法。在`someFunction(_:_:)`中`T`类型必须是 SomeClass 类或子类，`U`类型必须是遵循 SomeProtocol 协议类型。

### 关联类型

关联类型可以通过`associatedtype`关键字来定义，关联类型其实就是一个类型参数名。尤其是在声明协议的时候可以为一个或多个关联类型，来为协议中的某个类型提供类型参数名。我们可以认为带有关联类型的协议是`泛型协议`。

#### 关联类型实践

```swift
protocol Extensible {
    associatedtype Element
    subscript(i: Int) -> Element { get }
}
```

这里定义了一个可扩展协议`Extensible`，任何类型只要采纳这个协议，就必须提供协议中声明的全部实现，也就是要实现`subscript(_:)`方法。协议中我们只要求声明方法，具体实现交给采纳协议者。协议中关联类型`Element`的实际类型我们同样不需要关心。看个例子，比如`Tree`采纳这个协议：

```swift
extension Tree: Extensible {
    subscript(i: Int) -> Tree {
        return children[i]
    }
}
```

协议中`Element`最终会变成实现者的类型，也就是`Tree`类型，不能在实现者中使用关联类型。

### 总结

这篇文章中写的大部分都是对泛型编程的讨论。泛型编程可以编写出高质量、简洁、优雅、稳定...的代码，就这诱人的几点还只是泛型编程的冰山一角，想要了解更多还需要我们继续深入挖掘，其实她就在那里等着有一天被你发现。谢谢大家，祝玩得开心！
