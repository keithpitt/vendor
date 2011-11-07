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
