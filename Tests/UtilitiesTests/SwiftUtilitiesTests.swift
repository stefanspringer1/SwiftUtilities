import XCTest
@testable import Utilities

final class UtilitiesTests: XCTestCase {
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
}
