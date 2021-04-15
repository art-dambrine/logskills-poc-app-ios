//
//  FormActivityView.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 11/04/2021.
//

import SwiftUI

struct FormActivityView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var categoriesObs: CategoriesObs
    @EnvironmentObject var activitiesObs: ActivitiesObs
    @EnvironmentObject var user: User
    
    
    @State private var categories: [Category] = []
    @State private var selectedCategory = ""
    @State private var categorySelectionList = [""]
    
    @State private var activityName: String = ""
    
    @State private var nbRoundSelected = 1
    @State private var rounds = [1, 2, 3]
    
    @State private var tempsFocus: Double = 25
    @State private var tempsPause: Double = 5
    
    @State private var title: String = "Create a new activity"
    
    private var activityAlreadyExist: Bool
    private var selectedActivity: Activity
    
    init(activityAlreadyExist: Bool = false,
         selectedActivity: Activity = Activity(id: 0, nom: "", temps_focus: 0, temps_pause: 0, nb_round: 0, id_categorie: 0)){
        
        self.activityAlreadyExist = activityAlreadyExist
        self.selectedActivity = selectedActivity
    }
    
    
    var body: some View {
        
        NavigationView{
            Form{
                Section(header: Text("Select category")){
                    Picker("Select category", selection: $selectedCategory){
                        
                        ForEach(categorySelectionList, id: \.self){
                            Text($0)
                                .font(.subheadline)
                        }
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Activity name", text: $activityName)
                }
                
                Section(header: Text("Select temps de focus")){
                    HStack{
                        Slider(value: $tempsFocus, in: 1...45)
                        Text("\(tempsFocus, specifier: "%.f") minutes.")
                    }
                }
                
                Section(header: Text("Select temps de pause")){
                    HStack{
                        Slider(value: $tempsPause, in: 1...15)
                        Text("\(tempsPause, specifier: "%.f") minutes.")
                    }
                }
                
                Section(header: Text("Nombre de rounds")){
                    Picker("Select the number of rounds", selection: $nbRoundSelected) {
                        ForEach(rounds, id: \.self) {
                            Text(String($0))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Save changes") {
                        
                        if (!activityAlreadyExist) {
                            // Send POST data API :
                            // Récupération de l'id category à partir du nom
                            let filtered = categories.filter{ $0.nom.contains(self.selectedCategory) }
                            var categoryFilteredId = 0
                            if (filtered.count>0) {
                                categoryFilteredId = filtered[0].id
                            }
                                                        
                            let activity = Activity(
                                id: 0,
                                nom: self.activityName,
                                temps_focus: Int(round(self.tempsFocus)),
                                temps_pause: Int(round(self.tempsPause)),
                                nb_round: self.nbRoundSelected,
                                id_categorie: categoryFilteredId
                            )                                                        
                            
                            activityApi().postActivity(apiBaseUrl: settings.apiBaseUrl, token:user.token, activity: activity)
                            activitiesObs.activities.append(activity)
                            
                            // return back to home view after 0.2 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                action: do {self.presentationMode.wrappedValue.dismiss()}
                            }
                        } else {
                            // Send UPDATE data API :
                            // Récupération de l'id category à partir du nom
                            let filtered = categories.filter{ $0.nom.contains(self.selectedCategory) }
                            let categoryFilteredId = filtered[0].id
                            
                            let activity = Activity(
                                id: self.selectedActivity.id,
                                nom: self.activityName,
                                temps_focus: Int(round(self.tempsFocus)),
                                temps_pause: Int(round(self.tempsPause)),
                                nb_round: self.nbRoundSelected,
                                id_categorie: categoryFilteredId
                            )
                            
                            activityApi().updateActivity(apiBaseUrl: settings.apiBaseUrl,token: user.token, activity: activity)
                            
                            if let index = activitiesObs.activities.firstIndex(where: { $0.id == activity.id }) {
                                activitiesObs.activities[index] = activity
                            }
                            
                            // return back to home view after 0.2 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                action: do {self.presentationMode.wrappedValue.dismiss()}
                            }
                        }
                        
                    }
                    
                    if activityAlreadyExist {
                        Button("Delete activity") {
                            
                            activityApi().deleteActivity(apiBaseUrl: settings.apiBaseUrl,token: user.token, activityId: selectedActivity.id)
                            
                            // return back to home view after 0.2 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                action: do {self.presentationMode.wrappedValue.dismiss()}
                            }
                            
                        }.foregroundColor(.red)
                    }
                }
                
                
            }.onAppear{
                
                //    categoryApi().getAllCategories(apiBaseUrl: settings.apiBaseUrl) { (categories) in
                //          ...
                //  }
                
                self.categories = categoriesObs.categories
                    print(self.categories)
                    
                    self.categorySelectionList = []
                    for categorie in categories { self.categorySelectionList.append(categorie.nom) }
                    
                    if !activityAlreadyExist{
                        // Valeur par défaut pour le slider
                        if (categorySelectionList.count > 0) {
                            self.selectedCategory = categorySelectionList[0]
                        }
                    }
                    

                
                // Récupération des informations de l'activité selectionnée
                if activityAlreadyExist {
                    self.title = "Activite n°" + String(self.selectedActivity.id)
                    
                    self.tempsFocus = Double(self.selectedActivity.temps_focus)
                    self.tempsPause = Double(self.selectedActivity.temps_pause)
                    self.nbRoundSelected = self.selectedActivity.nb_round
                    self.activityName = selectedActivity.nom
                    
                    // print(self.selectedActivity)    // ->  category: "/api/categories/1"
//                    let array = self.selectedActivity.id_categorie.components(separatedBy: "/")
//                    let categoryId = Int(array[array.count - 1]) ?? 1
                    
                    // Récupération de la categorie selectionnée par id
                    if (categories.filter{ $0.id == selectedActivity.id_categorie }.count > 0) {
                        self.selectedCategory = categories.filter{ $0.id == selectedActivity.id_categorie }[0].nom
                    } else {
                        print ("ERROR { $0.id == selectedActivity.id_categorie }[0] out of range")
                    }
                    
                    
                }
            }
            .navigationTitle(self.title)
        }
        
    }
}

struct FormActivityView_Previews: PreviewProvider {
    static var previews: some View {
        FormActivityView()
    }
}
