import XCTest
@testable import Utilities

final class UtilitiesTests: XCTestCase {
    
    let characterClasses = CharacterClasses()
    
    /*func createFile(inSubDirectopry directoryName: String) {
        // Note that the according subdirectory has to exist already,
        // but the file to create should not exist.
#if os(Windows)
        let path = "C:\\tmp\\\(directoryName)\\test.txt"
#else
        let path = "/tmp/\(directoryName)/test.txt"
#endif
        print("!!!!! \(FileManager.default.createFile(atPath: path, contents: nil))")
    }

    func testWritableFile_OK() throws {
        createFile(inSubDirectopry: "a")
    }

    func testWritableFile_WINDOWSCRASH() throws {
        createFile(inSubDirectopry: "ä")
    }*/

    func testNoNEmpty() {
        XCTAssertEqual("hello".nonEmpty, "hello")
        XCTAssertEqual("".nonEmpty, nil)
    }
    
    func testWithoutQuotes() {
        XCTAssertEqual("hello".withoutQuotes, "hello")
        XCTAssertEqual("\"hello\"".withoutQuotes, "hello")
        XCTAssertEqual("'hello'".withoutQuotes, "hello")
    }
    
    func testCharacterClassForName() throws {
        _ = CharacterClass.characterClass(ofName: "SMALL_LATIN_LETTERS")
    }
    
    func testCharacterClassNamesInRegex() throws {
        let input = #"[${SMALL_LATIN_LETTERS}${CAPITAL_LATIN_LETTERS}]"#
        let result = try input.replacingCharacterClassesWithRegex(usingCharacterClasses: characterClasses)
        XCTAssertEqual(result, #"[\x{61}-\x{7A}\x{41}-\x{5A}]"#)
    }
    
    func testCharacterClassNamesInRegexWithEscape() throws {
        let input = #"[${SMALL_LATIN_LETTERS}\${CAPITAL_LATIN_LETTERS}]"#
        let result = try input.replacingCharacterClassesWithRegex(usingCharacterClasses: characterClasses)
        XCTAssertEqual(result, #"[\x{61}-\x{7A}\${CAPITAL_LATIN_LETTERS}]"#)
    }
    
    func testReplacingTextualRegexWithPattern() throws {
        let input = "aba"
        let result = input.replacing(regex: #"a([a-z])a"#, withTemplate: "a$1$1a")
        XCTAssertEqual(result, "abba")
    }
    
    func testReplacementsOfUnicodeScalarsUsingLiteralRegex() throws {
        let input = "a\u{0358}c"
        var result = ""
        if #available(macOS 13.0, *) {
            let regex = #/([a-z])\x{0358}([a-z])/#.matchingSemantics(.unicodeScalar)
            result = input.replacing(regex, withTemplate: "$1\u{0357}$2")
        }
        XCTAssertEqual(result, "a\u{0357}c")
    }
    
    func testReplacementsOfUnicodeScalarsUsingInitalizedRegex() throws {
        let input = "a\u{0358}c"
        var result = ""
        if #available(macOS 13.0, *) {
            let regex = try! Regex(#"([a-z])\x{0358}([a-z])"#).matchingSemantics(.unicodeScalar)
            result = input.replacing(regex, withTemplate: "$1\u{0357}$2")
        }
        XCTAssertEqual(result, "a\u{0357}c")
    }
    
    func testReplacementsOfUnicodeScalarsUsingTextualRegex() throws {
        let text = "a\u{0358}c"
        let result = text.replacing(regex: #"([a-z])\x{0358}([a-z])"#, withTemplate: "$1\u{0357}$2", usingSemanticLevel: .unicodeScalar)
        XCTAssertEqual(result, "a\u{0357}c")
    }
    
    func testRegexForCharacterSet() throws {
        XCTAssertEqual(
            characterClasses.codePoints(forClass: .COMBINING_ABOVE).regexPart(usingCharacterClasses: characterClasses),
            #"""
            \x{300}\x{301}\x{302}\x{303}\x{304}\x{305}\x{306}\x{307}\x{308}\x{309}\x{30A}\x{30B}\x{30C}\x{30D}\x{30E}\x{30F}\x{310}\x{311}\x{312}\x{313}\x{314}\x{315}\x{31A}\x{31B}\x{33D}\x{33E}\x{33F}\x{340}\x{341}\x{342}\x{343}\x{344}\x{34A}\x{34B}\x{34C}\x{350}\x{351}\x{352}\x{357}\x{358}\x{35D}\x{35E}\x{360}\x{361}\x{363}\x{364}\x{365}\x{366}\x{367}\x{368}\x{369}\x{36A}\x{36B}\x{36C}\x{36D}\x{36E}\x{36F}\x{483}\x{484}\x{485}\x{486}\x{487}\x{2DE0}\x{2DE1}\x{2DE2}\x{2DE3}\x{2DE4}\x{2DE5}\x{2DE6}\x{2DE7}\x{2DE8}\x{2DE9}\x{2DEA}\x{2DEB}\x{2DEC}\x{2DED}\x{2DEE}\x{2DEF}\x{2DF0}\x{2DF1}\x{2DF2}\x{2DF3}\x{2DF4}\x{2DF5}\x{2DF6}\x{2DF7}\x{2DF8}\x{2DF9}\x{2DFA}\x{2DFB}\x{2DFC}\x{2DFD}\x{2DFE}\x{2DFF}\x{A674}\x{A675}\x{A676}\x{A677}\x{A678}\x{A679}\x{A67A}\x{A67B}\x{A67C}\x{A67D}\x{FE20}\x{FE21}\x{FE22}\x{FE23}\x{FE24}\x{FE25}\x{FE26}\x{FE2E}\x{FE2F}\x{346}\x{35B}\x{A66F}\x{A69E}
            """#
        )
    }
    
    func testRangesInRegexForNonLetters() throws {
        XCTAssertEqual("\u{222B}".contains(/[\x{0300}-\x{0333}\x{2200}-\x{22ED}]/), true)
        XCTAssertEqual("\u{0041}".contains(/[\x{0300}-\x{0333}\x{2200}-\x{22ED}]/), false)
        XCTAssertEqual("\u{0326}".contains(/[\x{0300}-\x{0333}\x{2200}-\x{22ED}]/), true)
        XCTAssertEqual("\u{0041}".contains(/[\x{0300}-\x{0333}\x{2200}-\x{22ED}]/), false)
    }
    
    func randomString(length: Int) -> String {
      let letters = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func randomSubString(length: Int) -> Substring {
      let letters = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length+5).map{ _ in letters.randomElement()! }).prefix(length)
    }
    enum AnyStringProtocol {
        case string(_ value: String)
        case substring(_ value: String.SubSequence)
    }
    
    @available(macOS 13.0, *)
    func testDataDirectory() throws {
        let dataFolder = try determineDataFolder(withSubPathComponents: ["a", "b", "c"])
        print(dataFolder.osPath)
    }
    
    func testAppendingToURL() throws {
        let url = URL(fileURLWithPath: "/tmp/haha")
        XCTAssertEqual(url.appending(components: "a", "b", "c").path, "/tmp/haha/a/b/c")
    }
    
    func testOccurrenceOfRegex() throws {
        
        // String:
        do {
            let text = "Count 123 and be 456 happy 789."
            let empty = text.startIndex..<text.startIndex
            
            do {
                let range = text.firstOccurrence(ofRegex: #"not there"#) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "")
            }
            
            do {
                let range = text.firstOccurrence(ofRegex: #"\d+"#) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "123")
            }
            
            do {
                let range = text.firstOccurrence(ofRegex: #"\d+"#, skipping: 2) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "789")
            }
            
            do {
                let range = text.firstOccurrence(ofRegex: #"\d+"#, skipping: 10) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "")
            }
        }
        
        // Substring:
        do {
            let text = "Count 123 and be 456 happy 789.".dropLast()
            let empty = text.startIndex..<text.startIndex
            
            do {
                let range = text.firstOccurrence(ofRegex: #"not there"#) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "")
            }
            
            do {
                let range = text.firstOccurrence(ofRegex: #"\d+"#) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "123")
            }
            
            do {
                let range = text.firstOccurrence(ofRegex: #"\d+"#, skipping: 2) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "789")
            }
            
            do {
                let range = text.firstOccurrence(ofRegex: #"\d+"#, skipping: 10) ?? empty
                XCTAssertEqual(String(text[range.lowerBound..<range.upperBound]), "")
            }
        }
    }
    
    /*func testXXX() throws {
        let source = URL(fileURLWithPath: "/Users/stefan/tmp")
        let target = URL(fileURLWithPath: "/Users/stefan/tmp Kopie")
        print(try source.isContained(inFileTree: target))
    }*/
    
    //func testEnvironmentWithPriorityPaths() {
    //    print(environment(withPriorityPaths: ["a", "b"]))
    //}
    
    /*
    func embraceCombinations(n: Int, m: Int, l: Int)  {
        let base0 = randomString(length: n)
        let pre0: String? = nil
        let post0: String? = nil
        XCTAssert(base0.embrace(pre: pre0, post: post0) == "\(base0)")

        let base1 = randomString(length: n)
        let pre1: String? = nil
        let post1 = randomString(length: m)
        XCTAssert(base1.embrace(pre: pre1, post: post1) == "\(base1)\(post1)")

        let base2 = randomString(length: n)
        let pre2: String? = nil
        let post2 = randomSubString(length: m)
        XCTAssert(base2.embrace(pre: pre2, post: post2) == "\(base2)\(post2)")

        let base3 = randomString(length: n)
        let pre3 = randomString(length: m)
        let post3: String? = nil
        XCTAssert(base3.embrace(pre: pre3, post: post3) == "\(pre3)\(base3)")

        let base4 = randomString(length: n)
        let pre4 = randomString(length: m)
        let post4 = randomString(length: m)
        XCTAssert(base4.embrace(pre: pre4, post: post4) == "\(pre4)\(base4)\(post4)")

        let base5 = randomString(length: n)
        let pre5 = randomString(length: m)
        let post5 = randomSubString(length: m)
        XCTAssert(base5.embrace(pre: pre5, post: post5) == "\(pre5)\(base5)\(post5)")

        let base6 = randomString(length: n)
        let pre6 = randomSubString(length: m)
        let post6: String? = nil
        XCTAssert(base6.embrace(pre: pre6, post: post6) == "\(pre6)\(base6)")

        let base7 = randomString(length: n)
        let pre7 = randomSubString(length: m)
        let post7 = randomString(length: m)
        XCTAssert(base7.embrace(pre: pre7, post: post7) == "\(pre7)\(base7)\(post7)")

        let base8 = randomString(length: n)
        let pre8 = randomSubString(length: m)
        let post8 = randomSubString(length: m)
        XCTAssert(base8.embrace(pre: pre8, post: post8) == "\(pre8)\(base8)\(post8)")

        let base9 = randomSubString(length: n)
        let pre9: String? = nil
        let post9: String? = nil
        XCTAssert(base9.embrace(pre: pre9, post: post9) == "\(base9)")

        let base10 = randomSubString(length: n)
        let pre10: String? = nil
        let post10 = randomString(length: m)
        XCTAssert(base10.embrace(pre: pre10, post: post10) == "\(base10)\(post10)")

        let base11 = randomSubString(length: n)
        let pre11: String? = nil
        let post11 = randomSubString(length: m)
        XCTAssert(base11.embrace(pre: pre11, post: post11) == "\(base11)\(post11)")

        let base12 = randomSubString(length: n)
        let pre12 = randomString(length: m)
        let post12: String? = nil
        XCTAssert(base12.embrace(pre: pre12, post: post12) == "\(pre12)\(base12)")

        let base13 = randomSubString(length: n)
        let pre13 = randomString(length: m)
        let post13 = randomString(length: m)
        XCTAssert(base13.embrace(pre: pre13, post: post13) == "\(pre13)\(base13)\(post13)")

        let base14 = randomSubString(length: n)
        let pre14 = randomString(length: m)
        let post14 = randomSubString(length: m)
        XCTAssert(base14.embrace(pre: pre14, post: post14) == "\(pre14)\(base14)\(post14)")

        let base15 = randomSubString(length: n)
        let pre15 = randomSubString(length: m)
        let post15: String? = nil
        XCTAssert(base15.embrace(pre: pre15, post: post15) == "\(pre15)\(base15)")

        let base16 = randomSubString(length: n)
        let pre16 = randomSubString(length: m)
        let post16 = randomString(length: m)
        XCTAssert(base16.embrace(pre: pre16, post: post16) == "\(pre16)\(base16)\(post16)")

        let base17 = randomSubString(length: n)
        let pre17 = randomSubString(length: m)
        let post17 = randomSubString(length: m)
        XCTAssert(base17.embrace(pre: pre17, post: post17) == "\(pre17)\(base17)\(post17)")
    }

    
    func testStringEmbrace() throws {
        let values = [0,5,50,100]
        for n in  values{
            for m in values {
                for l in values {
                    embraceCombinations(n: n, m: m, l: l)
                }
            }
        }
    }
    
    func testTrims() {
        let comp = "12345"
        let testString =  comp.embrace(pre: " ", post: " ")
        let testSubString = testString.prefix(10)
        XCTAssert(testSubString.trim() == comp)
        XCTAssert(testSubString.trimLeft() == "\(comp) ")
        XCTAssert(testSubString.trimRight() == " \(comp)")
    }
    
    func testContains() {
        let comp = "12345"
        XCTAssert(comp.contains(regex: "[0-9]{5}"))
        XCTAssert(!comp.contains(regex: "[0-9]{6}"))
    }
    
    func testReplace() {
        let comp = "12345"
        XCTAssert(comp.embrace(post: "678").replace(regex: "[5-9]+", by: "5") == comp)
    }
    
    func testUntil() {
        let comp = "12345"
        XCTAssert(comp.until(substring: "6") == comp)
        XCTAssert(comp.embrace(post: "678").until(substring: "6") == comp)
        XCTAssert(comp.embrace(post: "678").until(substring: "7") != comp)
    }
    */
    
    func testTrimming() {
        XCTAssertEqual("[\(" \n hal lo \n ".trimmingLeft())]", "[hal lo \n ]")
        XCTAssertEqual("[\(" \n hal lo \n ".trimmingRight())]", "[ \n hal lo]")
        XCTAssertEqual("[\(" \n hal lo \n ".trimming())]", "[hal lo]")
    }
    
    func testReplacingCharacterClassesWithRegex() throws {
        XCTAssertEqual(
            try "${LATIN_LETTERS}${CLOSING_DELIMITERS}".replacingCharacterClassesWithRegex(usingCharacterClasses: characterClasses),
            //#"\x{61}-\x{7A}\x{41}-\x{5A}\x{5C}\x{5D}\x{7C}\x{7D}\x{29}\x{2F}\x{2016}\x{2016}\x{2191}\x{2193}\x{2195}\x{21D1}\x{21D3}\x{21D5}\x{2309}\x{230B}\x{23B1}\x{27E9}\x{2986}\x{300B}\x{3015}\x{301B}"#
            // problem with ranges should be fixed in newer Swift versions (see test: testRangesInRegexForNonLetters()):
            #"\x{61}-\x{7A}\x{41}-\x{5A}\x{5C}-\x{5D}\x{7C}-\x{7D}\x{29}\x{2F}\x{2016}\x{2016}\x{2191}\x{2193}\x{2195}\x{21D1}\x{21D3}\x{21D5}\x{2309}\x{230B}\x{23B1}\x{27E9}\x{2986}\x{300B}\x{3015}\x{301B}"#
        )
    }
    
    func testReplacingCharacterEntitiesWithRegex() throws {
        XCTAssertEqual(
            try "&auml;&alpha;".replacingCharacterEntitiesWithRegex(),
            #"\x{e4}\x{3b1}"#
        )
    }
    
    func testReplacingCharacterEntitiesWithString() throws {
        XCTAssertEqual(
            try #"&auml;&alpha;\&alpha;\\&alpha;"#.replacingCharacterEntitiesWithString(),
            #"äα&alpha;\α"#
        )
    }
    
        func testOSPathNix() {
#if os(macOS) || os(Linux) || os(Android)
        XCTAssertEqual(
            #"/hello/yes"#,
            URL(fileURLWithPath: #"/hello/yes"#).osPath
        )
#endif
    }

    func testOSPathWindows() {
#if os(Windows)
        XCTAssertEqual(
            #"C:\hello\yes"#,
            URL(fileURLWithPath: #"C:/hello/yes"#).osPath
        )
#endif
    }

    func testCleaningUpURLNix() throws {
#if os(macOS) || os(Linux) || os(Android)
        XCTAssertEqual(
            "/hello/yes",
            URL(fileURLWithPath: "/hello/nice/world/.././../yes").cleaningUpPath.osPath
        )
 #endif
    }

    func testCleaningUpURLWindows() throws {
#if os(Windows)
        XCTAssertEqual(
            URL(fileURLWithPath: #"C:\hello\yes"#).osPath,
            URL(fileURLWithPath: #"C:\hello\nice\world\..\.\..\yes"#).cleaningUpPath.osPath
        )
#endif
    }

    func testWidths() throws {
        XCTAssertEqual(length(fromText: "0.5em", in: .em), 0.5)
        XCTAssertEqual(length(fromText: "0.5cm", in: .cm), 0.5)
        XCTAssertEqual(length(fromText: "1in", in: .cm), 2.54)
    }

#if os(macOS)
    // This test only prints!
    func testRunProgramSync() {
        let ok = runProgramSync(
            executableURL: URL(filePath: "/usr/bin/more")!,
            environment: .inherit.updating(["NewKey": "NewValue"]),
            arguments: ["a.txt"],
            currentDirectoryURL: URL(filePath: ProcessInfo.processInfo.environment["TESTDATA"]!),
            outputHandler: { print($0) }
        )
        print(String(describing: ok))
    }
#endif
    
#if os(macOS)
    // This test only prints!
    func testRunProgramAsync() async {
        let ok = await runProgramAsync(
            executableURL: URL(filePath: "/usr/bin/more")!,
            environment: .inherit.updating(["NewKey": "NewValue"]),
            arguments: ["a.txt"],
            currentDirectoryURL: URL(filePath: ProcessInfo.processInfo.environment["TESTDATA"]!),
            outputHandler: { print($0) }
        )
        print(ok as Any)
    }
#endif
    
#if os(macOS)
    // This test only prints!
    @available(macOS 26.0, *)
    func testParallelWithRunProgramAsync() {
        parallel(batch: ["a","b","c","d"], threads: 2) { name in
            let ok = await runProgramAsync(
                executableURL: URL(filePath: "/usr/bin/more")!,
                environment: .inherit.updating(["NewKey": "NewValue"]),
                arguments: ["\(name).txt"],
                currentDirectoryURL: URL(filePath: ProcessInfo.processInfo.environment["TESTDATA"]!),
                outputHandler: { print($0) }
            )
            print("\(name).txt: \(String(describing: ok))")
        }
    }
#endif
    
#if os(macOS)
    // This test only prints!
    @available(macOS 26.0, *)
    func testParallelWithRunProgramSync() {
        parallel(batch: ["a","b","c","d"], threads: 2) { name in
            let ok = await runProgramAsync(
                executableURL: URL(filePath: "/usr/bin/more")!,
                environment: .inherit.updating(["NewKey": "NewValue"]),
                arguments: ["\(name).txt"],
                currentDirectoryURL: URL(filePath: ProcessInfo.processInfo.environment["TESTDATA"]!),
                outputHandler: { print($0) }
            )
            print("\(name).txt: \(String(describing: ok))")
        }
    }
#endif
    
}
