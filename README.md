
XcodeIconTagger
===============

The XcodeIconTagger can add a version number and a GIT commit hash (or any other text) as an overlay to your iOS app's icon. This can be really useful for beta/AdHoc builds, just a glimpse at Springboard can reveal which version of your app is installed on a device! The idea for this tool came from Evan Doll who presented it at NSConference #5 as a part of development setup that Flipboard is using.

## Usage

The entry point of the tagger is tagIcons.sh script, which takes two arguments:

	tagIcons.sh <command> [path-to-icons-directory]
	
The two available commands are:

* _tag_ - tags icons with version number and commit hash
* _cleanup_ - checkouts the icons to their original state

The script is designed to be run as one of Xcode build phases. It uses environmental variables to retrieve application version and icons file names from application's Info Plist file (since the plist doesn't include full paths you still need to provide the base path to icons directory).

The easiest way to integrate XcodeIconTagger with your project is by adding two scripts to build phases, one at the very beginning:

	if [ $CONFIGURATION == "Release" ] ; then
    	${SRCROOT}/XcodeIconTagger/tagIcons.sh tag MyApp/Images
	fi

and one at the very end:

	if [ $CONFIGURATION == "Release" ] ; then
	    ${SRCROOT}/XcodeIconTagger/tagIcons.sh cleanup MyApp/Images
	fi

## Sample tagged icon

![Tagged Icon](https://raw.github.com/bejo/XcodeIconTagger/master/sample/Icon-Small-50@2x.png)
