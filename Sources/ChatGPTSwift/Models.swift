//
//  File.swift
//  
//
//  Created by Alfian Losari on 02/03/23.
//

import Foundation
import Defaults

struct Message: Convertable, Hashable, _DefaultsSerializable, Codable {
    var role: Role
    var content: String
    private(set) var id: UUID

    init(role: Role, content: String) {
        self.role = role
        self.content = content
        self.id = UUID()
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(Role.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        id = UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
    }
}


// Enums
enum Model: String, Codable, _DefaultsSerializable {
    case turbo = "gpt-3.5-turbo"
    case turbo31 = "gpt-3.5-turbo-0301"
    case gpt4 = "gpt-4"
}

import Foundation

enum Role: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
    
    var exportName: String {
        switch self {
        case .system:
            return "⚙️"
        case .user:
            return "👱"
        case .assistant:
            return "🤖"
        }
    }
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

protocol Convertable: Codable {}
extension Convertable {
    func convertToDict() -> [String: Any] {
        var dict: [String: Any]
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
        } catch {
            print(error)
            dict = [:]
        }
        
        return dict
    }
}
