// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import HTTPTypes
import OpenAPIRuntime

struct DeviceInfoMiddleware: ClientMiddleware {
  let deviceInfo: DeviceInfo

  func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var request = request
    request.setHeader("Wallet-Device-OS", deviceInfo.os)
    request.setHeader("Wallet-Device-OS-Version", deviceInfo.osVersion)
    request.setHeader("Wallet-Device-Model", deviceInfo.model)
    request.setHeader("Wallet-App-Version", deviceInfo.appVersion)
    return try await next(request, body, baseURL)
  }
}
