---
layout: post
title: "Good Spirits: Syncing Data Statelessly"
date: 2018-09-03 14:56:58 -0700
summary: "Isolating cloud sync and persistent storage in an app architecture."
comments: true
categories: programming
image_header: "header.jpg"
image_path: /blog/goodspirits/
---
{% include imageheader wide=true %}

I just released a drink-tracking app called [Good Spirits][app]. The code is [available under the GPL][code].

Following my [CRDT explorations][crdt] earlier this year, I wanted to build an app on top of a persistence layer that adopted the same kinds of resilient sync patterns, even if it didn't use the actual low-level "ORDT" data structures described in the article. Having used a spreadsheet to track my drinking over the past few years, a dedicated drink tracking app seemed like the perfect little project.

The main problem I was aiming to solve was architectural. Many apps establish rather unclear relationships between the main app, the persistent store, and the cloud. Does the local database or the cloud count as the primary store? When a change comes down from the UI layer, how does it eventually get synced to the local database and to other devices, and what code keeps track of all this state? Which system does the cloud talk to? How is offline mode dealt with? How do critical errors percolate through this pipework? And what does the in-memory cache have to say about all of this? A common result is that the data layer becomes a monstrous thing that deals with persistence, sync, caching, reachability changes, UI notifications, and many other systems, all at once.

The reason for this mess, in my mind, is state. Sync often relies on systems catching every change and remembering their exact place in the whole process. If an update falls through the cracks, the data has a high chance of desyncing. Naturally, this leads to monoliths that try to claim ownership over every last bit of data.

Ergo, my goal was to get rid of as much state as possible.

<!--more-->

For the app-facing data layer, I decided to build a fairly generic interface that could encapsulate any sort of persistent store. The commands and queries were unique to my app, but the interface could be implemented by databases, in-memory stores, JSON, CloudKit, and others. For sync purposes, I wanted to be able to treat my local database and cloud storage as one and the same.

```swift
public protocol DataAccessProtocol
{
    func initialize(_ block: @escaping (Error?)->Void)
    func readTransaction(_ block: @escaping (_ data: DataProtocol)->())
    func readWriteTransaction(_ block: @escaping (_ data: DataWriteProtocol)->())
}

public protocol DataAccessProtocolImmediate
{
    func initialize() throws
    func readTransaction<T>(_ block: @escaping (_ data: DataProtocolImmediate) throws -> T) rethrows -> T
    func readWriteTransaction<T>(_ block: @escaping (_ data: DataWriteProtocolImmediate) throws -> T) rethrows -> T
}

public protocol DataProtocol
{
    func lamportTimestamp(withCompletionBlock block: @escaping (MaybeError<DataLayer.Time>)->())
    func vectorTimestamp(withCompletionBlock block: @escaping (MaybeError<VectorClock>)->())
    func operationLog(afterTimestamp timestamp: VectorClock, withCompletionBlock block: @escaping (MaybeError<DataLayer.OperationLog>)->())
    func nextOperationIndex(forSite site: DataLayer.SiteID, withCompletionBlock block: @escaping (MaybeError<DataLayer.Index>)->())
    func data(forID id: GlobalID, withCompletionBlock block: @escaping (MaybeError<DataModel?>)->())
    func data(fromIncludingDate from: Date, toExcludingDate to: Date, afterTimestamp: VectorClock?, withCompletionBlock block: @escaping (MaybeError<([DataModel],VectorClock)>)->())
    // plus some others
}

public protocol DataProtocolImmediate
{
    func lamportTimestamp() throws -> DataLayer.Time
    func vectorTimestamp() throws -> VectorClock
    func operationLog(afterTimestamp timestamp: VectorClock) throws -> DataLayer.OperationLog
    func nextOperationIndex(forSite site: DataLayer.SiteID) throws -> DataLayer.Index
    func data(forID id: GlobalID) throws -> DataModel?
    func data(fromIncludingDate from: Date, toExcludingDate to: Date, afterTimestamp: VectorClock?) throws -> ([DataModel],VectorClock)
    // plus some others
}

public protocol DataWriteProtocol: DataProtocol
{
    func commit(data: [DataModel], withSite: DataLayer.SiteID, completionBlock block: @escaping (MaybeError<[GlobalID]>)->())
    func sync(data: Set<DataModel>, withOperationLog: DataLayer.OperationLog, completionBlock block: @escaping (Error?)->())
    // plus some others
}

public protocol DataWriteProtocolImmediate: DataProtocolImmediate
{
    func commit(data: [DataModel], withSite: DataLayer.SiteID) throws -> [GlobalID]
    func sync(data: Set<DataModel>, withOperationLog: DataLayer.OperationLog) throws
    // plus some others
}
```

GRDB inspired the synchronous `try` calls in the `Immediate` variants, but cloud services (and some database calls) still demanded asynchronous support. Fortunately, you didn't need to implement both at once: if you had one, you could fill in the other [by way of protocol extensions][protocol].

For the actual database framework, I looked into Realm, YapDatabase, FMDB (and FCModel), SQLite.swift, CoreData, and GRDB. By far, GRDB was the best of the bunch. It took the best bits of YapDatabase and FCModel, pared them down into a simple library, made the whole thing very Swifty, and wrapped it all up in an incredibly intuitive interface. Working with this framework was a complete delight, even given that I was writing SQLite commands by hand in many places. It's exactly the way SQLite ought to work in a modern language.

My data needs were very simple. The only user-generated unit of data was the check-in, which was just a bunch of basic drink properties such as ABV, volume, price, and so on, as well as a bit of metadata. (There were no relationships between check-ins.) Consequently, I decided on a two-table approach. The first table contained the check-ins themselves. Each check-in had a GUID in the form of a site-specific UUID together with an operation index[^opindex]. (This pair became the primary key for the table.) Most of the rest of the properties came in pairs: an actual value and its Lamport timestamp. Each row additionally sported a `deleted` flag in lieu of native SQLite deletions. This would ordinarily require garbage collection to deal with, but drink check-ins rarely needed to be deleted and had an upper bound of about 100,000 over the course of several years (based on to top Untappd users) so I didn't bother.

[^opindex]: An operation index, or sequence number, is simply a counter that increases by one with every new operation performed by a site. Each site's index starts at zero. There must be no gaps.

The second table contained a simple log of events. Each row was identified by a site-specific UUID together with an operation index, and contained a foreign key reference to a check-in GUID from the data table. No further information about the event was provided: an entry could indicate a check-in creation, deletion, or mutation. A new row was added at the same time as any change to the data table. This table was ordered first by site UUID, then by operation index.

{% include image name="schema.svg" width="50rem" %}

The point of this schema was to enable conflict-free merging and delta-updates. The former feature was guaranteed by the Lamport timestamps stored with each property. On check-in creation, each property was initialized with the Lamport timestamp of its origin site, provided by taking the max of every Lamport column. On merge, if an inbound property had a higher Lamport timestamp than that of the incumbent property, then the new value replaced the old value. (In other words: last-writer-wins CRDT logic.) The latter feature, meanwhile, was granted by the operation log. Given a [version vector][vvec] in the form of one or more site UUID and operation index pairs, the log table could efficiently return a GUID set of every check-in touched after that particular timestamp. In a conventional event sourcing system, you'd need to do some assembly work at this point to actually get the data you want, since any delta patch was fundamentally a sequence of actions. In our architecture, every check-in was effectively a CRDT, so a delta patch didn't have to be anything more than a set of check-in rows. Just pull the GUIDs from the data table and you're done!

(Incidentally, this scheme happened to be a perfect fit for SQLite, since I could validate many of my constraints within the database itself, and also efficiently run queries for Lamport timestamps, version vectors, and changesets using table indexes.)

I intended for all this to lead to easy, stateless CloudKit sync. Instead of enforcing tight coupling between the persistence and cloud layers, I would have a "sync whenever" system that was guaranteed to succeed whenever it happened to run. Both the local SQLite database and CloudKit would keep around the same data and log tables. On sync, the local store would request the version vector from the CloudKit log table. Based on this timestamp, the local store would know which local check-ins needed to be uploaded, and could additionally request any check-ins from the server that were needed to complete the local database. Merge between check-ins was eventually consistent and conflict-free, and nothing was ever deleted, so you'd never need to do anything more complicated than send sets of check-ins and event log entries around. Sync would become completely stateless!

Unfortunately, I didn't actually get around to implementing CloudKit. The logic was sound, and I even built some unit tests for inter-database sync, but there was just too much to do before my release deadline. Nonetheless, I quickly found that this architecture was a boon even for strictly local development.

In many app architectures, the data layer has to communicate directly with the view controllers. If there's a change in the database, the precise changeset has to be sent to any interested parties, whether by notification, delegate callback, KVO or something else. Alternatively, the view controller has to re-initialize its views and caches from scratch whenever a change happens. In my architecture, any view controller or subsystem that relies on the persistent store need only keep around a version vector (hereafter "token") from its last refresh. The data layer doesn't need to know which updates to send where: it simply dispatches a global, generic "something changed" notification on any alteration. Upon receiving this notification, the controllers ask the data layer for any check-ins that have been touched following their last token, then update their caches and store the new token sent along with those updates.

The result of all this is that the data layer exists in complete, wonderful isolation from both the UI and network layers. It doesn't have any plug-ins, extensions, or hooks into the rest of the system. Instead, it deals entirely with its own problem domain—persistence—and vends out just enough data to allow interested parties to keep *themselves* in sync. As with CvRDTs, the work of sync is left to the edges, ensuring the robustness of the system.

Untappd integration turned out to be a cinch with this approach. (Untappd is a very popular beer social network that also features check-ins, and I wanted Untappd check-ins to automatically appear in the app once a user's account was linked. Upon receiving an Untappd check-in, the user would either fill it out with volume and price information and approve it, or reject it.) Still thinking in terms of CloudKit, I was worried at first about the problem of different, disconnected devices receiving the same check-in from Untappd and creating duplicate entries in the database. How would these conflicts be resolved? Moreover, how could we prevent the same check-in from appearing on one device after being dismissed by another?

Fortunately, after thinking about it for a bit, I realized that all my Untappd functionality would overlay perfectly on top of my existing check-in logic. Each Untappd check-in had its own integer GUID provided by the server, so I simply defined a local Untappd check-in in my database to be one that had an arbitrary, pre-determined UUID for the site ID and the Untappd GUID for the operation index. This scheme ensured that local Untappd check-ins had the same GUID on every device. (While this approach didn't strictly follow the rules of operation indexes, since there could be gaps between operation indexes in the operation log, it didn't interfere with any of my logic and could be special cased if needed.) Upon receiving a new check-in from Untappd, a row in the local database and an event log entry were immediately created. An extra `untapd_approved` column was added to my check-in schema which, when set on an Untappd row, indicated that the row was promoted to a regular check-in. Rejections, meanwhile, were simply mapped to existing deletes.

In effect, Untappd check-ins were treated as though they were created by a foreign user, then updated by the local user. This allowed the Untappd subsystem to operate completely independently from the data layer, without having to worry about sync at all. Everything was still guaranteed to converge.

I was also able to implement HealthKit very easily with this architecture, though this feature, unfortunately, didn't make it into the final release. The `HKMetadataKeySyncIdentifier` and `HKMetadataKeySyncVersion` keys could be used to automatically keep HealthKit entries updated, so I simply populated them with the GUIDs and Lamport timestamps of the associated rows. Just like in my view controllers, the current HealthKit baseline was stored as a version vector token. On a sync pass, any operations following this token were pulled from the database and sent off to HealthKit (or deleted). The process was entirely idempotent.

Although I didn't have a lot of time to refine this system, I believe I succeeded in my architectural goals. My persistent store exists in perfect isolation from the rest of the app. You could tear out the database, replace it with a JSON serializer/deserializer, and still have everything work just fine. If I had a cloud component, I could schedule its sync based on network conditions, user activity, or any other attributes, without ever having to worry about piling-up state, merge conflicts, or staleness. I'd also be able to easily sync between multiple remote stores at once: other servers, other apps, or even peer-to-peer. The data structure tying all this together is the version vector token, which perfectly encapsulates sync state. Any subsystem that relies on sending or receiving exact sets of changes following a certain timestamp only needs to keep around a simple token, then pass along that token to any database calls. Eventual consistency turns any set of check-ins into a de facto delta patch. There are no volatile changeset notifications that break the system if missed: a dropped "something changed" notification only delays convergence. And of course, the whole thing works perfectly offline.

Not an architecture for every app, but a great architecture for this particular one!

[app]: https://itunes.apple.com/us/app/good-spirits/id1434237439?mt=8&ref=blog
[code]: https://github.com/archagon/good-spirits
[crdt]: {% post_url 2018-03-24-data-laced-with-history %}
[protocol]: https://github.com/archagon/good-spirits/blob/22983beed78844972e219d4f5c20e9b97a804843/Modules/DBComparison/DataLayer/Data_Default.swift
[vvec]: https://en.wikipedia.org/wiki/Version_vector