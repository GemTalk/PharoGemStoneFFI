# Version 1.1, December 22, 2024

## GemStone version 3.7.1 or later is now required. 3.7.0 and 3.6.x are no longer supported.

## Issues Fixed in 1.1:

### issue 17: Support fork and detach semantics
Add support for "execute and detach" semantics. This allows the FFI to "fork" code to run on the server and tells the gem to keep running if the client logs out and/or closes the socket.

### issue 16: Need smalltalk logic to call thread safe library GciTsNbLogout
Add GsSession>>logoutNbNoError method to call GciTsNbLogout(). This method causes an immediate logout without waiting for a response from the gem.

### issue 12: Should GsSession>>logout signal an error if not logged in?
This was a bug. GsSession>>logout now raises an error if the session is not logged in. To avoid the exception, use #logoutNbNoError or #logoutNoError.

### issue 5: SparkleFFI should trim white space on strings passed to C that are used in the NRS
Remove whitespace from stone, netldi, host, logPattern, dirPattern .
