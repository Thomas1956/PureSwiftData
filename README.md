#  PureSwiftData

June 11, 2023
This week at WWDC 2023, Apple introduced SwiftData.
For many developers who have been using CorData, SwiftData is supposed to make it easier than ever to ensure persistence of an application's data.

When analyzing the stored data and internals of SwiftData, one realizes that SwiftData is just another layer on top of CoreData. The mechanisms and functions of CoreData are still used and also the storage is done in a SQLITE file.

So far, Apple has only introduced the implementation of SwiftData in SwiftUI applications. Moreover, not everything works as described by Apple in the beta version. Nevertheless, you can already do some tests with the current state.

Since I have developed a number of apps with CoreData so far, it was interesting for me to find out if and how SwiftDate works in a pure Swift environment.
The biggest issue I had was with updating the UI after a data change, which works automatically in SwiftUI. But by using the notification 'didChangeObjectsNotification' from CoreData, a solution was found. It is worth noting that this notification is sent twice for each data change. By the evaluation of the 'userInfo' one determines that once directly the NSManagedObjects from CoreData and the second time the packed PersistentObjects from SwiftData are transferred. Since one cannot access the PersistenObjects unfortunately, the variables of the ModelContext were used for the actualization.

