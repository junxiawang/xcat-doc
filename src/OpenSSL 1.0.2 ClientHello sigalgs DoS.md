OpenSSL 1.0.2 introduced the "multiblock" performance improvement. This feature only applies on 64 bit x86 architecture platforms that support AES NI instructions. A defect in the implementation of "multiblock" can cause a segmentation fault within OpenSSL, thus enabling a potential DoS attack. This issue affects OpenSSL version: 1.0.2
xCAT does not ship OpenSSL. Please upgrade OpenSSL to 1.0.2a or upper, you can get the package from the OS distribution.

