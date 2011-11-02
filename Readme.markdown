# Vendor – an iOS library management system

[![Build Status](https://secure.travis-ci.org/keithpitt/vendor.png)](http://travis-ci.org/keithpitt/vendor)

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
source "https://vendorforge.com"

# Downloads the latest version of DKBenchmark from
# http://vendorforge.com
lib "DKBenchmark"

# Downloads version 0.5 of DKPredicateBuilder from
# http://vendorforge.com
lib "DKPredicateBuilder", '0.5'

# Include all the source files found in ~/Development/DKRest/Classes
# This is usefull when developing your own libraries
lib "DKRest", :path => "~/Development/DKRest", :require => "Classes"

# Checks out the git repo and includes all the files found in the
# AFNetworking folder in the repo. The require option is handy for
# repo's that haven't created vendor libraries and pushed them to
# Vendorforge
lib "DKRest", :git => "git://github.com/gowalla/AFNetworking.git", :require => "AFNetworking"

# The Vendorfile allows you to specify targets to add your libraries to.
# By default, each library will be added to all targets, but if you have
# library that you only wanted to use in the "Integration Tests" target,
# you could do the following
target "Integration Tests" do
  lib "cedar", '0.2'
end

# These lines are an alternative syntax to the target specification above
lib "OCMock", :targets => [ "Integration Tests", "Specs" ]
lib "Kiwi", :target => "Specs"
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

If a vendor library has no framework dependencies, has no required additional compiler/linker flags, and has an XCode project, it doesn’t require a "vendorspec". An example is JSONKit, which may be specified as below. However, if another Vendor library requires JSONKit, JSONKit must have a vendorspec.

```ruby
lib "JSONKit", :git => "https://github.com/johnezang/JSONKit.git"
```

However, if the vendor library requires frameworks or has dependencies on other Vendor libraries, it must have a vendorspec. As with Rubygems, a vendorspec is some declarative Ruby code that is open source and centrally managed.

To create a vendorspec, simply run:

```bash
$ vendor library init
```

This command will create a blank `.vendorspec` file that looks something like this:

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

Change what you need to match your project, then build a packaged
vendor library by running:

```bash
$ vendor library build my_library.vendorspec
```

Now that you have a packaged library, you can push it to [http://vendorforge.org](http://vendorforge.org) by
running:

```bash
$ vendor library publish my_library.vendor
```

## Why not CocoaPods?

During the early days of Vendor development, another dependency/package
manager called [CocoaPods](https://github.com/alloy/cocoapods) came on the seen. I had a look into the
project, but there were a few things that I didn't quite like.
I prefer all the source files for my dependencies to be stored in the project itself - not hidden in a static
library. I tend to tweak and read through those libraries, so having
the source readily available is handy. I also don't like the approach of requiring all the libraries to
be commited to a centralized git repo (similar to [homebrew](https://github.com/mxcl/homebrew)).
I think it puts alot of pressure on the maintainer to make sure that he reviews all the libs and that they're
not doing anything smelly. It also fattens the git repo :D

In saying that, trying to solve the problem of iOS dependency
management, is tough, and a big shout out to anyone that tries to solve
the problem. I should also mention another library that I admire that is
also trying to solve this problem: [Kit](https://github.com/nkpart/kit)

I wrote Vendor the way I think dependency management should be handled,
and in a way that I like. Vendor can work with any lib, even if it
doesn't have a compiled vendorspec - which I think is one of the
strengths of Vendor.

I also like the idea of a central site where people can upload their own
libraries - just like Rubygems. There isn't much of an ecosystem
around iOS development, just lots of isolated Github repos. I hope
Vendor can fix this.

## History

Vendor was inspired by a blog post entitled [Vendor – Bringing Bundler to iOS](http://engineering.gomiso.com/2011/08/08/vendor-the-best-way-to-manage-ios-libraries/). I had started working on Vendor after they started doing it themselves. Their repo can be found here [https://github.com/bazaarlabs/vendor](https://github.com/bazaarlabs/vendor). I took many of the ideas (and parts of this Readme) from their code.

After reading [this blog post](http://www.germanforblack.com/articles/false-fears) by Ben Schwarz, I decided just to start something.

> There is no value in hoarding away your treasures. If you’re genuinely creating things that you want to share with other people, then put them out there, fail, make mistakes and poor judgements... but for gods sake, do something!

So I've probably made mistake or two. But thats OK, because at least I have *something* working. If you see something you think could be done better, feel free to fork and submit a pull request :)

## Contributers

* [Keith Pitt](http://www.keithpitt.com)
* [Tim Lee](http://twitter.com/#!/timothy1ee)
* [Jari Bakken](https://github.com/jarib/plist/blob/master/lib/plist/ascii.rb)

## Special Thanks

Thanks to the following libraries. They provided me with a great deal of
inspiration and example code :D

* [CocoaPods](https://github.com/alloy/cocoapods)
* [Kit](https://github.com/nkpart/kit)
* [Vendor](https://github.com/bazaarlabs/vendor)
* [Bundler](https://github.com/carlhuda/bundler)

## Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright &copy; 2011 Keith Pitt. See LICENSE for details.
