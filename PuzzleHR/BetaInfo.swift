
struct WebBetaInfo: Codable {
    let webVersion: String
}

struct AppBetaInfo: Codable {
    let webVersion: String
    let buildVersion: String
    let releaseVersion: String
}
