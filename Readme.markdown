# Vendor – an iOS library management system

Vendor makes the process of using and managing libraries in iOS easy. Vendor is modeled after Bundler. Vendor streamlines the installation and update process for dependent libraries.  It also tracks versions and manages dependencies between libraries.

## Installation

`$ gem install vendor`

## Installing Libraries

### Step 1) Specify dependencies

Specify your dependencies in a Vendors file in your project's root.

```ruby
source "https://vendorage.com"

lib "facebook-ios-sdk"  # Formula specified at source above
lib "three20"
lib "asi-http-request", :git => "https://github.com/pokeb/asi-http-request.git"
lib "JSONKit", :git => "https://github.com/johnezang/JSONKit.git"
```

### Step 2) Install dependencies

```ruby
$ vendor install
$ git add Vendors.lock
```

Installing a vendor library gets the latest version of the code, and adds them directly to your project under a "Vendor" group.  As part of the installation process, the required frameworks are added aswell as any compiler/linker flags.  The installed version of the library is captured in the Vendors.lock file.

## Creating Libraries

Run `vendor library create` in the root of your library. It will create a
`.vendorspec` file that looks something like this:

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
[http://vendorage.com](http://vendorage.com), just type in the
following:

`$ vendor library publish`

## Contributers

* [Keith Pitt](http://www.keithpitt.com)
* [Tim Lee](http://twitter.com/#!/timothy1ee) (For his inspiring post on [Vendor – Bringing Bundler to iOS](http://engineering.gomiso.com/2011/08/08/vendor-the-best-way-to-manage-ios-libraries/))
* [Jari Bakken](https://github.com/jarib/plist/blob/master/lib/plist/ascii.rb) (For his ASCII Plist Parser)

## Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Keith Pitt. See LICENSE for details.
