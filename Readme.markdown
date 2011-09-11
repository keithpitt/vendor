# Vendor – an iOS library management system

Vendor makes the process of using and managing libraries in iOS easy. Vendor is modeled after [Bundler](https://github.com/carlhuda/bundler). Vendor streamlines the installation and update process for dependent libraries.  It also tracks versions and manages dependencies between libraries.

## Installation

If you have [RVM](http://beginrescueend.com/rvm/install/) installed, simply run:

```bash
$ gem install vendor
```

Otherwise, you'll need to:

```bash
$ sudo gem install vendor
```

## Installing Libraries

### Step 1: Specify dependencies

Specify your dependencies in a Vendors file in your project's root.

```ruby
source "https://vendorage.com"

lib "DKBenchmark"
lib "DKPredicateBuilder"
lib "JSONKit", :git => "https://github.com/johnezang/JSONKit.git"
```

You can do this by either creating a `Vendorfile` manually, or by running:

```bash
$ vendor init
```

### Step 2: Install dependencies

```bash
$ vendor install
$ git add Vendors.lock
```

Installing a vendor library gets the latest version of the code, and adds them directly to your project in a `Vendor` group.

As part of the installation process the required frameworks are added aswell as any compiler/linker flags. The installed version of the library is captured in the Vendors.lock file.

### Step 3: Restart XCode

XCode sometimes goes bonkers if you try and make a modification to it while its running. It's easier just to either `vendor install` while its not running, or restart right after installing libraries.

## Creating Libraries

```bash
$ vendor library create
```

Will create a `.vendorspec` file that looks something like this:

```ruby
name          "DKBenchmark"
version       "0.1"

authors       "keithpitt"
email         "me@keithpitt.com"
homepage      "http://www.keithpitt.com"
description   "Easy benchmarking in Objective-C using blocks"

github        "https://github.com/keithpitt/DKBenchmark"

files         [ "DKBenchmark.h", "DKBenchmark.m" ]
```

Change what you need to match your project, and to push the library to
[http://vendorage.com](http://vendorage.com), just run the following:

```bash
$ vendor library publish
```

## History

Vendor was inspired by a blog post entitled [Vendor – Bringing Bundler to iOS](http://engineering.gomiso.com/2011/08/08/vendor-the-best-way-to-manage-ios-libraries/). I had started working on Vendor after they started doing it themselves. Their repo can be found here [https://github.com/bazaarlabs/vendor](https://github.com/bazaarlabs/vendor). I took many of the ideas (and parts of this Readme) from their code.

After reading [this blog post](http://www.germanforblack.com/articles/false-fears) by Ben Schwarz, I decided just to start something.

> There is no value in hoarding away your treasures. If you’re genuinely creating things that you want to share with other people, then put them out there, fail, make mistakes and poor judgements... but for gods sake, do something!

So I've probably made mistake or two. But thats OK, because at least I have *something* working. If you see something you think could be done better, feel free to fork and submit a pull request :)

## Contributers

* [Keith Pitt](http://www.keithpitt.com)
* [Tim Lee](http://twitter.com/#!/timothy1ee)
* [Jari Bakken](https://github.com/jarib/plist/blob/master/lib/plist/ascii.rb)

## Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Keith Pitt. See LICENSE for details.
