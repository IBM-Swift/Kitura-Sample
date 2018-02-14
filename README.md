![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**Sample application for Kitura Web Framework**

## Summary


This [Kitura](https://github.com/IBM-Swift/Kitura/) sample shows off the powerful features available in Kitura 2, baking several demos into one project. See instructions for installing on [macOS ](https://github.com/IBM-Swift/Kitura#macos) or [Linux](https://github.com/IBM-Swift/Kitura#ubuntu-linux). You access the projects by navigating to their routes in a browser.


It features the following:

* Kitura WebSocket based Chat Server
* Stencil Template Engine example
* Using multiple handlers per route example
* Reading and accepting parameters in a route


## Getting Set Up
1. `git clone https://github.com/IBM-Swift/Kitura-Sample.git && cd Kitura-Sample`
> Note: do not use the GitHub "Download ZIP" button

2. `swift build`

3. `./.build/debug/Kitura-Sample`

  You should see message _Listening on port 8080_. You may need to "Allow" if a security pop up appears, dependent on your firewall settings.

4. Open your browser at [http://localhost:8080](http://localhost:8080)

5. Navigate to an examples route on the localhost URL, for example for the chat server go to [localhost:8080/chat](localhost:8080/chat)

## Available Examples
### Kitura WebSocket
> Route: [localhost:8080/chat](localhost:8080/chat)

This demo sets up a local chat server using [Kitura's WebSocket](https://github.com/IBM-Swift/Kitura-WebSocket/) library, and the UI mimicks a chat room. Two separate browser windows pointed to the `/chat` route can be used to represent two people in the chat roomif the project is running on localhost. It can also be deployed to the [IBM Cloud](https://bluemix.net) and then accessed via a Cloud Foundry App.

### Stencil Templating Engine
> Route: [localhost:8080/articles](localhost:8080/articles)

Kitura supports the popular Stencil Templating Engine, using the [Kitura Stencil](https://github.com/IBM-Swift/Kitura-StencilTemplateEngine/) library. This route looks for a Stencil file in a subdirectory called `Views` and renders the page with it.

### Multiple Handlers in one Route
> Route: [localhost:8080/multi](localhost:8080/multi)

Support for multiple handlers per route is supported in [Kitura](https://github.com/IBM-Swift/Kitura), and this example simply prints several lines to the window using different `response.send()` methods.

### Reading and Accepting Parameters
> Route: [localhost:8080/users/:user](localhost:8080/users/:user)

**Note:** This example uses `:users` but you can use anything you like, as long as the first part of the route is `/users/`.

This route accepts a parameter in its URL and uses that parameter in it's HTML creation. It does this using a colon (:) in the URL which defines the item following it as a parameter. It then assigns this to a variable, and concatenates it into the HTML.


## Testing
To run local tests, run `swift test` from the projects directory locally.

## Running in Xcode

You can also run this sample application inside Xcode. For more details, visit the [Kitura wiki](https://github.com/IBM-Swift/Kitura/wiki/Building-your-Kitura-application-in-Xcode).

---

## License

This sample app is licensed under the [Apache License, Version 2.0](LICENSE.txt).
