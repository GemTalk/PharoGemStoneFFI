# PharoGemStoneFFI
GemStone GCI access via Pharo FFI

## Prerequisites

### Version 1.1
**GemStone version ==3.7.1== or later is now required!**

Tested on Pharo 9, 10, 11 on Windows and Linux. Other Pharo versions/platforms will probably work but might not.

Installation instructions assume that you have registered SSH Keys with your GitHub account. See [Connecting to GitHub with SSH](https://help.github.com/articles/connecting-to-github-with-ssh/) for more information.

You must have git installed: [git setup](https://help.github.com/articles/set-up-git/)

You must have access to the GemStone client libraries for 3.7.1 or later for the client platform you're running on .
The build step [slow|fast]clientlibs generates a zip file containing these libraries in the correct directory structure.

## Installation

If you are installing Sparkle, it will automatically install PharoGemStoneFFI, and there is no need to perform an manual install of PharoGemStoneFFI.  See [Sparkle on github](https://github.com/GemTalk/Sparkle); the Installation Guide is under Documentation.

### Client Library Installation
Choose a location for the client library files and copy the client library zip file to that location. ClientLibs are available here:
https://downloads.gemtalksystems.com/pub/GemStone64/3.7.1/GemStoneClientLibs3.7.1-x86.Windows_NT.zip
https://downloads.gemtalksystems.com/pub/GemStone64/3.7.1/GemStoneClientLibs3.7.1-x86_64.Linux.zip

unzip the zip file into a directory named clientLibs. 

The examples below show installing on Windows under cygwin, but the process is similar for Linux.
```
$ mkdir clientlibs
$ cd clientlibs
$ cp installdir/GemStoneClientLibs3.7.1-x86.Windows_NT.zip .
$ unzip GemStoneClientLibs3.7.1-x86.Windows_NT.zip
Archive:  GemStoneClientLibs3.7.1-x86.Windows_NT.zip
   creating: 3.7.1/
   creating: 3.7.1/32bit/
  inflating: 3.7.1/32bit/libgcirpc-3.7.1-32.dll
  inflating: 3.7.1/32bit/libgcirpc-3.7.1-32.pdb
  inflating: 3.7.1/32bit/libgcits-3.7.1-32.dll
  inflating: 3.7.1/32bit/libgcits-3.7.1-32.pdb
  inflating: 3.7.1/32bit/libssl-3.7.1-32.dll
  inflating: 3.7.1/32bit/libssl-3.7.1-32.pdb
  inflating: 3.7.1/32bit/vcruntime140d.dll
   creating: 3.7.1/64bit/
  inflating: 3.7.1/64bit/libgcirpc-3.7.1-64.dll
  inflating: 3.7.1/64bit/libgcirpc-3.7.1-64.pdb
  inflating: 3.7.1/64bit/libgcits-3.7.1-64.dll
  inflating: 3.7.1/64bit/libgcits-3.7.1-64.pdb
  inflating: 3.7.1/64bit/libssl-3.7.1-64.dll
  inflating: 3.7.1/64bit/libssl-3.7.1-64.pdb
  inflating: 3.7.1/64bit/vcruntime140d.dll
  inflating: 3.7.1/64bit/vcruntime140_1d.dll

```
The installdir/clientLibs directory is your client libs directory. Remember this location, you will need it later. 
On Windows, this must be a path in Windows format, NOT cygwin format.

Note: slow client libs will not function properly on Windows unless you have the debug versions of the vcruntime dlls that come with MS VisualStudio 2019. Therefore it is better to use fast builds on Windows.

### PharoGemStoneFFI Smaltalk code Installation
If you don't already have one, choose a standard location on disk where you will locate your GitHub project clones.
Clone the PharoGemStoneFFI repository:

```
cd <GitHub clones directory>
git clone git@github.com:GemTalk/PharoGemStoneFFI.git
```
If you have already performed the clone, do a "git pull origin development" before running the install (if you will install the current developement branch).
* Start a Pharo 11 or 12 image and open Iceberg.
* In the Repositories window, click "+" and select "Import from existing clone".
* Select the directory you cloned to above and add the repository.
* Right click and select "Load" to load the code.
* Open a Pharo playground and execute this code to tell the FFI where to find the client libraries using the directory you saved from above:

```
GciInterface libraryDirectory: 'installDir\clientlibs'
```
* Save the image.

## That's it, you're done!

There are examples in classmethods in GsSession that demonstrate how to login and logout of GemStone and execute strings. To do that you will need a running GemStone server that you can log into. 





