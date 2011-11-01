//
//  BingMaps.h
//  BingMaps
//
//  Copyright (C) Microsoft 2011. All rights reserved.
//

#import <BingMaps/BMGeometry.h>
#import <BingMaps/BMMapView.h>
#import <BingMaps/BMUserLocation.h>
#import <BingMaps/BMReverseGeocoder.h>
#import <BingMaps/BMTypes.h>
#import "BingMaps/BMMarker.h"
#import "BingMaps/BMMarkerView.h"
#import "BingMaps/BMPushpinView.h"
#import	"BingMaps/BMEntity.h"

/** @mainpage
 *
 * @section aboutbmios Bing Maps iOS Control
 * 
 * The Bing Maps iOS Control is an Objective-C control for 
 * embedding maps directly into native iOS apps. With a rich, 
 * gesture-based UI provided by Seadragon, the Bing Maps iOS Control
 * provides support for adding pushpins and other overlays to the map, 
 * allows your device location to be displayed, and provides the 
 * ability to retrieve contextual information for a given map location.
 *
 * @section gettingstarted Getting Started
 *
 * Before you being using the Bing Maps iOS Control, you need to get a Bing Maps Key to 
 * authenticate your iOS app. To obtain a Bing Maps Key, go to the <A HREF="http://www.bingmapsportal.com/" target="_blank">Bing Maps 
 * Account Center</a> and create a Bing Maps Account. This is described in the <a href="http://msdn.microsoft.com/en-us/library/gg650598.aspx" target="_blank">Creating a Bing Maps Account</a> and <a href="http://msdn.microsoft.com/en-us/library/ff428642.aspx" target="_blank">Getting a Bing Maps Key</a> 
 * topics. Information about using your Bing Maps Key in your app is found in the Adding your Bing Maps Key topic in this SDK. 
 * 
 * @section filesincinrelease Installation Files
 *
 * The Bing Maps iOS Control SDK includes the following:
 * 
 * - A readme.html file.
 * - The Bing Maps iOS Control (as a universal static library) plus the required resources bundle and header files, found in the @a MapControl folder. 
 * - Sample Xcode projects, found in the @a Samples folder.
 * - API reference documentation for the Bing Maps iOS Control, as HTML files in the @a Docs folder.
 *
 * @section seealso See Also
 *
 * - <a href="http://msdn.microsoft.com/en-us/library/dd877180.aspx" target="_blank">Bing Maps REST Services</a>
 * - <a href="http://www.microsoft.com/maps/product/terms.html" target="_blank">Bing Maps Platform API Terms of Use</a>
 * - <A HREF="http://www.bing.com/maps/" target="_blank">Bing Maps</A>
 *
 * @page gettingstarted Getting Started with the Bing Maps iOS Control
 * 
 * @section one Include the Library in Your Xcode Project
 *
 * You can find the Bing Maps iOS Control (as a universal static library) plus the required resources bundle and header files in the @a MapControl folder of your SDK installation.
 *
 * - Right-click on the project file and choose @b <b> Add Files to "<Project>"...</b>. Navigate to the @a MapControl folder, and select all items. Click @b Add.
 *
 * @image html addexistingfiles.png
 *
 * - Left-click on the project file and click on the @b <b> Build Settings </b> tab.
 *
 * - Set the value of the <b>Header Search Paths</b> environment variable to the path to your @a MapControl directory (for example, <tt>/Users/{username}/Documents/BingMapsiOS/MapControl/</tt>).
 *
 * @b Note: If there are any spaces in the path, be sure to enclose the entire path with double quotes (").
 *
 * @section two Add Linker Flags
 *
 * - Left-click on the project file and click on the @b <b> Build Settings </b> tab.
 *
 * - Set the value of the <b>Other Linker Flags</b> environment variable to <tt>-ObjC -all_load</tt>.
 *
 * @image html addlinkerflags.png
 *
 * @section three Add Required Frameworks
 *
 * - Left-click on the project file. Select the target of your project and select the @b <b> Build Phases </b> tab. 
 *
 * - Click to expand the <b>Link Binary With Libraries</b> item and click the [+] on the bottom to add frameworks. Select the following frameworks:
 *
 * - CoreData.framework
 * - CoreLocation.framework
 * - OpenGLES.framework
 * - QuartzCore.framework
 * - SystemConfiguration.framework
 * - libxml2.dylib
 * - libz.dylib
 *
 * @image html addframeworks.png
 *
 * @section four Inserting the Map Control in a NIB File
 *
 * - Open up the NIB file (.xib) where you want to insert the map in <b>Interface Builder</b>. From the @b Library palette, select the Objects tab and drag the @a UIView control to the space where you want the map to appear.
 *
 * @image html insertmapcontrolinanib.png
 *
 * - With the @a UIView control selected, tick the <b>Multiple Touch</b> checkbox within the @b Interaction section of the @b Inspector palette.
 *
 * - Click on the @b Identity tab of the @b Inspector palette. For the @b Class item, type in @c BMMapView.
 *
 * - Save the file in <b>Interface Builder</b>.
 *
 * @section five Implementing the BMMapView Delegate in UIViewController
 *
 * - Within your View Controller header file, import BingMaps/BingMaps.h.
 *
 
@code
#import "BingMaps/BingMaps.h"
@endcode

 * - Declare the ViewController to be implementing BMMapViewDelegate. Also declare a BMMapView @a IBOutlet member as shown below:
 *

@code
@interface LocationMapViewController : UIViewController <BMMapViewDelegate> {
	IBOutlet BMMapView* mapView;
}
@end
@endcode

 *
 * - Go to the ViewController class file and add the following code in the @a viewDidLoad: method.
 *
 *
 
@code
- (void)viewDidLoad {
	[super viewDidLoad];
	[mapView setDelegate:self];
	
	// If you want to show user location...
	[mapView setShowsUserLocation:YES];
}
@endcode

 * - Save and build your project.
 *
 * - Open up the NIB file (.xib) where you want to insert the map in Interface Builder. Ctrl + drag from the <b>File's Owner</b> item in the @b Document window to the BMMapView you created earlier and select @a mapView in the @b Outlets pop-up. 
 *
 * @image html implementing.png
 *
 * - Save the file in <b>Interface Builder</b>.
 *
 * @section addingyourbingmapskey Adding Your Bing Maps Key
 *
 * To use the Bing Maps iOS Control, you need to have a Bing Maps Key to use in your app.
 *
 * Bing Maps Keys can be requested from the Bing Maps Account Center (http://www.bingmapsportal.com). More information is available at http://msdn.microsoft.com/en-us/library/ff428642.aspx
 *
 * Once you have a Bing Maps Key, follow the steps below to add it to your app project's main property list, named <i>{appname}_Info.plist</i>
 *
 * - In the property list, click the [+] at the bottom-right to add a new row. The key should be specified as @a BingMapsKey and the value should be your Bing Maps Key.
 *
 * @image html addingkey.png
 *
 * @section sessioncounting Session Counting
 *
 * When the Bing Maps iOS Control is loaded with a valid Bing Maps Key, Bing Maps counts sessions. A session begins with the load of the first Bing Maps iOS Control which appears in an app and includes all map control interactions until the app is terminated. Information about Bing Maps usage reports is found in the <A HREF="http://msdn.microsoft.com/en-us/library/ff859477.aspx" target="_blank">Viewing Bing Maps Usage Reports</a> topic.
 *
 * @page releasenotes System Requirements
 *
 * @section systemrequirement Development Requirements
 *
 * To develop a Bing Maps iOS Control app, you must have:
 * 
 * - A Macintosh computer with an Intel x86 processor.
 * - Mac OS X Snow Leopard, version 10.6.4 or later.
 * - Xcode version 4.0 or later. 
 * - The latest version of the iOS SDK. (This SDK is available from http://developer.apple.com. An Apple Developer 
 * account is required.)
 *
 * @page samplecode Sample Code
 * 
 * The Bing Maps iOS Control SDK includes a template project and three sample projects, which are found 
 * in the @a Samples folder.
 * 
 * @section template iOS Map Control Project Template
 *
 * - @b BMMapTemplate  Load this template project to quickly get started building your Bing Maps iOS Control app.
 *
 * @section samples Sample Projects
 *
 * - @b BMMapViewDynamic  This sample shows how to create a map view programmatically.
 * - @b LocationMap  This sample demonstrates user location functionality.
 * - @b MapMarkers  This sample demonstrates how to work with map markers.
 *
 * @page devresources Developer Resources
 * 
 * @section links Developer Resources
 *
 * The following resources are available for Bing Maps iOS Control developers:
 * 
 * - <A HREF="http://www.bing.com/community/maps/f/13224.aspx" target="_blank">Bing Maps iOS Control Forum</A>
 * - <A HREF="http://msdn.microsoft.com/en-us/library/dd877180.aspx" target="_blank">Bing Maps on MSDN</A>
 * - <A HREF="http://www.bing.com/community/blogs/maps/default.aspx" target="_blank">Bing Maps Developer Blog</A>
 * - <A HREF="http://developer.apple.com/iphone/" target="_blank">Apple iPhone Developer Center</A>
 *
 * @section accountissues Account Issues
 *
 * If you are having issues creating a Bing Maps Account in the <A HREF="http://www.bingmapsportal.com/" target="_blank">Bing Maps Account Center</A>, getting a Bing Maps Key, or have an account access question, contact @a mpnet@microsoft.com.
 *
 * @section licensing Licensing Questions
 *
 * If you are interested in finding out more about Bing Maps or have questions about licensing Bing Maps, email @a maplic@microsoft.com or go to <A HREF="http://www.microsoft.com/maps/resources/default.aspx" target="_blank">http://www.microsoft.com/maps/resources/default.aspx</A>.
 *
 * @section seealso See Also
 * - <A HREF="http://www.microsoft.com/maps/product/terms.html" target="_blank">Bing Maps Platform API Terms of Use</A>
 * - <A HREF="http://www.bing.com/maps/" target="_blank">Bing Maps</A>
 */
