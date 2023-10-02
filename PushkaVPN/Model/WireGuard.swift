import PIAWireguard

class WG
{
    
    static let shared = WG()
    static let WireGuard = WGPacketTunnelProvider()
    
    func MakeTunnel()
    {
        APIManager.shared.getPost(collection: "servers", serverName: "Netherland", completion: {
            conf in
            guard conf != nil else {return}
            let networkSettings = 
        }
    }
}
