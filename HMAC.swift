import Foundation
import CryptoKit

/// HMAC-SHA1 signature helper (for PTV API v3)
enum HMAC {
    static func sign(path: String, key: String) -> String {
        let keyData = Data(key.utf8)
        let pathData = Data(path.utf8)
        let hmac = Insecure.HMAC<Insecure.SHA1>.authenticationCode(for: pathData, using: SymmetricKey(data: keyData))
        return hmac.map { String(format: "%02hhx", $0) }.joined()
    }
}