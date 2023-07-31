# SwiftUtilities

This is a collection of some Swift utilities.

## Usage

Add the package in Package.swift:

```Swift
.package(url: "https://github.com/stefanspringer1/SwiftUtilities", from: "...my minimal version..."),
```

Add as dependency of the target:

```Swift
.product(name: "Utilities", package: "SwiftUtilities"),
```

Add an `import` statement in the source code:

```Swift
import Utilities
```

## API documentation

Build the API documentation using DocC, e.g. in Xcode via the `Product` / `Build Documentation` command. Include the `--include-extended-types` option (available since Swift 5.8) to also document extensions to types from other modules: `swift package generate-documentation --include-extended-types`.

[^1]: see the Swift issue [SR-15410](https://github.com/apple/swift-docc/issues/210)

## Overview

- **AutoreleasepoolShim.swift:** Allowing you the use of auto-release pools to optimize memory footprint on Darwin platforms while maintaining compatibility with Linux where this API is not implemented (and not necessary).
- **CharacterUtilities.swift:** Some definitions to be useful when working with characters, e.g. for characterizing them. _Contains extensions of `String` and `UnicodeScalar`._
- **DataTypes.swift:** Definitons of some helpful data types.
- **Errors.swift:** Definition of a basic error with desription, and of the usefule operator `?!`.
- **FileUtilities.swift:** Some definitions to be useful when working with files, e.g. `URL.files(withPattern:findRecursively:)` to find files. _Contains extensions of `FileHandle`, `URL`, `[URL]`, and `String`._
- **Lengths.swift:** Some definitions useful when working with lengths (e.g. in layouts).
- **Parallel.swift:** Utilities for parallel execution.
- **Process.swift:** Definitions useful for running external programs.
- **Properties.swift:** Some definitions for working with key-value properties lists in files.
- **SequenceUtilities.swift:** Definitions useful when working with sequences. _Contains extensions of `Sequence`._
- **StringUtilities.swift:** Definitions useful when working with string and substrings. _Contains extensions of `String`, `[String]`, and `StringProtocol`._
- **SystemUtilities.swift:** Some definitions useful e.g. to find out about the current platform.
- **TimeUtilities.swift:** Some definitions useful when working with time, e.g. for measuring durations.
