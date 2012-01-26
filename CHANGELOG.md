## 0.1.5 (January 27, 2012)

Bug Fixes:

  - Improvements to the Plist converter
  - Fixes for projects that have Aggregate Targets
  - Use the correct PList converter on OSX

## 0.1.4 (January 13, 2012)

Features:

  - Updated default Vendorfile
  - Added support for files with .c extensions (@rauluranga)

Bug Fixes:

  - Don't allow libraries with no vendor files
  - Renamed vendorforge.org to vendorkit.com in various places

## 0.1.2 (November 8, 2011)

Bug Fixes:

  - When adding dylibs and framworks ensure they have the correct name

## 0.1.2 (November 8, 2011)

Features:

  - Added support for adding dylibs to the frameworks build phase

## 0.1.1 (November 8, 2011)

Bug Fixes:

  - Make a backup of the Xcode project before saving

## 0.1 (November 8, 2011)

Features:

  - Initial release
  - Build vendor libraries with `vendor library build VENDORSPEC`
  - Create template vendor libraries with `vendor library init`
  - Push vendor libraries to http://vendorforge.org with `vendor library push VENDOR`
  - Install vendor libraries with `vendor install` using a Vendorfile
  - Basic dependency management and conflict resolution
  - Vendorspecs support adding frameworks to projects
  - Vendorspecs support adding build settings / compiler flags to projects
  - Vendorspecs support adding build settings / compiler flags to projects
  - Libraries defined in the Vendorfile can reference libraries that
    exist on http://vendorforge.org
  - Libraries defined in the Vendorfile can be git repositories
  - Libraries defined in the Vendorfile can be a local path
  - Libraries do not need to be built to be installed in a Xcode project
    as long as they have a folder that contains the source files (not
    the project file, tests etc). To reference this folder, you can pass a
    `:require` option to the lib to declare which folder the source files
    live in.
