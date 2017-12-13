#!/bin/bash

##
## Installation script for prerequisites for running crydra-16
##
## Script installs the Hydra and support tools.
##
## Application Security Threat Attack Modeling (ASTAM)
##
## Copyright (C) 2017 Applied Visions - http://securedecisions.com
##
## Written by Aspect Security - http://aspectsecurity.com
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

topDir=`dirname "$0"`

### Required Tools
apt-get update

# Full install of Hydra would need these libs, but currely ASTAM is aimed
# only at HTTP authentication, so we save 2minutes by not installing these.
# apt-get install -y libssl-dev libssh-dev libidn11-dev libpcre3-dev \
#    libgtk2.0-dev libmysqlclient-dev libpq-dev libsvn-dev \
#    firebird2.1-dev libncp-dev libncurses5-dev
apt-get install -y make gcc libpcre3-dev libssl-dev libidn11-dev dos2unix

### Git latest Hydra from master/HEAD, build only hydra
git clone https://github.com/vanhauser-thc/thc-hydra.git /opt/hydra
cd /opt/hydra
## checkout known working version
git checkout 59819655d1e13f712d4f4791d99b172699103979

## remove political echo message
cp Makefile.am Makefile.am.orig
grep -v "abortion" Makefile.am.orig > Makefile.am

sh ./configure
make hydra

# copy hydra to bin
cp hydra /usr/local/bin/
chmod a+x /usr/local/bin/hydra

cp /opt/attack-scripts/crydra16/crydra-16 /usr/local/bin/
