**SwiftUsing** brings to Swift the `using` feature from Jai, [Jonathan Blow](https://twitter.com/Jonathan_Blow)'s programming language. It uses [SwiftSyntax](https://github.com/apple/swift-syntax) to code generate the required code.

To learn more about **SwiftUsing** development you can check out the blog post [Implementing using in Swift with SwiftSyntax](http://alejandromp.com/blog/2019/04/22/implementing-using-in-swift-with-swiftsyntax/).

## What is `using`

`using` helps with [Struct composition](https://alejandromp.com/blog/2018/02/03/using-structs-swift-jai-oop/).

It allows you to recover the nice syntax from class inheritance when you use `struct`s instead.

```swift
struct User {
    var name: String
    var age: Int
}

struct Friend {
    // using
    let user: User
    var friendshipDate: Date
}

friend.name // with class inheritance
friend.user.name // with struct composition :(
friend.name // with struct composition and using !!
```

## Usage

1. Annotate a property with a comment: `// using`

```swift
struct Friend {
    ...
    // using          <- add this comment
    let user: User
    ...
}
```

*Note that both types must be in the same file. See Known limitations below.*

2. Run the command line tool

⚠️ This command will overwrite the original file so make sure you have a copy or you're using a versioning control system like Git in case something goes wrong.

```swift
swiftusing /path/to/file
```

## Installation

Clone the repo and run `make install`.

## Known limitations

- Basic declaration syntax `let/var identifier: Type`
- Reliant on comments (is just an external tool after all)
- Single file, using types must be in the same file.
- No collision detection, the compiler will error instead.

## Acknowledgements

- [Jonathan Blow](https://twitter.com/Jonathan_Blow) for sharing the development of Jai
- [pointfree](https://www.pointfree.co/episodes/ep53-swift-syntax-enum-properties) for the informative and inspiring videos
- [Swift AST Explorer](https://swift-ast-explorer.kishikawakatsumi.com)
- [swift-syntax](https://github.com/apple/swift-syntax) obviously!
- [Yaap](https://github.com/hartbit/Yaap)
- [PackageBuilder](https://github.com/pixyzehn/PackageBuilder)

## Contributions & support

**SwiftUsing** is developed completely in the open, and your contributions are more than welcome.

This project does not come with GitHub Issues-based support, and users are instead encouraged to become active participants in its continued development — by fixing any bugs that they encounter, or improving the documentation wherever it’s found to be lacking.

If you wish to make a change, [open a Pull Request](https://github.com/alexito4/SwiftUsing/pull/new) — even if it just contains a draft of the changes you’re planning, or a test that reproduces an issue — and we can discuss it further from there.

## Author

Alejandro Martinez | http://alejandromp.com | [@alexito4](https://twitter.com/alexito4)