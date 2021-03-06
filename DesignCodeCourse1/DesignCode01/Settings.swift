//
//  Settings.swift
//  DesignCode01
//
//  Created by 仝华帅 on 2021/3/14.
//

import SwiftUI

struct Settings: View {
    @State var receive = false
    @State var number = 1
    @State var selection = 1
    @State var date = Date()
    @State var email = ""
    @State var submit = false
    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $receive) {
                    Text("Receive notifications")
                }
                Stepper(value: $number, in: 1...10) {
                    Text("\(number) Notification\(number > 1 ? "s" : "") per week")
                }
                Picker(selection: $selection, label: Text("Favorite course")) {
                    Text("SwfitUI").tag(1)
                    Text("React").tag(2)
                }
                DatePicker(selection: $date, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
                
                Section(header: Text("Email")) {
                    TextField("Your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {self.submit.toggle()}) {
                    Text("Submit")
                }
                .alert(isPresented: $submit, content: {
                    Alert(title: Text("Thanks!"), message: Text("Email: \(self.email)"))
                    
                })
            }
            .navigationTitle("Settings")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
