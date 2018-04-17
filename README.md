<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>

<p align="center">
    <a href="http://www.kitura.io/">
    <img src="https://img.shields.io/badge/docs-kitura.io-1FBCE4.svg" alt="Docs">
    </a>
    <a href="https://travis-ci.org/IBM-Swift/Kitura-Sample">
    <img src="https://travis-ci.org/IBM-Swift/Kitura-Sample.svg?branch=master" alt="Build Status - Master">
    </a>
    <img src="https://img.shields.io/badge/os-macOS-green.svg?style=flat" alt="macOS">
    <img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
    <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
    <a href="http://swift-at-ibm-slack.mybluemix.net/">
    <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg" alt="Slack Status">
    </a>
</p>

**Sample application for Kitura Web Framework**

## Summary


This [Kitura](https://github.com/IBM-Swift/Kitura/) sample shows off the powerful features available in Kitura 2, baking several demos into one project. You can access the individual examples by navigating to their specific routes in a browser.


It features the following:

* Kitura WebSocket based chat server
* Stencil template engine example
* Using multiple handlers per route
* Reading and accepting parameters in a route


## Getting Set Up

1. Install the [prerequisites]( http://www.kitura.io/en/starter/settingup.html) (ignore the requirement to install Homebrew on macOS as it is not required for this sample).

2. `git clone https://github.com/IBM-Swift/Kitura-Sample.git && cd Kitura-Sample`
> Note: do not use the GitHub "Download ZIP" button

3. `swift build`

4. `./.build/debug/Kitura-Sample`

  You should see a message _Listening on port 8080_. You may need to click "Allow" if a security pop up appears, dependent on your firewall settings.

5. Open your browser at [http://localhost:8080](http://localhost:8080).

6. Navigate to one of the example routes on the localhost URL, for example, for the chat server go to [localhost:8080/chat](localhost:8080/chat).

## Available Examples
### Kitura WebSocket
> Route: [localhost:8080/chat](localhost:8080/chat)

This demo sets up a local chat server using [Kitura's WebSocket](https://github.com/IBM-Swift/Kitura-WebSocket/) library, and the UI mimicks a chat room. Two separate browser windows pointed to the `/chat` route can be used to represent two people in the chat room if the project is running on localhost. It can also be deployed to the [IBM Cloud](https://bluemix.net) and then accessed via a Cloud Foundry App.

### Stencil Templating Engine
> Route: [localhost:8080/articles](localhost:8080/articles)

Kitura supports the popular Stencil Templating Engine, using the [Kitura Stencil](https://github.com/IBM-Swift/Kitura-StencilTemplateEngine/) library. This route looks for a Stencil file in a subdirectory called `Views` and renders the page with it.

### Multiple Handlers in one Route
> Route: [localhost:8080/multi](localhost:8080/multi)

[Kitura](https://github.com/IBM-Swift/Kitura) supports multiple handlers per route, this example prints several lines to the window using different `response.send()` methods.

### Reading and Accepting Parameters
> Route: [localhost:8080/users/:user](localhost:8080/users/:user)

**Note:** This example uses `:users` but you can use anything you like, as long as the first part of the route is `/users/`.

This route accepts a parameter in its URL and uses that parameter in its HTML creation. It does this using a colon (:) in the URL which defines the item following it as a parameter. It then assigns this parameter to a variable, and concatenates it into the HTML.


## Testing
To run the tests locally, run `swift test` from the Kitura-Sample directory.

## Running in Xcode

You can also run this sample application inside Xcode. For more details, visit [kitura.io](http://www.kitura.io/en/starter/xcode.html).

---

## License

This sample app is licensed under the [Apache License, Version 2.0](LICENSE.txt).
