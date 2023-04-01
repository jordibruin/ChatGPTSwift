//
//  File.swift
//  
//
//  Created by Alfian Losari on 02/03/23.
//

import Foundation
import Defaults

public struct Message: Convertable, Hashable, _DefaultsSerializable, Codable {
    public var role: Role
    public var content: String
    public private(set) var id: UUID

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
        self.id = UUID()
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(Role.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        id = UUID()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
    }
}


// Enums
public enum Model: String, Codable, _DefaultsSerializable {
    case turbo = "gpt-3.5-turbo"
    case turbo31 = "gpt-3.5-turbo-0301"
    case gpt4 = "gpt-4"
}

extension Array where Element == Message {
    
    var contentCount: Int { map { $0.content }.count }
    var content: String { reduce("") { $0 + $1.content } }
}

struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [Message]
    let stream: Bool
}

struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}

struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}

struct CompletionResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?
}

struct Usage: Decodable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
}

struct Choice: Decodable {
    let finishReason: String?
    let message: Message
}

struct StreamCompletionResponse: Decodable {
    let choices: [StreamChoice]
}

struct StreamChoice: Decodable {
    let finishReason: String?
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let content: String?
    let role: String?
}
