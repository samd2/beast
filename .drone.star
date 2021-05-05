# Use, modification, and distribution are
# subject to the Boost Software License, Version 1.0. (See accompanying
# file LICENSE.txt)
#
# Copyright Rene Rivera 2020.

# For Drone CI we use the Starlark scripting language to reduce duplication.
# As the yaml syntax for Drone CI is rather limited.
#
#
globalenv={}
linuxglobalimage="cppalliance/droneubuntu1604:1"
windowsglobalimage="cppalliance/dronevs2019"

addon_base = { "apt": { "packages": [ "software-properties-common", "libffi-dev", "libstdc++6", "binutils-gold", "gdb" ] } }

def main(ctx):
  return [
  linux_cxx("docs", "g++", packages="docbook docbook-xml docbook-xsl xsltproc libsaxonhe-java default-jre-headless flex libfl-dev bison unzip", buildtype="docs", buildscript="drone", image="cppalliance/droneubuntu1604:1", environment={'DRONE_JOB_UUID': 'b6589fc6ab'}, globalenv=globalenv),
  linux_cxx("GCC 6.0, Debug + Coverage", "g++-6", packages=" ".join(addon_base["apt"]["packages"]) + " g++-6 libssl-dev", buildtype="boost", buildscript="drone", image=linuxglobalimage, environment={'VARIANT': 'beast_coverage', 'TOOLSET': 'gcc', 'COMPILER': 'g++-6', 'CXXSTD': '14', 'DRONE_JOB_UUID': '356a192b79'}, globalenv=globalenv),
  linux_cxx("Default clang++ with libc++", "clang++-libc++", packages=" ".join(addon_base["apt"]["packages"]) + " libc++-dev", buildtype="boost", buildscript="drone", image=linuxglobalimage, environment={'VARIANT': 'debug', 'TOOLSET': 'clang', 'COMPILER': 'clang++-libc++', 'CXXSTD': '11', 'CXX_FLAGS': '<cxxflags>-stdlib=libc++ <linkflags>-stdlib=libc++', 'DRONE_JOB_UUID': 'da4b9237ba'}, globalenv=globalenv),
  linux_cxx("GCC Valgrind", "g++", packages=" ".join(addon_base["apt"]["packages"]) + " g++-7 libssl-dev valgrind", buildtype="boost", buildscript="drone", image="cppalliance/droneubuntu2004:1", environment={'VARIANT': 'beast_valgrind', 'TOOLSET': 'gcc', 'COMPILER': 'g++', 'CXXSTD': '11', 'DRONE_JOB_UUID': '77de68daec'}, globalenv=globalenv),
  linux_cxx("Default g++", "g++", packages=" ".join(addon_base["apt"]["packages"]), buildtype="boost", buildscript="drone", image=linuxglobalimage, environment={'VARIANT': 'release', 'TOOLSET': 'gcc', 'COMPILER': 'g++', 'CXXSTD': '11', 'DRONE_JOB_UUID': '1b64538924'}, globalenv=globalenv),
  linux_cxx("GCC 8, C++17, libstdc++, release", "g++-8", packages=" ".join(addon_base["apt"]["packages"]) + " g++-8", buildtype="boost", buildscript="drone", image=linuxglobalimage, environment={'VARIANT': 'release', 'TOOLSET': 'gcc', 'COMPILER': 'g++-8', 'CXXSTD': '17', 'DRONE_JOB_UUID': 'ac3478d69a'}, globalenv=globalenv),
  linux_cxx("Clang 3.8, UBasan", "clang++-3.8", packages=" ".join(addon_base["apt"]["packages"]) + " clang-3.8 libssl-dev", llvm_os="precise", llvm_ver="3.8", buildtype="boost", buildscript="drone", image=linuxglobalimage, environment={'VARIANT': 'beast_ubasan', 'TOOLSET': 'clang', 'COMPILER': 'clang++-3.8', 'CXXSTD': '11', 'UBSAN_OPTIONS': "'print_stacktrace=1'", 'DRONE_JOB_UUID': 'c1dfd96eea'}, globalenv=globalenv),
  linux_cxx("GCC 9", "g++-9", packages=" ".join(addon_base["apt"]["packages"]) + " g++-9", buildtype="boost", buildscript="drone", image="cppalliance/droneubuntu1804:1", environment={'VARIANT': 'release', 'TOOLSET': 'gcc', 'COMPILER': 'g++-9', 'CXXSTD': '17'}, globalenv=globalenv),
  linux_cxx("GCC 10", "g++-10", packages=" ".join(addon_base["apt"]["packages"]) + " g++-10", buildtype="boost", buildscript="drone", image="cppalliance/droneubuntu1804:1", environment={'VARIANT': 'release', 'TOOLSET': 'gcc', 'COMPILER': 'g++-10', 'CXXSTD': '17,2a'}, globalenv=globalenv),
  linux_cxx("Clang 11", "clang++-11", packages="clang-11 libstdc++-9-dev", llvm_os="bionic", llvm_ver="11", buildtype="boost", buildscript="drone", image="cppalliance/droneubuntu1804:1", environment={'VARIANT': 'release', 'TOOLSET': 'clang', 'COMPILER': 'clang++-11', 'CXXSTD': '17,2a'}, globalenv=globalenv),
  osx_cxx("VARIANT=debug TOOLSET=clang COMPILER=clang++ Job 7", "clang++", packages="", buildtype="boost", buildscript="drone", xcode_version="9.4", environment={'VARIANT': 'debug', 'TOOLSET': 'clang', 'COMPILER': 'clang++', 'CXXSTD': '14', 'DRONE_JOB_UUID': '902ba3cda1'}, globalenv=globalenv),
    windows_cxx("msvc-14.1", "", image="cppalliance/dronevs2017", buildtype="boost", buildscript="drone", environment={ "VARIANT": "release", "TOOLSET": "msvc-14.1", "CXXSTD": "17", "DEFINE" : "BOOST_BEAST_USE_STD_STRING_VIEW", "ADDRESS_MODEL": "64"}, globalenv=globalenv),
    windows_cxx("msvc-14.2", "", image="cppalliance/dronevs2019", buildtype="boost", buildscript="drone", environment={ "VARIANT": "release", "TOOLSET": "msvc-14.2", "CXXSTD": "17", "DEFINE" : "BOOST_BEAST_USE_STD_STRING_VIEW", "ADDRESS_MODEL": "64"}, globalenv=globalenv),
    ]

# from https://github.com/boostorg/boost-ci
load("@boost_ci//ci/drone/:functions.star", "linux_cxx","windows_cxx","osx_cxx","freebsd_cxx")
