
import CoreData

struct CacheUnit {
	let data: Data
	let code: Int64
	let etag: String
	let headers: Data
	let lastFetched: Date

	var actualHeaders: [AnyHashable : Any] {
		return NSKeyedUnarchiver.unarchiveObject(with: headers) as! [AnyHashable : Any]
	}

	var parsedData: Any? {
		return try? JSONSerialization.jsonObject(with: data, options: [])
	}
}

final class CacheEntry: NSManagedObject {

	@NSManaged var etag: String
	@NSManaged var code: Int64
	@NSManaged var data: Data
	@NSManaged var lastTouched: Date
	@NSManaged var lastFetched: Date
	@NSManaged var key: String
	@NSManaged var headers: Data

	var cacheUnit: CacheUnit {
		return CacheUnit(data: data, code: code, etag: etag, headers: headers, lastFetched: lastFetched)
	}

	class func setEntry(key: String, code: Int64, etag: String, data: Data, headers: [AnyHashable : Any]) {
		var e = entry(for: key)
		if e == nil {
			e = NSEntityDescription.insertNewObject(forEntityName: "CacheEntry", into: DataManager.main) as? CacheEntry
			e!.key = key
		}
		e!.code = code
		e!.data = data
		e!.etag = etag
		e!.headers = NSKeyedArchiver.archivedData(withRootObject: headers)
		e!.lastFetched = Date()
		e!.lastTouched = Date()
	}

	class func entry(for key: String) -> CacheEntry? {
		let f = NSFetchRequest<CacheEntry>(entityName: "CacheEntry")
		f.fetchLimit = 1
		f.predicate = NSPredicate(format: "key == %@", key)
		f.returnsObjectsAsFaults = false
		f.includesSubentities = false
		if let e = try! DataManager.main.fetch(f).first {
			e.lastTouched = Date()
			return e
		} else {
			return nil
		}
	}

	class func cleanOldEntries(in moc: NSManagedObjectContext) {
		let f = NSFetchRequest<CacheEntry>(entityName: "CacheEntry")
		f.returnsObjectsAsFaults = true
		f.includesSubentities = false
		let date = Date(timeIntervalSinceNow: -3600.0*24.0*7.0) as CVarArg // week-old
		f.predicate = NSPredicate(format: "lastTouched < %@", date)
		for e in try! moc.fetch(f) {
			DLog("Expiring unused cache entry for key %@", e.key)
			moc.delete(e)
		}
	}

	class func markFetched(for key: String) {
		if let e = entry(for: key) {
			e.lastFetched = Date()
		}
	}
}
