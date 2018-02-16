#!/bin/sh

#  create-cardio-framework.sh
#  RTCreditCardInput
#
#  Created by A-25 on 16/02/2018.
#  Copyright © 2018 CocoaPods. All rights reserved.

FWNAME=CardIO

#pwd
#exit 1

#if [ ! -d lib ]; then
#echo "Please run build-cardio-deps.sh first!"
#exit 1
#fi

if [ -d $FWNAME.framework ]; then
echo "Removing previous $FWNAME.framework copy"
rm -rf $FWNAME.framework
fi

if [ "$1" == "dynamic" ]; then
LIBTOOL_FLAGS="-dynamic -ios_version_min $2"
else
LIBTOOL_FLAGS="-static"
fi

echo "Creating $FWNAME.framework"
mkdir -p $FWNAME.framework/Headers
libtool -no_warning_for_no_symbols $LIBTOOL_FLAGS -o $FWNAME.framework/$FWNAME -install_name @rpath/$FWNAME.framework/$FWNAME Example/Pods/CardIO/CardIO/libCardIO.a Example/Pods/CardIO/CardIO/libopencv_core.a Example/Pods/CardIO/CardIO/libopencv_imgproc.a
cp -r include/$FWNAME/* $FWNAME.framework/Headers/
echo "Created $FWNAME.framework"
