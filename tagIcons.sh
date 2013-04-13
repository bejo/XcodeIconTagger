#!/bin/bash

commit=`git rev-parse --short HEAD`
version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLIST_FILE}"`

mode=$1
tagMode="tag"
cleanupMode="cleanup"

iconsDirectory=`cd $2 && pwd`
icons=(`/usr/libexec/PlistBuddy -c "Print CFBundleIconFiles" "${INFOPLIST_FILE}" | grep png | tr -d '\n'`)

taggerDirectory=`dirname $0`
taggerPlist="tagImage.workflow/Contents/document.wflow"
paramsPath=":actions:0:action:ActionParameters"

iconsCount=${#icons[*]}
for (( i=0; i<iconsCount; i++ ))
do
    icon="$iconsDirectory/${icons[$i]}"

    if [ -f $icon ]; then
        height=`sips -g pixelHeight $icon | tail -n 1 | sed "s/ *pixelHeight: */ /"`
        width=`sips -g pixelWidth $icon | tail -n 1 | sed "s/ *pixelWidth: */ /"`

        if (( $height == $width )); then
            if [ $mode == $tagMode ]; then
                renderSize=$(( $width * 4 )) # for some reason it looks much better when rendering canvas are bigger than an icon
                renderSize=$(( $renderSize + $width%2 )) # rendering canvas for odd sized images should also be odd

                cd $taggerDirectory
                /usr/libexec/PlistBuddy -c "Set $paramsPath:renderPixelsHigh $renderSize" -c "Set $paramsPath:renderPixelsWide $renderSize" $taggerPlist
                automator -D text=$version$'\n'$commit -D image=$icon -i tagImage.qtz tagImage.workflow > /dev/null
                git checkout $taggerPlist

                sips --cropToHeightWidth $height $width tagImage.png > /dev/null
                mv tagImage.png $icon
            elif [ $mode == $cleanupMode ]; then
                git checkout $icon
            fi
        fi
    fi
done
