//
//  NetworkWorker.swift
//  Schedule
//
//  Created by Egor Molchanov on 16.11.2022.
//  Copyright © 2022 Prismade. All rights reserved.
//

import Foundation
import CommonCrypto

class NetworkWorker {
  let session: URLSession
  let cookieStorage: HTTPCookieStorage
  
  init(session: URLSession = .shared, cookieStorage: HTTPCookieStorage = .shared) {
    self.session = session
    self.cookieStorage = cookieStorage
  }
  
  func data<T: Decodable>(from endpoint: Endpoint) async throws -> T {
    let data = try await data(from: endpoint)
    return try JSONDecoder().decode(T.self, from: data)
  }
  
  func data(from endpoint: Endpoint) async throws -> Data {
    debugPrint(endpoint)
    guard let url = endpoint.fullUrl else { throw NSError(domain: "net.prismade.Schedule", code: 400) }
    return try await data(from: url)
  }
  
  private func data(from url: URL) async throws -> Data {
    let (data, _) = try await makeRequestAndBreakDDOSProtectionIfNeeded(for: url)
    String(data: data, encoding: .utf8).map { print("[Response]:\n\t\($0)\n") }
    return data
  }
  
  private func makeRequestAndBreakDDOSProtectionIfNeeded(for url: URL) async throws -> (Data, URLResponse) {
    let (data, response) = try await session.data(from: url)
    
    guard
      let html = String(data: data, encoding: .utf8),
      html.contains("toNumbers("),
      let cookie = DDOSProtectionBreaker().createCookie(for: html)
    else {
      return (data, response)
    }
    
    cookieStorage.setCookie(cookie)
    return try await session.data(from: url)
  }
}

fileprivate struct DDOSProtectionBreaker {
  func createCookie(for html: String) -> HTTPCookie? {
    guard
      let parameters = extractAESParameters(from: html),
      let cipher = Data(hexString: parameters[2]),
      let key = Data(hexString: parameters[0]),
      let iv = Data(hexString: parameters[1]),
      let cookieData = decrypt(cipher: cipher, key: key, iv: iv)
    else {
      return nil
    }
    return createCookie(with: cookieData.hexString)
  }
  
  private func extractAESParameters(from html: String) -> [String]? {
    do {
      let regex = try NSRegularExpression(pattern: "toNumbers\\(\\\"(.*?)\\\"\\)")
      let results = regex.matches(in: html, range: .init(html.startIndex..., in: html))
      return results.map {
        let match = String(html[Range($0.range, in: html)!])
        return match
          .replacingOccurrences(of: "toNumbers(\"", with: "")
          .replacingOccurrences(of: "\")", with: "")
      }
    } catch {
      return nil
    }
  }
  
  private func decrypt(cipher: Data, key: Data, iv: Data) -> Data? {
    guard let result = NSMutableData(length: cipher.count + kCCBlockSizeAES128) else { return nil }
    let resultPointer = result.mutableBytes
    var numberOfBytesEncrypted: size_t = 0
    
    let status = CCCrypt(
      CCOperation(kCCDecrypt),
      CCAlgorithm(kCCAlgorithmAES128),
      CCOptions(0),
      (key as NSData).bytes, key.count,
      (iv as NSData).bytes,
      (cipher as NSData).bytes, cipher.count,
      resultPointer, result.count,
      &numberOfBytesEncrypted)
    
    if status == kCCSuccess {
      result.length = numberOfBytesEncrypted
      return result as Data
    } else {
      return nil
    }
  }
  
  private func createCookie(with cookieValue: String) -> HTTPCookie? {
    let properties = [
      HTTPCookiePropertyKey.name : "asmr",
      HTTPCookiePropertyKey.value : cookieValue,
      HTTPCookiePropertyKey.domain : "oreluniver.ru",
      HTTPCookiePropertyKey.path : "/",
      HTTPCookiePropertyKey.expires : "Thu, 31-Dec-37 23:55:55 GMT"
    ]
    return HTTPCookie(properties: properties)
  }
}

fileprivate extension Data {
  init?(hexString: String) {
    let numberOfBytes = hexString.count / 2
    var data = Data(capacity: numberOfBytes)
    var i = hexString.startIndex
    for _ in 0..<numberOfBytes {
      let j = hexString.index(i, offsetBy: 2)
      let bytes = hexString[i..<j]
      if var num = UInt8(bytes, radix: 16) {
        data.append(&num, count: 1)
      } else {
        return nil
      }
      i = j
    }
    self = data
  }
  
  var hexString: String {
    self.map { String(format: "%02hhx", $0) }.joined()
  }
}
