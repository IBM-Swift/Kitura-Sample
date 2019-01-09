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

## Kitura Sample

Sample application for the Kitura Web Framework

## Summary

This [Kitura](https://github.com/IBM-Swift/Kitura/) sample shows off the powerful features available in Kitura 2, baking several demos into one project. You can access the individual examples by navigating to their specific page in a browser.


It features the following:

* Raw and Codable routing examples
* Database persistence using [Swift-Kuery-ORM](https://github.com/IBM-Swift/Swift-Kuery-ORM)
* Sessions persistence using [Kitura-Session](https://github.com/IBM-Swift/Kitura-Session)
* Rendering templates with [Markdown](https://github.com/IBM-Swift/Kitura-Markdown) and [Stencil](https://github.com/IBM-Swift/Kitura-StencilTemplateEngine)
* HTTP Basic and Oauth2 authentication with [Kitura-Credentials](https://github.com/IBM-Swift/Kitura-Credentials)
* A [Kitura WebSocket](https://github.com/IBM-Swift/Kitura-WebSocket) based chat server

## Getting Set Up

1. `git clone https://github.com/IBM-Swift/Kitura-Sample.git`

2.  `cd Kitura-Sample`

3. `swift run`

  You should see a message _Listening on port 8080_. You may need to click "Allow" if a security pop up appears, dependent on your firewall settings.

4. Open your browser at [http://localhost:8080](http://localhost:8080).

## Available Examples

### Hello World: Kitura Raw routing

This page demonstrates routing in Kitura using the Raw HTTP request and response.  
When you make a get request to [localhost:8080/hello](http://localhost:8080/hello) the server will send back with the traditional Hello World response.  
You can then send HTTP POST or DELETE requests to change the name that the server will respond with.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/HelloWorldRoutes.swift)

### Kitura Codable routing

This page demonstrates [Codable routing](https://developer.ibm.com/swift/2017/10/30/codable-routing/) in Kitura where you work directly with Codable models.  
You make HTTP requests to [localhost:8080/books](http://localhost:8080/book) to GET, POST or DELETE a swift model of a book.  
You can then search all your books using query parameters.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/CodableRoutes.swift)

### Database persistence using Swift-Kuery-ORM

This page demonstrates a server which will save and retrieve a students `Grades` using the [Swift-Kuery-ORM](https://github.com/IBM-Swift/Swift-Kuery-ORM) API. 
The example initially uses a dummy database but you can connect it to a live PostgreSQL database by by following the steps below:

1. In terminal, set up a PostgreSQL database:
```
brew install postgresql
brew services start postgresql
createdb school
```

2. Add `SwiftKueryPostgreSQL` to your dependancies in `Package.swift`
3. Switch the connection to `PostgreSQLConnection` in `DatabaseRoutes.swift`

This adds persistance to the data, meaning even if the server is restarted the grades will be stored.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/DatabaseRoutes.swift)

### Sessions persistence using Kitura-Session

This page demonstrates a server which will save an array of `Books` in a session. This array is unique to a single user who is authenticated via http cookies. You can test the session by saving books a private and a normal browser window and observing that both windows maintain their own array. The page includes example for both Raw and Codable Session routes.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/SessionsRoutes.swift)

### Stencil Templating Engine

The route looks for a Stencil template file in a subdirectory called `Views` and renders an HTML page using it. This allows for you to create dynamic web pages by inserting data from your server into your HTML.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/StencilRoutes.swift)

### Rendering Markdown files

The route looks for a Markdown file in a subdirectory called `Views` and generates an HTML page using it. This allows for you to server Markdown formatted files as web pages.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/MarkdownRoutes.swift)

### Kitura WebSocket

This demo sets up a local chat server using [Kitura's WebSocket](https://github.com/IBM-Swift/Kitura-WebSocket/) library, and the UI mimicks a chat room. Two separate browser windows pointed to the `/chat` route can be used to represent two people in the chat room if the project is running on localhost.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/ChatService/ChatService.swift)

### HTTP Basic Authentication

This page demonstrates how to protect Raw and Codable routes using [HTTP Basic Authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme). You can sign up to the server by providing a username and password and then to access your desired route you must provide that username and password or your request will be rejected as unauthorized.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/BasicAuthRoutes.swift)

### OAuth2 token authentication

This page demonstrates how to protect Raw and Codable routes using OAuth2 tokens. You generate a user access token for either facebook or google (Which would normally be performed by another application) and send an HTTP request to the server with that token. The server authenticates the token with the provider to identify the user and allow access to the protected route. If the token is incorrect the request is rejected as unauthorized.

[Link to Code](https://github.com/IBM-Swift/Kitura-Sample/blob/master/Sources/Application/Routes/TokenAuthRoutes.swift)

### OAuth2 token authentication

This page demonstrates how to authenticate a user with OAuth2 by redirecting to a trusted third party. You create an OAuth2 authentication application with either AppID, Facebook or Google and add its credentials to Kitura Sample. You can then log in with any of the providers to access the protected route. If the user is not logged in the request is rejected as unauthorized.

## Swagger/OpenAPI

The sample is using [Kitura-OpenAPI](https://github.com/IBM-Swift/Kitura-OpenAPI) to automatically generate [OpenAPI](https://www.openapis.org/) (aka Swagger) Specification for it's Codable routes.

1. Start the Kitura-Sample server
2. Go to [http://localhost:8080/openapi](http://localhost:8080/openapi) to view OpenAPI definition
3. Go to [http://localhost:8080/openapi/ui](http://localhost:8080/openapi/ui) to view OpenAPI User Interface

## Testing
To run the tests locally, run `swift test` from the Kitura-Sample directory.

## Running in Xcode

You can also run this sample application inside Xcode. For more details, visit [kitura.io](https://www.kitura.io/guides/building/xcodebuild.html).

## Running with Docker
A description of the files related to Docker can be found in the [Docker files](#docker-files) setion. To build the two docker images, run the following commands from the root directory of the project:
* `docker build -t myapp-run .`
* `docker build -t myapp-build -f Dockerfile-tools .`
You may customize the names of these images by specifying a different value after the `-t` option.

To compile the application using the tools docker image, run:
* `docker run -v $PWD:/swift-project -w /swift-project myapp-build /swift-utils/tools-utils.sh build release`

To run the application:
* `docker run -it -p 8080:8080 -v $PWD:/swift-project -w /swift-project myapp-run sh -c .build-ubuntu/release/Kitura-Sample`

## Deploy to Cloud Foundry

1. Log in to IBM Cloud

```
bluemix api https://api.ng.bluemix.net
bluemix login
bluemix target -o <YOUR_ORG> -s <YOUR_DEV_SPACE>
```

where YOUR_ORG is the organisation you used when signing up to IBM Cloud and YOUR_DEV_SPACE is the space you created.

2. Deploy your application to IBM Cloud

```
bx app push
```

---

## License

This sample app is licensed under the [Apache License, Version 2.0](LICENSE.txt).
