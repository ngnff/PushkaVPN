import Foundation
import WireGuardKit
import WireGuardKitC
import WireGuardKitGo
import NetworkExtension

class WG: NEPacketTunnelProvider
{
    func ReadFromFile(options: [String: NSObject]?) -> TunnelConfiguration?{
        var peer: PeerConfiguration?
        var interface: InterfaceConfiguration?
        
        
        if let publicKey = PublicKey(base64Key: options?["PublicKey"] as! String) {
            peer = PeerConfiguration(publicKey: publicKey)
            print(publicKey)
            if let preSharedKey = PreSharedKey(base64Key: options?["PreSharedKey"] as! String) {
                peer!.preSharedKey = preSharedKey
            }
            if let endPoint = Endpoint(from: options?["Endpoint"] as! String) {
                peer!.endpoint = endPoint
            }
            if let persistentKeepAlive = options?["persistentKeepAlive"] as? UInt16 {
                peer!.persistentKeepAlive = persistentKeepAlive
            }
            if let allowedIPs = IPAddressRange(from: options?["AllowedIPs"] as! String) {
                peer!.allowedIPs = [allowedIPs]
            }
        }
        
        if let privateKey = PrivateKey(hexKey: options?["PrivateKey"] as! String) {
            interface = InterfaceConfiguration(privateKey: privateKey)
            print(privateKey)
            if let addresses = IPAddressRange(from: options?["Address"] as! String) {
                interface!.addresses = [addresses]
            }
            if let dns1 = DNSServer(from: options?["DNS1"] as! String) {
                let dns2 = DNSServer(from: options?["DNS2"] as! String)
                interface!.dns = [dns1, dns2] as! [DNSServer]
            }
        }
        
        let name = "tunnel"
        
        if let interface = interface, let peer = peer {
            return TunnelConfiguration(name: name, interface: interface, peers: [peer])
        }
        return nil
    }
    
    private lazy var adapter: WireGuardAdapter = {
        return WireGuardAdapter(with: self) { err,log  in
            print("\(err) - \(log)")
        }
    }()
    
    func StartTunnel(options: [String: NSObject]?)
    {
        let tunnelConf = ReadFromFile(options: options)
        
        if tunnelConf != nil
        {
            adapter.start(tunnelConfiguration: tunnelConf!, completionHandler: {
                err in
                print("Error start method: \(err)")
            })
        }
    }
    
    func StopTunnel()
    {
        adapter.stop(completionHandler: {
            err in
            print("Error stop method: \(err)")
        })
    }
}
