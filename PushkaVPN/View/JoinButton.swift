import SwiftUI
import WireGuardKit
import MobileCoreServices
import WireGuardKitGo
import WireGuardKitC

extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}



class TunnelManagerDelegate: NSObject, TunnelsManagerActivationDelegate, TunnelsManagerListDelegate {
    func tunnelActivationAttemptFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationAttemptError) {
        //
    }
    
    func tunnelActivationAttemptSucceeded(tunnel: TunnelContainer) {
        //
    }
    
    func tunnelActivationFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationError) {
        //
    }
    
    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
        //
    }
    
    func tunnelRemoved(at index: Int, tunnel: TunnelContainer) {
        //
    }
    
    var tunnelsManager: TunnelsManager?
    
    func setupTunnelsManager() {
        TunnelsManager.create { result in
            switch result {
            case .failure(let error):
                print("Ошибка создания TunnelsManager: \(error.localizedDescription)")
            case .success(let manager):
                self.tunnelsManager = manager
                self.tunnelsManager?.activationDelegate = self
            }
        }
    }
    
    func connect_ac() {
        guard let tunnelsManager = tunnelsManager else {
            print("TunnelsManager не инициализирован")
            return
        }
        
        if let tunnel = tunnelsManager.tunnel(named: "Wanted") {
            if tunnel.status == .active {
                tunnelsManager.startDeactivation(of: tunnel)
                return
            }
        }
       
        let str = "W0ludGVyZmFjZV0KQWRkcmVzcyA9IDE5Mi4xNjguNi41My8zMgpQcml2YXRlS2V5ID0gYUZZMEV5NzV2eE5GbVczbllOVFBBQ3VIRmNoc1VvUDFmczdyRTVMaHRuOD0KRE5TID0gOS45LjkuOSw4LjguOC44CgpbUGVlcl0KUHVibGljS2V5ID0gbm9PN2ZINmxmZGE2bTIyWEVxaE13SHhtWllTMFFRRlBuNStCVEZEVWxWaz0KUHJlc2hhcmVkS2V5ID0gYm8ycHZSNXc4RWlBMTdvY09xSEFISDMxUUJZdUpPREErSEtSWHRiSVRRTT0KQWxsb3dlZElQcyA9IDAuMC4wLjAvMApFbmRwb2ludCA9IDE5My41Ny4xMzYuMTQ4OjQxMTk0ClBlcnNpc3RlbnRLZWVwYWxpdmUgPSAxNQo="
        let decode = str.base64Decoded()
        print("Decoded is =>", decode!)
        
        guard let scannedTunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: decode!, called: "Scanned") else {
            print("Ошибка создания конфигурации туннеля")
            return
        }
        var tunnelConfiguration = scannedTunnelConfiguration
        tunnelConfiguration.name = "Wanted"
        
        var interface = InterfaceConfiguration(privateKey: PrivateKey(base64Key: "aFY0Ey75vxNFmW3nYNTPACuHFchsUoP1fs7rE5Lhtn8=")!)
        interface.addresses = [IPAddressRange(from: "192.168.6.53/32")!, IPAddressRange(from: "fddd:2c4:2c4:2::2/64")!]
        interface.dns = [DNSServer(from: "9.9.9.9")!, DNSServer(from: "8.8.8.8")!]
        
        var peer = PeerConfiguration(publicKey: PublicKey(base64Key: "noO7fH6lfda6m22XEqhMwHxmZYS0RQFPn4+BTFDUlVk=")!)
        peer.endpoint = Endpoint(from: "193.57.136.148:41194")
        peer.allowedIPs = [IPAddressRange(from: "0.0.0.0/0")!, IPAddressRange(from: "::/0")!]
        peer.persistentKeepAlive = 15
        peer.preSharedKey = PreSharedKey(base64Key: "bo2pvR5w8EiA17ocOqHAHH31QBYuJODA+hKRXtbITQM=")
        
        tunnelConfiguration = TunnelConfiguration(name: "Wanted", interface: interface, peers: [peer])
        
        tunnelsManager.add(tunnelConfiguration: tunnelConfiguration) { result in
            switch result {
            case .failure(let error):
                print("Ошибка:", error.alertText.title)
                if error.alertText.title == "alertTunnelAlreadyExistsWithThatNameTitle" {
                    let tunnel = tunnelsManager.tunnel(named: "Wanted")
                    tunnelsManager.startActivation(of: tunnel!)
                }
            case .success:
                print("Добавлено успешно")
                let tunnel = tunnelsManager.tunnel(named: "Wanted")
                tunnelsManager.startActivation(of: tunnel!)
            }
        }
    }
    func disconnect_ac() {
            guard let tunnelsManager = tunnelsManager else {
                print("TunnelsManager не инициализирован")
                return
            }
            
            if let tunnel = tunnelsManager.tunnel(named: "Wanted"), tunnel.status == .active {
                tunnelsManager.startDeactivation(of: tunnel)
            }
        }
        
        // Реализация методов делегатов
        func tunnelAdded(at index: Int) {
            print("Туннель добавлен на индекс \(index)")
        }
        
        func tunnelModified(at index: Int) {
            print("Туннель изменен на индекс \(index)")
        }
        
        func tunnelMoved(from oldIndex: Int, to newIndex: Int) {
            print("Туннель перемещен с \(oldIndex) на \(newIndex)")
        }
        
        func tunnelRemoved(at index: Int) {
            print("Туннель удален на индексе \(index)")
        }
        
        func activationAttemptFailed(for tunnel: TunnelContainer, with error: TunnelsManagerActivationAttemptError) {
            print("Попытка активации не удалась для туннеля: \(tunnel.name), ошибка: \(error.localizedDescription)")
        }
        
        func activationAttemptSucceeded(for tunnel: TunnelContainer) {
            print("Попытка активации успешна для туннеля: \(tunnel.name)")
        }
        
        func activationAttemptSucceededAfterReactivation(for tunnel: TunnelContainer) {
            print("Попытка повторной активации успешна для туннеля: \(tunnel.name)")
        }
    }

    struct JoinButton: View {
        private var delegate = TunnelManagerDelegate()
        @State private var buttonOn: Bool = false
        
        var body: some View {
            Button(action: {
                buttonOn.toggle()
                if buttonOn {
                    delegate.connect_ac()
                } else {
                    delegate.disconnect_ac()
                }
            }) {
                if !buttonOn {
                    Image("JoinButtonBegin")
                } else {
                    ZStack {
                        Image("JoinButtonFinal")
                        Text("Отключиться")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
            }
            .onAppear {
                delegate.setupTunnelsManager()
            }
        }
    }

    struct JoinButton_Previews: PreviewProvider {
        static var previews: some View {
            JoinButton()
        }
    }
