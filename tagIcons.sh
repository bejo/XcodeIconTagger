#!/bin/bash

# get the mode parameter

mode=$1
commitMode="commit"
versionMode="version"
customMode="custom"
cleanupMode="cleanup"

# get version info from plist in case we need it later, before we change directories
version1=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLIST_FILE}"`
version2=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}"`
version="${version1}+${version2}"

# locate icons with path parameter

taggerDirectory=`dirname $0`
taggerPlist="tagImage.workflow/Contents/document.wflow"
paramsPath=":actions:0:action:ActionParameters"

IFS=$'\n'
iconsDirectory=`cd $2 && pwd`
if [ $(echo "${iconsDirectory}" | grep -E "\.appiconset$") ]; then
	icons=(`sed -n -e 's/.*filename.*: \"\(.*\)\",/\1/p' < "${iconsDirectory}/Contents.json"`)
else
	icons=(`/usr/libexec/PlistBuddy -c "Print CFBundleIconFiles" "${INFOPLIST_FILE}" | grep png | tr -d '\n'`)
fi

iconsCount=${#icons[*]}
for (( i=0; i<iconsCount; i++ ))
do
    icon="$iconsDirectory/${icons[$i]}"

    if [ -f $icon ]; then
        height=`sips -g pixelHeight $icon | tail -n 1 | sed "s/ *pixelHeight: */ /"`
        width=`sips -g pixelWidth $icon | tail -n 1 | sed "s/ *pixelWidth: */ /"`

        if (( $height == $width )); then
            if [[ $mode = $versionMode || $mode = $customMode || $mode = $commitMode ]]; then
                renderSize=$(( $width * 4 )) # for some reason it looks much better when rendering canvas are bigger than an icon
                renderSize=$(( $renderSize + $width%2 )) # rendering canvas for odd sized images should also be odd
                
                # prepare the text for the overlay
                if [[ $mode = $versionMode ]]; then
                    textContent="$version"
                elif [[ $mode = $commitMode ]]; then
                    textContent=`git rev-parse --short HEAD`
                    echo $textContent
                elif [[ $mode = $customMode ]]; then
                    textContent="$3"
                fi

                cd $taggerDirectory
                /usr/libexec/PlistBuddy -c "Set $paramsPath:renderPixelsHigh $renderSize" -c "Set $paramsPath:renderPixelsWide $renderSize" $taggerPlist
                automator -D text="$textContent" -D image="$icon" -i tagImage.qtz tagImage.workflow > /dev/null
                git checkout $taggerPlist
                sips --cropToHeightWidth $height $width tagImage.png > /dev/null
                mv tagImage.png $icon
            elif [ $mode == $cleanupMode ]; then
                git checkout $icon
            fi
        fi
    fi
done
