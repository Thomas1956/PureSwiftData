//
//  Persistence.swift
//  PureSwiftData
//
//  Created by Thomas on 11.06.23.
//

import OSLog
import UIKit
import SwiftData


//--------------------------------------------------------------------------------------------
// MARK: - Extension UIViewController for  P E R S I S T E N C E

public extension UIViewController {
    
    /// Variable 'persistentContainer' von Persistence bereitstellen
    var modelContainer : ModelContainer {
        get {
            return Persistence.shared.modelContainer
        }
    }
    
    /// Variable 'viewContext' von Persistence bereitstellen
    var mainContext : ModelContext {
        get {
            return Persistence.shared.modelContainer.mainContext
        }
    }
        
    /// Funktion 'saveContext' von Persistence bereitstellen
    func saveContext() {
        do {
            try mainContext.save()
        } catch {
            fatalError("SaveContext error")
        }
    }
}



//--------------------------------------------------------------------------------------------
// MARK:  P E R S I S T E N C E

open class Persistence {
    
    /// Statische Referenz auf die Klasse
    public static var shared : Persistence!
    
    static var applicationName      : String!
    static var applicationVersion   : String!
    static var applicationCopyright : String!
    
    //----------------------------------------------------------------------------------------
    // MARK: Initialisierung
    
    public init(appName: String, appVersion: String, appCopyright: String, inMemory: Bool = false, useUndo: Bool = true) {
        if appName.isEmpty {
            fatalError("Der NAME der Applikation muss definiert sein.")
        }
        if appVersion.isEmpty {
            fatalError("Der VERSION der Applikation muss definiert sein.")
        }
        if appCopyright.isEmpty {
            fatalError("Der COPYRIGHT der Applikation muss definiert sein.")
        }
        
        Persistence.applicationName      = appName
        Persistence.applicationVersion   = appVersion
        Persistence.applicationCopyright = appCopyright
        
        logger = Logger(subsystem: "tw." + Persistence.applicationName, category: "persistence")
    }
    
    
    //----------------------------------------------------------------------------------------
    /// Logging für Debug
    public  let logger : Logger!
    
    private let datamodelName = "default"   // Name der Datenbank
    private let storeType     = "store"     // Datei-Erweiterung

    
    //----------------------------------------------------------------------------------------
    // MARK: ModelContainer
    
    public lazy var modelContainer: ModelContainer = {
        printPath()
        do {
            let container = try ModelContainer(for: Line.self)
            return container
        } catch {
            fatalError("ModelContainer error")
        }
    }()
        
    
    //----------------------------------------------------------------------------------------
    // MARK: Variablen für Zugriff auf SQL-Datei
    
    private lazy var urlApplication : URL? = {            // URL der Applikation
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    }()
    
    private lazy var pathApplication : String? = {        // Pfad der Applikation
        guard let url = urlApplication else { return nil }
        return url.absoluteString.replacingOccurrences(of: "file://", with: "").removingPercentEncoding
    }()
    
    private lazy var urlContainer: URL? = {                // URL der Datenbank
        guard let urlApp = urlApplication else { return nil }
        let url = urlApp.appendingPathComponent("\(datamodelName).\(storeType)")
        if !FileManager.default.fileExists(atPath: url.path) { return nil }
        return urlApp
    }()
    
    /// Pfad der Datenbank anzeigen
    func printPath() {
        print("CoreData Datenbank :: \(pathApplication ?? "Nicht gefunden")")
    }
        
}
