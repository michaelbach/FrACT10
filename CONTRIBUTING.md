# CONTRIBUTING guidelines (2021-05-28)

This file is part of FrACT10.


## What’s the development workflow?

- install Cappuccino
- run XcodeCapp
- add the folder containing all FrACT₁₀ files to XcodeCapp and use the hammer symbol to open this project in Xcode
- to test your changes, save the pertinent Xcode file, wait until the XcodeCapp menu item is no longer blue (done processing), and open index.html (may need to flush browser cache).


## Do I have to create an issue for a feature or a bug fix and discuss it with the existing contributors?

Contact <michael.bach@uni-freiburg.de>


## Should I just present a merge request with my modifications?

Better get in touch with <michael.bach@uni-freiburg.de>


## Should my changes be accompanied by documentation?

Of course, but no need to go overboard


## What are some short links I should be aware of?

- no bug tracker at this time
- I'm sure you know about visual testing
- have perused <https://michaelbach.de/fract/> and the manual


## How can I get in touch with the development team?

<michael.bach@uni-freiburg.de>


## What are the code conventions?

- I like to put "{" on the end of the line preceding the code block
- I usually surround operators by blanks
- I usually place 2 empty lines between functions

## Does this repository follow a certain commit message pattern?

No, but in future I will again start with the ISO date at the beginning of message.


## How do I set up the development environment for this project?

Necessary directory structure:

`root …/ ┳-misc/cappFrameworks/AppKit… etc. from Cappuccino`
`        ┗FrACT10/capp/… all project files`

A different directory structure can be used by editing the 2 pertinent framework links in index.html.

Depending on the browser you use, you will need to disable cross-origin safety or it will not open using the file:// protocol. You can, of course, set up a local web server.
