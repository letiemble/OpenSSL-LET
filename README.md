OpenSSL-LET
===========

The OpenSSL-LET CocoaPod provides the OpenSSL universal static libraries for iOS and OSX. The CocoaPod comes with precompiled libraries, and includes a script to build newer versions.

**Supported Architectures**

-	iOS: armv7, armv7s, arm64 (w/bitcode enabled)
-	iOS simulator: i386, x86_64
-	OS X: i386, x86_64

**Why ?**

[Apple says](https://developer.apple.com/library/mac/documentation/security/Conceptual/cryptoservices/GeneralPurposeCrypto/GeneralPurposeCrypto.html): "Although OpenSSL is commonly used in the open source community, OpenSSL does not provide a stable API from version to version. For this reason, although OS X provides OpenSSL libraries, the OpenSSL libraries in OS X are deprecated, and OpenSSL has never been provided as part of iOS."

**How to install ?**

```
pod 'OpenSSL-LET', '1.0.2d'
```

Or to get the latest version:

```
pod 'OpenSSL-LET', :git => 'https://github.com/letiemble/OpenSSL-LET.git', :branch => :master
```

**Authors**

[Laurent Etiemble](https://twitter.com/letiemble)
