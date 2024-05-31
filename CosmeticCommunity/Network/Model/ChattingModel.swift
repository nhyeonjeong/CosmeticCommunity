//
//  ChattingModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/31.
//

import Foundation
// MARK: - Encodable
struct ChattingRoomQuery: Encodable {
    let opponent_id: String
}

// MARK: - Decodable
struct ChattingRoomModel: Decodable {
    let room_id: String
    let createdAt: String
    let updatedAt: String
    let participants: [CreatorModel] // UserModel
    let lastChat: ChatContentModel? // lastContent가 없으면 첫 대화
    let isFirstTalk: Bool // 첫 대화인지?
    
    enum CodingKeys: CodingKey {
        case room_id
        case createdAt
        case updatedAt
        case participants
        case lastChat
        case isFirstTalk
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.room_id = try container.decode(String.self, forKey: .room_id)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.participants = try container.decode([CreatorModel].self, forKey: .participants)
        if let lastChat = try container.decodeIfPresent(ChatContentModel.self, forKey: .lastChat) {
            self.lastChat = lastChat
            self.isFirstTalk = true
        } else {
            self.lastChat = nil
            self.isFirstTalk = false
        }
    }
}

struct ChatContentModel: Decodable {
    let chat_id: String
    let room_id: String
    let content: String
    let createdAt: String
    let sender: CreatorModel
    let files: [String]?
    
    enum CodingKeys: CodingKey {
        case chat_id
        case room_id
        case content
        case createdAt
        case sender
        case files
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chat_id = try container.decode(String.self, forKey: .chat_id)
        self.room_id = try container.decode(String.self, forKey: .room_id)
        self.content = try container.decode(String.self, forKey: .content)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.sender = try container.decode(CreatorModel.self, forKey: .sender)
        self.files = try container.decodeIfPresent([String].self, forKey: .files) ?? []
    }
}
