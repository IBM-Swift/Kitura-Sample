/**
 * Copyright IBM Corporation 2018
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

import KituraMarkdown

func initializeMarkdownRoutes(app: App) {
    // Add KituraMarkdown as a TemplateEngine
    app.router.add(templateEngine: KituraMarkdown())

    app.router.setDefault(templateEngine: KituraMarkdown())
    

    app.router.get("/docs") { _, response, next in
        response.headers["Content-Type"] = "text/html"
        try response.render("/docs/index.md", context: [String:Any]())
        try response.status(.OK).end()

    }

    app.router.get("/docs/*") { request, response, next in
        response.headers["Content-Type"] = "text/html"
        if request.urlURL.path == "/docs" {
            try response.render("/docs/index.md", context: [String:Any]())
            response.status(.OK)
        }else {
            try response.render(request.urlURL.path, context: [String:Any]())
            response.status(.OK)
        }
        try response.end()
    }
}
