Pod::Spec.new do |s|
  s.name         = "OpenSSL-LET"
  s.version      = "1.0.2j"
  s.summary      = "Universal OpenSSL for iOS and OS X"
  s.description  = "OpenSSL is an SSL/TLS and Crypto toolkit. This pod provides fat static libraries iOS (armv7,armv7s,arm64,i386,x86_64) and for OSX (i386,x86_64)."
  s.homepage     = "http://github.io/letiemble/OpenSSL-LET"
  s.license	     = { :type => 'OpenSSL (OpenSSL/SSLeay)', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/letiemble/OpenSSL-LET.git", :tag => "#{s.version}" }

  s.authors       =  {'Mark J. Cox' => 'mark@openssl.org',
                     'Ralf S. Engelschall' => 'rse@openssl.org',
                     'Dr. Stephen Henson' => 'steve@openssl.org',
                     'Ben Laurie' => 'ben@openssl.org',
                     'Lutz Jänicke' => 'jaenicke@openssl.org',
                     'Nils Larsch' => 'nils@openssl.org',
                     'Richard Levitte' => 'nils@openssl.org',
                     'Bodo Möller' => 'bodo@openssl.org',
                     'Ulf Möller' => 'ulf@openssl.org',
                     'Andy Polyakov' => 'appro@openssl.org',
                     'Geoff Thorpe' => 'geoff@openssl.org',
                     'Holger Reif' => 'holger@openssl.org',
                     'Paul C. Sutton' => 'geoff@openssl.org',
                     'Eric A. Young' => 'eay@cryptsoft.com',
                     'Tim Hudson' => 'tjh@cryptsoft.com',
                     'Justin Plouffe' => 'plouffe.justin@gmail.com'}

  s.ios.deployment_target = '6.0'
  s.ios.source_files        = 'include/ios/openssl/**/*.h'
  s.ios.public_header_files = 'include/ios/openssl/**/*.h'
  s.ios.header_dir          = 'openssl'
  s.ios.preserve_paths      = 'lib/ios/libcrypto.a', 'lib/ios/libssl.a'
  s.ios.vendored_libraries  = 'lib/ios/libcrypto.a', 'lib/ios/libssl.a'

  s.osx.deployment_target = '10.6'
  s.osx.source_files        = 'include/osx/openssl/**/*.h'
  s.osx.public_header_files = 'include/osx/openssl/**/*.h'
  s.osx.header_dir          = 'openssl'
  s.osx.preserve_paths      = 'lib/osx/libcrypto.a', 'lib/osx/libssl.a'
  s.osx.vendored_libraries  = 'lib/osx/libcrypto.a', 'lib/osx/libssl.a'

  s.libraries = 'ssl', 'crypto'
end
