# SwiftUtilities

This is a collection of some Swift utilities.

Build the documentation using DocC, e.g. in Xcode via the `Product` / `Build Documentation` command. But in the current state of DocC, that documentation will not document any extensions[^1], _so currently you need to look the extensions up in the code._ In the overview below it is noted which types are extended.

[^1]: see the Swift issue [SR-15410](https://github.com/apple/swift-docc/issues/210)

Overview:

- file `AutoreleasepoolShim.swift`: Allowing you the use of auto-release pools to optimize memory footprint on Darwin platforms while maintaining compatibility with Linux where this API is not implemented (and not necessary).
- file `DataTypes.swift`: Definitons of some helpful data types.
- file `Errors.swift`: Definition of a basic error with desription, and of the usefule operastor `?!`.
- file `FileUtilities.swift`: Some definitions to be useful when working with files, e.g. `URL.files(withPattern:findRecursively:)` to find files. _Contains extensions of `FileHandle`, `URL`, `[URL]`, and `String`._
- file `Lengths.swift`: Some definitions useful when working with lengths (e.g. in layouts).
- file `Properties.swift`: Some definitions for working with key-value properties lists in files.
- file `SequenceUtilities.swift`: Definitions useful when working with sequences. _Contains extensions of `Sequence`._
- file `StringUtilities.swift`: Definitions useful when working with string and substrings. _Contains extensions of `String`, `[String]`, and `StringProtocol`._
- file `SystemUtilities.swift`: Some definitions useful e.g. to find out about the current platform.
- file `TimeUtilities.swift`: Some definitions useful when working with time, e.g. for measuring durations.
