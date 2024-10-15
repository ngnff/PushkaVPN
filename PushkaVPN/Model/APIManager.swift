import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore

class APIManager
{
    static let shared = APIManager()
    
    private func configureFB() -> Firestore
    {
        var db: Firestore!
        let settings = FirestoreSettings() //Check this
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        return db
    }
    
    func getPost(collection: String, serverName: String, completion: @escaping (configure?) -> Void)
    {
        let db = configureFB()
        db.collection(collection).document(serverName).getDocument(completion: {(config, error) in
            guard error == nil else { completion(nil); return}
            let conf = configure(name: config?.get("name") as! String, Address: config?.get("Address") as! String, AllowedIPs: config?.get("AllowedIPs") as! String, DNS: config?.get("DNS") as! String, Endpoint: config?.get("Endpoint") as! String, PersistentKeepalive: config?.get("PersistentKeepalive") as! String, PresharedKey: config?.get("PresharedKey") as! String, PrivateKey: config?.get("PrivateKey") as! String, PublicKey: config?.get("PublicKey") as! String, img: config?.get("img") as! String)
            completion(conf)
        })
    }
    
    
    
    func getPost(collection: String, completion: @escaping (confSettings?) -> Void)
    {
        let db = configureFB()
        db.collection(collection).getDocuments(completion: {(config, error) in
            guard error == nil else { completion(nil); return}
            do {
                let config = try JSONDecoder().decode(confSettings.self, from: Data())
            } catch {
              print("Error for getPost: \(error)")
            }
        })
    }
}
