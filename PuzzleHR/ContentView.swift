
import SwiftUI
import NotPWA2

class AppConfig: WebAppConfiguration, ObservableObject {
    
    var fetch: Response?
    
    @Published var showBetaInfo: Bool = false
    @Published var betaInfo: AppBetaInfo?
    
    override var url: URL? { URL(string: "https://phr2.geekydevelopment.com") }
//    override var url: URL? { URL(string: "http://localhost:3000") }
    override var debug: Bool { true }
    override var scrollManagedByApp: Bool { true }
    
    enum BridgeHook: String {
        case subscribeToFetch
        case updateToken
        case call
        case showBetaInfo
        case openLink
    }
    
    override func recieveRequest(request: Request, completion: @escaping Response) {
        guard let hook = BridgeHook(rawValue: request.function) else { return }
        
        if hook == .subscribeToFetch {
            fetch = completion
        }
        
        if hook == .updateToken {
            Auth.token = request.model(TokenUpdate.self)?.token
        }
        
        if hook == .call {
            guard let call = request.model(CallRequest.self) else { return }
            guard let url = URL(string: "tel://\(call.phone)") else { return }
            UIApplication.shared.open(url)
        }
        
        if hook == .showBetaInfo {
            guard let webBetaInfo = request.model(WebBetaInfo.self) else { return }
            betaInfo = AppBetaInfo(webVersion: webBetaInfo.webVersion,
                                   buildVersion: Versioning.build ?? "0.0",
                                   releaseVersion: Versioning.release ?? "0.0")
            showBetaInfo = true
        }
        
        if hook == .openLink {
            guard let openLink = request.model(OpenLinkRequest.self) else { return }
            guard let url = URL(string: openLink.url) else { return }
            UIApplication.shared.open(url)
        }
    }
    
}

struct ContentView: View {
    
    @ObservedObject var config = AppConfig()
    
    let background = Color.white // Color(.displayP3, red: 243 / 255, green: 241 / 255, blue: 239 / 255, opacity: 1.0)
    let activatedNotification = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    
    var versionMessage: String {
        "Hey there, welcome to PuzzleHR beta! You are currently running web version \(config.betaInfo?.webVersion ?? ""), app release version \(config.betaInfo?.releaseVersion ?? "0.0"), and build version \(config.betaInfo?.buildVersion ?? "0.0")."
    }
    
    var body: some View {
        WebView(config: config)
            .background(background)
            .ignoresSafeArea(.all)
            .onReceive(activatedNotification) { _ in
                config.fetch?(.success(nil))
            }
//            .alert(isPresented: $config.showBetaInfo) {
//                Alert(title: Text("Beta Info"),
//                      message: Text(versionMessage),
//                      dismissButton: .default(Text("Don                                                          e")))
//            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
