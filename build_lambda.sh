#!/usr/bin/env bash

# Upside Travel, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

lambda_output_file=/opt/app/build/lambda.zip

set -e

yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum update -y
yum install yum-utils -y
yum install -y cpio python2-pip zip
pip install --no-cache-dir virtualenv
pip install --upgrade pip
virtualenv env
. env/bin/activate
pip install --no-cache-dir -r requirements.txt

pushd /tmp
yumdownloader -x \*i686 --archlist=x86_64 clamav clamav-lib clamav-update json-c pcre2 libprelude gnutls libtasn1 lib64nettle nettle libtool-ltdl
rpm2cpio pcre2*.rpm | cpio -idmv
rpm2cpio json-c*.rpm | cpio -idmv
rpm2cpio clamav-0*.rpm | cpio -idmv
rpm2cpio clamav-lib*.rpm | cpio -idmv
rpm2cpio clamav-update*.rpm | cpio -idmv
rpm2cpio gnutls*.rpm | cpio -idmv
rpm2cpio nettle*.rpm | cpio -idmv
rpm2cpio libprelude*.rpm | cpio -idmv
rpm2cpio libtasn1*.rpm | cpio -idmv
rpm2cpio libtool-ltdl*.rpm | cpio -idmv

popd
mkdir -p bin
cp /tmp/usr/bin/clamscan /tmp/usr/bin/freshclam /tmp/usr/lib64/* bin/.
echo "DatabaseMirror database.clamav.net" > bin/freshclam.conf

mkdir -p build
zip -r9 $lambda_output_file *.py bin
cd env/lib/python2.7/site-packages
zip -r9 $lambda_output_file *