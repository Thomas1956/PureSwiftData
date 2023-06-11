//
//  ListViewController.swift
//  PureSwiftData
//
//  Created by Thomas on 11.06.23.
//

import UIKit
import SwiftData
import CoreData


//--------------------------------------------------------------------------------------------
// MARK: - ListViewController

class ListViewController: UICollectionViewController {

    ///---------------------------------------------------------------------------------------
    /// Define DataSource and SnapShot
    public typealias DataSource = UICollectionViewDiffableDataSource<String, PersistentIdentifier>
    public typealias Snapshot   = NSDiffableDataSourceSnapshot<String, PersistentIdentifier>
    
    public var dataSource: DataSource!

    /// Header for the list
    var headerView: ListHeaderView?
    
    ///---------------------------------------------------------------------------------------
    // MARK: - Initialize

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        /// Register Collection View Cell
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        /// Connect Collection View Cell to the datasource
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: PersistentIdentifier) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        /// Register Collection View Header and handle the action of the button
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: ListHeaderView.elementKind) {
            (listHeaderView: ListHeaderView, _, _) in
            
            /// Action for the header as closure
            listHeaderView.initialize() { [weak self] active in
                if let lines = try? self?.mainContext.fetch(FetchDescriptor<Line>() )  {
                    for line in lines { line.active = active }
                }
            }
            self.headerView = listHeaderView
        }
        
        /// Connect Collection View Header to the datasource
       dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        ///------------------------------------------------------------------------------------
        /// Query Data
        var descriptor = FetchDescriptor<Line>()
        descriptor.sortBy = [SortDescriptor(\.name)]

        let lines = try? mainContext.fetch(descriptor)
        let ids = lines.map { $0.id }
        
        var snapshot = Snapshot()
        snapshot.appendSections(["Lines"])
        snapshot.appendItems(ids, toSection: "Lines")
        
        dataSource.apply(snapshot, animatingDifferences: false)
        
        //------------------------------------------------------------------------------------
        /// CoreData - Notification that posts when the context completes a save. This notification comes twice.
        /// One with the CoreData NSManagedObjects und one with the SwiftData PersistentObjects
        
        NotificationCenter.default.addObserver(forName: NSManagedObjectContext.didChangeObjectsNotification,
                                               object: nil, queue: nil) { notification in
              
            let changedObjects = self.mainContext.changedObjectsArray
            if !changedObjects.isEmpty {
                print("Changed", changedObjects.count)
                
               var snapshot = self.dataSource.snapshot()
                snapshot.reconfigureItems(changedObjects.map {$0.id} )
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            
            let deletedObjects = self.mainContext.deletedObjectsArray
            if !deletedObjects.isEmpty {
                print("Deleted", deletedObjects.count)
                
               var snapshot = self.dataSource.snapshot()
                snapshot.reconfigureItems(deletedObjects.map {$0.id} )
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }

            let insertedObjects = self.mainContext.insertedObjectsArray
            if !insertedObjects.isEmpty {
                print("Inserted", insertedObjects.count)
                
               var snapshot = self.dataSource.snapshot()
                snapshot.reconfigureItems(insertedObjects.map {$0.id} )
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            self.updateTableHeader()
        }
    }

    /// Update Collection View Header with the number of selected lines
    @MainActor func updateTableHeader() {
        let predicate = #Predicate<Line> { line in line.active == true }
        if let count = try? mainContext.fetch(FetchDescriptor(predicate: predicate)).count {
            let title = count == 0 ? "No Selection" : String(count) + (count > 1 ? " Lines selected" : " Line selected")
            headerView?.configure(title: title)
        }
    }

    /// Layout of Collection Views
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.showsSeparators = true
        listConfiguration.backgroundColor = .clear
        listConfiguration.separatorConfiguration.color = .gray
        listConfiguration.separatorConfiguration.bottomSeparatorVisibility = .automatic
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    /// Register Collection View Cell
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, identifier: PersistentIdentifier) {
        
        guard let line = self.mainContext.object(with: identifier) as? Line else { return }

        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = line.name
        cell.contentConfiguration = contentConfiguration
        
        /// Add Activate Button as customview
        cell.accessories = [ .customView(configuration: activeButtonConfiguration(for: identifier)) ]

        /// Background Configuration
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .clear
        cell.backgroundConfiguration = backgroundConfiguration
    }

    /// Define Activate Button and set the position on left side of the cell
    private func activeButtonConfiguration(for identifier: PersistentIdentifier) -> UICellAccessory.CustomViewConfiguration
    {
        let button = ActivateButton(identifier: identifier)
        if let line = self.mainContext.object(with: identifier) as? Line {
            button.isActive = line.active ?? false
        }

        button.addTarget(self, action: #selector(didPressActiveButton(_:)), for: .touchUpInside)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
    }
    
    /// Activate Button action of the cells
    @objc func didPressActiveButton(_ activateButton: ActivateButton) {
        guard let id = activateButton.identifier, let line = self.mainContext.object(with: id) as? Line else { return }
        line.active?.toggle()
        activateButton.isActive = line.active ?? false
    }

 }


//--------------------------------------------------------------------------------------------
// MARK: - A c t i v a t e B u t t o n  ein Button mit einem Optionsfeld zur Auswahl

class ActivateButton: UIButton {
    
    var identifier: PersistentIdentifier?
    
    /// Eigenschaft für das Checkmark im Button
    var isActive = false {
        didSet {
            var config = self.configuration
            config?.image = UIImage(systemName: isActive ? "checkmark.square" : "square")
            self.configuration = config
        }
    }

    convenience init(identifier: PersistentIdentifier?) {
        self.init(frame: .zero)
        self.identifier = identifier
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: isActive ? "checkmark.square" : "square")
        config.buttonSize = .medium
        configuration = config
    }
}

