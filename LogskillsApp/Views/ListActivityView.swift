//
//  ListActivityView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct ListActivityView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var user: User
    @EnvironmentObject var activitiesObs: ActivitiesObs
    @EnvironmentObject var categoriesObs: CategoriesObs
    @State private var selectedActivityId: Int = 0
    @State private var isShowingCreationView = false
    @State private var isShowingModifificationView = false
    
    enum ActiveSheet: Identifiable {
        case first, second
        
        var id: Int {
            hashValue
        }
    }
    
    @State var activeSheet: ActiveSheet?
    
    
    var body: some View {
        
        NavigationView{
            
            Form {
                Section{
                    List{
                        ForEach(self.activitiesObs.activities, id: \.id){ activite in
                            HStack{
                                Button(action: {
                                    print(activite)
                                    activitiesObs.selectedActivityId = activite.id
                                    // return back to home view after 0.2 sec
                                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                                        // isShowingModifificationView.toggle()
                                        activeSheet = .second
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Text(activite.nom)
                                    }
                                }
                                
                            }.padding(10)
                            .foregroundColor(.primary)
                            .opacity(0.8)
                        }.onDelete(perform: delete)
                        
                    }
                }
                
                Section {
                    Button(action: {                                                
                        activeSheet = .first
                    }) {
                        HStack(spacing: 10) {
                            Text("Ajouter une activité")
                            Spacer()
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
                
            }
            .navigationTitle("Activities")
                        
            .sheet(item: $activeSheet) { item in
                switch item {
                case .first:
                    FormActivityView()
                case .second:
                    // Modif view
                    if(self.activitiesObs.selectedActivityId != 0){
                        FormActivityView(activityAlreadyExist: true, selectedActivity: self.activitiesObs.activities.filter{$0.id == self.activitiesObs.selectedActivityId}[0])
                    } else {
                        Text("Id: \(activitiesObs.selectedActivityId)")
                    }
                }
            }
            
            
            
        }
        .onAppear {
            activitiesObs.refreshActivityList()            
        }
        // Important
        .environmentObject(activitiesObs)
        .environmentObject(categoriesObs)
        
        
        
    }
    
    func delete(at offsets: IndexSet) {
        // delete the objects here`
        let index = offsets[offsets.startIndex]
        // Delete from API
        activityApi().deleteActivity(apiBaseUrl: settings.apiBaseUrl, token: user.token, activityId: self.activitiesObs.activities[index].id)
        // Delete from view
        self.activitiesObs.activities.remove(atOffsets: offsets)
    }
}



struct ListActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ListActivityView()
    }
}
