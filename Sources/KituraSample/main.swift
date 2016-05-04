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
import KituraSys
import KituraNet

import LoggerAPI
import HeliumLogger

import CFEnvironment

// All Web apps need a router to define routes
let router = Router()

// Using an implementation for a Logger
Log.logger = HeliumLogger()

// Serve static content from "public"
router.all("/static", middleware: StaticFileServer())

// Basic GET request
router.get("/hello") { _, response, next in
     response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
     do {
         try response.status(HttpStatusCode.OK).send("Hello from Kitura!").end()
     } catch {
         Log.error("Failed to send response \(error)")
     }
}

// Basic POST request
router.post("/hello") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        if let name = try request.readString() {
            try response.status(HttpStatusCode.OK).send("Hello \(name), from Kitura!").end()
        } else {
            try response.status(HttpStatusCode.OK).send("Hello POST to Kitura!").end()
        }
    } catch {
        Log.error("Failed to send response \(error)")
    }
}

// Basic PUT request
router.put("/hello") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        if let name = try request.readString() {
            try response.status(HttpStatusCode.OK).send("Hello \(name), from Kitura!").end()
        } else {
            try response.status(HttpStatusCode.OK).send("Hello PUT to Kitura!").end()
        }
    } catch {
        Log.error("Failed to send response \(error)")
    }
}

// Basic DELETE request
router.delete("/hello") {request, response, next in
    response.setHeader("Content-Type", value: "text/plain; charset=utf-8")
    do {
        try response.status(HttpStatusCode.OK).send("Got a DELETE request!").end()
    } catch {
        Log.error("Failed to send response \(error)")
    }
}

// Reading Parameters
router.get("/users/:user") { request, response, next in
    response.setHeader("Content-Type", value: "text/html; charset=utf-8")
    let user = request.params["user"] ?? "(nil)"
    do {
        try response.status(HttpStatusCode.OK).send(
            "<!DOCTYPE html><html><body>" +
            "<b>User:</b> \(user)" +
            "</body></html>\n\n").end()
    } catch {
        Log.error("Failed to send response \(error)")
    }
}

// Redirection
router.get("/redir") { _, response, next in
    do {
        try response.redirect("http://www.ibm.com")
    } catch {
         Log.error("Failed to redirect \(error)")
    }
    next()
}

// Error Handling
router.get("/error") { _, response, next in
    Log.error("Example of error being set")
    response.status(HttpStatusCode.INTERNAL_SERVER_ERROR)
    response.error = NSError(domain: "RouterTestDomain", code: 1, userInfo: [:])
    next()
}

// Start Server
do {
    
    let appEnv = try CFEnvironment.getAppEnv()
    let ip: String = appEnv.bind
    let port: Int = appEnv.port

    let server = HttpServer.listen(port: port, delegate: router)
    Server.run()

    Log.info("Server is started on \(appEnv.url).")

} catch CFEnvironmentError.InvalidValue {
    Log.error("Server did not start.")
}