# ExtendedSwiftMath

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/v/release/ChrisGVE/ExtendedSwiftMath?style=flat&logo=github)](https://github.com/ChrisGVE/ExtendedSwiftMath/releases)
[![CI](https://github.com/ChrisGVE/ExtendedSwiftMath/actions/workflows/ci.yml/badge.svg)](https://github.com/ChrisGVE/ExtendedSwiftMath/actions/workflows/ci.yml)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2011+%20|%20macOS%2012+-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue.svg?style=flat&logo=readthedocs&logoColor=white)](https://github.com/ChrisGVE/ExtendedSwiftMath)

A comprehensive Swift library for rendering LaTeX math on iOS and macOS, featuring extensive LaTeX symbol coverage including missing mathematical symbols, blackboard bold, delimiter sizing, amssymb equivalents, and automatic line wrapping.

## Overview

ExtendedSwiftMath provides a full Swift implementation for displaying beautifully rendered math equations in iOS and macOS applications. It typesets formulae written using LaTeX in a `UILabel` equivalent class, using the same typesetting rules as LaTeX so equations are rendered exactly as LaTeX would render them.

ExtendedSwiftMath is similar to [MathJax](https://www.mathjax.org) or [KaTeX](https://github.com/Khan/KaTeX) for the web but for native iOS or macOS applications without having to use a `UIWebView` and Javascript. More importantly, it is significantly faster than using a `UIWebView`.

This library prepackages everything needed for direct access via the Swift Package Manager.

> **Related project:** [MarkdownExtendedView](https://github.com/ChrisGVE/MarkdownExtendedView) is built on top of ExtendedSwiftMath and benefits from all the LaTeX extensions it brings, rendering math seamlessly inside Markdown content.

## Examples
Here are screenshots of some formulae that were rendered with this library:

```LaTeX
x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}
```

![Quadratic Formula](img/quadratic-light.png#gh-light-mode-only) 
![Quadratic Formula](img/quadratic-dark.png#gh-dark-mode-only) 

```LaTeX
f(x) = \int\limits_{-\infty}^\infty\!\hat f(\xi)\,e^{2 \pi i \xi x}\,\mathrm{d}\xi
```

![Calculus](img/calculus-light.png#gh-light-mode-only) 
![Calculus](img/calculus-dark.png#gh-dark-mode-only) 

```LaTeX
\frac{1}{n}\sum_{i=1}^{n}x_i \geq \sqrt[n]{\prod_{i=1}^{n}x_i}
```

![AM-GM](img/amgm-light.png#gh-light-mode-only) 
![AM-GM](img/amgm-dark.png#gh-dark-mode-only) 

```LaTex
\frac{1}{\left(\sqrt{\phi \sqrt{5}}-\phi\\right) e^{\frac25 \pi}}
= 1+\frac{e^{-2\pi}} {1 +\frac{e^{-4\pi}} {1+\frac{e^{-6\pi}} {1+\frac{e^{-8\pi}} {1+\cdots} } } }
```

![Ramanujan Identity](img/ramanujan-light.png#gh-light-mode-only) 
![Ramanujan Identity](img/ramanujan-dark.png#gh-dark-mode-only) 

More examples are included in [EXAMPLES](EXAMPLES.md)

## Fonts
Here are previews of the included fonts:

![](img/FontsPreview.png#gh-dark-mode-only) 
![](img/FontsPreviewLight.png#gh-light-mode-only) 
 
## Requirements
`ExtendedSwiftMath` works on iOS 11+ or MacOS 12+. It depends
on the following Apple frameworks:

* Foundation.framework
* CoreGraphics.framework
* QuartzCore.framework
* CoreText.framework

Additionally for iOS it requires:
* UIKit.framework

Additionally for MacOS it requires:
* AppKit.framework

## Installation

### Swift Package Manager

Add ExtendedSwiftMath to your Swift package:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisGVE/ExtendedSwiftMath.git", from: "1.0.0")
]
```

Or add it directly in Xcode via File > Add Package Dependencies using `https://github.com/ChrisGVE/ExtendedSwiftMath.git`.

## Usage

The library provides a class `MTMathUILabel` which is a `UIView` that
supports rendering math equations. To display an equation simply create
an `MTMathUILabel` as follows:

```swift

import ExtendedSwiftMath

let label = MTMathUILabel()
label.latex = "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"

```
Adding `MTMathUILabel` as a sub-view of your `UIView` will render the
quadratic formula example shown above.

The following code creates a SwiftUI component called `MathView` encapsulating the MTMathUILabel:

```swift
import SwiftUI
import ExtendedSwiftMath

struct MathView: UIViewRepresentable {
    var equation: String
    var font: MathFont = .latinModernFont
    var textAlignment: MTTextAlignment = .center
    var fontSize: CGFloat = 30
    var labelMode: MTMathUILabelMode = .text
    var insets: MTEdgeInsets = MTEdgeInsets()

    func makeUIView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        let font = MTFontManager().font(withName: font.rawValue, size: fontSize)
        font?.fallbackFont = UIFont.systemFont(ofSize: fontSize)
        view.font = font
        view.textAlignment = textAlignment
        view.labelMode = labelMode
        view.textColor = MTColor(Color.primary)
        view.contentInsets = insets
        view.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MTMathUILabel, context: Context) -> CGSize? {
        // Enable line wrapping by passing proposed width to the label
        if let width = proposal.width, width.isFinite, width > 0 {
            uiView.preferredMaxLayoutWidth = width
            let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            return size
        }
        return nil
    }
}
```

For code that works with SwiftUI running natively under MacOS use the following:

```swift
import SwiftUI
import ExtendedSwiftMath

struct MathView: NSViewRepresentable {
    var equation: String
    var font: MathFont = .latinModernFont
    var textAlignment: MTTextAlignment = .center
    var fontSize: CGFloat = 30
    var labelMode: MTMathUILabelMode = .text
    var insets: MTEdgeInsets = MTEdgeInsets()

    func makeNSView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }

    func updateNSView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        let font = MTFontManager().font(withName: font.rawValue, size: fontSize)
        font?.fallbackFont = NSFont.systemFont(ofSize: fontSize)
        view.font = font
        view.textAlignment = textAlignment
        view.labelMode = labelMode
        view.textColor = MTColor(Color.primary)
        view.contentInsets = insets
        view.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: MTMathUILabel, context: Context) -> CGSize? {
        // Enable line wrapping by passing proposed width to the label
        if let width = proposal.width, width.isFinite, width > 0 {
            nsView.preferredMaxLayoutWidth = width
            let size = nsView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            return size
        }
        return nil
    }
}
```

### Automatic Line Wrapping

`ExtendedSwiftMath` supports automatic line wrapping (multiline display) for mathematical content. The implementation uses **interatom line breaking** which breaks equations at atom boundaries (between mathematical elements) rather than within them, preserving the semantic structure of the mathematics.

#### Using Line Wrapping with UIKit/AppKit

For direct `MTMathUILabel` usage, set the `preferredMaxLayoutWidth` property:

```swift
let label = MTMathUILabel()
label.latex = "\\text{Calculer le discriminant }\\Delta=b^{2}-4ac\\text{ avec }a=1\\text{, }b=-1\\text{, }c=-5"
label.font = MTFontManager.fontManager.defaultFont

// Enable line wrapping by setting a maximum width
label.preferredMaxLayoutWidth = 235
```

You can also use `sizeThatFits` to calculate the size with a width constraint:

```swift
let constrainedSize = label.sizeThatFits(CGSize(width: 235, height: .greatestFiniteMagnitude))
```

#### Using Line Wrapping with SwiftUI

The `MathView` examples above include `sizeThatFits()` which automatically enables line wrapping when SwiftUI proposes a width constraint. No additional configuration is needed:

```swift
VStack(alignment: .leading, spacing: 8) {
    MathView(
        equation: "\\text{Calculer le discriminant }\\Delta=b^{2}-4ac\\text{ avec }a=1\\text{, }b=-1\\text{, }c=-5",
        fontSize: 17,
        labelMode: .text
    )
}
.frame(maxWidth: 235)  // The equation will break across multiple lines
```

#### Line Wrapping Behavior and Capabilities

ExtendedSwiftMath implements **two complementary line breaking mechanisms**:

##### 1. Interatom Line Breaking (Primary)
Breaks equations **between atoms** (mathematical elements) when content exceeds the width constraint. This is the preferred method as it maintains semantic integrity.

##### 2. Universal Line Breaking (Fallback)
For very long text within single atoms, breaks at Unicode word boundaries using Core Text with number protection (prevents splitting numbers like "3.14").

See `MULTILINE_IMPLEMENTATION_NOTES.md` for implementation details and recent changes.

#### Fully Supported Cases

These atom types work perfectly with interatom line breaking:

**✅ Variables and ordinary text:**
```swift
label.latex = "a b c d e f g h i j k l m n o p"
label.preferredMaxLayoutWidth = 150
// Breaks between individual variables at natural boundaries
```

**✅ Binary operators (+, -, ×, ÷):**
```swift
label.latex = "a+b+c+d+e+f+g+h"
label.preferredMaxLayoutWidth = 100
// Breaks cleanly: "a+b+c+d+"
//                 "e+f+g+h"
```

**✅ Relations (=, <, >, ≤, ≥, etc.):**
```swift
label.latex = "a=1, b=2, c=3, d=4, e=5"
label.preferredMaxLayoutWidth = 120
// Breaks after commas and operators
```

**✅ Mixed text and simple math:**
```swift
label.latex = "\\text{Calculer }\\Delta=b^{2}-4ac\\text{ avec }a=1\\text{, }b=-1"
label.preferredMaxLayoutWidth = 200
// Breaks between text and math atoms naturally
```

**✅ Punctuation (commas, periods):**
```swift
label.latex = "\\text{First, second, third, fourth, fifth}"
label.preferredMaxLayoutWidth = 150
// Breaks at commas and spaces
```

**✅ Brackets and parentheses (simple):**
```swift
label.latex = "(a+b)+(c+d)+(e+f)"
label.preferredMaxLayoutWidth = 120
// Breaks between parenthesized groups
```

**✅ Greek letters and symbols:**
```swift
label.latex = "\\alpha+\\beta+\\gamma+\\delta+\\epsilon+\\zeta"
label.preferredMaxLayoutWidth = 150
// Breaks between Greek letters
```

**✅ Fractions (NEW!):**
```swift
label.latex = "a+\\frac{1}{2}+b+\\frac{3}{4}+c"
label.preferredMaxLayoutWidth = 150
// Fractions stay inline if they fit, break to new line only when needed
// Example: "a + ½ + b" stays on one line if it fits
```

**✅ Radicals/Square roots (NEW!):**
```swift
label.latex = "x+\\sqrt{2}+y+\\sqrt{3}+z"
label.preferredMaxLayoutWidth = 150
// Radicals stay inline if they fit, break to new line only when needed
// Example: "x + √2 + y" stays on one line if it fits
```

**✅ Mixed fractions and radicals (NEW!):**
```swift
label.latex = "a+\\frac{1}{2}+\\sqrt{3}+b"
label.preferredMaxLayoutWidth = 200
// Intelligently breaks between complex mathematical elements
```

#### Limited Support Cases

These cases work but with some constraints:

**⚠️ Atoms with superscripts/subscripts:**
```swift
label.latex = "a^{2}+b^{2}+c^{2}+d^{2}+e^{2}"
label.preferredMaxLayoutWidth = 150
// Works, but uses fallback breaking mechanism
// May not break at the most optimal positions
```
**Note**: Scripted atoms (with superscripts/subscripts) trigger the universal breaking mechanism which breaks within accumulated text rather than at atom boundaries. This still works but may not be as clean as pure interatom breaking.

**⚠️ Very long single text atoms:**
```swift
label.latex = "\\text{This is an extremely long piece of text within a single text command}"
label.preferredMaxLayoutWidth = 200
// Uses Unicode word boundary breaking with Core Text
// Protects numbers from being split (e.g., "3.14" stays together)
```

#### Now Fully Supported (Previously Limited)

These complex atom types now work with intelligent inline layout:

**✅ Large operators (∑, ∫, ∏, lim):**
```swift
label.latex = "\\sum_{i=1}^{n} x_i + \\int_{0}^{1} f(x)dx"
label.preferredMaxLayoutWidth = 200
// ✅ Operators stay inline when they fit, break intelligently when needed
```

![Large operators](img/readme-wrap-largeops-light.png#gh-light-mode-only)
![Large operators](img/readme-wrap-largeops-dark.png#gh-dark-mode-only)

**✅ Delimited expressions (\left...\right):**
```swift
label.latex = "\\left(\\frac{a}{b}\\right) + c"
label.preferredMaxLayoutWidth = 150
// ✅ Delimited groups stay inline when they fit
```

![Delimited expressions](img/readme-wrap-delim-light.png#gh-light-mode-only)
![Delimited expressions](img/readme-wrap-delim-dark.png#gh-dark-mode-only)

**✅ Colored expressions:**
```swift
label.latex = "a + \\color{red}{b} + c"
label.preferredMaxLayoutWidth = 150
// ✅ Colored sections respect width constraints
```

![Colored expressions](img/readme-wrap-color-light.png#gh-light-mode-only)
![Colored expressions](img/readme-wrap-color-dark.png#gh-dark-mode-only)

**⚠️ Math accents (partial support):**
```swift
label.latex = "\\hat{x} + \\tilde{y} + \\bar{z}"
// Common accents (\hat, \tilde, \bar) are positioned correctly in most cases.
// Some complex grapheme clusters or font-specific metrics may still need additional polishing.
// See MULTILINE_IMPLEMENTATION_NOTES.md for details and known edge cases.
```

#### Best Practices

**DO:**
- Use interatom breaking for simple equations with operators and relations
- Use for mixed text and math where you want natural breaks
- Use for long sequences of variables, numbers, and operators
- Set appropriate `preferredMaxLayoutWidth` based on your layout needs

**DON'T:**
- Use extremely narrow widths (less than ~80pt) which may cause poor breaks

#### Examples

**Excellent use case (discriminant formula):**
```swift
label.latex = "\\text{Calculer le discriminant }\\Delta=b^{2}-4ac\\text{ avec }a=1\\text{, }b=-1\\text{, }c=-5"
label.preferredMaxLayoutWidth = 235
// ✅ Breaks naturally at good points between atoms
```

**Good use case (simple arithmetic):**
```swift
label.latex = "5+10+15+20+25+30+35+40+45+50"
label.preferredMaxLayoutWidth = 150
// ✅ Breaks between operators cleanly
```

**Excellent use case (fractions inline - NEW!):**
```swift
label.latex = "a+\\frac{1}{2}+b+\\frac{3}{4}+c"
label.preferredMaxLayoutWidth = 200
// ✅ Fractions stay inline when they fit!
// Breaks intelligently: "a + ½ + b" on line 1, "+ ¾ + c" on line 2
```

**Excellent use case (radicals inline - NEW!):**
```swift
label.latex = "x+\\sqrt{2}+y+\\sqrt{3}+z"
label.preferredMaxLayoutWidth = 150
// ✅ Radicals stay inline when they fit!
// Example: "x + √2 + y" on line 1, "+ √3 + z" on line 2
```

**Alternative for complex expressions:**
```swift
// Instead of trying to break this:
label.latex = "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"
// Consider it as a single display equation without width constraint
label.preferredMaxLayoutWidth = 0  // No breaking
```

#### Technical Details

- **Line spacing**: New lines are positioned at `fontSize × 1.5` below the previous line
- **Breaking algorithm**: Greedy - breaks immediately when projected width exceeds constraint
- **Width calculation**: Includes inter-element spacing according to TeX spacing rules
- **Number protection**: Numbers in patterns like "3.14", "1,000", etc. are kept intact
- **Supports locales**: English, French, Swiss number formats

### Included Features
This is a list of formula types that the library currently supports:

* Simple algebraic equations
* Fractions and continued fractions (including `\frac`, `\dfrac`, `\tfrac`, `\cfrac`)
* Exponents and subscripts
* Trigonometric formulae (including inverse hyperbolic: `\arcsinh`, `\arccosh`, etc.)
* Square roots and n-th roots
* Calculus symbols - limits, derivatives, integrals (including `\iint`, `\iiint`, `\iiiint`)
* Big operators (e.g. product, sum)
* Big delimiters (using `\left` and `\right`)
* Manual delimiter sizing (`\big`, `\Big`, `\bigg`, `\Bigg` and variants)
* Greek alphabet
* Bold Greek symbols (`\boldsymbol`)
* Combinatorics (`\binom`, `\choose` etc.)
* Geometry symbols (e.g. angle, congruence etc.)
* Ratios, proportions, percentages
* Math spacing
* Overline and underline
* Math accents
* Matrices (including `\smallmatrix` and starred variants like `pmatrix*` with alignment)
* Multi-line subscripts and limits (`\substack`)
* Equation alignment
* Change bold, roman, caligraphic and other font styles (`\bf`, `\text`, etc.)
* Style commands (`\displaystyle`, `\textstyle`)
* Custom operators (`\operatorname`, `\operatorname*`)
* Dirac notation (`\bra`, `\ket`, `\braket`)
* Most commonly used math symbols
* Colors for both text and background
* **Inline and display math mode delimiters** (see below)

### LaTeX Math Delimiters

`ExtendedSwiftMath` supports all standard LaTeX math delimiters for both inline and display modes. The parser automatically detects and handles these delimiters:

#### Inline Math (Text Style)
Use these delimiters for inline math within text, which renders more compactly:

```swift
// Dollar signs (TeX style)
label.latex = "$E = mc^2$"

// Parentheses (LaTeX style)
label.latex = "\\(\\sum_{i=1}^{n} x_i\\)"

// Cases environment in inline mode
label.latex = "\\(\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}\\)"
```

#### Display Math (Display Style)
Use these delimiters for standalone equations with larger operators and limits:

```swift
// Double dollar signs (TeX style)
label.latex = "$$\\int_{0}^{\\infty} e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}$$"

// Square brackets (LaTeX style)
label.latex = "\\[\\sum_{k=1}^{n} k^2 = \\frac{n(n+1)(2n+1)}{6}\\]"

// Equation environment
label.latex = "\\begin{equation} x^2 + y^2 = z^2 \\end{equation}"

// Cases environment in display mode
label.latex = "\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}"
```

**Note:** The difference between inline and display modes:
- **Inline mode** (`$...$` or `\(...\)`) renders compactly, suitable for math within text
- **Display mode** (`$$...$$`, `\[...\]`, or environments) renders with larger operators and limits positioned above/below

All delimiters are automatically stripped during parsing, and the math mode is set appropriately. No additional configuration is needed!

#### Backward Compatibility
Equations without explicit delimiters continue to work as before, defaulting to display mode:

```swift
label.latex = "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"  // Works as always
```

#### Programmatic API
For advanced use cases where you need to parse LaTeX and determine the detected style programmatically, use the `buildWithStyle` method:

```swift
// Parse LaTeX and get both the math list and detected style
let (mathList, style) = MTMathListBuilder.buildWithStyle(fromString: "\\[x^2 + y^2 = z^2\\]")

// style will be .display for \[...\] or $$...$$
// style will be .text for \(...\) or $...$

// Create a display with the detected style
if let mathList = mathList {
    let display = MTTypesetter.createLineForMathList(mathList, font: myFont, style: style)
    // Use the display for rendering
}
```

This is particularly useful when building custom renderers or when you need to respect the user's choice of delimiter style.

Note: ExtendedSwiftMath only supports the commands in LaTeX's math mode. There is
also no language support for other than west European languages and some
Cyrillic characters. There would be two ways to support more languages:

1) Find a math font compatible with `ExtendedSwiftMath` that contains all the glyphs
for that language.
2) Add support to `ExtendedSwiftMath` for standard Unicode fonts that contain all
language glyphs.

Of these two, the first is much easier.  However, if you want a challenge,
try to tackle the second option.

### Example

The original [SwiftMathDemo](https://github.com/mgriebling/SwiftMathDemo) by Mike Griebling demonstrates SwiftUI usage and can be adapted for ExtendedSwiftMath by changing the package dependency URL.

### Advanced configuration

`MTMathUILabel` supports some advanced configuration options:

##### Math mode

You can change the mode of the `MTMathUILabel` between Display Mode
(equivalent to `$$` or `\[` in LaTeX) and Text Mode (equivalent to `$`
or `\(` in LaTeX). The default style is Display. To switch to Text
simply:

```swift
label.labelMode = .text
```

##### Text Alignment
The default alignment of the equations is left. This can be changed to
center or right as follows:

```swift
label.textAlignment = .center
```

##### Font size
The default font-size is 30pt. You can change it as follows:

```swift
label.fontSize = 25
```
##### Font
The default font is *Latin Modern Math*. This can be changed as:

```swift
label.font = MTFontManager.fontmanager.termesFont(withSize:20)
```

This project has 12 fonts bundled with it, but you can use any OTF math
font. A python script is included that generates the `.plist` files 
required for an `.otf` font to work with `ExtendedSwiftMath`.  If you generate
(and test) any other fonts please contribute them back to this project for
others to benefit.



Note: The `KpMath-Light`, `KpMath-Sans`, `Asana` fonts currently incorrectly
render very large radicals. It appears that the font files do
not properly define the offsets required to typeset these glyphs.  If
anyone can fix this, it would be greatly appreciated.

##### Text Color
The default color of the rendered equation is black. You can change
it to any other color as follows:

```swift
label.textColor = .red
```

It is also possible to set different colors for different parts of the
equation. Just access the `displayList` field and set the `textColor`
of the underlying displays of which you want to change the color. 

##### Fallback Font for Unicode Text
By default, math fonts only support a limited set of characters (Latin, Greek, common math symbols).
To display other Unicode characters like Chinese, Japanese, Korean, emoji, or other scripts in `\text{}`
commands, you can configure a fallback font:

```swift
let mathFont = MTFontManager().font(withName: MathFont.latinModernFont.rawValue, size: 30)

// Set a fallback font for unsupported characters (defaults to nil)
#if os(iOS) || os(visionOS)
let systemFont = UIFont.systemFont(ofSize: 30)
mathFont?.fallbackFont = CTFontCreateWithName(systemFont.fontName as CFString, 30, nil)
#elseif os(macOS)
let systemFont = NSFont.systemFont(ofSize: 30)
mathFont?.fallbackFont = CTFontCreateWithName(systemFont.fontName as CFString, 30, nil)
#endif

label.font = mathFont
label.latex = "\\text{Hello 世界 🌍}"  // English, Chinese, and emoji
```

When the main math font doesn't contain a glyph for a character, the fallback font will be used automatically.
This is particularly useful for:
- Chinese text: `\text{中文}`
- Japanese text: `\text{日本語}`
- Korean text: `\text{한국어}`
- Emoji: `\text{Math is fun! 🎉📐}`
- Mixed scripts: `\text{Equation: 方程式}`

**Note**: The fallback font only applies to characters within `\text{}` commands, not regular math mode.

##### Custom Commands
You can define your own commands that are not already predefined. This is
similar to macros is LaTeX. To define your own command use:

```swift
MTMathAtomFactory.addLatexSymbol("lcm", value: MTMathAtomFactory.operator(withName: "lcm", limits: false))
```

This creates an `\lcm` command that can be used in the LaTeX.

##### Content Insets
The `MTMathUILabel` has `contentInsets` for finer control of placement of the
equation in relation to the view.

If you need to set it you can do as follows:

```swift
label.contentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
```

##### Error handling

If the LaTeX text given to `MTMathUILabel` is
invalid or if it contains commands that aren't currently supported then
an error message will be displayed instead of the label.

This error can be programmatically retrieved as `label.error`. If you
prefer not to display anything then set:

```swift
label.displayErrorInline = true
```

## Future Enhancements

Note this is not a complete implementation of LaTeX math mode. There are
some pieces that are missing and may be included in future updates:

* `\middle` delimiter for use between `\left` and `\right`
* Some fine spacing commands (`\:`, `\;`, `\!` - note that `\,` works)

For a complete list of features and their implementation status, see [MISSING_FEATURES.md](MISSING_FEATURES.md).

## License

`ExtendedSwiftMath` is available under the Apache License 2.0. See the [LICENSE](./LICENSE)
and [NOTICE](./NOTICE) files for more info.

### Fonts
This distribution contains the following fonts. These fonts are
licensed as follows:
* Latin Modern Math: 
    [GUST Font License](GUST-FONT-LICENSE.txt)
* Tex Gyre Termes:
    [GUST Font License](GUST-FONT-LICENSE.txt)
* [XITS Math](https://github.com/khaledhosny/xits-math):
    [Open Font License](OFL.txt)
* [KpMath Light/KpMath Sans](http://scripts.sil.org/OFL):
    [SIL Open Font License](OFL.txt)

## Acknowledgments

ExtendedSwiftMath was inspired by [SwiftMath](https://github.com/mgriebling/SwiftMath) by [Mike Griebling](https://github.com/mgriebling), itself a Swift translation of [iosMath](https://github.com/kostub/iosMath) by Kostub Deshmukh. ExtendedSwiftMath has since been independently rewritten and has taken on a life of its own as a standalone library. We gratefully acknowledge that earlier work for sparking this project.
