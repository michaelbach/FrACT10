# CONTRIBUTING guidelines (2021-05-30)

This file is part of FrACT10.

If anything is unclear, don't hesitate to contact me <bach@uni-freiburg.de>.


## What’s the development workflow?

- Install Cappuccino <https://www.cappuccino.dev>. This, in principle, also runs in Unix/Linux, but all my explanation pertains to a MacOS environment. You should be fluent with the terminal. The Framework, built by the install processs, needs to be referred to appropriately in `ìndex.html`, see "directory structure" below. A good place to start: [Cappucino Wiki](https://github.com/cappuccino/cappuccino/wiki).

- run `XcodeCapp`
- add the folder containing all FrACT₁₀ files to XcodeCapp and use the hammer symbol to open this project in Xcode
- to test your changes, save the pertinent Xcode file, wait until the XcodeCapp menu item is no longer blue (done processing), and open `index.html` (may need to flush browser cache)
- when all is working well, run `jake release` to produce the directory `capp` with all *.j files aggregated. I use the shell script `make.sh` to do this and get rid of all extranous files produced in the process. But look at the script first if it does the right things for you before running it.


## Do I have to create an issue for a feature or a bug fix and discuss it with the existing contributors?

Contact <bach@uni-freiburg.de>.


## Should I just present a merge request with my modifications?

Best get in touch with <bach@uni-freiburg.de>.


## Should my changes be accompanied by documentation?

Of course, but no need to go overboard.


## What are some short links I should be aware of?

- I assume you know about visual testing
- peruse <https://michaelbach.de/fract/>, follow <https://michaelbach.de/fract/checklist.html> and the [manual](https://michaelbach.de/fract/manual.html).


## How can I get in touch with the developer?

<bach@uni-freiburg.de>.


## What are the code conventions?

- I like to put "{" on the end of the line _preceding_ the code block
- I usually surround operators by blanks
- I usually place 2 empty lines between functions
- I prefer camelCase over underlines
- long variable/function names can replace much documentation


## Does this repository follow a certain commit message pattern?

No.


## How do I set up the development environment for this project?

Necessary directory structure:<br>
`┳-misc/cappFrameworks/AppKit… etc. from Cappuccino`<br>
`┗FrACT10/_cappDevelop/… all project files`

A different directory structure can be used by editing the 2 pertinent framework links in `index.html`. Currently they read `../../-misc/cappFrameworks` corresponding to the directory structure above, but both can be changed to correspond to your home of the Cappuccino build.

Depending on the browser you use, you will need to disable¹ cross-origin safety or it will not open using the file:// protocol. You can, of course, set up a local web server.<br>
¹Easy in Firefox & Safari, no longer easily possible with Chrome.
