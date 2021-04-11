//
//  ListActivityView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct ListActivityView: View {
    @EnvironmentObject var settings: Settings    
    
    @State var activities: [Activity] = []
    @State private var isShowingCreationView = false
    
    
    var body: some View {
        
        
        
        Form{
            
            HStack{
                Text("Ajouter une activité")
                    .bold()
                    .font(.title2)
                    .background(
                        NavigationLink(destination: FormActivityView(), isActive: $isShowingCreationView){
                            EmptyView()
                        }.disabled(!isShowingCreationView)
                    )
                
                Spacer()
                
                Button(action: {
                    isShowingCreationView.toggle()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.pencil")
                    }
                }
                
            }.padding(20)
            
            
            
            Section{
                List{
                    ForEach(activities, id: \.id){ activite in
                        HStack{
                            Text(activite.nom)
                                .font(.subheadline)
                            
                            NavigationLink(destination: FormActivityView(activityAlreadyExist: true, selectedActivity: activite)){
                                EmptyView()
                            }
                            
                            // Button(action: { activityApi().deleteActivity(apiBaseUrl: settings.apiBaseUrl, activityId: activite.id) }) { Image(systemName: "trash") }
                        }.padding(10)
                    }.onDelete(perform: delete)
                    
                }
            }
            
            
        }.onAppear {
            activityApi().getAllActivities(apiBaseUrl: settings.apiBaseUrl) { (activities) in
                self.activities = activities
            }
        }
        
        
        
    }
    
    func delete(at offsets: IndexSet) {
        // delete the objects here`
        let index = offsets[offsets.startIndex]
        // Delete from API
        activityApi().deleteActivity(apiBaseUrl: settings.apiBaseUrl, activityId: activities[index].id)
        // Delete from view
        self.activities.remove(atOffsets: offsets)
    }
}



struct ListActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ListActivityView()
    }
}
