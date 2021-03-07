import Foundation
import CoreData

protocol StorageServiceProtocol {
    func save(url: URL, search: String, occurrences: UInt)
    var pages: [Page] { get }
}

final class StorageService {

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Crawler")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: StorageServiceProtocol

extension StorageService: StorageServiceProtocol {
    var pages: [Page] {
        get {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Page")
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            do {
                if let result = try persistentContainer.viewContext.fetch(request) as? [Page] {
                    return result
                }
            } catch { }
            return [Page]()
        }
    }

    func save(url: URL, search: String, occurrences: UInt) {
        let page = Page(context: persistentContainer.viewContext)
        page.date = Date()
        page.url = url.absoluteString
        page.searchtext = search
        page.count = Int64(occurrences)
        saveContext()
    }
}
