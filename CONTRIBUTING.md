# CONTRIBUTING guidelines

This file is part of FrACT10. Quesitions? Don't hesitate to contact me <bach@uni-freiburg.de>.


## What’s the development workflow?

- It is not necessary to install Cappuccino, nor to compile. Just download the entire project from Github (e.g. ZIP), unzip, serve with a local server (or disable local file restrictions, see below), and open `index.html`. That should run FrACT10 on all platforms (I tested this on MacOS & Windows). You can modify any `*.j` file with a source editor and see results immediately on reload (possibly need to clear browser cache).

- Should you want to install Cappuccino <https://www.cappuccino.dev>: A good place to start is the [Cappucino Wiki](https://github.com/cappuccino/cappuccino/wiki). The Cappuccino frameworks are already in the Resources folder, so you don't need them. But you do need Cappuccino's tools for GUI compilation. Then you can also edit the GUI (using Xcodes Interface Builder, sorry, MacOS only) by openening `_cappDevelop.xcodeproj`. Then, having made changes:
  - `_make-XcodeCapp.sh` (can be started within Xcode with ⌘B) saves any changed files from Xcode, creates the `.XcodeSupport` folder (if not already present), compiles the GUI (producing the `.cib` fle), and opens in Safari after clearing Safari's cache.
  - For development, I find it easiest to run directly from the files w/o compilation and w/o a local server. Depending on your preferred browser, you will need to disable¹ "local file restrictions" or "cross-origin safety", or it will not open using the file:// protocol.<br>
¹Easy in Firefox & Safari, no longer possible with Chrome.
  - Best not run `_make-FrACT.sh` unless you really know what you're doing. Briefly: it compiles, removes unnecessary build products and produces a folder with the minimum number of files necessary for running FrACT10. Best look at its code and then fit to your environment.



## Do I have to create an issue for a feature or a bug fix and discuss it with the existing contributors?

Contact <bach@uni-freiburg.de>.


## Should I just present a merge request with my modifications?

Best get in touch with <bach@uni-freiburg.de>.


## Should my changes be accompanied by documentation?

Of course, but no need to go overboard. Use highly descriptive variable/function naming.


## What are some short links I should be aware of?

- I assume you know about visual testing
- peruse <https://michaelbach.de/fract/>, follow <https://michaelbach.de/fract/checklist.html> and the [manual](https://michaelbach.de/fract/manual.html).


## How can I get in touch with the developer?

<bach@uni-freiburg.de>. Looking forward…


## What are the code conventions?

- I like to put "{" on the end of the line _preceding_ the code block
- I usually surround operators by blanks
- I usually place 2 empty lines between functions
- I prefer camelCase over underlines
- long variable/function names can replace much documentation


## Does this repository follow a certain commit message pattern?

No.
