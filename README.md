# SparkleFFI
GemStone GCI access via Pharo FFI

## Prerequisites
Installation instructions assume that you have registered SSH Keys with your GitHub account. See [Connecting to GitHub with SSH](https://help.github.com/articles/connecting-to-github-with-ssh/) for more information.

You must have git installed: [git setup](https://help.github.com/articles/set-up-git/)

You must have access to the GemStone client libraries for 3.6.1 or 3.7.0 for the client platform you're running on .
The build step [slow|fast]clientlibs generates a zip file containing these libraries in the correct directory structure.

## Installation
### Client Library Installation
Choose a location for the client library files and copy the client library zip file to that location. unzip the zip file (on Windows, use cygwin).
The examples below show installing on Windows under cygwin. Linux is the same but different :wink:
```
$ cd /home/normg
$ mkdir clientlibs
$ cd clientlibs
$ cp /home/normg/gs370/slow11/gs/GemStoneClientLibs3.7.0-x86.Windows_NT-slow.zip .
$ unzip GemStoneClientLibs3.7.0-x86.Windows_NT-slow.zip
Archive:  GemStoneClientLibs3.7.0-x86.Windows_NT-slow.zip
   creating: 3.7.0/
   creating: 3.7.0/32bit/
  inflating: 3.7.0/32bit/libgcirpc-3.7.0-32.dll
  inflating: 3.7.0/32bit/libgcirpc-3.7.0-32.pdb
  inflating: 3.7.0/32bit/libgcits-3.7.0-32.dll
  inflating: 3.7.0/32bit/libgcits-3.7.0-32.pdb
  inflating: 3.7.0/32bit/libssl-3.7.0-32.dll
  inflating: 3.7.0/32bit/libssl-3.7.0-32.pdb
  inflating: 3.7.0/32bit/vcruntime140d.dll
   creating: 3.7.0/64bit/
  inflating: 3.7.0/64bit/libgcirpc-3.7.0-64.dll
  inflating: 3.7.0/64bit/libgcirpc-3.7.0-64.pdb
  inflating: 3.7.0/64bit/libgcits-3.7.0-64.dll
  inflating: 3.7.0/64bit/libgcits-3.7.0-64.pdb
  inflating: 3.7.0/64bit/libssl-3.7.0-64.dll
  inflating: 3.7.0/64bit/libssl-3.7.0-64.pdb
  inflating: 3.7.0/64bit/vcruntime140d.dll
  inflating: 3.7.0/64bit/vcruntime140_1d.dll
$ cygpath -w `pwd`
C:\cygwin64\home\normg\clientlibs

```
The directory above is your client libs directory. Remember this location, you will need it later. Note: on Windows, this must be a path in Windows format, NOT cygwin format.
Note: slow client libs will not function properly on Windows unless you have the debug versions of the vcruntime dlls that come with MS VisualStudio 2019. Therefore it is better to use fast builds on Windows.

### Sparkle FFI Smaltalk code Installation
If you don't already have one, choose a standard location on disk where you will locate your GitHub project clones.
Clone the sparkleffi repository:

```
cd <GitHub clones directory>
git clone git@github.com:GemTalk/sparkleffi.git
```
If you have already performed the clone, do a "git pull origin development" before running the install.
* Start a Pharo 9 image and open Iceberg.
* In the Repositories window, click "+" and select "Import an existing clone".
* Select the directory you cloned to above and add the repository.
* Right click and select "Load" to load the code.
* Open a Pharo playground and execute this code to tell the FFI where to find the client libraries using the directory you saved from above:

```
GciInterface libraryDirectory: 'C:\cygwin64\home\normg\clientlibs'
```
* Save the image.

## That's it, you're done!

There are examples in classmethods in GsSession that demonstrate how to login and logout of GemStone and execute strings. To do that you will need a GemStone server running to log into.





