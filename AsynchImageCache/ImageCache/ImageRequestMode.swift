import Foundation

enum ImageRequestMode: String, CaseIterable, Identifiable {
    case httpRules
    case cacheFirst
    case reload
    case cacheOnly

    var id: Self { self }

    var title: String {
        switch self {
        case .httpRules: "HTTP Rules"
        case .cacheFirst: "Cache First"
        case .reload: "Reload"
        case .cacheOnly: "Cache Only"
        }
    }

    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .httpRules: .useProtocolCachePolicy
        case .cacheFirst: .returnCacheDataElseLoad
        case .reload: .reloadIgnoringLocalCacheData
        case .cacheOnly: .returnCacheDataDontLoad
        }
    }

    var explanation: String {
        switch self {
        case .httpRules:
            "Use normal HTTP freshness and validation rules."
        case .cacheFirst:
            "Use cached data when available; otherwise load it."
        case .reload:
            "Ignore locally cached data and load from the server."
        case .cacheOnly:
            "Use cached data only and fail when it is unavailable."
        }
    }
}
/*
 
 */
