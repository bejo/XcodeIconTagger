# XcodeIconTagger

`XcodeIconTagger` can add a version number, git commit hash or custom text as an overlay to your iOS app's icon. This can be really useful for beta or ad hoc builds, just a glimpse at Springboard can reveal which version of your app is installed on a device! The idea for this tool came from Evan Doll who presented it at NSConference #5 as a part of development setup that Flipboard is using.

## Usage

The entry point of the tagger is tagIcons.sh script, which takes two arguments:

	tagIcons.sh <command> /path/to/.../<icons-directory> [optional-custom-tag]

The available commands are:

* `commit` - tag icons with git commit hash
* `version` - tag icons with semantic+build version string
* `custom` - tag icons with a custom string, provided at the end of the command
* `cleanup` - restore the icons to their original state by performing a git checkout on their directory

The easiest way to use `XcodeIconTagger` is from a _Run Script_ Build Phase in Xcode, where it grabs the location of the application's Info.plist file. Place an invocation like the following somewhere before the _Copy Files_ Build Phase that copies the directory containing your icons:

	if [ $CONFIGURATION == "Debug" ] ; then
		/path/to/.../tagIcons.sh commit /path/to/.../<icons-directory>
	elif [ $CONFIGURATION == "Release" ] ; then
		/path/to/.../tagIcons.sh version /path/to/.../<icons-directory>
	fi

If instead of version/hash info in the tag, you want to put "My custom string":

	/path/to/.../tagIcons.sh custom /path/to/.../<icons-directory> "My custom string"

Then, somewhere after the _Copy Files_ Build Phase for icons:

	/path/to/.../tagIcons.sh cleanup /path/to/.../<icons-directory>

## Sample tagged icon

![Tagged Icon](https://raw.github.com/bejo/XcodeIconTagger/master/sample/Icon-Small-50@2x.png)
