# ``ExtendedSwiftMath``

Render beautifully typeset mathematical equations in iOS and macOS applications using LaTeX syntax.

## Overview

ExtendedSwiftMath is a comprehensive LaTeX math rendering library for Swift. It provides native rendering of mathematical equations without requiring web views or JavaScript, making it significantly faster and more integrated than web-based solutions.

This library extends [SwiftMath](https://github.com/mgriebling/SwiftMath) with:
- Comprehensive LaTeX symbol coverage
- Blackboard bold characters
- Manual delimiter sizing (`\big`, `\Big`, `\bigg`, `\Bigg`)
- amssymb equivalents
- Automatic line wrapping for long equations

### Quick Start

```swift
import ExtendedSwiftMath

// Create a math label
let label = MTMathUILabel()
label.latex = "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"
```

### SwiftUI Integration

```swift
import SwiftUI
import ExtendedSwiftMath

struct MathView: UIViewRepresentable {
    var equation: String
    var fontSize: CGFloat = 30

    func makeUIView(context: Context) -> MTMathUILabel {
        MTMathUILabel()
    }

    func updateUIView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        view.fontSize = fontSize
    }
}
```

## Topics

### Essentials

- ``MTMathUILabel``
- ``MTMathListBuilder``
- ``MTTypesetter``

### Fonts

- ``MTFontManager``
- ``MTFont``

### Math Lists

- ``MTMathList``
- ``MTMathAtom``
- ``MTMathAtomFactory``

### Display

- ``MTMathListDisplay``
- ``MTDisplay``
