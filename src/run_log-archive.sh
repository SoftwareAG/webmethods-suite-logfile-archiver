#!/bin/sh

# (c) Copyright 2012-2023 Software AG, Darmstadt, Germany and/or Software AG USA  Inc.,
# Reston, United States of America, and/or their suppliers.
# http://www.softwareag.com
#
# SPDX-License-Identifier: Apache-2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


# NAME
#     run_log-archive.sh - Archive and, where appropriate, delete log files
#
#
# SYNOPSIS
#
#     run_log-archive.sh [WEBMETHODS_HOME]
#
#
# DESCRIPTION
#     This script acts as a convenience wrapper to run the Ant script that 
#     does the actual work. It takes care of checking for the existence of
#     required environment variables and, if they are not defined, tries
#     to auto-set them. The variables are
#     - WEBMETHODS_HOME
#     - ANT_HOME
#     - JAVA_HOME
#
#     WEBMETHODS_HOME
#          If not set (either system-wide or from the command line), it will
#          be determined by taking this script's location, assuming the latter is
#          $WEBMETHODS_HOME/tools/operations/logArchiver
#
#     JAVA_HOME
#          The JVM that comes with the webMethods Suite will be used.
#
#     ANT_HOME
#          The Ant installation that comes with the Asset Build Environment (ABE) 
#          will be used.
#


# Log files older than $RETENTION_DAYS days, will be deleted from the archive location
# (The default in the Ant script is 30 days and will be overriden with this value.)
SCRIPT_DIR=`dirname $0`
SCRIPT_CFG="$SCRIPT_DIR/run_log-archive.cfg"
if [ -r "$SCRIPT_CFG" ] ; then 
	. "$SCRIPT_CFG"
else
	RETENTION_DAYS=30
	RETENTION_DAYS_ZIP=60
fi


CHECK_ANT_INSTALLATIONS="../../../common/lib/ant ../apache-ant ../../../common/AssetBuildEnvironment/ant"
CHECK_ANT_PROFILE="/etc/profile.d/ant.sh"
CHECK_JAVA_INSTALLATIONS="../../../jvm/jvm ../../../jvm/jvm180_64 ../../../jvm/jvm180_32 ../../../jvm/jvm180"
CHECK_JAVA_PROFILE="/etc/profile.d/jdk.sh"

# Use optional command line argument to specify/override the 
# installation's main directory
if [ ! -z "$1" ] ; then 
	WEBMETHODS_HOME="$1"
fi

# If no installation directory is defined or provided,
# determine it from this script's location, assuming the
# script is installed in $WEBMETHODS_HOME/tools/operations/logArchiver
if [ -z "$WEBMETHODS_HOME" ] ; then 
	WEBMETHODS_HOME=`dirname $(readlink -f $0)`/../../..
fi

echo WEBMETHODS_HOME = "$WEBMETHODS_HOME"

# Check for /etc/profile.d/ant.sh if ANT_HOME is not defined
if [ -z "$ANT_HOME" ] ; then
    echo "ANT_HOME is not set, checking $CHECK_ANT_PROFILE"
    if [ -r $CHECK_ANT_PROFILE ] ; then
	. $CHECK_ANT_PROFILE
    fi
fi


# If ANT_HOME is not defined, try to find an installation
if [ -z "$ANT_HOME" ] ; then 
	echo ANT_HOME is not set
	for i in $CHECK_ANT_INSTALLATIONS; do
		echo Checking $i
		if [ -x $i ]; then
			echo Found $i
			ANT_HOME=$i
			break
		fi
	done
fi


# Abort if ANT_HOME is not defined and could also not be located
if [ -z "$ANT_HOME" ] ; then 
	echo ANT_HOME is not set and no installation could be found automatically. Aborting
	exit 1
else
	echo ANT_HOME = "$ANT_HOME"
fi


# Check for /etc/profile.d/jdk.sh if JAVA_HOME is not defined
if [ -z "$JAVA_HOME" ] ; then
    echo "JAVA_HOME is not set, checking $CHECK_JAVA_PROFILE"
    if [ -r $CHECK_JAVA_PROFILE ] ; then
	. $CHECK_JAVA_PROFILE
    fi
fi


# If JAVA_HOME is not defined, try to find an installation
if [ -z "$JAVA_HOME" ] ; then 
	echo JAVA_HOME is not set
	for i in $CHECK_JAVA_INSTALLATIONS; do
		echo Checking $i
		if [ -x $i ]; then
			echo Found $i
			JAVA_HOME=$i
			break
		fi
	done
fi



# Abort if JAVA_HOME is not defined and could also not be located
if [ -z "$JAVA_HOME" ] ; then 
	echo JAVA_HOME is not set and no installation could be found automatically. Aborting
	exit 1
else
	echo JAVA_HOME = "$JAVA_HOME"
fi

ANT_CMD="$ANT_HOME/bin/ant"

CURRENT_DIR=`dirname $0`

$ANT_CMD -f $CURRENT_DIR/build_log-archive.xml -DretentionDays=$RETENTION_DAYS -DretentionDaysZIP=$RETENTION_DAYS_ZIP -DwebMethods.home="$WEBMETHODS_HOME"
