# Feature Gallery

A visual tour of the extended LaTeX commands added by ExtendedSwiftMath, beyond
the base SwiftMath command set.

## Overview

Each example below shows the LaTeX you write and the rendered output. All images
render in both light and dark appearances. To reproduce any of them in your own
app, assign the LaTeX string to an ``MTMathUILabel`` or render it to an image
with ``MathImage``.

```swift
let label = MTMathUILabel()
label.latex = "\\overset{\\text{def}}{=}"
```

## Over/Under Annotations

`\overset{annotation}{base}` places an annotation above the base, `\underset`
places it below, and `\stackrel{annotation}{relation}` stacks an annotation over
a relation (and is spaced as a relation). Annotations render one style smaller
than the base.

### \overset

```latex
\overset{\text{def}}{=}
```

![The equals sign with "def" set above it.](extended-overset)

### \underset

```latex
\underset{x \to 0}{\lim}
```

![The limit operator with "x to 0" set below it.](extended-underset)

### \stackrel

```latex
A \stackrel{f}{\rightarrow} B
```

![An arrow from A to B with f set above the arrow.](extended-stackrel)

## Cancellation Marks

`\cancel{x}` strikes through its content with a forward diagonal, `\bcancel{x}`
with a backward diagonal, and `\xcancel{x}` with both (an X). The strike is drawn
at the fraction-rule thickness over the content's bounding box.

### \cancel

```latex
\frac{\cancel{x}}{\cancel{x} + 1}
```

![A fraction whose numerator and a denominator term are struck through.](extended-cancel)

### \bcancel

```latex
\bcancel{a + b}
```

![The expression a + b struck through with a backward diagonal.](extended-bcancel)

### \xcancel

```latex
\xcancel{abc}
```

![The letters abc struck through with an X.](extended-xcancel)

## Overlap Boxes

`\mathrlap{x}` renders its content with zero advance width, overlapping to the
right; `\mathllap{x}` overlaps to the left; and `\mathclap{x}` centers the
zero-width content on the insertion point. These are used for fine positioning,
such as centering a wide subscript under a summation without widening the symbol.

### \mathrlap

```latex
\mathrlap{\,/}{=}
```

![A not-equals sign formed by overlapping a slash over an equals sign.](extended-mathrlap)

### \mathclap

```latex
\sum_{\mathclap{1 \le i \le n}} x_i
```

![A summation whose lower limit is centered under the symbol without widening it.](extended-mathclap)

## Extensible Arrows

`\xrightarrow[under]{over}` and `\xleftarrow[under]{over}` draw an arrow that
stretches horizontally to fit the wider of its optional labels. The `[under]`
argument is optional; the `{over}` argument is required (it may be empty).
`\xleftrightarrow` is also supported.

### \xrightarrow

```latex
A \xrightarrow[\text{below}]{\text{above}} B
```

![A right arrow from A to B with labels above and below, sized to the labels.](extended-xrightarrow)

### \xleftarrow

```latex
X \xleftarrow{f} Y
```

![A left arrow from Y to X labelled f.](extended-xleftarrow)

## Generalized Fractions

`\genfrac{left}{right}{thickness}{style}{num}{den}` gives full control over a
fraction: explicit delimiters, an explicit rule thickness (`0pt` for a
binomial-like stack with no bar, empty for the font default), and a forced style
(`0`=display, `1`=text, `2`=script, `3`=scriptscript; empty inherits).

### Binomial-like (no rule)

```latex
\genfrac{(}{)}{0pt}{}{n}{k}
```

![n over k inside parentheses with no fraction bar, like a binomial coefficient.](extended-genfrac-binom)

### Thick rule with bracket delimiters

```latex
\genfrac{[}{]}{2pt}{0}{x}{y}
```

![x over y inside square brackets with a thick fraction bar in display style.](extended-genfrac-thick)

## Topics

### Related

- ``MTMathUILabel``
- ``MathImage``
- ``MTMathListBuilder``
