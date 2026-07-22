// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Network

struct SystemInfo: Sendable {
  let appVersion: String
  let iosVersion: String
  let deviceModel: String
  let network: String
}

final class SystemInfoProvider: @unchecked Sendable {
  static let shared = SystemInfoProvider()

  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "se.digg.wallet.systemInfo.network")
  private let lock = NSLock()
  private var currentNetwork = "Okänt"

  private init() {
    monitor.pathUpdateHandler = { [weak self] path in
      self?.setNetwork(networkLabel(for: path))
    }
    monitor.start(queue: queue)
  }

  func snapshot() -> SystemInfo {
    SystemInfo(
      appVersion: Bundle.main.fullVersion,
      iosVersion: Self.osVersion,
      deviceModel: Self.deviceIdentifier,
      network: network,
    )
  }

  private var network: String {
    lock.lock()
    defer { lock.unlock() }
    return currentNetwork
  }

  private func setNetwork(_ label: String) {
    lock.lock()
    currentNetwork = label
    lock.unlock()
  }
}

private extension SystemInfoProvider {
  static var osVersion: String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }

  static var deviceIdentifier: String {
    var info = utsname()
    uname(&info)
    let size = MemoryLayout.size(ofValue: info.machine)
    let identifier = withUnsafePointer(to: &info.machine) { pointer in
      pointer.withMemoryRebound(to: CChar.self, capacity: size) { bytes in
        String(cString: bytes)
      }
    }
    return identifier.isEmpty ? "Okänt" : identifier
  }
}

private func networkLabel(for path: NWPath) -> String {
  guard path.status == .satisfied else {
    return "Ingen anslutning"
  }
  if path.usesInterfaceType(.wifi) {
    return "Wi-Fi"
  }
  if path.usesInterfaceType(.cellular) {
    return "Mobilnät"
  }
  if path.usesInterfaceType(.wiredEthernet) {
    return "Ethernet"
  }
  return "Okänt"
}
