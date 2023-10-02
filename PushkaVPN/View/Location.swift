import SwiftUI

struct Location: View {
    @State private var singleSelection: UUID?
    
    @State private var servers: [String] = []
    
    var body: some View {
        List(servers, id:\.self, selection: $singleSelection)
        {
            Text($0)
        }.onAppear{
            APIManager.shared.getPost(collection: "Servers", completion: {conf in
                guard conf != nil else {return}
                servers = conf?.names ?? [""]
            })
        }
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Location()
    }
}
