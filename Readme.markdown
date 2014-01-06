# [NOT MAINTAINED] Vendor – an iOS library management system [![Build Status](https://secure.travis-ci.org/keithpitt/vendor.png)](http://travis-ci.org/keithpitt/vendor)

__Note: This software is currently in super alpha. I've been testing it
with my own projects, and its seemed to work so far. If you have any
problems, feel free to create an issue. If your having a problem with
installing the vendor libraries into XCode, could you also provide me
with your .xcodeproj file, you don't need to give me the source files
just the project file is all I need.__

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
# Downloads the latest version of DKBenchmark from
# http://vendorkit.com
lib "DKBenchmark"

# Downloads version 0.5 of DKPredicateBuilder from
# http://vendorkit.com
lib "DKPredicateBuilder", '0.5'

# Include all the source files found in ~/Development/DKRest/Classes
# This is usefull when developing your own libraries
lib "DKRest", :path => "~/Development/DKRest", :require => "Classes"

# Checks out the git repo and includes all the files found in the
# AFNetworking folder in the repo. The require option is handy for
# repo's that haven't created vendor libraries and pushed them to
# VendorKit.com
lib "DKRest", :git => "git://github.com/AFNetworking/AFNetworking.git", :require => "AFNetworking"

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

### Step 3: There is no spoon

Or step 3 for that matter!

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
Vendor::Spec.new do |s|

  s.name           "DKBenchmark"
  s.version        "0.1"

  s.authors        "keithpitt"
  s.email          "me@keithpitt.com"
  s.description    "Easy benchmarking in Objective-C using blocks"

  s.homepage       "http://www.keithpitt.com"
  s.source         "https://github.com/keithpitt/DKBenchmark"
  s.docs           "https://github.com/keithpitt/DKBenchmark/wiki"

  s.files          [ "DKBenchmark.h", "DKBenchmark.m", "static-lib.a" ]
  s.resources      [ "images/loading.png", "images/loading@2x.png" ]

  s.build_setting  :other_linker_flags, [ "-ObjC", "+lsdd" ]
  s.build_setting  "CLANG_WARN_OBJCPP_ARC_ABI", false
  s.build_setting  "GCC_PRECOMPILE_PREFIX_HEADER", "YES"

  s.framework      "CoreGraphics.framework"
  s.framework      "UIKit.framework"

  s.dependency     "JSONKit", "0.5"
  s.dependency     "ASIHTTPRequest", "~> 4.2"
  s.dependency     "AFINetworking", "<= 2.5.a"

end
```

Change what you need to match your project, then build a packaged
vendor library by running:

```bash
$ vendor library build my_library.vendorspec
```

Now that you have a packaged library, you can push it to [http://vendorkit.com](http://vendorkit.com) by
running:

```bash
$ vendor library push my_library.vendor
```

## History

Vendor was inspired by a blog post entitled [Vendor – Bringing Bundler to iOS](http://engineering.gomiso.com/2011/08/08/vendor-the-best-way-to-manage-ios-libraries/). I had started working on Vendor after they started doing it themselves. Their repo can be found here [https://github.com/bazaarlabs/vendor](https://github.com/bazaarlabs/vendor). I took many of the ideas (and parts of this Readme) from their code.

After reading [this blog post](http://www.germanforblack.com/articles/false-fears) by Ben Schwarz, I decided just to start something.

> There is no value in hoarding away your treasures. If you’re genuinely creating things that you want to share with other people, then put them out there, fail, make mistakes and poor judgements... but for gods sake, do something!

So I've probably made mistake or two. But thats OK, because at least I have *something* working. If you see something you think could be done better, feel free to fork and submit a pull request :)

## Special Thanks

Thanks to the following libraries and people, without their
contributions to open source, Vendor would have never been...

* [Rubygems](http://rubyforge.org/projects/rubygems/)
* [Bundler](https://github.com/carlhuda/bundler)
* [CocoaPods](https://github.com/alloy/cocoapods)
* [Kit](https://github.com/nkpart/kit)
* [Vendor](https://github.com/bazaarlabs/vendor)
* [Jari Bakken](https://github.com/jarib/plist/blob/master/lib/plist/ascii.rb)
* [Tim Lee](http://twitter.com/#!/timothy1ee)

## Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright &copy; 2011 Keith Pitt. See LICENSE for details.
