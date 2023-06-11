//
//  AppDelegate.swift
//  PureSwiftData
//
//  Created by Thomas on 11.06.23.
//

import UIKit
import SwiftData


var applicationName      = String()
var applicationVersion   = String()
let applicationCopyright : String = "© Ingenieurbüro Halbritter 2023"


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        /// App-Informationen auslesen
        let dictionary = Bundle.main.infoDictionary!
        applicationName    = dictionary["CFBundleName"] as! String
        applicationVersion = dictionary["CFBundleShortVersionString"] as! String

        /// PersistentContainer laden
        Persistence.shared = Persistence(appName: applicationName, appVersion: applicationVersion,
                                         appCopyright: applicationCopyright, inMemory: true, useUndo: false)
        let container = Persistence.shared.modelContainer
        
        
        let modelContext = container.mainContext
        if let lines = try? modelContext.fetch(FetchDescriptor<Line>()), lines.isEmpty {
            /// Daten generieren
            for i in 0..<1000 {
                let person = Line(name: "Line " + String(i+1), active: false)
                modelContext.insert(object: person)
            }
            try? modelContext.save()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

