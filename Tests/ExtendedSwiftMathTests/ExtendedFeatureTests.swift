//
//  ExtendedFeatureTests.swift
//
//  Parse-level and render-level unit tests for the LaTeX commands added by this
//  fork: \overset/\underset/\stackrel, \cancel/\bcancel/\xcancel,
//  \mathllap/\mathrlap/\mathclap, \xrightarrow/\xleftarrow/\xleftrightarrow,
//  and \genfrac.
//

import XCTest
@testable import ExtendedSwiftMath

final class ExtendedFeatureTests: XCTestCase {

    private func build(_ latex: String, file: StaticString = #file, line: UInt = #line) -> MTMathList {
        var error: NSError? = nil
        let list = MTMathListBuilder.build(fromString: latex, error: &error)
        XCTAssertNil(error, "Unexpected parse error for \(latex): \(error?.localizedDescription ?? "")", file: file, line: line)
        return list ?? MTMathList()
    }

    private func render(_ latex: String, file: StaticString = #file, line: UInt = #line) -> MTMathListDisplay {
        let font = MTFontManager.fontManager.defaultFont
        let display = MTTypesetter.createLineForMathList(build(latex), font: font, style: .display)
        XCTAssertNotNil(display, "nil display for \(latex)", file: file, line: line)
        return display ?? MTMathListDisplay(withDisplays: [], range: NSRange(location: 0, length: 0))
    }

    // MARK: - Over/Under

    func testOverset() {
        let list = build("\\overset{a}{b}")
        XCTAssertEqual(list.atoms.count, 1)
        let ou = list.atoms[0] as! MTOverUnder
        XCTAssertEqual(ou.type, .overUnder)
        XCTAssertNotNil(ou.over)
        XCTAssertNil(ou.under)
        XCTAssertFalse(ou.isStackrel)
        XCTAssertEqual(MTMathListBuilder.mathListToString(ou.over), "a")
        XCTAssertEqual(MTMathListBuilder.mathListToString(ou.base), "b")
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\overset{a}{b}")
    }

    func testUnderset() {
        let list = build("\\underset{x\\to 0}{\\lim }")
        let ou = list.atoms[0] as! MTOverUnder
        XCTAssertNil(ou.over)
        XCTAssertNotNil(ou.under)
        XCTAssertFalse(ou.isStackrel)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\underset{x\\to 0}{\\lim }")
    }

    func testStackrel() {
        let list = build("a\\stackrel{f}{\\rightarrow }b")
        XCTAssertEqual(list.atoms.count, 3)
        let ou = list.atoms[1] as! MTOverUnder
        XCTAssertTrue(ou.isStackrel)
        XCTAssertNotNil(ou.over)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "a\\stackrel{f}{\\rightarrow }b")
    }

    func testOverUnderRendering() {
        let d = render("\\overset{a}{b}")
        XCTAssertGreaterThan(d.width, 0)
        XCTAssertEqual(d.subDisplays.count, 1)
        XCTAssertTrue(d.subDisplays[0] is MTLargeOpLimitsDisplay)
        XCTAssertGreaterThan(render("\\underset{x}{\\lim}").width, 0)
        XCTAssertGreaterThan(render("a\\stackrel{f}{\\rightarrow}b").width, 0)
    }

    // MARK: - Cancel

    func testCancel() {
        let list = build("\\cancel{x}")
        let c = list.atoms[0] as! MTCancel
        XCTAssertEqual(c.cancelType, .forward)
        XCTAssertEqual(MTMathListBuilder.mathListToString(c.innerList), "x")
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\cancel{x}")
    }

    func testBcancel() {
        let list = build("\\bcancel{xy}")
        XCTAssertEqual((list.atoms[0] as! MTCancel).cancelType, .backward)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\bcancel{xy}")
    }

    func testXcancel() {
        let list = build("\\xcancel{abc}")
        XCTAssertEqual((list.atoms[0] as! MTCancel).cancelType, .cross)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\xcancel{abc}")
    }

    func testCancelWithScript() {
        let list = build("\\cancel{x}^2")
        XCTAssertEqual(list.atoms.count, 1)
        XCTAssertNotNil(list.atoms[0].superScript)
    }

    func testCancelRendering() {
        for latex in ["\\cancel{x}", "\\bcancel{2}", "\\xcancel{abc}", "\\frac{\\cancel{x}}{\\cancel{y}}"] {
            XCTAssertGreaterThan(render(latex).width, 0, "zero width for \(latex)")
        }
        let d = render("\\cancel{x}")
        let cd = d.subDisplays[0] as! MTCancelDisplay
        XCTAssertGreaterThan(cd.lineThickness, 0)
        XCTAssertEqual(cd.width, cd.inner!.width)
    }

    // MARK: - Overlap

    func testMathrlap() {
        let list = build("\\mathrlap{x}")
        XCTAssertEqual((list.atoms[0] as! MTOverlap).overlapType, .right)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\mathrlap{x}")
    }

    func testMathllap() {
        let list = build("\\mathllap{abc}")
        XCTAssertEqual((list.atoms[0] as! MTOverlap).overlapType, .left)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\mathllap{abc}")
    }

    func testMathclap() {
        let list = build("\\mathclap{XY}")
        XCTAssertEqual((list.atoms[0] as! MTOverlap).overlapType, .center)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\mathclap{XY}")
    }

    func testOverlapRendering() {
        let d = render("\\mathrlap{x}")
        let od = d.subDisplays[0] as! MTOverlapDisplay
        XCTAssertEqual(od.width, 0)
        XCTAssertGreaterThan(od.actualWidth, 0)
        // The overlap box contributes no advance width.
        let withOverlap = render("a\\mathrlap{BC}d")
        let plain = render("aBCd")
        XCTAssertLessThan(withOverlap.width, plain.width)
    }

    // MARK: - Extensible arrows

    func testXrightarrowOverOnly() {
        let list = build("\\xrightarrow{f}")
        let a = list.atoms[0] as! MTExtensibleArrow
        XCTAssertEqual(a.direction, .right)
        XCTAssertNotNil(a.overScript)
        XCTAssertNil(a.underScript)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\xrightarrow{f}")
    }

    func testXrightarrowOverAndUnder() {
        let list = build("\\xrightarrow[g]{f}")
        let a = list.atoms[0] as! MTExtensibleArrow
        XCTAssertNotNil(a.overScript)
        XCTAssertNotNil(a.underScript)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\xrightarrow[g]{f}")
    }

    func testXleftarrow() {
        let list = build("\\xleftarrow{abc}")
        XCTAssertEqual((list.atoms[0] as! MTExtensibleArrow).direction, .left)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\xleftarrow{abc}")
    }

    func testXleftrightarrow() {
        let list = build("\\xleftrightarrow{f}")
        let a = list.atoms[0] as! MTExtensibleArrow
        XCTAssertEqual(a.direction, .leftRight)
        XCTAssertEqual(a.arrowCharacter, "\u{2194}")
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\xleftrightarrow{f}")
    }

    func testExtensibleArrowRendering() {
        XCTAssertGreaterThan(render("\\xrightarrow{f}").width, 0)
        // Wider labels yield a wider arrow display.
        let narrow = render("\\xrightarrow{f}")
        let wide = render("\\xrightarrow{\\text{verylonglabel}}")
        XCTAssertGreaterThan(wide.width, narrow.width)
        XCTAssertTrue(render("\\xrightarrow{f}").subDisplays[0] is MTLargeOpLimitsDisplay)
    }

    func testExtensibleArrowWithScriptRenders() {
        // Scripts on an arrow must be rendered, not dropped.
        let list = build("\\xrightarrow{f}^2")
        XCTAssertNotNil(list.atoms[0].superScript)
        let font = MTFontManager.fontManager.defaultFont
        let scripted = MTTypesetter.createLineForMathList(build("\\xrightarrow{f}^2"), font: font, style: .display)!
        let bare = MTTypesetter.createLineForMathList(build("\\xrightarrow{f}"), font: font, style: .display)!
        XCTAssertGreaterThan(scripted.width, bare.width, "superscript should add width")
    }

    // MARK: - genfrac

    func testGenfracBinomLike() {
        let list = build("\\genfrac{(}{)}{0pt}{}{n}{k}")
        let frac = list.atoms[0] as! MTFraction
        XCTAssertEqual(frac.leftDelimiter, "(")
        XCTAssertEqual(frac.rightDelimiter, ")")
        XCTAssertEqual(frac.ruleThickness, 0)
        XCTAssertFalse(frac.hasRule)
        XCTAssertNil(frac.forcedStyle)
    }

    func testGenfracWithStyleAndThickness() {
        let list = build("\\genfrac{[}{]}{2pt}{1}{x}{y}")
        let frac = list.atoms[0] as! MTFraction
        XCTAssertEqual(frac.ruleThickness, 2)
        XCTAssertTrue(frac.hasRule)
        XCTAssertEqual(frac.forcedStyle, .text)
        XCTAssertEqual(MTMathListBuilder.mathListToString(list), "\\genfrac{[}{]}{2pt}{1}{x}{y}")
    }

    func testGenfracDefaultThickness() {
        let list = build("\\genfrac{}{}{}{0}{a}{b}")
        let frac = list.atoms[0] as! MTFraction
        XCTAssertNil(frac.ruleThickness)
        XCTAssertTrue(frac.hasRule)
        XCTAssertEqual(frac.forcedStyle, .display)
    }

    func testGenfracWhitespaceThicknessIsDefault() {
        let list = build("\\genfrac{}{}{ }{}{a}{b}")
        let frac = list.atoms[0] as! MTFraction
        XCTAssertNil(frac.ruleThickness)
        XCTAssertTrue(frac.hasRule)
    }

    func testGenfracRuledWithDelimitersRoundTrip() {
        // A ruled fraction with delimiters but default thickness/style must still
        // round-trip through \genfrac (it cannot be expressed by \frac or \binom).
        let list = build("\\genfrac{(}{)}{}{}{n}{k}")
        let frac = list.atoms[0] as! MTFraction
        XCTAssertTrue(frac.hasRule)
        XCTAssertEqual(frac.leftDelimiter, "(")
        let str = MTMathListBuilder.mathListToString(list)
        XCTAssertTrue(str.hasPrefix("\\genfrac{(}{)}"), "expected genfrac round-trip, got: \(str)")
        // And it must re-parse to an equivalent fraction.
        let reparsed = build(str)
        let frac2 = reparsed.atoms[0] as! MTFraction
        XCTAssertEqual(frac2.leftDelimiter, "(")
        XCTAssertEqual(frac2.rightDelimiter, ")")
        XCTAssertTrue(frac2.hasRule)
    }

    func testGenfracInvalidThicknessError() {
        var error: NSError? = nil
        let list = MTMathListBuilder.build(fromString: "\\genfrac{(}{)}{xx}{}{a}{b}", error: &error)
        XCTAssertNotNil(error)
        XCTAssertNil(list)
    }

    func testGenfracInvalidStyleError() {
        var error: NSError? = nil
        let list = MTMathListBuilder.build(fromString: "\\genfrac{}{}{}{9}{a}{b}", error: &error)
        XCTAssertNotNil(error)
        XCTAssertNil(list)
    }

    func testGenfracRendering() {
        for latex in ["\\genfrac{(}{)}{0pt}{}{n}{k}",
                      "\\genfrac{[}{]}{2pt}{1}{x}{y}",
                      "\\genfrac{}{}{}{0}{a}{b}",
                      "\\genfrac{}{}{}{}{a}{b}"] {
            XCTAssertGreaterThan(render(latex).width, 0, "zero width for \(latex)")
        }
        // A 0pt-rule genfrac with parens matches \binom width.
        let gen = render("\\genfrac{(}{)}{0pt}{}{n}{k}")
        let binom = render("\\binom{n}{k}")
        XCTAssertEqual(gen.width, binom.width, accuracy: 0.5)
    }
}
