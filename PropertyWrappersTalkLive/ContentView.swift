import SwiftUI

struct ContentView: View {
    
    @State
    var isShowingModal: Bool = false
    @ObservedObject
    var imageDownloader = ImageDownloader(url: "https://pbs.twimg.com/media/Dby_GmVW0AAkU0F.jpg", defaultImageTitle: "now-loading")
    @Uppercased
    var name = ""
    @Lazy var inset = {
        return 50
    }()
    @Lazy var outroNumero = 50
    @Regexed(regex: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
    var email: String?
    @Regexed(regex: "[0-9]{3}\\.[0-9]{3}\\.[0-9]{3}-[0-9]{2}")
    var cpf: String?
    
    init() {
        name = "Leonel"
        print(name)
        print(inset)
        print(outroNumero)
        self.email = "mml_leo@hotmail.comasdf.aisudfa@"
        self.cpf = "123.456.457-895"
        print(email)
        print(cpf)
        FeatureToggleConfig.isPaymentEnabled = true
    }
    
    var body: some View {
        VStack {
            Text(self.name)
            imageDownloader.storedImage
                .resizable()
                .aspectRatio(contentMode: .fit)
            Button(action: {
                self.isShowingModal.toggle()
            }, label: {Text("Clicka ae po")})
                .sheet(isPresented: $isShowingModal, content: {Image("sextis")})
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
#endif


@propertyWrapper
struct Uppercased {
    var storedValue: String = ""
    
    init(wrappedValue: String) {
        self.storedValue = wrappedValue
    }
    
    var wrappedValue: String {
        get {
            return storedValue.uppercased()
        }
        set {
            self.storedValue = newValue
        }
    }
}

@propertyWrapper
struct Lazy<T> {
    var storedValue: T?
    var constructor: () -> T
    
    init(wrappedValue constructor: @autoclosure @escaping () -> T) {
        self.constructor = constructor
    }
    
    var wrappedValue: T {
        mutating get {
            if storedValue == nil {
                self.storedValue = constructor()
            }
            return storedValue!
        }
        set {
            storedValue = newValue
        }
    }
}

@propertyWrapper
struct Regexed {
    var storedValue: String?
    let regexExpression: String
    
    init(regex: String) {
        self.regexExpression = regex
    }
    
    var wrappedValue: String? {
        get {
            return storedValue
        }
        set {
            do {
                let regexExpression = try NSRegularExpression(pattern: self.regexExpression, options: .caseInsensitive)
                if let newValue = newValue,
                    isMatching(regexExpression, on: newValue) {
                    self.storedValue = newValue
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func isMatching(_ regexExpression: NSRegularExpression, on text: String) -> Bool {
        let range = NSRange(location: 0, length: text.count)
        if let firstMatch = regexExpression.firstMatch(in: text, options: [], range: range) {
            return firstMatch.range == range
        }
        return false
    }
}

@propertyWrapper
struct UserDefault<T> {
    var storedValue: T
    var key: String
    
    init(key: String, defaultValue: T) {
        self.storedValue = defaultValue
        self.key = key
    }
    
    var wrappedValue: T {
        set {
            UserDefaults.standard.set(newValue, forKey: self.key)
        }
        get {
            return UserDefaults.standard.value(forKey: self.key) as? T ?? self.storedValue
        }
    }
}

enum FeatureToggleConfig {
    @UserDefault(key: "feat_payment_toggle", defaultValue: false)
    static var isPaymentEnabled: Bool
    @UserDefault(key: "feat_wallet_toggle", defaultValue: false)
    static var isWalletEnabled: Bool
}
