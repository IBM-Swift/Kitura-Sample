/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// KituraSample shows examples for creating custom routes.

import Foundation

import Kitura
import KituraMarkdown
import KituraStencil // required for using StencilTemplateEngine
import Stencil // required for adding a Stencil namespace to StencilTemplateEngine
import KituraWebSocket

import LoggerAPI
import HeliumLogger

#if os(Linux)
    import Glibc
#endif
// Error handling example

enum SampleError: Error {
    case sampleError
}

let customParameterHandler: RouterHandler = { request, response, next in
    let id = request.parameters["id"] ?? "unknown"
    response.send("\(id)|").status(.OK)
    next()
}

class CustomParameterMiddleware: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
        do {
            try customParameterHandler(request, response, next)
        } catch {
            Log.error("customParameterHandler returned error: \(error)")
        }

    }
}

extension SampleError: CustomStringConvertible {
    var description: String {
        switch self {
        case .sampleError:
            return "Example of error being set"
        }
    }
}

public struct RouterCreator {
    public static func create() -> Router {
        let router = Router()

        /**
         * RouterMiddleware can be used for intercepting requests and handling custom behavior
         * such as authentication and other routing
         */
        class BasicAuthMiddleware: RouterMiddleware {
            func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
                let authString = request.headers["Authorization"]
                Log.info("Authorization: \(String(describing: authString))")
                // Check authorization string in database to approve the request if fail
                // response.error = NSError(domain: "AuthFailure", code: 1, userInfo: [:])
                next()
            }
        }

        // Variable to post/put data to (just for sample purposes)
        var name: String?

        // This route executes the echo middleware
        router.all(middleware: BasicAuthMiddleware())

        router.all("/static", middleware: StaticFileServer())
        router.all("/chat", middleware: StaticFileServer(path: "./chat"))
        
        router.all("/", middleware: StaticFileServer(path: "./Views"))
        router.get("/") { request, response, next in
            response.headers["Content-Type"] = "text/html; charset=utf-8"
            do {
                try response.render("home.stencil", context: [String: Any]()).end()
            } catch {
                Log.error("Failed to render template \(error)")
            }
            
        }

        router.get("/hello") { _, response, next in
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            let fName = name ?? "World"
            try response.send("Hello \(fName), from Kitura!").end()
        }

        // This route accepts POST requests
        router.post("/hello") {request, response, next in
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            name = try request.readString()
            try response.send("Got a POST request").end()
        }

        // This route accepts PUT requests
        router.put("/hello") {request, response, next in
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            name = try request.readString()
            try response.send("Got a PUT request").end()
        }

        // This route accepts DELETE requests
        router.delete("/hello") {request, response, next in
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            name = nil
            try response.send("Got a DELETE request").end()
        }

        router.get("/error") { _, response, next in
            Log.error("Example of error being set")
            response.status(.internalServerError)
            response.error = SampleError.sampleError
            // Set status code to 200, because status code 500 doesn't display the message in a web
            // broswer window.
            response.statusCode = .OK
            next()
        }

        // Redirection example
        router.get("/redir") { _, response, next in
            try response.redirect("http://www.ibm.com/us-en/")
            next()
        }

        // Reading parameters
        // Accepts user as a parameter
        router.get("/users/:user") { request, response, next in
            response.headers["Content-Type"] = "text/html"
            let p1 = request.parameters["user"] ?? "(nil)"
            try response.send(
                "<!DOCTYPE html><html><body>" +
                    "<b>User:</b> \(p1)" +
                "</body></html>\n\n").end()
        }

        // Uses multiple handler blocks
        router.get("/multi", handler: { request, response, next in
            response.send("I'm here!\n")
            next()
            }, { request, response, next in
                response.send("Me too!\n")
                next()
        })
        router.get("/multi") { request, response, next in
            try response.send("I come afterward..\n").end()
        }

        router.get("/user/:id", allowPartialMatch: false, middleware: CustomParameterMiddleware())
        router.get("/user/:id", handler: customParameterHandler)

        // add Stencil Template Engine with a extension with a custom tag
        let _extension = Extension()
        // from https://github.com/kylef/Stencil/blob/master/ARCHITECTURE.md#simple-tags
        _extension.registerSimpleTag("custom") { _ in
            return "Hello World"
        }

        let templateEngine = StencilTemplateEngine(extension: _extension)
        //router.setDefault(templateEngine: templateEngine)
        router.add(templateEngine: templateEngine,
                   forFileExtensions: ["html"])

        // the example from https://github.com/kylef/Stencil
        let stencilContext: [String: Any] = [
            "articles": [
                [ "title": "Migrating from OCUnit to XCTest", "author": "Kyle Fuller" ],
                [ "title": "Memory Management with ARC", "author": "Kyle Fuller" ],
            ]
        ]

        router.get("/articles") { _, response, next in
            defer {
                next()
            }
            do {
                try response.render("document.stencil", context: stencilContext).end()
            } catch {
                Log.error("Failed to render template \(error)")
            }
        }

        router.get("/articles.html") { _, response, next in
            defer {
                next()
            }
            do {
                // we have to specify file extension here since it is not the extension of Stencil
                try response.render("document.html", context: stencilContext).end()
            } catch {
                Log.error("Failed to render template \(error)")
            }
        }

        router.get("/articles_subdirectory") { _, response, next in
            defer {
                next()
            }
            do {
                try response.render("subdirectory/documentInSubdirectory",
                                    context: stencilContext).end()
            } catch {
                Log.error("Failed to render template \(error)")
            }
        }

        router.get("/articles_include") { _, response, next in
            defer {
                next()
            }
            do {
                try response.render("includingDocument",
                                    context: stencilContext).end()
            } catch {
                Log.error("Failed to render template \(error)")
            }
        }

        router.get("/custom_tag_stencil") { _, response, next in
            defer {
                next()
            }
            do {
                try response.render("customTag", context: [:]).end()
            } catch {
                Log.error("Failed to render template \(error)")
            }
        }

        // Add KituraMarkdown as a TemplateEngine
        router.add(templateEngine: KituraMarkdown())

        router.setDefault(templateEngine: KituraMarkdown())
        
        router.get("/docs") { _, response, next in
            response.headers["Content-Type"] = "text/html"
            try response.render("/docs/index.md", context: [String:Any]())
            response.status(.OK)
            next()
        }

        router.get("/docs/*") { request, response, next in
            response.headers["Content-Type"] = "text/html"
            if request.urlURL.path != "/docs/" {
                try response.render(request.urlURL.path, context: [String:Any]())
                response.status(.OK)
            }
            next()
        }

        // Handles any errors that get set
        router.error { request, response, next in
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            let errorDescription: String
            if let error = response.error {
                errorDescription = "\(error)"
            } else {
                errorDescription = "Unknown error"
            }
            try response.send("Caught the error: \(errorDescription)").end()
        }


        // A custom Not found handler
        router.all { request, response, next in
            if  response.statusCode == .unknown  {
                // Remove this wrapping if statement, if you want to handle requests to / as well
                let path = request.urlURL.path
                if  path != "/" && path != ""  {
                    try response.status(.notFound).send("404: Route not found in Sample application!").end()
                }
            }
            next()
        }

        return router
    }
}
