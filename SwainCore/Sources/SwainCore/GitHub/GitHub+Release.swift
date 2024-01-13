//
//  GitHub+Release.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import FoundationEssentials

extension GitHub {
    struct Release: Decodable {
        private enum CodingKeys: String, CodingKey {
            case htmlURL = "html_url"
            case tagName = "tag_name"
            case name
            case prerelease
            case createdAt = "created_at"
            case publishedAt = "published_at"
        }
        
        let htmlURL: FoundationEssentials.URL
        let tagName: String
        let name: String
        let prerelease: Bool
        let createdAt: FoundationEssentials.Date
        let publishedAt: FoundationEssentials.Date
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.htmlURL = try container.decode(FoundationEssentials.URL.self, forKey: .htmlURL)
            self.tagName = try container.decode(String.self, forKey: .tagName)
            self.name = try container.decode(String.self, forKey: .name)
            self.prerelease = try container.decode(Bool.self, forKey: .prerelease)
            self.createdAt = try container.decode(FoundationEssentials.Date.self, forKey: .createdAt)
            self.publishedAt = try container.decode(FoundationEssentials.Date.self, forKey: .publishedAt)
        }
    }
}
