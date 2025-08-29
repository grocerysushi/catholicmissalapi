import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CatholicMissal")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Readings Storage
    func saveReadings(_ readings: DailyReadings) {
        let entity = NSEntityDescription.entity(forEntityName: "SavedReading", in: context)!
        let savedReading = NSManagedObject(entity: entity, insertInto: context)
        
        savedReading.setValue(readings.date, forKey: "date")
        savedReading.setValue(readings.source, forKey: "source")
        savedReading.setValue(Date(), forKey: "savedAt")
        
        // Store readings as JSON
        if let data = try? JSONEncoder().encode(readings) {
            savedReading.setValue(data, forKey: "readingsData")
        }
        
        save()
    }
    
    func getReadings(for date: Date) -> DailyReadings? {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "SavedReading")
        let dateString = date.toAPIDateString()
        request.predicate = NSPredicate(format: "date == %@", dateString)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let savedReading = results.first,
               let data = savedReading.value(forKey: "readingsData") as? Data,
               let readings = try? JSONDecoder().decode(DailyReadings.self, from: data) {
                return readings
            }
        } catch {
            print("Failed to fetch readings: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Prayer Storage
    func savePrayers(_ prayers: [Prayer], category: String) {
        // Remove existing prayers for this category
        let deleteRequest: NSFetchRequest<NSFetchRequest.Result> = NSFetchRequest(entityName: "SavedPrayer")
        deleteRequest.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            try context.execute(deleteRequest)
        } catch {
            print("Failed to delete existing prayers: \(error)")
        }
        
        // Save new prayers
        for prayer in prayers {
            let entity = NSEntityDescription.entity(forEntityName: "SavedPrayer", in: context)!
            let savedPrayer = NSManagedObject(entity: entity, insertInto: context)
            
            savedPrayer.setValue(prayer.name, forKey: "name")
            savedPrayer.setValue(prayer.category, forKey: "category")
            savedPrayer.setValue(prayer.text, forKey: "text")
            savedPrayer.setValue(prayer.source, forKey: "source")
            savedPrayer.setValue(prayer.language, forKey: "language")
            savedPrayer.setValue(Date(), forKey: "savedAt")
        }
        
        save()
    }
    
    func getPrayers(for category: String) -> [Prayer] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "SavedPrayer")
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NSManagedObject.objectID, ascending: true)]
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { savedPrayer in
                guard let name = savedPrayer.value(forKey: "name") as? String,
                      let category = savedPrayer.value(forKey: "category") as? String,
                      let text = savedPrayer.value(forKey: "text") as? String,
                      let source = savedPrayer.value(forKey: "source") as? String,
                      let language = savedPrayer.value(forKey: "language") as? String else {
                    return nil
                }
                
                return Prayer(
                    name: name,
                    category: category,
                    text: text,
                    source: source,
                    language: language,
                    copyrightNotice: nil
                )
            }
        } catch {
            print("Failed to fetch prayers: \(error)")
            return []
        }
    }
    
    // MARK: - Favorites
    func toggleFavorite(prayerName: String) {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FavoritePrayer")
        request.predicate = NSPredicate(format: "name == %@", prayerName)
        
        do {
            let results = try context.fetch(request)
            if let favorite = results.first {
                // Remove from favorites
                context.delete(favorite)
            } else {
                // Add to favorites
                let entity = NSEntityDescription.entity(forEntityName: "FavoritePrayer", in: context)!
                let favorite = NSManagedObject(entity: entity, insertInto: context)
                favorite.setValue(prayerName, forKey: "name")
                favorite.setValue(Date(), forKey: "addedAt")
            }
            save()
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }
    
    func isFavorite(prayerName: String) -> Bool {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FavoritePrayer")
        request.predicate = NSPredicate(format: "name == %@", prayerName)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    // MARK: - Cleanup
    func deleteOldData() {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        // Delete old readings
        let readingsRequest: NSFetchRequest<NSFetchRequest.Result> = NSFetchRequest(entityName: "SavedReading")
        readingsRequest.predicate = NSPredicate(format: "savedAt < %@", cutoffDate as NSDate)
        
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: readingsRequest)
            try context.execute(deleteRequest)
            save()
        } catch {
            print("Failed to delete old readings: \(error)")
        }
    }
}