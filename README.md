![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

![Mac OS X](https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**Sample application for Kitura Web Framework**

## Summary

This is a sample [Kitura](https://github.com/IBM-Swift/Kitura) application. See instructions for [Installation on OS X ](https://github.com/IBM-Swift/Kitura#installation-os-x) or [Installation on Linux](https://github.com/IBM-Swift/Kitura#installation-linux-apt-based).

## Build and run
1. Build:

  Mac OS X: `swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib`
  
  Linux: `swift build -Xcc -fblocks`

2. Then run:
  `.build/debug/KituraSample`

  Or
  
   `make run`

  You should see message _Listening on port 8090_. The result executable is located in `.build/debug` directory: `./.build/debug/KituraSample`
  
3. Open your browser at [http://localhost:8090](http://localhost:8090)

## Kitura Wiki
Feel free to visit our [Wiki](https://github.com/IBM-Swift/Kitura/wiki) for our roadmap and some tutorials.

## License

This sample app is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
