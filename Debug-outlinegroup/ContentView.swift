//
//  ContentView.swift
//  Debug-outlinegroup
//
//  Created by Eric Anderson on 1/6/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var myModel = MyModel.shared
    
    @State private var showAddFolder: Bool = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
            VStack {
                Sidebar()
                
                Spacer()
            }.frame(minWidth: 225)
            
        } content: {
            MyList()
                .navigationDestination(for: SidebarSelection.self) { selection in
                    MyList()
                }
        } detail: {
            Text("Select an item..details")
        }
    }

}

struct MyList: View {
    
    var body: some View {
        List {
            Text("1")
            Text("2")
        }
    }
}

struct Sidebar: View {
    @StateObject var myModel = MyModel.shared
    
    @State private var showAddFolder: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $myModel.sidebarSelection) {
                OutlineGroup(myModel.folders, children: \.subFolders) { folder in
                    //                    ForEach(Folder.fetchAll()) { folder in
                    NavigationLink(value: SidebarSelection(selectionType: .folders, selectedId: folder.id)) {
                        Text(folder.name)
                        
                    }
                }
            }
            
            HStack {
                Button(action: { showAddFolder.toggle() }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }.buttonStyle(.plain)
                    .padding(.horizontal, 8)
                Spacer()
            }
            
        }
        .listStyle(.sidebar)
        .contextMenu {
            Button(action: { showAddFolder.toggle() }, label: { Text("New Folder") })
            
        }
        .sheet(isPresented: $showAddFolder, content: {
            NewFolderView(selectedFolderId: myModel.sidebarSelection.selectedId)
        })
        
    }
}


struct NewFolderView: View {
    @Environment (\.presentationMode) var presentationMode
    @StateObject private var myModel = MyModel.shared
    
    @State private var name: String = ""
    
    @State var selectedFolderId: String
    
    private var folderName: String {
        return Folder.object(withID: selectedFolderId)?.name ?? ""
    }
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("Add New Folder").font(.headline)
                    Spacer()
                }
                
                TextField("Name", text: $name, axis: .horizontal)
                
                if folderName != "" {
                    LabeledContent(content: {
                        Text(folderName)
                    }, label: {
                        Label("In Folder:", systemImage: "folder")
                    })
                }
                
                
            }.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        addFolder(name: name)
                        
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save")
                    })
                }
            }
            
        }.padding()
            .frame(minWidth: 300, maxWidth: .infinity)
    }
    
    private func addFolder(name: String) {
        withAnimation {
            let newFolder = Folder.newFolder(name: name, icon: "folder.fill")
            
            if let parent = Folder.object(withID: selectedFolderId) {
                newFolder.parent = parent
            }
            
            myModel.save()
        }
    }
}
