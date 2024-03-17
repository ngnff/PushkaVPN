import Foundation
import WireGuardKit
import WireGuardKitC
import WireGuardKitGo

struct configure
{
    let name: String
    let Address: String
    let AllowedIPs: String
    let DNS: String
    let Endpoint: String
    let PersistentKeepalive: String
    let PresharedKey: String
    let PrivateKey: String
    let PublicKey: String
    let img: String
    
    func GoString() -> [String: AnyObject]
    {
        var gs = ["private_key": self.PrivateKey as AnyObject, "public_key": self.PublicKey as AnyObject, "endpoint": self.Endpoint as AnyObject, "persistent_keepalive_interval": self.PersistentKeepalive as AnyObject, "allowed_ip": self.AllowedIPs as AnyObject]
        return gs
    }
}

struct confSettings: Identifiable
{
    let id = UUID()
    let names: [String]
}

extension confSettings: Decodable
{
    private enum Key: String, CodingKey
    {
        case names = "servers"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

            self.names = try container.decode([String].self, forKey: .names)
    }
}
