## 0.1.1+1

* Added AndroidLocalNetwork.initialize() to automatically handle ACCESS_LOCAL_NETWORK permission for sockets.

## 0.1.1

* `AndroidLocalAreaSocket.connect` now automatically requests permission on first use.
* Synchronized `AndroidLocalNetwork.requestPermission` to handle concurrent calls.

## 0.1.0

* Initial release.
* Added `AndroidLocalNetwork` to check and request `ACCESS_LOCAL_NETWORK` permission.
* Added `AndroidLocalAreaSocket` wrapper for `Socket.connect`.
