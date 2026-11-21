import ConcurrencyExtras
import Foundation

final class URLProtocolStub: URLProtocol {
    enum Stub {
        case response(status: Int, data: Data)
        case failure(URLError)
    }

    private static let state = LockIsolated<(stub: Stub?, requests: [URLRequest])>((nil, []))

    static var requests: [URLRequest] {
        state.value.requests
    }

    static func reset(stub: Stub) {
        state.setValue((stub, []))
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override static func canInit(with _: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let currentRequest = request
        let stub = Self.state.withValue { state -> Stub? in
            state.requests.append(currentRequest)
            return state.stub
        }
        switch stub {
        case let .response(status, data):
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)
            else { return }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        case nil:
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
        }
    }

    override func stopLoading() {}
}
