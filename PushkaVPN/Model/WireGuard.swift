import WireGuardKit
import WireGuardKitC
import WireGuardKitGo
import NetworkExtension

class WG
{
    init(collection: String, serverName: String, completion: (() -> Void)? = nil)
    {
        var peer: PeerConfiguration?
        var interface: InterfaceConfiguration?
        var name: String?
        
        let packetTunnelProvider = NEPacketTunnelProvider()
        
        self.wireguardAdapter = WireGuardAdapter(with: packetTunnelProvider, logHandler: {
            log, err in
            print("Error - init: \(err)")
        })
        
        self.tunnelConf = nil
        
        APIManager.shared.getPost(collection: collection, serverName: serverName) { [weak self] conf in
            guard let self = self else { return }
            guard let conf = conf else { return }
            
            name = conf.name
            
            if let publicKey = PublicKey(base64Key: conf.PublicKey) {
                peer = PeerConfiguration(publicKey: publicKey)
                print(publicKey)
                if let preSharedKey = PreSharedKey(base64Key: conf.PresharedKey) {
                    peer!.preSharedKey = preSharedKey
                }
                if let endPoint = Endpoint(from: conf.Endpoint) {
                    peer!.endpoint = endPoint
                }
                if let persistentKeepAlive = UInt16(conf.PersistentKeepalive) {
                    peer!.persistentKeepAlive = persistentKeepAlive
                }
                if let allowedIPs = IPAddressRange(from: conf.AllowedIPs) {
                    peer!.allowedIPs = [allowedIPs]
                }
            }
            
            if let privateKey = PrivateKey(hexKey: conf.PrivateKey) {
                interface = InterfaceConfiguration(privateKey: privateKey)
                print(privateKey)
                if let addresses = IPAddressRange(from: conf.Address) {
                    interface!.addresses = [addresses]
                }
                if let dns = DNSServer(from: conf.DNS) {
                    interface!.dns = [dns]
                }
            }
            
            if let interface = interface, let peer = peer, let name = name {
                self.tunnelConf = TunnelConfiguration(name: name, interface: interface, peers: [peer])
                completion?()
            }
        }
    }
    
    //    init()
    //    {
    //        let base: TunnelConfiguration? = nil
    //        tunnelConfigure = try TunnelConfiguration(fromUapiConfig: str, basedOn: base)
    //        let packetTunnelProvider = NEPacketTunnelProvider()
    //        self.wireguardAdapter = WireGuardAdapter(with: packetTunnelProvider, logHandler: {
    //            log, err in
    //            print("Error - init: \(err)")
    //        })
    //    }
    
    var tunnelConf: TunnelConfiguration?
    var wireguardAdapter: WireGuardAdapter
    
    func StartTunnel()
    {
        if tunnelConf != nil {
            wireguardAdapter.start(tunnelConfiguration: tunnelConf!, completionHandler: {
                err in
                print("Error start method: \(err)")
                //print(self.tunnelConf?.name)
            })
        }
    }
    
    func StopTunnel()
    {
        wireguardAdapter.stop(completionHandler: {
            err in
            print("Error stop method: \(err)")
        })
    }
}
