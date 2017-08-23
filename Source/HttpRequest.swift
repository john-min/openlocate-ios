//
//  HttpRequest.swift
//
//  Copyright (c) 2017 OpenLocate
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

// Enum for HTTP method type
enum MethodType: String {
    case post = "POST"
}

extension URLRequest {
    init?(_ request: HttpRequest) {
        guard let url = URL(string: request.url) else {
            return nil
        }

        self.init(url: url)
        httpMethod = request.method.rawValue

        // create the body if there are params for the request
        if let params = request.params {
            let body = try? JSONSerialization.data(withJSONObject: params,
                                                   options: .init(rawValue: 0))
            httpBody = body
        }

        // add additional headers to the request
        if let headers = request.additionalHeaders,
            !headers.isEmpty,
            var existing = allHTTPHeaderFields {
            existing += headers
            allHTTPHeaderFields = existing
        }
    }
}

struct HttpRequest {
    let url: String
    let method: MethodType
    let params: Parameters?
    let additionalHeaders: Headers?
    let successCompletion: HttpClientCompletionHandler?
    let failureCompletion: HttpClientCompletionHandler?

    private init(
        url: String,
        method: MethodType,
        params: Parameters?,
        additionalHeaders: Headers?,
        success: HttpClientCompletionHandler?,
        failure: HttpClientCompletionHandler?
        ) {
        self.url = url
        self.method = method
        self.params = params
        self.additionalHeaders = additionalHeaders
        self.successCompletion = success
        self.failureCompletion = failure
    }
}

extension HttpRequest {

    final class Builder {
        private var url = ""
        private var method = MethodType.post
        private var params: Parameters?
        private var additionalHeaders: Headers?
        private var success: HttpClientCompletionHandler?
        private var failure: HttpClientCompletionHandler?

        func set(url: String) -> Builder {
            self.url = url
            return self
        }

        func set(method: MethodType) -> Builder {
            self.method = method
            return self
        }

        func set(params: Parameters?) -> Builder {
            self.params = params
            return self
        }

        func set(additionalHeaders: Headers?) -> Builder {
            self.additionalHeaders = additionalHeaders
            return self
        }

        func set(success: @escaping HttpClientCompletionHandler) -> Builder {
            self.success = success
            return self
        }

        func set(failure: @escaping HttpClientCompletionHandler) -> Builder {
            self.failure = failure
            return self
        }

        func build() -> HttpRequest {
            return HttpRequest(
                url: url,
                method: method,
                params: params,
                additionalHeaders: additionalHeaders,
                success: success,
                failure: failure
            )
        }
    }
}