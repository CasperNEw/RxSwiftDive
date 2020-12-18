//
//  SupportCode.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 09.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - typealias
typealias Example = (title: String, action: () -> Void)

enum MyError: Error {
    case anError
}

enum FileReadError: Error {
    case fileNotFound, unreadable, encodingFailed
}

enum HandError: Error {
    case busted(points: Int)
}

enum UserSession {
    case loggedIn, loggedOut
}

enum LoginError: Error {
    case invalidCredentials
}

public let cards = [
    ("🂡", 11), ("🂢", 2), ("🂣", 3), ("🂤", 4),
    ("🂥", 5), ("🂦", 6), ("🂧", 7), ("🂨", 8),
    ("🂩", 9), ("🂪", 10), ("🂫", 10), ("🂭", 10),
    ("🂮", 10), ("🂱", 11), ("🂲", 2), ("🂳", 3),
    ("🂴", 4), ("🂵", 5), ("🂶", 6), ("🂷", 7),
    ("🂸", 8), ("🂹", 9), ("🂺", 10), ("🂻", 10),
    ("🂽", 10), ("🂾", 10), ("🃁", 11), ("🃂", 2),
    ("🃃", 3), ("🃄", 4), ("🃅", 5), ("🃆", 6),
    ("🃇", 7), ("🃈", 8), ("🃉", 9), ("🃊", 10),
    ("🃋", 10), ("🃍", 10), ("🃎", 10), ("🃑", 11),
    ("🃒", 2), ("🃓", 3), ("🃔", 4), ("🃕", 5),
    ("🃖", 6), ("🃗", 7), ("🃘", 8), ("🃙", 9),
    ("🃚", 10), ("🃛", 10), ("🃝", 10), ("🃞", 10)
]

public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

public func customPrint<T: CustomStringConvertible>(label: String,
                                                    event: RxSwift.Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

public func cardString(for hand: [(String, Int)]) -> String {
    return hand.map { $0.0 }.joined(separator: "")
}

public func points(for hand: [(String, Int)]) -> Int {
    return hand.map { $0.1 }.reduce(0, +)
}

// MARK: - GitFeed Module
struct Event: Codable {
  let action: String
  let repo: Repo
  let actor: Actor

  enum CodingKeys: String, CodingKey {
    case action = "type"
    case repo
    case actor
  }
}

struct Repo: Codable {
  let name: String
}

struct Actor: Codable {
  let name: String
  let avatar: URL

  enum CodingKeys: String, CodingKey {
    case name = "display_login"
    case avatar = "avatar_url"
  }
}

// MARK: - Extension
extension Event {

    var detail: String {
        repo.name + ", " + action
            .replacingOccurrences(of: "Event", with: "")
            .lowercased()
    }
}
