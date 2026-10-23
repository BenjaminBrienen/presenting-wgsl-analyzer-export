#import "@preview/touying:0.8.0": *
#import themes.university: *

#let link-row(logo, label, url, qr) = grid(
  columns: (4cm, 1fr, 4cm),
  column-gutter: 1em,
  align: (center + horizon, left + horizon, center + horizon),
  image(logo, height: 3cm, fit: "contain"),
  [
    #text(size: 1.5em, weight: "bold")[#label]
    #linebreak()
    #text(size: 0.8em)[#link(url)[#url]]
  ],
  image(qr, height: 4cm, fit: "contain"),
)

#let social-row(platform, logo, handle, url, qr) = {
  grid(
    columns: (4cm, 1fr, 4cm),
    column-gutter: 1em,
    align: (center + horizon, left + horizon, center + horizon),
    image(logo, height: 3cm, fit: "contain"),
    [
      #text(size: 0.85em, fill: luma(130))[#platform]
      #linebreak()
      #text(size: 1.05em, weight: "bold")[#handle]
      #if url != none [
        #linebreak()
        #text(size: 0.8em)[#link(url)[#url]]
      ]
    ],
    if qr != none {
      image(qr, height: 4cm, fit: "contain")
    },
  )
}

#let divider-line = line(length: 100%, stroke: 0.5pt + luma(210))

#let fit-text(max-size: 48pt, min-size: 10pt, body) = layout(avail => context {
  let fits(s) = {
    let m = measure(block(width: avail.width, text(size: s, body)))
    m.height <= avail.height
  }
  if fits(max-size) { return text(size: max-size, body) }
  let (lo, hi) = (min-size, max-size)
  for _ in range(8) {
    let mid = (lo + hi) / 2
    if fits(mid) { lo = mid } else { hi = mid }
  }
  text(size: lo, body)
})

#let sn(i, body, dim: luma(150)) = {
  only(str(i), body) // current: normal
  only(str(i + 1) + "-", text(fill: dim, body)) // past: dimmed
}

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(
    breakable: false,
    show-notes-on-second-screen: right,
  ),
  config-info(
    title: "wgsl-analyzer",
    subtitle: "a language server for WebGPU Shading Language",
    author: "Benjamin Brienen",
    date: "30.10.2026",
    logo: image("assets/w-a.png"),
  ),
)

#title-slide()

#speaker-note[
  // fix these?
  Speakers notes will appear on the second screen.

  Apologies for the mixed use of "I"/"we" and "me"/"us" throughout.
]

== Who am I?

#grid(
  columns: (4cm, 1fr),
  column-gutter: 1.2cm,
  align: (center + horizon, left + horizon),
  image("assets/self/Me.jpg"),
  [
    #text(size: 2em, weight: "bold")[Benjamin Brienen]
  ],
)

#social-row(
  "GitHub",
  "assets/GitHub Logos/PNG/GitHub_Invertocat_Black.png",
  "BenjaminBrienen",
  "https://github.com/BenjaminBrienen",
  "assets/qr/GitHub-BenjaminBrienen.png",
)

#social-row(
  "Matrix",
  "assets/matrix icons/matrix-icon.png",
  "@benjaminbrienen:matrix.org",
  "https://matrix.to/#/@benjaminbrienen:matrix.org",
  "assets/qr/Matrix-benjaminbrienen.png",
)

#speaker-note[
  #block(width: 100%, height: 80%, fit-text[
    Hello everyone! I am Benjamin Brienen.
    #linebreak() My family and I are immigrants to the Netherlands.
    #linebreak() A couple years ago, I decided to look for an interesting project to contribute to.
    #linebreak() Video games, programming, and game development are long-time passions of mine.
    #linebreak() I found an open source game engine project called Bevy which was a perfect fit.
    #linebreak() I got nerd-sniped into an issue related to shader programming tooling and long story short, I found wgsl-analyzer.
    #linebreak() However, it wasn't working properly and was unmaintained, so I adopted ownership and maintenance of the project.
    #linebreak() Everyone needs a hobby!
    #linebreak() I work on wgsl-analyzer almost every day, although many days are project management, reviewing code, and discussions with other contributors.
    #linebreak() Ok, now...
  ])
]

== Who are you?

#pause
...and what do you want?

#meanwhile
#speaker-note[
  #sn(1)[
    who are you...

    Let me get a feel for what experience we have in the audience:

    Raise your hand if you are a software engineer.

    Put your hand down if you are *not* a programmer.

    Put your hand down if you don't author shaders.

    Put your hand down if you don't use WebGPU Shading Language, #linebreak() a.k.a W-G-S-L or WGSL.
  ]

  #sn(2)[
    Ok :) now clap once if you have ever wished for better developer tooling.
  ]
]

== What's the problem?

- Programming in WGSL is a sub-par experience
- Tooling that exists for other languages doesn't exist for WGSL.

#pause
Solution: Language support in your editor of choice.

#meanwhile
#speaker-note[
  #sn(1)[
    - Compare to what you get when writing your host code
    - When you write Rust or TypeScript, your code editor does all sorts of fancy things.
    - The difference between a simple code editor and an "IDE" is whether it actively helps you work in that language.
      - We want programming to be more fun by leveraging your computer to its potential.
  ]
  #sn(2)[
    - What if you could get feedback about what you typed directly in your code editor?
    - What if your code editor had features that helped you better understand what is written?
    - What if it made writing code easier with intelligent suggestions?
  ]
]

== What already exists?

#v(20%)

- Syntax highlighting using RegEx-based grammars or a tree-sitter, but:
  - Out-of-date WGSL standards
  - No support for bespoke code preprocessors
  - RegEx or tree-sitter grammars are only so powerful
  - No fancy goodies like completions, diagnostics, inlay hints, renames, formatting, and such

#speaker-note[
  Use your editor of choice, possibly with syntax highlighting and whatever support it provides generically.

  However, it will almost never work for you.

  - Glasgow was last released 2 years ago
  - Another option called simply "WGSL" was last released 3 years ago
  - Other projects with bus factor of 1

  Nothing seems to support the latest spec of WGSL and they definitely don't support your bespoke code-sharing or module system, such as Bevy's old `naga_oil`.
]

== What can we do about it?

rust-analyzer is nice.
#pause

#components.adaptive-columns(start: [It has:], [
  #text(size: 14pt, [
    - Annotations
    - Auto Import
    - Child Modules
    - Completion With Autoimport
    - Completions Attribute
    - Debug ItemTree
    - Expand Macro Recursively
    - Expand and Shrink Selection
    - File Structure
    - Find All References
    - Folding
    - Format String Completion
    - Go to Declaration
    - Go to Definition
    - Go to Implementation
    - Go to Type Definition
    - Highlight Related
    - Hover
    - Inlay Hints
    - Interpret A Function, Static Or Const.
    - Join Lines
    - Macro Brace Style Attribute
    - Magic Completions
    - Matching Brace
    - Memory Usage
    - Move Item
    - On Enter
    - On Typing Assists
    - Open Docs
    - Parent Module
    - Prefer Underscore Import Attribute
    - Related Tests
    - Rename
    - Run
    - Semantic Syntax Highlighting
    - Show Dependency Tree
    - Show Syntax Tree
    - Status
    - Structural Search and Replace
    - User Snippet Completions
    - View Crate Graph
    - View Hir
    - View Memory Layout
    - View Mir
    - Workspace Symbol
  ])
])

#meanwhile

#speaker-note[
  #sn(1)[
    rust-analyzer is nice. I use it daily and it does what I want, but for a different programming language.
  ]

  #sn(2)[
    It has... \*points\* all that stuff.

    Can we do that, but for WGSL? Let's copy their homework!
  ]]

== But...

Rust is pretty different from WGSL.

#components.adaptive-columns(start: [A lot of this is not applicable:], [
  #text(size: 14pt, [
    - #strike[Annotations]
    - #strike[Auto Import]
    - #strike[Child Modules]
    - Completion #strike[With Autoimport]
    - Completions Attribute
    - Debug ItemTree
    - #strike[Expand Macro Recursively]
    - Expand and Shrink Selection
    - File Structure
    - Find All References
    - Folding
    - #strike[Format String Completion]
    - Go to Declaration
    - Go to Definition
    - #strike[Go to Implementation]
    - Go to Type Definition
    - Highlight Related
    - Hover
    - Inlay Hints
    - #strike[Interpret A Function, Static Or Const.]
    - Join Lines
    - #strike[Macro Brace Style Attribute]
    - Magic Completions
    - Matching Brace
    - Memory Usage
    - Move Item
    - On Enter
    - On Typing Assists
    - #strike[Open Docs]
    - #strike[Parent Module]
    - #strike[Prefer Underscore Import Attribute]
    - #strike[Related Tests]
    - Rename
    - #strike[Run]
    - Semantic Syntax Highlighting
    - #strike[Show Dependency Tree]
    - Show Syntax Tree
    - Status
    - Structural Search and Replace
    - User Snippet Completions
    - #strike[View Crate Graph]
    - #strike[View Hir]
    - View Memory Layout
    - #strike[View Mir]
    - Workspace Symbol
  ])
])

#speaker-note[
  Rust is pretty different from WGSL. Arguably, it is much more complex.

  All of these features of rust-analyzer do not make any sense in a WGSL editor.

  That means we have less to do! We can just rip out entire modules instead of adapting those for a different programming language
]

== What is out of scope?

#v(20%)

- Older WGSL standards
- Analyzing other languages such as TypeScript or Rust where WGSL source may appear as strings.
- Bespoke code-sharing or preprocessing solutions

#speaker-note[
  - WGSL isn't stable enough to be worth supporting multiple editions
  - Analyzing host code would mean a massive increase in the complexity of the language server when we can instead ask users to put their WGSL code into `.wgsl` files.
  - Supporting multiple of these would exponentially increase complexity
  - Supporting bespoke systems uses up a lot of maintainer effort for a small number of users
]

== What is LSP?

#v(20%)

- Language Server Protocol
- Standardized interface
- Supports all editors with LSP support
- The language server process is long-lived and holds the state of the source code in-memory

#speaker-note[
  The language server protocol is a specification created by Microsoft.

  Having a standard for this lets us support many code editors, so long as they have built-in support for LSP or a plugin system that enables the community to add LSP support.

  The editor communicates with a background process that handles requests such as "show me the completions" or notifications such as "this document contents changed".
]

== So let's make it

- A language server implementation for WebGPU Shading Language
- IDE features based on semantic analysis of WGSL code

#v(1fr)

#link-row(
  "assets/GitHub Logos/PNG/GitHub_Invertocat_Black.png",
  "GitHub",
  "https://github.com/wgsl-analyzer/wgsl-analyzer",
  "assets/qr/GitHub-wgsl-analyzer.png",
)

#link-row(
  "assets/w-a.png",
  "Website",
  "https://wgsl-analyzer.github.io",
  "assets/qr/Website.png",
)

#v(1fr)

== wgsl-analyzer meta

#v(20%)

First commit was in October 2021. I adopted it in March 2025.

- 480k downloads of the VS Code extension
  #linebreak() (open-vsx and Visual Studio Marketplace)
- 56 total contributors (30 contributors since 2025)
- 718 stars on GitHub
- 100+ people following development on Discord and Matrix

== Demo

#slide(config: config-info(logo: none))[#image("assets/demo/install_and_use.gif")]

== Syntax Highlighting

#alternatives[
  #align(center, [#image("assets/capabilities/syntax_highlighting.png")])
][
  #align(center, [#image("assets/Bevy/syntax-highlighting.webp")])
]

#speaker-note[
  we do currently use textmate grammar for syntax highlighting, but this will be replaced with the semantic token provider language server capability in the next few months, is what is planned

  (click to show other demo)
]

== Diagnostics

- Our own diagnostics based on parsing and semantic analysis
- External diagnostics from WGSL compilers

#align(center, [#image("assets/capabilities/diagnostics.png")])

== Go-to Definition

#align(center, [#image("assets/capabilities/goto_definition.png")])

#speaker-note[
  - Navigate to where something is declared, such as a function or variable
  - Even works on some builtins
]

== Completions

#alternatives[
  #align(center, [
    #image("assets/capabilities/completions.png")
  ])
][
  #align(center, [
    #image("assets/capabilities/completions2.png")
  ])
]

#speaker-note[
  It suggests known items in-scope

  - It currently works in function contexts
  - More contexts and context-sensitive completions is to-do
]

#slide(config: config-info(logo: none))[#image("assets/Bevy/autocomplete.webp")]

== Inlay Hints

#align(center, [#image("assets/capabilities/inlay_hints.png")])

#speaker-note[
  Inlay hints are labels that show additional information such as inferred types and parameter names.
]

== Signature Help

#align(center, [#image("assets/capabilities/signature_help.png", width: 90%)])

#speaker-note[
  Signature help shows the function signature based on context and the available overloads.

  WGSL does not allow for user code to define overloads, but certain builtins do have overloads.
]

== Formatting

#alternatives[
  #align(center, [#image("assets/capabilities/formatting_before.png")])
][
  #align(center, [#image("assets/capabilities/formatting_after.png")])
]

#speaker-note[
  - Code formatting means that you do not have to make the code pretty yourself
  - A standard style makes code more readable
  - If used consistently, less noise in changes
  - Also available as a standalone CLI tool called `wgslfmt`, especially useful in a CI check
]

== VS Code Extension

#align(center, [#image("assets/capabilities/vscode.png")])

#speaker-note[
  - The VS Code extension is available on Visual Studio Marketplace and open-vsx
  - It has many extra features that are experimental LSP extensions, so it has a more complex "front end"
  - VS Code extension and the language server native binary are both called "wgsl-analyzer"
  - Works on Visual Studio Code, Codium, and vscode.dev
]

== WASM build

#align(center, [#image("assets/capabilities/npmjs.png")])

#speaker-note[
  node package for web workers
  - Server binary as a WASM package for web workers
    - Can be used on web playgrounds (think, shadertoy)
    - Maybe someday on webgpufundamentals.org
]

== Zed Plugin

#align(center, [#image("assets/capabilities/zed.png")])

#speaker-note[
  Zed plugin that installs and registers the language server
]

== Other Editors

#v(20%)

- Neovim
- Emacs
- Vim
- Sublime Text
- Kate Text Editor
- juCi++
- Kakoune
- Helix

#speaker-note[
  We get these for free thanks to the nature of a standardized language server protocol.

  You just have to give it some minimal configuration to declare that it exists.
]

== WESL Support

#v(10%)

WESL is a language extension that adds imports, conditional compilation, shader libraries and packages, and more.

Try it at #link("https://play.wesl-lang.dev")
- Uses `wgsl-analyzer-web`!

#align(center, [#image("assets/qr/wesl_playground.png", height: 50%)])

#speaker-note[
  We said that we don't want to support every bespoke shader preprocessor, but we do want to enable that use case, so we teamed up with a group authoring an extension to WGSL called WESL.

  The idea of WESL is that the features are actually upstreamed to WGSL. The WESL team is directly working with the WebGPU committee on these proposals.

  Stick around for the next talk and learn more about it.

  You can try it *with* wgsl-analyzer on the WESL playground. Yes, wgsl-analyzer has a WASM build!
]

== WESL Playground

#slide(config: config-info(logo: none))[
  #alternatives[
    #image("assets/demo/wesl_playground.png")
  ][
    #image("assets/demo/wesl_playground2.png")
  ]
]

== WESL - View Package/Module Graph

#slide(config: config-info(logo: none))[#image("assets/Bevy/module-graph.webp")]

#speaker-note[
  - Note that we do currently make a compromise here:
  - We assume a filesystem-based workspace
  - Analyzing host code to understand how your implementation of module resolution works is not in scope
  - We just assume that your module structure is the same as the file structure
  - This is something we really want to improve, but will require some hard design work in WESL
]

== Who is currently using it?

#v(20%)

#pause
- Microsoft - qdk
#pause
- Google - dawn
#pause
- Netflix - ?
#pause
- Bevy and Bevy users; the latest version of Bevy replaces `naga_oil` with `wesl-rs`
#pause
- Anyone else who managed to find us :)

#meanwhile

#speaker-note[
  #alternatives[
    From conversations with users and seeing who is filing issues on our GitHub:
    developers at high-profile companies:
  ][
    Apparently someone at Microsoft is programming their quantum computer with wgsl-analyzer, I don't know. That's Microsoft Quantum Development Kit.
  ][
    Google engineers working on their WebGPU implementation "dawn" asked for an integration with their shader compiler and validator "tint" so that they could throw away their own unmaintained language server.
    So, for context, Chromium uses dawn/tint, Firefox uses wgpu/Naga.
  ][
    Someone working at Netflix
  ][
    Bevy, of course. That's how I got here. We work with them directly for feedback on the user experience. Also, Bevy users.
  ][
    others, and you, after this conference!
  ]
]

== Integrations with Other Tools

#v(20%)

Other WGSL utilities are called directly by wgsl-analyzer:

- Naga
- tint
- wesl-rs
- wesldoc (planned)
- host-code package managers

#speaker-note[
  There are some existing tools that wgsl-analyzer can leverage to provide more information such as diagnostics.

  If you are using wgpu in your project, then it makes sense for wgsl-analyzer to parse and validate your shaders with Naga.

  For resolving WESL dependencies, we query your project's host-code package manager. Currently only implemented for Cargo.
]

== Integration Demo: External Diagnostics

#slide(config: config-info(logo: none))[
  #align(center, [#image("assets/Bevy/external-errors-nice.webp")])
]

#speaker-note[
  In this demo, you can see wgsl-analyzer can provide diagnostics from Naga using the rust crate and from tint by calling the CLI tool.
]

== Technical Design

#v(20%)

- Architecture is nearly 1:1 with rust-analyzer
#pause
- Internals are structured as libraries

#meanwhile
#speaker-note[
  #sn(1)[
    - Lots of smart people have already landed on this design and redoing that work is simply out of scope
      - Most design decisions are "inherited"
    - As rust-analyzer improves, we can pull those changes
    - We get to contribute upstream when we fix or make stuff that isn't WGSL-specific
    - "Onboarding" to contribute is easy if you have worked on rust-analyzer
      - Learning material for rust-analyzer works for wgsl-analyzer too
  ]
  #sn(2)[
    - Each library solves a specific problem and can be tested independently
  ]
]

== Architecture

#slide(config: config-info(logo: none))[
  #align(center, [#image("assets/crate_graph.png")])
]

#speaker-note[
  wgsl-analyzer looks like this on the inside, but let's simplify it a little...
]

== High-Level Architecture

#v(10%)

#let layers = (
  (rgb("#ff0000"), "Language server", "Talks to your editor (VS Code, Zed, …)"),
  (rgb("#ffff00"), "IDE features", "Completion, error messages, formatting, go to definition, …"),
  (rgb("#00ff00"), "Analysis Engine", "Understands semantics of WGSL; incremental computation with salsa"),
  (rgb("#0080ff"), "Syntax", "The code as a tree of WGSL syntax based on rowan"),
  (rgb("#8000ff"), "Parser", "Turns raw text into a tree of WGSL tokens based on lelwel"),
)

#let w = 10cm
#let h = 2cm
#let n = layers.len()

#v(10%)

#grid(
  columns: (w, 1fr),
  column-gutter: 1.2em,

  box(width: w, height: n * h, {
    for (i, l) in layers.enumerate() {
      let inset-top = w / 2 * i / n
      let inset-bottom = w / 2 * (i + 1) / n

      place(top + left, dy: i * h, polygon(
        fill: l.at(0).desaturate(50%).darken(10%),
        stroke: white + 1.5pt,
        (w / 2 - inset-top, 0pt),
        (w / 2 + inset-top, 0pt),
        (w / 2 + inset-bottom, h),
        (w / 2 - inset-bottom, h),
      ))
    }
  }),

  stack(
    dir: ttb,
    spacing: 0pt,
    ..layers
      .enumerate()
      .map(((i, l)) => box(
        height: h,
        align(horizon)[
          #only("1")[
            #text(size: 20pt, weight: "bold", fill: black)[#l.at(1)]
            #linebreak()
            #text(size: 15pt, fill: black)[#l.at(2)]
          ]
          #only("2")[
            #text(
              size: 20pt,
              weight: "bold",
              fill: if i == 0 { black } else { rgb("#999999") },
            )[#l.at(1)]
            #linebreak()
            #text(
              size: 15pt,
              fill: if i == 0 { black } else { rgb("#999999") },
            )[#l.at(2)]
          ]
          #only("3")[
            #text(
              size: 20pt,
              weight: "bold",
              fill: if i == 1 { black } else { rgb("#999999") },
            )[#l.at(1)]
            #linebreak()
            #text(
              size: 15pt,
              fill: if i == 1 { black } else { rgb("#999999") },
            )[#l.at(2)]
          ]
          #only("4")[
            #text(
              size: 20pt,
              weight: "bold",
              fill: if i == 2 { black } else { rgb("#999999") },
            )[#l.at(1)]
            #linebreak()
            #text(
              size: 15pt,
              fill: if i == 2 { black } else { rgb("#999999") },
            )[#l.at(2)]
          ]
          #only("5")[
            #text(
              size: 20pt,
              weight: "bold",
              fill: if i == 3 or i == 4 { black } else { rgb("#999999") },
            )[#l.at(1)]
            #linebreak()
            #text(
              size: 15pt,
              fill: if i == 3 or i == 4 { black } else { rgb("#999999") },
            )[#l.at(2)]
          ]
        ],
      )),
  ),
)

#pause
#pause
#pause
#pause

#speaker-note(subslide: 2)[
  At the top is the binary executable, the language server. It talks to the editor directly and does other work such as discovering the workspace.
]

#speaker-note(subslide: 3)[
  It is built on top of IDE features. When it receives a request, it calls one of the handlers from this layer. Those handlers use the analysis engine as context, use the relevant information, and create the appropriate response object.
]

#speaker-note(subslide: 4)[
  The analysis engine has the implementation of the type system. It collects errors, which we call diagnostics. The analysis engine uses salsa databases and queries for very efficient, incremental results.
]

#speaker-note(subslide: 5)[
  Inside that, it has to parse the code. The syntax and parser layers handle turning the source code string from the original LSP request into a token tree and then a syntax tree.
]

== It's fast!

#v(20%)

- Some tens of milliseconds for analyzing one shader
- A few milliseconds of round-trip latency for any LSP request or notification
- Incremental computation using `salsa`

#speaker-note[
  - We do not want to recompile the universe when you change one function
  - Split up language semantics into small, composable queries
  - Queries don't have to be reevaluated when the inputs are fresh
  - Salsa is a complex topic that could be its own talk
  - Not regularly measured or benchmarked yet
  - Will be more important once workspace analysis is implemented
  - We do not benchmark it yet as it feels fast enough
]

== Best-Effort Analysis

#v(20%)

- wgsl-analyzer is supposed to make users' lives easier
- Provide diagnostics on code that is *known* to be wrong - and only the "first" thing that went wrong
  - Example: "you can't add an `[error]` and an `i32`"

#speaker-note[
  - So do not require users to spend their effort focusing on w-a
  - The signal-to-noise ratio must be extremely high or else users feel hindered/distracted
  - Error recovery needs to be good from top to bottom
  - We don't need to tell the user that they cannot add an `[error]` to an `i32` because the error "type" happened from a mistake "earlier" in the code. When they fix the original problem, maybe the addition operation is valid.
]

== Find the Mistake (gone wrong)

#image("assets/demo/before.png")

#speaker-note[
  can you find the *actual* mistake in this code snippet?
]

== Find the Mistake

#image("assets/demo/after.png")

#speaker-note[
  *now* can you find the mistake?
]

== Error recovery

#image("assets/Bevy/error-recovery.webp")


== Every User Is Different

#v(20%)

- What is helpful for different users varies - config necessary
- Good defaults are really important
- All config should be user preferences, not project meta

#speaker-note[
  - How much detail to show in inlay hints, for example

  - If the user has to set up configuration in order for the language server or extension to understand their project, then that would probably have to be checked-in and shared among developers.
]

== Every Project Is Different

#v(20%)

- wgsl-analyzer should do smart things to eliminate the need for "setup"
- Use your existing project manifest to see what tools you're using
  - Cargo integration
  - wesl-rs and Naga detection is TODO

#speaker-note[
  - Checking-in dev tool configuration is a barrier for most teams. for example, devs should be free to use whatever tool they like most.

  - Also a UX issue

  - This has to be balanced with how much complexity we want in wgsl-analyzer
    - For example, supporting multiple versions instead of the latest version
    - No unified toolchain that includes tooling, compiler, and other components
]

== Fast Delivery

#v(20%)

When you contribute something to wgsl-analyzer, your whole team can already use it the next day!

- Nightly releases
- Requires a high quality bar and comprehensive tests to make this possible and reliable

#speaker-note[
  - We have nightly releases so that new stuff can be used in immediately.
  - Marketplace and open-vsx have separate release and prerelease channels.
  - To make that possible, we want the main branch to never be broken.
  - We have lots of unit tests (mostly snapshot tests) and strict PR checks to catch regressions and prove the code
  - We do measure code coverage because it means reviewing changes is much easier
  - Rust makes it easier to achieve a high quality bar relying mainly on PR checks
  - But, we still have that nightly release to find broken stuff for what we don't test properly
]

== Open Source

#slide(config: config-info(logo: none))[
  #link-row(
    "assets/GitHub Logos/PNG/GitHub_Invertocat_Black.png",
    "GitHub",
    "https://github.com/wgsl-analyzer/wgsl-analyzer",
    "assets/qr/GitHub-wgsl-analyzer.png",
  )
  #link-row(
    "assets/matrix icons/matrix-icon.png",
    "Matrix",
    "https://matrix.to/#/#wgsl-analyzer:matrix.org",
    "assets/qr/Matrix-wgsl-analyzer.png",
  )
  #link-row(
    "assets/Discord_Symbol_Black/Discord-Symbol-Black.png",
    "Discord",
    "https://discord.gg/XDYT5NQkjv",
    "assets/qr/Discord.png",
  )
]

#speaker-note[
  - Development happens "here"
  - Made by humans, for humans. Artisanal code
  - Anybody can contribute. All levels of experience and familiarity
  - Guidance is available to people wanting to contribute
  - Welcoming, accessible, and friendly
]

== Way of Working

#v(20%)

- Modelled on Bevy's community-focused, open-source way of working
- Anybody can create issues, open PRs, comment or create discussions
- Anybody can review a PR, including requesting changes or giving approval.

#speaker-note[
  Our open source way of working is derived from Bevy's approach, which they've done talks about before.

  We let people create issues, PRs, comment, review, and all that jazz because those are (so far) all valuable forms of contributing to the project.
]

== Contributing

#v(10%)

- Creativity optional
- Well-maintained and active
- Contribute upstream to rust-analyzer
- See our contributor guide in our book:

#link-row(
  "assets/w-a.png",
  "Contributing",
  "https://wgsl-analyzer.github.io/book/contributing",
  "assets/qr/contributing.png",
)

#speaker-note[
  - Creativity is optional, copy-pasting from rust-analyzer is encouraged
  - Wgsl-analyzer is a fun project to hack on, that's my goal
  - Upstreaming stuff feels rewarding, benefit even more people
  - We try to upstream stuff if it is new feature or an upstreamable bugfix
]

== User Feedback

#v(20%)

- People use cutting-edge features of WGSL
- People expect a lot from the word "supports"
- People want more features!
- This really is the best (basically, the only) tool for what they want
- Open-source community is pretty friendly
- They really like what works
- They notice things that do not work
- UX with Cargo is still rough

#speaker-note[
  "It supports X" can mean anything from "doesn't panic" to "watch us wield magic with this".
]

== Limited Bandwidth

#v(20%)

- Adapting all features at once for WGSL is not feasible
- Only so much time in the day to work on it
- Maintainer effort is split across multiple projects and real-life things
- Maintainers and contributors are volunteers

#speaker-note[
  - It has to be done incrementally according to what feels important
  - Even pulling just one feature verbatim and filling in the blanks vertically leads to infinite rabbit-holes
  - Sometimes, according to what sounds interesting and there is motivation for
  - Things get implemented when people ask/feel like it
  - People work on whatever they want whenever there is time and motivation
  - Everybody likes working on different things, so the more the merrier
]

== Short-Term Roadmap

#v(20%)

- Better WESL support
  - Analyze conditional transpilation properly
- Polish user experience with Cargo
  - Get dependencies without extra setup

== Long-Term Roadmap

#pause
- Implement all WGSL language extensions from the WGSL spec
#pause
- Validate more parts of WGSL code for correctness
#pause
- Bring wgsl-analyzer up to speed with internal refactoring in rust-analyzer
#pause
- Implement more Naga extensions
#pause
- Language server capabilities that can be implemented:

#components.adaptive-columns([
  - Go-to declaration
  - Go-to type definition
  - Find all references
  - Document highlights
  - Document symbol provider
  - Workspace symbol provider
  - Code actions
  - Code lenses
  - Renames
  - Call hierarchy
  - Semantic tokens provider
  - Snippets
  - Other experimental LSP stuff
])
#meanwhile
#speaker-note[
  #sn(2)[
    - Many of the newer WGSL language extensions are not implemented yet such as buffer types and subgroups
  ]

  #sn(3)[
    - We can add more validation to catch more kinds of mistakes such as using derivative functions from the wrong kind of entry point
  ]

  #sn(4)[
    - Copying features from rust-analyzer is more difficult than it should be because of refactors that we haven't done yet
  ]

  #sn(5)[
    - Naga extensions are cool and in-demand, but we don't support all of them yet. Some are used in Bevy or are nearing a state to be upstreamed into standard WGSL.
  ]

  #sn(6)[
    - Many language server capabilities that feel "basic" are not implemented yet, but there aren't really blockers
  ]
]

== Challenges

#v(20%)

- Turning a language specification into a purpose-built implementation is hard
- Balancing polish and robustness vs works for an ideal use-case
- Huge learning curve to create this
- Certain properties of code are not local
- Naga extensions are not well-documented

#speaker-note[
  There is a huge learning curve to be an expert on:
  - Shader programming languages
  - Compiler design
  - Rust-analyzer's design and internal APIs
  - The language server protocol
  - Quirks of LSP-capable editors
  - WGSL is hard to analyze.
    - For example, struct memory layout depends on where it gets used and the spec is written in a way such that knowing the types of expressions alone isn't enough information to validate statements.
    - Derivative functions and other items are only valid in certain contexts, not encoded in function signature.
]

== Wrong Assumptions

#v(20%)

#pause
- I assumed that changing the Rust-specific details to be WGSL-specific would have a small blast radius
#pause
- Pulling changes and features from upstream is harder than expected due to evolutions in rust-analyzer
#pause
- It surprised me how maintenance of open-source projects by well-funded companies and organizations can feel often inadequate

#meanwhile
#speaker-note[
  #alternatives[
    I assumed wrong about a couple things.
  ][
    - The differences between Rust and WGSL are big enough that some "core" concepts don't apply
      - rust-analyzer only has to support one "ecosystem", workspace discovery in WGSL is completely different
  ][
    - rust-analyzer had a lot of internal refactors that make it harder to pull changes
      - The project will get there eventually, but refactoring competes for time budget
  ][
    - Lots of proposals to improve the LSP specification get no attention
    - Dependencies can be slow to fix trivial maintenance and vulnerability advisories
    - Tons of open issues and PRs not receiving attention
  ]
]

== Lessons

#v(20%)

#pause
- Programming language design
  - Be friendly to developer tooling
  - Edge cases will drive your design for the better
  - Take prior art into account
#pause
- Snapshot testing is actually so cool!
#pause
- Feedback from users is motivation fuel

#meanwhile
#speaker-note[
  #sn(1)[
    Some short lessons really quick in my experience working on wgsl-analyzer
  ]

  #sn(2)[
    - Certain design decisions that make the developer UX good in one way create an awful developer UX in another way
    - Specifically, with shaders, everything that gets computed at runtime and passed from host-code is a challenge for static analysis tools
    - A human brain reading code is performing static analysis
    - When you look at prior art, you learn a lot
  ]

  #sn(3)[
    - Crates such as `expect-test` or `insta` make it easy to see changes in behavior
  ]

  #sn(4)[
    - When they ask about a specific issue they have, it is motivating
      - I can help you!
  ]
]

== Takeaways

#v(20%)

- wgsl-analyzer fills a gap in the user-experience of writing shaders
- It is ready to use, but also has a lot to-do
- It is a fun project to hack on with active maintainers willing to provide almost any level of guidance you need
- I learned a lot personally while working on it
- Please try it out and give feedback

== `return;`

#slide(config: config-info(logo: none))[
  #link-row(
    "assets/GitHub Logos/PNG/GitHub_Invertocat_Black.png",
    "GitHub",
    "https://github.com/wgsl-analyzer/wgsl-analyzer",
    "assets/qr/GitHub-wgsl-analyzer.png",
  )
  #link-row(
    "assets/Discord_Symbol_Black/Discord-Symbol-Black.png",
    "Discord",
    "https://discord.gg/XDYT5NQkjv",
    "assets/qr/Discord.png",
  )
  #link-row(
    "assets/w-a.png",
    "Website",
    "https://wgsl-analyzer.github.io",
    "assets/qr/Website.png",
  )
]
