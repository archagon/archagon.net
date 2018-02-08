---
layout: post
title: "Operational Thinking: Mergeable, Historied, and Coordination-Free CvRDT Documents"
date: 2017-09-30 18:02:53 +0300
comments: true
categories: programming
---

**WARNING: VERY ROUGH DRAFT! Please do not publish anywhere.**

# Introduction

(Sorry about the length! At some point in the distant past, this was supposed to be a short blog post. If you like, you can skip straight to the [demo section][sec-demo] which will get to the point faster than anything else.)

Embarrassingly, most my app development to date has been confined to local devices. Programmers like to gloat about the stupendous mental castles they build of their circutous, multi-level architectures, but not me. In truth, networks leave me quite perplexed. I start thinking about data serializing to bits, servers performing secret handshakes, distant operations forming into an ordered history, merge conflicts pushing into app-space and starting the whole process over again — and it all just turns to mush in my head. For peace of mind, my code needs to be *locally provable*, and this means things like idempotent functions, immediate mode rendering, contiguous structures in memory, and dependency injection. Networks, unfortunately, throw a giant wrench in the works.

A few months ago, after realizing that most of my ideas for future document-based apps would probably require CloudKit for sync and collaboration, I decided to finally take a stab at the problem. Granted, there were tons of frameworks that purported to do the hard work of data model replication for me, but I didn't want to black-box the most important part of my code. My gut told me that there had to be some arcane bit of foundational knowledge — some *gold nugget of truth* — that would allow me to network my documents in a more refined and functional way, all without the edge-case-peppered spaghetti of conventional network architectures. Instead of downloading a Github framework and [smacking the build button](http://amzn.to/2iigBOI), I wanted to develop a base set of skills that would allow me to easily network *any* document-based app in the future, even if I was starting from scratch.

<!--more-->

The first order of business was to devise a wishlist for my fantastical system:

* Most obviously, users should be able to edit their documents immediately, without even touching the network. (In other words, the system should only require *optimistic concurrency*.)
* Sync should happen in the background, entirely separate from the main application code, and any remote changes should be seamlessly integrated in real-time. (Put another way, sync should be treated as a kind of progressive enchancement.)
* Merge should always be automatic, even for concurrent edits. The user should never be faced with a "pick the correct revision" dialog box.
* A user should be able to work on their document offline for an indefinite period of time without accruing "sync debt". (Meaning that if, for example, sync is accomplished by way of an operation log, performance should not suffer even if a user spends a month offline and then sends all their hundreds of changes at once.) 
* Secondary data structures and state should be minimized. Most of the extra information required for sync should be stored in the same place as the document, and moving the document to a new device should not break sync. (No out-of-band metadata or caches!)
* Network back-and-forth should be condensed down to a bare minimum, and rollbacks and re-syncs should practically never happen. To the greatest possible degree, network communication should be stateless and dumb.
* If at all possible, the system should require no extra servers. Apple's CloudKit was alluringly free and required no server management on my part, but it could only function as a simple data store. If I could make do with just that, I'd save myself tons of money, effort, and stress.
* To top it all off, my chosen technique had to pass the **PhD Test**. That is to say, one shouldn't need a PhD to understand and implement the chosen approach for custom data models.

To be clear, my focus with this challenge was ultimately on data structures and document formats, not all-encompassing systems. There were, for instance, plenty of distributed databases and related frameworks to take inspiration from, but I'm a bit old school when it comes to sync. In my view, content-producing applications should store their data in self-contained files, freely readable and editable by other applications supporting the format. We've moved away from this approach in many classes of apps (especially on mobile), but I believe that having a standard unit of data exchange is crucial to fostering a truly decentralized, expansive, and open computing environment. It's also much easier to make your code functional when you're simply dealing with data and algorithms instead of stateful monoliths such as databases. Files are prolific, usable over networks and USB sticks alike, and any developer can write software to interface with them. Good luck doing that with an SQL file!

After musing over my wishlist, it occurred to me that the network problems I was dealing with — cloud sync, editing across multiple devices, collaborative editing, offline support, and reconciliation of distant or conflicting revisions — were all really different facets the same problem. Namely: how do we design a system such that any two revisions of the same document could always be merged deterministically and without requiring user intervention? Was it possible to consistently design a coordination-free, 100% auto-merging document format? In hope of uncovering some prior art, I started by looking at the proven leader in the field, Google Docs. Venturing down the deep rabbit hole of [real-time collaborative editing](https://en.wikipedia.org/wiki/Collaborative_real-time_editor) techniques, I discovered that many of the problems I faced fell under the umbrella of [eventual consistency](https://en.wikipedia.org/wiki/Eventual_consistency). Unlike the more conventional strong consistency model, where all clients receive changes in identical order and rely on locking to some degree, eventual consistency allows clients to individually diverge and then arrive at a final, consistent result once each update has been received. (Or, in a word, when the network is *quiescent*.)

There were a number of tantalizing techniques to investigate in this field, and I kept several questions in mind going forward. First, could a given technique be generalized to arbitrary data models? Second, did the technique pass the PhD Test? And third, could the technique be utilized in a situation with smart clients and dumb servers?

The reason for that last question was CloudKit Sharing, a framework introduced in iOS 10. For the most part, this framework functioned as a superset of regular CloudKit, requiring only minor code changes to enable real-time collaboration in an app. A developer didn't even have to worry about connecting users or showing custom UI: Apple did most of the hard work in the background and leveraged standard system dialogs to make it work. But almost two years later, [on the order of no one](https://github.com/search?l=Swift&q=UICloudSharingController&type=Code&utf8=✓) seemed to be using it. Why was this? After all, most Apple APIs tended to be readily adopted, especially when they allowed the developer to expand into system areas which were normally out of bounds. 

My guess was that CloudKit Sharing forced the issue of real-time collaboration over a relatively dumb channel, which was a problem outside the purview of conventional sync approaches. CloudKit allowed developers to easily store, retrieve, and listen for new data, but not much else besides. Concurrent editing made this a problem. Unlike in the single-user/multi-device case, you couldn't just pop up a merge dialog every time somebody simultaneously changed your document. But you also couldn't resolve conflicts on the server side, since CloudKit did not permit developers to run custom code on their end. The only remaining option seemed to be some sort of ugly, heuristic auto-merge or data-dropping last-write-wins, neither of which was palatable by modern standards. Real-time collaboration along the lines of Google Docs seemed to be impossible using this system! But was it really?

I realized that this was my prize to be won — that this issue and my problem domain were quite synergetic. If I could figure out a way to develop auto-merging documents, I'd be able to implement real-time collaboration over CloudKit and reap the benefits of free service and low-level OS support. So this was my ultimate research goal: a collaborative text editor demo syncing entirely over Apple's servers. (And here's a spoiler: [it worked!][sec-demo]) 

<div class="toc">

<div class="toc-header">

<p>Table of Contents</p>

</div>

<div class="toc-links">

<ul>

<li><a href="#convergence-techniques-a-high-level-overview">Convergence Techniques: A High-Level Overview</a>

<ul>

<li><a href="#operational-transformation-ot">Operational Transformation (OT)</a></li>

<li><a href="#conflict-free-replicated-data-types-crdts">Conflict-Free Replicated Data Types (CRDTs)</a></li>

<li><a href="#differential-synchronization">Differential Synchronization</a></li>

<li><a href="#finding-the-best-approach">Finding the Best Approach</a></li>

</ul>

</li>

<li><a href="#causal-trees-ct">Causal Trees (CT)</a></li>

<li><a href="#demo">Demo</a></li>

<li><a href="#the-gold-nugget-of-truth-operation-based-crdts">The Gold Nugget of Truth: Operation-Base CRDTs</a>

<ul>

<li><a href="#the-rdt-pipeline">The RDT Pipeline</a></li>

<li><a href="#garbage-collection">Garbage Collection</a></li>

<li><a href="#rdt-design--implementation">RDT Design & Implementation</a></li>

</ul>

</li>

<li><a href="#causal-trees-in-depth">Causal Trees In Depth</a>

<ul>

<li><a href="#implementation-details">Implementation Details</a></li>

<li><a href="#representing-non-string-objects">Representing Non-String Objects</a></li>

<li><a href="#performance">Performance</a></li>

<li><a href="#missing-features--future-improvements">Missing Features & Future Improvements</a></li>

</ul>

</li>

<li><a href="#conclusion">Conclusion</a></li>

<li><a href="#references">References</a></li>

</ul>

</div>

</div>

# Convergence Techniques: A High-Level Overview

There are a few basic terms that are critical to understanding eventual consistency. The first is **causality**. An operation is *caused* by another operation when it directly modifies or otherwise involves the results of that operation. (In other words, when executed, the causing operation must always come first.) However, we can't always determine direct causality in a general way, so algorithms often assume a causal link between operations if the site generating the newer operation has seen the older operation on creation. This "soft" causality can be determined using a variety of schemes. The simplest is a [Lamport timestamp][lamport], which requires that every new operation have a higher Lamport timestamp than every other known operation, including any remote operations received. (Note that this approach is stateless. As long as each operation retains its Lamport timestamp, you don't need any extra data in the system to determine causality.) Although there are eventual consistency schemes that can receive operations in any order, most algorithms rely on operations arriving at each site in their **causal order** (e.g. "Insert A" necessarily arriving before "Delete A"). When discussing convergence schemes, we can often assume causal order since it can be enforced on the transport layer. If two operations are not causal — if they were created simultaneously on different sites without knowledge of each other — they are said to be **concurrent**. An operation log in causal order can be described as having a **partial order**, since concurrent operations might be in different positions on different clients. If the log is guaranteed to be identical on all clients, it has a **total order**. Most of the hard work in eventual consistency involves reconciling and ordering these concurrent operations. Generally speaking, concurrent operations have to be made to **commute**, or have the same effect on the data regardless of their order of arrival. This can be done in a variety of ways: defining the operations to be commutative in the first place, transforming operations depending on their order of arrival, reordering operations and replaying history, and more.

Now, there are two competing approaches in eventual consistency state-of–the-art, both tagged with rather unappetizing initialisms: [Operational Transformation][ot] (OT) and [Conflict-Free Replicated Data Types][crdt] (CRDTs). Fundamentally, these approaches tackle the same problem. Given an object that has been edited by an arbitrary number of connected devices, how do we coalesce and apply their changes in a consistent way, even when those changes might be concurrent or arrive out of creation order? And, moreover, what do we do if a user goes offline for a long time, or if the network is unstable, or even if we're in a peer-to-peer environment with no single source of truth?

## Operational Transformation (OT)

[Operational Transformation][ot] is the proven leader in the field, notably used by Google Docs and (now Apache) Wave as well as Etherpad and ShareJS. Unfortunately, it is only proven insofar as you have a company with billions of dollars and hundreds of PhDs at hand, as the problem is *hard*. With OT, each user has their own copy of the data, and each atomic mutation is called an **operation**. (For example, "Insert A at Index 2" or "Delete Index 3".) Whenever a user mutates their data, they send their new operation to all their peers, often in practice through a central server. OT makes the assumption that the data is a black box and that incoming operations will be applied directly on top without the possibility of a rebase operation. Consequently, the only way to ensure that concurrent operations will commute in their effect is to **transform** them depending on their order.

Let's say Peer A inserts a character in a string at position 3, while Peer B simultaneously deletes a character at position 2. If Peer C, who has the original state of the string, receives A's edit before B's, everything is peachy keen. If B's edit arrives first, however, A's insertion will be in the wrong spot. A's insertion position will therefore have to be transformed by subtracting the length of B's edit. This is fine for the simple case of two switched edits, but it gets a whole lot more complicated when you start dealing with more than a single pair of concurrent changes. (An algorithm that deals with this case — and thus, [provably][cp2], with any conceivable case — is said to be have the "CP2/TP2" property rather than the pairwise "CP1/TP1" property. Yikes, where are professional namers when you need them?) In fact, the majority of published algorithms for string OT actually have subtle bugs in certain edge cases (such as the so-called ["dOPT puzzle"][dopt]), meaning that they aren't strictly convergent without occasional futzing and re-syncing by way of a central server. And while the idea that you can treat your model objects strictly in terms of operations is elegant in its premise, the fact that adding a new operation to the schema requires figuring out its interactions with *every existing operation* is nearly impossible to grapple with.

[dopt]: http://www3.ntu.edu.sg/home/czsun/projects/otfaq/#_Toc321146192

## Conflict-Free Replicated Data Types (CRDTs)

[Conflict-Free Replicated Data Types][crdt] are the new hotness in the field. In contrast to OT, the CRDT approach considers sync in terms of the underlying data structures, not sequences of operations. A CRDT, at a high level, is a type of object that can be merged with any objects of the same type, in arbitrary order, to produce an identical union object. CRDT merge must be associative, commutative, and idempotent, and the resulting CRDT of each mutation or merge must be "greater" than than all its inputs. (Mathematically, this flow is said to form a *monotonic semilattice*.) As long as each connected peer eventually receives the updates of every other peer, the results will provably converge — even if one peer happens to be a month behind. This might sound like a tall order, but you're already aware of several simple CRDTs. For example, insert-only sets: no matter how you permute the merge order of any insert-set collection, you'll still end up with the same union set in the end. Really, the concept is rather intuitive!

Of course, simple sets aren't enough to represent arbitrary data, and much of CRDT research is dedicated to finding new and improved ways of implementing sequence CRDTs, often under the guise of string editing. Algorithms vary, but this is often accomplished by giving each individual letter its own unique identifier, then giving each letter a reference to its intended neighbor instead of dealing with indices. On deletion, letters are usually replaced with *tombstones* (placeholders), allowing an operation that deletes a character and another that references it to concurrently execute. This does tend to mean that sequence CRDTs perpetually grow in proportion to the number of deleted characters in a document, although there are various ways of dealing with this accumulated garbage.

One last thing to note is that there are actually two kinds of CRDTs: CmRDTs and CvRDTs. (Seriously, there's got to be a better way to name these things...) CmRDTs, or operation-based CRDTs, only require peers to send each other their changes[^op-crdt], but place some constraints on the transport layer. (For instance, exactly-once and/or causal delivery, depending on the CmRDT in question.) With CvRDTs, or state-based CRDTs, peers send each other their full data objects and then merge them locally, placing no constraints on the transport layer but taking up more bandwidth and possibly CPU time. Both types of CRDT are equivalent and can be converted to either form.

[^op-crdt]: This might sound a lot like Operational Transformation! Superficially, the approach is very similar, but the operations don't have to be transformed since the data structures already have commutativity built in. "Insert B to the Right of A" does not change its meaning even in the presence of concurrent operations, so long as A leaves a tombstone once it's been deleted. Again, we're focused on the data structures here. Their design comes first, and all the other parts follow.

## Differential Synchronization

There's actually one more technique that's worth discussing, and it's a bit of an outlier. This is Neil Faser's [Differential Synchronization][diffsync]. Used in an earlier version of Google Docs before their flavor of OT was implemented, Differential Sync uses [contextual diffing][context-diff] between local revisions of documents to generate streams of frequent, tiny edits between peers. If there's a conflict, the receiving peer uses [fuzzy patching][fuzzy-patch] to apply the incoming changes as best as possible, then contextually diffs the resulting document with a reproduced copy of the sender's document (using a cached "shadow copy" of the last seen version) and sends the new changes back. This establishes a sort of incremental sync loop. Eventually, all peers converge on a final, stable document state. Unlike with OT and CRDTs, the end result is not mathematically defined, but instead relies on the organic behavior of the fuzzy patching algorithm when faced with diffs of varying contexts and sizes.

[fuzzy-patch]: https://neil.fraser.name/writing/patch/
[context-diff]: https://neil.fraser.name/writing/diff/

## Finding the Best Approach

Going into this problem, my first urge was to adopt Differential Sync. One might complain that this algorithm has too many subjective bits for production use, but that's exactly what appealed to me about it. Merge is a complicated process that often relies on heuristics entirely separate from the data format. A human would merge two list documents and two prose documents very differently, even though they might both be represented as text. With Differential Sync, all this complex logic is contained within the singular patch function. The implementation of the data format could be refactored as needed, and the patch function could be tweaked and improved over time, and neither system would have to know about changes to the other. It also means that the documents in their original form could be preserved in their entirety server-side, synergizing nicely with Dropbox-style cloud backup. It felt like the perfect dividing line of abstraction.

But studying Differential Sync further, I realized that a number of details made it a non-starter. First, though the approach seems simple on the surface, its true complexity is concealed by the implementation of diff and patch. This class of algorithm works well for strings, but you basically need to be a seasoned algorithms expert to design one for a new data type. (Worse: the inherent fuzziness depends on non-objective metrics, so you might only figure out the effectiveness of new diff and patch algorithms after prolonged use and testing, not through formal analysis.) Second, diffing and patching as they currently exist are really meant for loosely-structured data formats such as strings and images. Barring conversion to text-based intermediary formats, tightly structured data would be very difficult to diff and patch while maintaining consistency. Next, there are some issues with using Differential Sync in an offline-first environment. Clients have to store their entire diff history while offline, and then, on reconnection, send the whole batch to their peers for a very expensive merge. Worse yet, assuming that other sites had been editing away in the meantime, distantly-divergent versions would very likely fail to merge on account of out-of-date diff context information and then lose much of the data for the reconnected peer. Finally, Differential Sync only allows one packet at a time to be in flight between two peers. If there are network issues, the whole thing grinds to a halt.

Begrudgingly, I had to abandon the elegance of Differential Sync and decide between the two deterministic approaches. CRDTs raised some troubling questions, including the impact of per-letter metadata and the necessity of tombstones in most sequence CRDTs. You could end up with a file that looked tiny (or even empty) but was in fact enormous under the hood. However, OT was a no-go right from the start. One, the event-based system would have been untenable to implement on top of a simple database like CloudKit. You really needed active servers or peer-to-peer connections for that. And two, I discovered that the few known sequence OT algorithms guaranteed to converge in all cases — the ones that had the coveted CP2/TP2 property — ended up relying on tombstones anyway! (If you're interested, Raph Levien touches on this curious overlap [in this article][convergence].) So it didn't really matter which choice I made. If I wanted the resiliency of a provably convergent system, I had to deal with metadata-laden data structures that left some trace of their deleted elements.

With CRDTs on my mind, I saw before me the promise of a mythical "golden file". With a document format based on CRDTs, issues of network synchronization and coordination fell completely out of the way. The system would be completely functional. It would work without quirks in offline mode. On syncing, it would always be able to merge with other revisions. It would be topology-agnostic to such a degree that one could use it in a completely decentralized peer-to-peer environment; between phone and laptop via Bluetooth or ad-hoc Wi-Fi; between two applications simultaneously editing the same local file; or plain old syncing with a central database. All at the same time! I just needed to figure out if I could use these things in a performant and space-efficient way for arbitrary data models — all while passing that dastardly PhD Test.

<fig — semilattice of files diagram>

My next step was to sift through the academic literature on CRDTs. There was a group of usual suspects for the hard case of sequence (text) CRDTs: [WOOT][woot], [Treedoc][treedoc], [Logoot][logoot]/[LSEQ][lseq], and [RGA][rga]. WOOT is the progenitor of the genre and makes each character in a string reference its adjacent neighbors on both sides. Recent analysis has shown this to be inefficient compared to newer approaches. Treedoc has a similar early-adoptor performance penalty and additionally requires coordination for its garbage collection — a no-go for true decentralization. Logoot (which is optimized further by LSEQ) curiously avoids tombstones by treating each sequence item as a unique point along a dense (infinitely-divisible) number line, and in exchange adopts item identifiers (similar to bignums) which have unbounded growth. Unfortunately, it has a problem with [interleaved text on concurrent edits](https://stackoverflow.com/questions/45722742/logoot-crdt-interleaving-of-data-on-concurrent-edits-to-the-same-spot). RGA makes each character implicitly reference its intended neighbor to the left and uses a hash table to make character lookup efficient. It also features an additional update operation alongside the usual insert and delete. This approach often comes out ahead in benchmark comparisons though the paper is annoyingly dense in theory. I also found a couple of recent, non-academic CRDT designs such as [Y.js][yjs] and the [Xi CRDT][xi], both of which brought something new to the table but felt rather convoluted in comparison to RGA. In almost all these cases, conflicts between concurrent changes were resolved by way of a creator UUID plus a logical timestamp per character. Sometimes, they were discarded when an operation was applied; sometimes, they were persisted for each character.

<fig — different crdt types>

Reading the literature was highly educational, and I now had a good intuition about the behavior of convergent sequence CRDTs. But I just couldn't find very much in common between the disparate approaches. Each one brought its own proofs, methods, optimizations, conflict resolution methods, and garbage collection schemes to the table. Many of the papers blurred the line between theory and implementation, making it even harder to suss out underlying principles. I felt confident using these algorithms for convergent arrays, but I wasn't quite sure how to build my own custom, convergent data structures using the same principles.

Finally, I discovered the one key CRDT that made things clear for me.

# Causal Trees (CT)

A a state-based CvRDT, on a high level, can be viewed as a data blob along with a (commutative, associative, idempotent) merge function that is always able to generate a further-ahead third blob from any given two. An operation-based CmRDT, meanwhile, can be viewed as a data blob together with a stream of immutable, commutative-in-effect (and perhaps causally-ordered) operations which are continuously applied on top.

Say you're designing a convergent sequence CvRDT from scratch. Instead of picking an existing sequence CRDT, you've been wickedly tempted by the operational approach of CmRDTs! You wonder if it's possible to take those CmRDT operations and fold them into an efficient CvRDT data structure, giving you the best of both worlds: an eminently-mergable "golden file", plus the flexibility and expressiveness of defining your model in terms of atomic operations.

Here's an example concurrent string mutation, just to have some data to work with.

<img src="../images/blog/causal-trees/network-chart.svg" width="500">

The small numbers over the letters are [Lamport timestamps][lamport]. Site 1 types "CMD", sends its changes to Site 2 and Site 3, then resumes its editing. Sites 2 and 3 then make their own changes and send them back to Site 1 for the final merge. The result, "CTRLALTDEL", is the most intuitive merge we might expect: insertions and deletions all persist, runs of characters don't split up, and most recent changes come first.

First idea: just take the standard set of array operations ("Insert 'A' at Index 0", "Delete Index 3"), turn each operation into its own struct, stick the structs into an array in their creation order, and read them back to reconstruct the original array as needed. (In other words, the array of operation structs becomes your CvRDT data structure.) This won't be convergent by default: there needs to be some way to establish a total order between operations when merging two of these operational arrays. This can simply be done by giving each operation a globally-unique ID in the form of an owner UUID[^uuid] plus a Lamport timestamp. With this scheme, no two operations can ever have the same ID: operations from the same owner will have different timestamps, while operations from different owners will have different UUIDs. The Lamport timestamp, together with the UUID for tie-breaking, also lets us put the operations into a sensible and causally-consistent total order. Now, when an array featuring new operations arrives from a remote peer, the merge is as simple as iterating through both arrays and shifting any new operations to their proper spots. (In other words, a merge sort.)

[^uuid]: Note that UUIDs with the right bit-length don't really need coordination to ensure uniqueness. If your UUID is long enough — 128 bits, let's say — randomly finding two UUIDs that collide would require generating a billion UUIDs every second for decades. Most applications probably don't need to worry about this possibility. If they do, UUIDs might need to be generated and agreed upon out-of-band.

<img src="../images/blog/causal-trees/indexed.svg">

Success: it's an operation-based, fully-convergent CvRDT! Well, sort of. There are two major issues here. First, reconstructing the original array by processing the full operational array has *O*(*n*<sup>2</sup>) complexity[^complexity], and it has to happen on every key press to boot. Completely untenable! Second, intent is completely clobbered. Reading the operations back, we get something along the lines of "CTRLDATLEL" (with a bit of handwaving when it comes to inserts past the array bounds). Just because a data structure converges doesn't mean it makes a lick of sense! As shown in the earlier OT section, concurrent index-based operations can be made to miss their intended characters depending on the order. (Recall that this is the problem OT solves by transforming the operations, but here our operations are immutable.) In a sense, this is because the operations are specified incorrectly. They make an assumption that doesn't get encoded in the operations themselves — that an index can always uniquely identify a character — and thus lose the commutativity of their intent when this turns out not to be the case. 

[^complexity]: Throughout the rest of this article, the *n* will generally refer to the total number of operations in a data structure.

OK, so the first step is to fix the intent problem. Fundamentally, "Insert A at Index 0" isn't *really* what the user wants to do. People don't think in terms of indices. They want to insert a character at the cursor position, which is perceived as being between two letters — or more simply, to the immediate right of a single letter. We can encode this by switching our operations to the format "Insert A<sup>id</sup> After B<sup>id</sup>", where each letter in the array is uniquely identified. Given causal order and assuming that deleted characters persist as tombstones, the intent of the operations is now commutative: there will only ever be that one specific 'B' in the array, allowing us to always position 'A' just as the user intended.

So how do we identify a particular letter? Just 'A' and 'B' are ambiguous, after all. We could generate a new ID for each inserted letter, but this isn't necessary: we already have unique UUID/timestamp identifiers for all our operations. Why not just use operation identifiers as proxies for their output? In other words, an "Insert 'A'" operation can stand for that particular letter 'A' when referenced by other operations since it is already immutable and uniquely identified. Now, no extra data is required, and everything is still defined in terms of atomic, immutable operations.

<img src="../images/blog/causal-trees/causal.svg">

This is significantly better than before! We now get "CTRLALTDEL", correctly ordered and even preserving character runs as expected. But performance is still an issue. As it stands, the output array would still take *O*(*n*<sup>2</sup>) to reconstruct. The main roadblock is that array insertions and deletions tend to be *O*(*n*) operations, and we need to replay our entire history whenever remote changes come in or when we're recreating the output array from scratch. Array *push* and *pop*, on the other hand, are only *O*(1) amortized. What if instead of sorting our entire operational array by timestamp+UUID, we positioned operations in the order of their output? This could be done by placing each operation to the right of its causal operation (parent), then sorting it in reverse timestamp+UUID order among the remaining operations[^rga]. In effect, this would cause the operational array to mirror the structure of the output array. The result would be exactly the same as with the previous approach, but the speed of execution would be substantially improved.

[^rga]: In fact, this is also how the RGA algorithm does its ordering, though it's not described in terms of explicit operations and uses a different format for the metadata.

<img src="../images/blog/causal-trees/causal-ordered.svg">

With this new order, local operations require a bit of extra processing when added to the operational array. Instead of simply appending to the back, they have to first locate their parent, then find their spot among the remaining operations. This takes *O*(*n*) time instead of *O*(1). In return, producing the output array is now only *O*(*n*), since we can read the operations in order and (mostly) push/pop elements in the output array as we go along[^deleteref]. In fact, we can treat this operational array *as if it were the string itself*, even using it as a backing store for a fully-functional `NSMutableString` subclass with some performance caveats. The operations are no longer just instructions for generating a string: they effectively *become* the data!

Note that throughout all this, we have not added any extra data to our operation structs. We have simply arranged the operations in a stricter causal order than the basic timestamp+UUID sort, which is possible on account of our knowledge of the unique causal characteristics of our data model. For example, we know that no matter how high a timestamp an insert operation might have, its final position in the string is solely determined by its parent and any concurrent (sibling) sequences of operations with a higher timestamp+UUID. Every other operation in timestamp+UUID order between that operation and its parent is irrelevant, even though the Lamport timestamps might conservatively imply otherwise. This means that an inserted character in this order can be placed right as it is read. In other words: the Lamport timestamp is a convenient upper bound on causality, but we can do a lot better with a bit of domain knowledge.

[^deleteref]: There's that one delete at S1@T7 that requires backtracking, but we can fix it by using a priority flag for that operation type. More on that later.

Pulled out of its containing array, we can see that what we've designed is, in fact, an operational *tree* — one which happens to be implicitly stored as a depth-first, in-order traversal in contiguous memory. Concurrent edits are sibling branches. Subtrees are runs of characters. By the nature of reverse timestamp+UUID sort, sibling subtrees are sorted in the order of their head operations.

<img src="../images/blog/causal-trees/tree.svg" width="400">

This is the underlying premise of the [Causal Tree][ct] CRDT.

In contrast to all the other CRDTs I'd been looking into, the design presented in Victor Grishchenko's [brilliant paper][ct] was simultaneously clean, performant, and consequential. Instead of dense layers of theory and complex data structures, everything was centered around the idea of atomic, immutable, and globally unique operations, stored in low-level data structures and directly usable as the data they represented. From this, entire classes of features effortlessly followed.

The rest of the paper will be describing [my own CT implementation in Swift](https://github.com/archagon/crdt-playground/tree/master/CRDTFramework), incorporating most of the concepts in the original paper but with tweaks to certain details based on further research.

In CT parlance, the operation structs that make up the tree are called **atoms**. Each atom has a unique **identifier** comprised of a **site** UUID, **index**, and Lamport **timestamp**[^awareness]. The index and timestamp serve the same role of logical clock, and the data structure could be made to work with one or the other in isolation. The reason to have both is to enable certain optimizations: the index for *O*(1) atom lookups by identifier, and the timestamp for *O*(1) causality queries between atoms. The heart of an atom is its **value**, which defines the given operation and stores any extra data. For an insert operation, this would be the new character to place, while delete operations contain no extra data. An atom also has a **cause** (or parent), which is another atom identifier that the current atom is said to "follow". As explained earlier, this causal link simply represents the character to the left of an insertion or the target of a deletion. Assuming that the site is stored in 2 bytes[^uuid2], the index in 4 bytes, and the timestamp in 4 bytes, each character in a basic Causal Tree string is, at minimum, 12× the size of an ordinary C-string character.

[^awareness]: In the original paper, atoms don't have Lamport timestamps, only indices, and atoms are compared by their **awareness** instead of by timestamp. An atom's awareness is a **weft** (version vector) that includes all the other atoms it would have "seen" at the time of its creation. This value is derived by recursively combining the awareness of the atom's parent with the awareness of the previous atom in its **yarn** (ordered sequence of atoms for a given site). Though awareness gives us more information than a simple Lamport timestamp, it is also *O*(*n*)–slow to derive and makes certain functions (such as verification and merge) substantially more complex. The 4 extra bytes per atom for the Lamport timestamp is therefore a worthwhile tradeoff, and also one which the author of the paper has used in [subsequent work][ron].
[^uuid2]: I mentioned earlier that UUIDs should use on the order of 128 bits to ensure uniqueness. However, having two 128-bit UUIDs per character is simply untenable. The compression scheme I devised for this problem is described further below.

In Swift code, an atom might look something like this:

```swift
struct Id: Codable, Hashable
{
	let site: UInt16
	let index: UInt32
  	let timestamp: UInt32
}

struct Atom<T: Codable>: Codable
{
	let id: Id
  	let cause: Id
	let value: T
}
```

While a string value might look like this:

```swift
enum StringValue: Codable
{
    case null
    case insert(char: UInt16)
    case delete
  
    // insert Codable boilerplate here
}

typealias StringAtom = Atom<StringValue>
```

(What's great about this representation is that Swift automatically compresses enums with associated values to their smallest possible byte size, i.e. the size of the largest associated value plus a byte for the case, or even less if Swift can determine that a value type have some extra bits available.)

For convenience, a CT begins with a "zero" root atom, and the ancestry of each subsequent atom can ultimately be traced back to it. The depth-first, in-order traversal of our operational tree is called a **weave**, equivalent to the operational array discussed earlier. Instead of representing our tree as an inefficient tangle of pointers, we store it in memory as this weave array. Additionally, since we know the creation order of every atom on each site by way of its index (or timestamp), and since a CT by definition is not allowed to contain any causal gaps, we can always derive a given site's exact sequence of operations from the beginning of time. This sequence of site-specific atoms in creation order is called a **yarn**. While yarns are more of a cache than a primary data structure in a CT, I keep them around together with the weave to enable *O*(1) atom lookups. To pull up an atom based on its identifier, all you have to do is grab the site's yarn array and read out the atom at the identifier's index.

<fig — yarns>

Storing the tree as an array means we have to be careful when modifying it — otherwise, our invariants will be invalidated and the whole thing will fall apart. When a local atom is created and parented to another atom, it is inserted immediately to the right of its parent in the weave. This preserves the sort order since the new atom necessarily has a higher Lamport timestamp than any other atom in the weave and therefore belongs in the spot closest to the parent. On merge, we have to be a bit more clever if we want to keep things *O*(*n*). The naive solution — iterating through the incoming weave and independently sorting each new atom into our local weave — would be *O*(*n*<sup>2</sup>). If we had an easy way to compare any two atoms, we could perform a simple and efficient merge sort. Unfortunately, the order of two atoms is non-binary since it involves ancestry in addition to the timestamp+UUID. In other words, you can't write a simple comparator function for two atoms in isolation.

Fortunately, we can use our knowledge of the underlying tree structure to keep things simple. (The following algorithm assumes that both weaves are correctly ordered and preserve all their invariants.) Going forward, it's useful to think of each atom as the head of a subtree in the larger CT. On account of the DFS ordering used for the weave, all of an atom's descendants are contained in a contiguous range immediately to its right called a **causal block**. To merge, we compare both weaves atom-by-atom until we find a mismatch. There are three possibilities in this situation: the local CT has a subtree missing from the incoming CT, the incoming CT has a new subtree missing from the local CT, or the two CTs have concurrent sibling subtrees. (Proving that the only possible concurrent change to the same spot is that of sibling subtrees is an exercise left to the reader.) The first two cases are easy to check and deal with: verify that one of the two atoms appears in the other's CT and keep inserting or fast-forwarding atoms until the two weaves line up again. For the last case, we have to arrange the two causal blocks in their proper order. The end of a causal block is easy to determine using an algorithm featured in the paper[^lemma], and the only thing left to do after that is to compare the two head atoms and arrange the causal blocks accordingly. (Note that any stored yarns must also be updated as the weave changes!)

[^lemma]: Lemma 2: simply iterate through the atoms to the right of your head atom until you find one whose parent has a lower Lamport timestamp than the head. This atom is the first atom past the causal block. Although the paper uses awareness for this lemma, you can easily show that this property applies to Lamport timestamps as well. (An ancestor of an atom will necessarily have a lower Lamport timestamp, while a descendant will necessarily have a higher Lamport timestamp.)

One more data structure to note is a collection of site/timestamp pairs called a **weft**. In essence, a weft is a version vector. You can think of it as a filter on the tree by way of a cut across yarns: only the atoms with indices less than or equal to the given timestamp for their site are included. Wefts are very useful for dealing with things like document revisions and garbage collection, since they can uniquely address the document at any point in its mutation timeline.

<img src="../images/blog/causal-trees/yarns.svg" width="600">

A weft is *consistent* when the tree it describes is fully-connected (or *closed* in the parlance of the paper) and is also able to produce a complete, consistent data structure from its operations. (All closed wefts are consistent in the case of string CTs, but not necessarily if the CT is used for other types of data. More on that below.) In the given example, the weft describes the string "CDADE", providing a hypothetical view of the distributed data structure in the middle of all three edits. This weft uses Lamport timestamps, but if you were using indices, it would be "1:4/2:2/3:1". The two representations are equivalent, though as mentioned earlier, the indexed representation lends itself to efficient atom lookups in yarns.

# Demo

To prove that the Causal Tree is a useful and effective data structure in the real world, [I've implemented a general version in Swift together with a demo app][crdt-playground]. Please note that this is strictly an educational codebase, not a production-quality library! My goal with this project was to dig for knowledge, not create another framework du jour. It's messy, it's slow, and it's surely broken in some places — but it serves its purpose.

<vid — top level text demo — do a bit of everything>

The first part of the demo is a macOS P2P simulator. Every window you see here represents a site. Each site has its own version of the CT forked at some point from another site, and each site can connect to any of its known peers. When connected to a peer, a site sends over its CT about once a second, and the remote site merges the incoming CT on receipt. Individual connections between sites can be toggled as needed. This is all done locally to simulate a partitioned, unreliable P2P network. The text view uses the CT directly as its backing store by way of an [`NSMutableString` wrapper][string-wrapper] plugged into a bare-bones [`NSTextStorage` subclass][container-wrapper].

<vid — yarns display>

You can open up a yarn view that resembles the diagram in the paper, though this is only really legible for simple cases. In this view, you can select individual atoms with the right mouse button to list their details and print their causal blocks.

<vid — bezier>

Also included is an example of a CT-backed data type for working with simple vector graphics. Using the editing view, you can create shapes, select and insert points, move points and shapes around, change the colors, and change the contours. Just as before, everything is synchronized with any combination of connected peers, even after numerous concurrent and offline edits. (To get a sense of how to use CTs with general non-string data types, read on!)

<vid — revisions>

Each site can display previously-synced, read-only revisions of its document via the dropdown list. This feature is just one of many emergent properties of CTs. On account of the immutable, atomic, and ordered nature of the format, you get this functionality effectively for free!

<vid — ios>

The second part of the demo is a very simple CloudKit-based text editing app for iOS. Much of it is wonky and unpolished, but the important part is that real-time collaboration (including remote cursors) works correctly and efficiently, whether syncing to the same user account, collaborating with others via CloudKit Sharing, or just working locally for long periods of time. No extra coordinating servers are required: the dumb CloudKit database works perfectly fine.

My CT implementation isn't quite production ready yet (though I'll keep hammering away for use in my own commercial projects), but I think it's convincing proof that the technique is sound and practical for use with collaborative document-based applications.

# The Gold Nugget of Truth: Operation-Based CRDTs

Causal Trees, however, are just the beginning: there is a higher-level pattern at work here. We are standing at the precipice of a fundamental, unifying theory of operational CRDTs!

Very recent research, including Victor Grishchenko's latest project [Replicated Object Notation][ron] (RON) and the academic paper [*Pure Operation-Based Replicated Data Types*][pure-op] (hereafter PORDT), has successfully demulsified the building blocks of CRDTs into a conceptually simple pipeline of atomic operations. Using this theoretical framework, CmRDTs and CvRDTs become one and the same and supersede OT in practically every respect. Better yet, many existing CRDTs (such as RGA) can to be expressed in terms of this approach, making it a kind of superset of CRDTs in general. Both RON and PORDT refer to their data structures as **replicated data types** (RDTs) instead of CRDTs, so this is the parlance I will be using for the rest of this section.

## The RDT Pipeline

In the same vein as the Causal Tree, an RDT is essentially an ordered set of operation atoms, and new operations (local and remote) are incorporated into this set through a series of functions. (For clarity, I'm going to be referring to this ordered set of operations as the **structured log** of the RDT.) The pipeline begins with an incoming stream of remote operations. For a CvRDT-equivalent RDT, this would be a state snapshot in the form of another structured log; for a CmRDT, any subset of causally-ordered operations, and often just a single one. Each operation is bestowed, at minimum, with an ID in the form of a site UUID and a Lamport timestamp, a location identifier (which is generally the ID of another operation), and a value.

As in the CT, each operation is meant to represent an atomic unit of change to the data structure, local in effect and directly dependent on one other operation at most. (In practice, operations can be designed to do pretty much anything with the data, but non-atomic or multi-causal operations create bubbles in the pipeline and may severely affect performance, simplicity, and intent.) Operations are meant to be immutable and globally unique.

New operations along with the existing structured log are first fed into a **reducer** (RON) or **effect** (PORDT) step. These take the form of pure functions that sort the operations into a structured log, then simplify or remove any redundant operations as needed.

<fig — operation stream + reducer>

What is this "simplifying", you might ask? Aren't the operations meant to be immutable? Generally, yes; but in some RDTs, new operations might definitively supersede previous operations. Take a last-writer-wins register, for example. In this very basic RDT, the value of an operation with the highest timestamp+UUID supplants any previous operation's value. Since merge only needs to compare a new operation against the previous highest operation, it stands to reason there's simply no point in keeping the older operations around. (PORDT defines these stale operations in terms of **redundancy relations**, which are unique to each RDT and are applied as part of the effect step.) Another possible reduction step is the stripping of ID or location data. In some RDTs, this information becomes unnecessary for later convergence once operations are placed in their proper sorted order. In the RON implementation of RGA, the location (parent) data of an operation is stripped by the reducer once the operation is properly situated in the structured log. (The original RGA paper features a very similar cleanup step. RON and PORDT simply generalize this to other RDTs.)

<fig — lww/reducer, rga>

Here, I have to diverge from my sources. In my opinion, the reducer/effect step ought to be split in two. Even though some RDT operations might be redundant for convergence, retaining every operation in full allows us to know the exact state of our RDT at any point in its history. Without this ability, relatively "free" features such as garbage collection and past revision viewing become much harder (if not impossible) to implement. Ergo, I posit that at this point in the pipeline, we ought to have a simpler **arranger** step. This function would perform the same kind of merge as the reducer/effect functions, but it wouldn't actually remove or modify any of the operations. Instead of happening implicitly, the previous simplification steps would be triggered in a more consistent and general way when space actually needs to be reclaimed. (More on that below.)

<fig — arragner>

The final bit of the pipeline is the **mapper** (RON) or **eval** (PORDT) step. This is the code that finally makes sense of the structured log. It can either be a function that produces an output data structure by reading the operations in order, or alternatively a collection of functions that directly interface with the structured log itself. In the case of string RDTs, the mapper might simply emit a native string object, or it might be an interface that lets you call methods such as `lenth`, `characterAtIndex:`, or even `replaceCharactersInRange:withString:` directly on the contents of the structured log.

<fig — mapper>

The arranger/reducer/effect and the mapper/eval functions together form the two halves of the RDT: one dealing with the low-level organization of data, the other with its user-facing interpretation. The data half, embodied in the organization of the structured log, needs to be structured in such a way that the interface half remains performant. If the structured log for an RDT ends up kind of looking like the abstract data type it's meant to represent (e.g. a CT's weave ⇄ array), the design is probably on the right track. In effect, the operations should *become the data*.

So how is the structured log stored, anyway? This is another point where I have to diverge from my source material. In RON, the reducer is a pure function that simply spits out a dumb, ordered sequence of operations called a **frame**. This frame is a generic blob of data that has no RDT-specific code. Everything custom about a particular data type is handled in the reducer and mapper functions. (PORDT does things very similarly, though I don't believe the precise storage mechanism for operations is clearly defined.) In my view — the CvRDT-centric view — the structured log ought to be more intelligent than that. Rather than treating the log and all its associated functions as separate entities, I prefer to conceptualize the whole thing as a persistent, type-tailored object, distributing operations among various internal data structures and exposing merge and data access through an OO interface. In other words, the structured log, arranger, and parts of the mapper would combine to form one giant object.

<fig — object-based log>

The reasoning behind this approach is simple. RDTs are meant to fill in for ordinary data structures, so sticking operations into some homogenous frame might lead to poor performance depending on the use case. For instance, many text editors now prefer to use the [rope data type][rope] instead of simple arrays. With a RON-style frame, this transition would be impossible. But with an object-based RDT, we could almost trivially switch out our internal data structure for a rope and be on our merry way. (Only the merge function would require some extra care.) And this is just the beginning: more complex RDTs might require numerous associated data types and caches to ensure optimal performance. The OO approach would ensure that all these secondary structures stayed together, remained consistent during merge, and offered a unified interface for data access. (More below.)

<fig — rope>

With all the pieces in place, it becomes trivial to reinterpret our Causal Tree in terms of this operational approach. The structured log is the weave array together with any yarn caches. The arranger is the merge function. The mapper is the `NSMutableString` wrapper around the CT. All the parts are already there with slightly different names.

And now, we can use this thinking to devise all sorts of new RDTs!

## Garbage Collection

(This section is a bit speculative since I haven't implemented any of it, but I believe the logic is sound.)

Garbage collection has been a sticking point in CRDT research, and I believe that operation-based CRDTs offer an excellent foundation for exploring this problem. A garbage-collected RDT can be thought of as a data structure in two parts: the "live" part and the compacted part. As we saw earlier, a CT can be split into two segments by way of a version vector (or weft in CT parlance). The same applies to any operational RDT. In a garbage-collected RDT, we can simply store a **baseline** weft alongside the main data structure to serve as the dividing line between the live and compact parts. Then, any site that receives the new baseline would be obliged to compact the operations falling under that weft, and to drop or orphan any operations that are not included in the weft but have a direct causal connection to any of the removed operations. The baseline can be thought of as just another operation in the RDT: one that requires all prior operations to pass through the RDT's particular garbage collection routine. The trick is making this operation commutative.

<figure>

<img src="../images/blog/causal-trees/baseline.svg" width="600">
<figcaption><blockquote>The dotted line represents baseline 1:6–2:7–3:7. In practice, S1@T2 may not necessarily be removed in order to preserve S1@T3's ancestral ordering information.</blockquote></figcaption>
</figure>

So what exactly does it mean to compact an RDT? There are really two mechanisms in play here. First, there's "lossless" compaction, which is simply dropping operations that are no longer necessary for future convergence. (In PORDT, this property of operations is called *causal redundancy*, and the cleanup is performed in the effect function. Remember, we split this off from our arranger.) In essence, lossless compaction is strictly a local issue, since the only thing it affects is the ability for a client to rewind the RDT and work with past revisions. As such, we don't even have to store it in a replicated variable: sites can just perform this cleanup step at their discretion. However, only simpler RDTs (such as last-writer-wins registers) tend to have operations with this property.

The second kind of compaction involves dropping operations that are no longer reflected in the RDT's output, but that others sites may still require to fully converge in the future. In a CT-style string RDT, this would involve removing delete operations along with their target (parent) operations, then preserving the order of any sibling inserts concurrent with that delete[^rewrite]. The risk here is that if a deleted operation has children other than the delete on any sites, then those child operations will be orphaned if the baseline fails to include them. We can mitigate this by first stipulating that no new operations may be *knowingly* parented to operations with attached delete operations, and also that no delete operations may have any children or be deleted themselves. (In other words, sibling insert and delete operations would only ever occur in RDTs with concurrent version vectors. This is the expected behavior anyway since the user can't insert to the right of deleted characters, but it should be codified programmatically.) With this precondition in place, we know that once a site has received a delete operation, it will never produce any new siblings for that operation. We therefore also know that once *every* site in the network has seen a particular delete operation and its causal ancestors — when that delete operation is *stable* — that no new operations concurrent to the delete will ever appear in the future, and that a baseline could in theory be constructed that avoids orphaning any operations across the network. (PORDT uses similar logic for its **stable** step, which comes after the effect step and cleans up any *causally stable* operations provably delivered to all other sites.)

[^rewrite]: There are a few possible ways to implement this. For example, the garbage-collected operations could be stored as an ordered block of data in their own separate area of the structured log. Keeping the operations in order would additionally allow them to drop their location identifiers and save even more space. (This is the strategy that PORDT recommends.) However, there may be performance repercussions (and headaches) from having the data split into two parts like that, especially if you're relying on spatial locality and random access for your mapper/eval step. An alternative is to keep the compacted operations mixed in with the live operations, but to only remove operations with no children other than delete operation. This might sound wasteful — almost every character will have an adjacent character, right? — but the property does cascade. Once the final operation at the end of a consecutive range of deletes is removed, the others can be picked off one by one in turn. And as an additional optimization, if a deleted operation's only child (other than the delete) is another deleted operation, then the child can take the place of its parent. This bit of rewriting of history is harmless since no new operations can be knowingly added to deleted operations, but may involve some extra code complexity and checks. Compaction schemes will vary for other RDTs. Keep in mind that in order for an RDT before and after garbage collection to produce identical output, every operation possibly affected by the removal of an operation has to be dealt with. With sequence RDTs, these would only be the parent and concurrent children of a delete; with other RDTs, possibly more than that.

Here's where we hit a snag. Generally speaking, CRDT research focuses on operation-based CmRDTs, with the latent assumption that those CRDTs are going be used as part of some distributed system. In other words: the CRDTs are meant to support real-time collaboration and smooth over any sync issues, but client-server (or client-cloud, or even client-client) communication is still expected. In my own exploration of this topic, I have made no such assumptions. The CRDTs as described above are system-agnostic mathematical structures, and it makes no difference to the algorithms how the data gets from one place to another. Even communication isn't a strict requirement! Someone could leave a copy of their CvRDT on an office thumb drive, return a year later, and successfully merge all the new changes back into their copy. This means that every time some additional bit of synchronization is mandated or assumed, the possibility space of the design shrinks and generality is lost. The messiness of time and state are injected into an otherwise functional system.

Unfortunately, garbage collection might be the one subsystem where a bit of coordination is actually required.

Take baseline selection, for instance. In an [available and partition-tolerant system][cap] system, is it possible to devise a selection scheme that always garbage collects without orphaning any operations? Logically speaking, no: if some site copies the RDT from storage and then works on it in isolation, there's no way the other sites will be able to take it into account when picking their baseline. However, if we require our system to only permit forks via request to an existing site, and also that any forked sites ACK back to their origin site on successful initialization, then we would have enough constraints to make selection work. Each site could hold a map of every site's ID to its last known version vector. When a fork happens, the origin site would add the new site ID to its map and seed it with its own timestamp. This map would be sent along with every operation or state snapshot between sites and merged at the receiver. (In essence, it would act as a distributed overview of the network.) Now, any site with enough information about the others would be free to independently set a baseline that a) is causally consistent, b) is consistent by the rules of the RDT, c) includes only those removable operations that have been received by every site in the network, and d) also includes every operation affected by the removal of those operations. With these preconditions, you can prove that even concurrent updates of the baseline across different sites will converge.

<figure>

<img src="../images/blog/causal-trees/garbage-collection.gif" width="800">

<figcaption><blockquote>An example of network knowledge propagation. Site 2 is forked from 1, Site 3 from 2, and Site 4 from 3. At the start, Site 1's C has been received by Site 2, but not Site 3. Maps are updated on receipt, not on send. At the end, Site 1 knows that every site has at least moved past ABE (or weft 1:2–4:9), making it a candidate for the new baseline.</blockquote></figcaption>

</figure>

But questions still remain. For instance: what do we do if a site simply stops editing and never returns to the network? It would at that point be impossible to set the baseline anywhere in the network past the last seen version vector from that site. Now some sort of timeout scheme has to be introduced, and I'm not sure this is possible in a truly partitioned system. There's just no way to tell if a site has left forever or if it's simply editing away in its own parallel partition. So we have to add some sort of mandated communication between sites, or perhaps some central authority to validate connectivity, and now the system is constrained even more! In addition, as an *O*(*s*<sup>2</sup>) space complexity data structure, the site-to-timestamp map could get unwieldily depending on the number of peers.

Alternatively, we might relax rule c) and allow the baseline to potentially orphan remote operations. In this scheme, any site would be free to pick a new baseline that was higher than (not concurrent to!) the previous baseline, taking care to pick one that had the highest chance of preserving operations on other sites[^preservation]. Upon receiving and executing this baseline, any site that had operations causally dependent on the newly-removed operations but not included in the baseline would be obliged to either drop them or to add them to some sort of secondary "orphanage" RDT.

[^preservation]: If we still had access to our site-to-version-vector map, we could pick a baseline common to every reasonably active site. This heuristic could be further improved by upgrading our Lamport timestamp to a [hybrid logical clock][hlc]. (A Lamport timestamp is allowed to be arbitrarily higher than the previous timestamp, not just +1 higher, so we can combine it with a physical timestamp and correction data to get the approximate wall clock time for each operation.)

But even here we run into problems with coordination. If this scheme worked as written, we would be a-OK, so long as sites were triggering garbage collection relatively infrequently and only during quiescent moments (as determined to the best of a site's ability). But we have a bit of an issue when it comes to picking strictly higher baselines. What happens if two peers concurrently pick new baselines that orphan each others' operations?

<img src="../images/blog/causal-trees/garbage.svg" width="250">

Assume that at this point in time, Site 2 and Site 3 don't know about each other and haven't received each other's operations yet. The system starts with a blank garbage collection baseline. Site 2 decides to garbage collect with baseline 1:3/2:6, leaving behind operations "ACD". Site 3 garbage collects with baseline 1:3/3:7, leaving operations "ABE". Meanwhile, Site 1 — which has received both Site 2 and 3's changes — decides to garbage collect with baseline 1:3/2:6/3:7, leaving operations "AED". So what do we do when Sites 2 and 3 exchange messages? How do we merge "ACD" and "ABE" to result in the correct answer of "AED"? In fact, too much information has been lost: 2 doesn't know to delete C and 3 doesn't know to delete B. So we're kind of stuck.

In this toy example, it may still be possible to converge by drawing inferences about the missing operations from the baseline version vector of each site. But that trick won't work with more devious examples featuring multiple sites deleting each others' operations and deletions spanning multiple adjacent operations. *Maybe* there exists some clever scheme which can bring us back to the correct state with any combination of partial compactions, but my hunch is that this situation is provably impossible to resolve in a local way without accruing ancestry metadata — at which point you're left with the same space complexity as the non-compacted case anyway.

Therefore — just as with the non-destructive baseline strategy — it seems that the only way to make this work is to add a bit of coordination. This might take the form of:

- Designating one or more sites superusers and making them decide on the baselines for all other sites.
- Putting the baseline to vote among a majority/plurality of connected sites.
- Relying on a server to synchronously store the current baseline. (This might be the best strategy for a system built on top of something like CloudKit. The syncing mechanism is centralized and synchronous anyway, so might as well force sites to pull the baseline on sync.)
- Enforcing a real-time clock scheme. As long as clients are synced to an accurate master clock, perhaps operations could become compactable once some preset amount of time has passed. (There has to be some sort of mitigation for sites that can't keep time accurately enough.)
- Allowing sites that end up losing in a concurrent baseline adjustment to pull the full RDT from somewhere, or to get the necessary parts from their peers.

In summary: while baseline operations are not commutative for every possible value, they can be made commutative with just a sprinkle of coordination. Either you ensure that a baseline *does not leave orphaned operations* (which requires some degree of knowledge about every site on the network), or you ensure that *each new baseline is higher than the last* (which requires a common point of synchronization). Fortunately, the messy business of coordination is localized to the problem of picking the data for a single operation, not to the functioning of the operation itself or any other part of the RDT. There's nothing special or unique about the baseline operation with respect to the rules of CRDTs, and so it can be treated, transferred, and processed just like any other operation. And if the baseline fails to get updated due to network conditions, nothing bad actually happens, and sites are still free to work on their documents. The scheme degrades very gracefully.

As one last idea, if the RDT propagation mechanism is restricted to state snapshots (as in a CvRDT), you could allow any site to arbitrarily set the baseline, but then replace any removed operations during a merge if the incoming state snapshot happens to include causal dependents of those removed operations. (This is possible because every state snapshot is a consistent version of the RDT, so the missing operations can be revived without having to make any additional requests.) Personally, I'm not too comfortable with this approach. My feeling is that it breaks CRDT monotonicity by allowing state to be restored, though it's not clear to me where this inconsistency might rear its head. It's much more correct for baselines to follow the rules of every other operation and move the CRDT forward through the monotonic semilattice. But I concede that this could possibly be the one perfect, coordination-free garbage collection approach — just as long as strictly CvRDT use was OK.

Finally, remember that in many cases, "don't worry about garbage collection" is also a viable option! Most collaborative documents aren't meant to be edited in perpetuity, and assuming good faith on the part of all collaborators, it would be surprising if the amount of deleted content (and thus, garbage) in a typical document was more than 2 or 3 times its visible length.

## RDT Design & Implementation

I've been thinking about the best way to integrate operation-based CRDTs into production software. [RON][ron], though incomplete, offers a blueprint for a general, flexible, and highly functional system. However, I think there's a lot to be said for object-based RDTs — especially where low-latency software is concerned.

To reiterate, RON stores the operations for any RDT in a singular, immutable *frame* data structure and pushes everything unique about the RDT into the reducer and mapper functions. The system is data-oriented and self-configuring. Each set of operations contains location and data type information which allows the pipeline to route operations to the correct RDT frame without any boilerplate. The reducers are actually multi-mode functions that can merge individual operations, partial frames (patches), or full frames (state snapshots) in *O*(*n*log*n*) time by way of heap sort, allowing RON to function equally well in CmRDT or CvRDT mode (or perhaps even mix modes on the fly). Operations are described using a regular language that compresses very well when stored in a frame, and an even more efficient binary mode is available. The end result is a teeming river of operations that can automatically form into larger, interconnected structures.

In the object-based approach, operations, reducer/mapper functions, and any relevant caches are herded into persistent, mutable objects. Certainly, there are many hassles with this compared to the RON paradigm: everything is tightly-coupled, ownership becomes a critical factor, a lot more boilerplate is involved. Since there's no built-in data layer, object management becomes a major concern. In exchange, you can target performance chokepoints with precision. A generic RON frame with *O*(*n*) reads and O(*n*log*n*) writes might be good for the general case, but there are plenty of problems where *O*(1) or *O*(log*n*) for certain functions is a hard requirement. Objects have the freedom to distribute their operations among various data structures, maintain caches of operations, and otherwise structure themselves for efficient queries. Since operations are stored as individual structs, they take up more space than in RON, but also benefit tremendously from memory locality and random access. The conception of RDTs as independent structures allows them to be used in non-network contexts; for example, as a way of dealing with local file merge or synchronizing data across threads. And unlike RON, there's no mapping step from frame to user data: the object can be used as a native data type, never goes stale, and never has to convert itself into different formats. (Think of the `NSMutableString` wrapper around the CT: you can use it just like any old system string.) All these factors really give this approach the leg up in low-level code.

Consider a hypothetical replicated bitmap as a thought experiment. Perhaps in the same vein as Reddit's [/r/place](http://i.imgur.com/ajWiAYi.png), you're working on a giant image with a bunch of different people — some online, some offline — and you want the whole thing to sensibly merge when the different parts come together. As a starting point, say the bitmap is conceived as a grid of LWW registers[^lww], and that each operation contains a single pixel's coordinates and RGBA color as the value. Let's also say that the image is 5000x5000 pixels and that each set-pixel operation couldn't be made smaller than 16 bytes. This means that once the entire canvas fills up, you'll be using about 400MB of uncompressed memory — and that doesn't even include any past history. Given that throughput for a single site could be in the hundreds of pixels per second, it's crucial that each set-pixel operation execute locally in *O*(log*n*) time at most. It's also vital for the garbage collector to be able to trim the RDT very often and very quickly, since even a few layers of history would eat up all your RAM. (Technically, garbage collection isn't even needed in a LWW context — see *causal redundancy* above — but maybe it's desirable for the app to have the full bitmap history until the memory situation is truly dire.) Perhaps it should even be possible to tile the bitmap and pull different chunks from storage as you're working on them.

[^lww]: In reality, to make the merge more meaningful and avoid artifacts, it would be better to keep around a sequence RDT of session IDs alongside the bitmap. Each site would generate new session IDs at sensible intervals and add them to the end of the sequence, and each new pixel would reference the last available session ID. Pixels would be sorted first by session, then by timestamp+UUID. (Basically, these would function as ad hoc layers.) But LWW is easier to talk about, so let's just go with that.

My feeling is that RON's general approach would falter here. The pipeline simply couldn't be tuned to fix these performance hot spots, and millions of pixel operations would grind it to a halt. With the object-based approach, you could store store the bitmap as a specialized k-d tree of buffers. The pixel values would be the operations themselves, and each buffer would represent a particular area of pixels , subdivided when needed to store a pixel's past operations. Since the buffers would be stored in contiguous chunks of memory, subdivision and rebalancing would be very fast. Garbage collection could be as simple as un-subdividing any buffer with too many subdivisions. Assuming that the RGBA value for each operation was formatted correctly and that a stride could be passed along to the graphics framework, nodes could be blitted as-is into another buffer, making it trivial to only update the dirty parts of a user's rendered image. In short, it seems that performance could end up being very close to that of an *actual* bitmap. It wouldn't even surprise me if /r/place itself — with its 16 million changes and 1 million unique sites — could be reproduced with this kind of object!

<fig — bitmap idea>

Finally, a few nascent thoughts on designing new RDTs:

* The operations *are* the data. Design your operations and organize your data structures so that you can query the RDT directly instead of having to actually execute the operations first. Start with the data type you're trying to RDT-ify and figure out the best way to divide it into atomic pieces of data while keeping the original structure intact.
* Keep in mind the essential functions: initialization, operation insertion, merging, garbage collection, serialization and deserialization. Nothing should be slower than *O*(*n*log*n*).
* As much as possible, avoid operations that have non-local effects, multiple causes, or affect multiple future operations. (Good operation: "Insert Letter After Letter". Bad operation: "Capitalize All Existing Letters".) Avoid bubbles in the pipeline!
* If garbage collection is going to be used, restrict the effective range of your removable operations. Ensure that only operations prior and concurrent to the removable operation could possibly be affected by its removal — none afterwards.
* If using the object-based approach, ensure that each operation only exists in a single data structure at a time. Don't rely on "incidental state" such as insertion order; keep your data structures organized, sorted, and balanced at all times. Avoid moving operations between data structures. Instead of thinking of your object as having state, treat it as an organizational structure for your immutable operations: a kind of advanced frame.
* One exception: caches of operations might be needed for optimal performance in some scenarios. (Example: yarns in the CT for *O*(1) atom lookups by ID.) If you have caches, make absolutely, 100% sure that they're consistent following all mutating operations; that they're never serialized; and that it's possible to efficiently recreate them on initialization. Caches are one of the easiest ways to corrupt your data!

All that being said, the need to design a new RDT should be relatively rare. Most data will be representable through the composition of existing RDTs, e.g. sequences and maps. Nonetheless, my feeling is that certain kinds of interactive software — drawing, music, and games, for example — would be impossible to CRDT-ify without using this approach. And in any case, it's a fun topic to think about!

# Causal Trees In Depth

But now, let's get back to our favorite data structure.

I'd like to posit that the humble Causal Tree, though intended for string use, is in fact one of the most versatile and general CRDTs out there. The first reason is that a CT is, in fact, a full-on convergent tree. As we've already seen, trees can represent sequences very well. But trees are also flexible enough to simulate registers, maps, and many other data types. Trees are also composed of subtrees, which provides a natural mechanism for data segmentation. The second reason is that CTs are stored in a single range of contiguous memory. This makes *O*(*n*) operations lightning-fast due to spatial locality, enabling various optimizations and even making it possible to eschew copy-on-write or locking schemes in favor of straight copies when dealing with multiple threads.

Together, these two properties make CTs perfect for use as a sort of quick-and-dirty "convergent struct". But we need to flesh out a few details first...

## Implementation Details

Before even touching the CT, it makes sense to define a general CvRDT protocol. Among other things, this allows CvRDTs to easily compose by forwarding all the relevant calls to their child CvRDTs.

```swift
public protocol CvRDT: Codable, Hashable
{
    // must obey CvRDT convergence properties
    mutating func integrate(_ v: inout Self)
    
    // for avoiding needless merging; should be efficient
    func superset(_ v: inout Self) -> Bool
    
    // ensures that our invariants are correct, for debugging and sanity checking
    func validate() throws -> Bool
}
```

CvRDTs are especially vulnerable to bad input since there's no guarantee of a central server to fix mistakes. In order to minimally safeguard against malicious and misbehaving peers, I’ve added a validation method to this interface. In the CT case, the `validate` method goes through the weave and checks as many preconditions as possible, including child ordering, atom type, priority atom behavior, and several others.

Next, if a CvRDT is an operational RDT as described in the previous section, we can expose even more functionality through the interface:

```swift
public protocol OperationalCvRDT: CvRDT
{
    var lamportClock: CRDTCounter<Int32> { get }
  
    func baseline() -> Weft // the point beyond which the CvRDT is compacted or reduced
    mutating func garbageCollect(_ w: Weft) // sets the baseline
 
    // make the CvRDT behave like an older (read-only) revision
    func revision() -> Weft?
    mutating func setRevision(_ r: Weft?) throws
  
    mutating func blame(_ a: AtomId) -> SiteIndex?
}
```

The methods for viewing past revisions aren't necessary, but they're potentially very useful to the end user and almost trivial to implement in operational CRDTs. If you know that a particular weft is consistent, getting a read-only view of the object at that point in time is as simple as filtering out operations older than the given weft and maybe regenerating the caches. (My string CT does this through the use of array slices.) As for getting a list of consistent wefts, one simple way to do this is to store the current weft right before any remote changes are integrated.

Next: UUIDs. So far, I've been describing my site identifiers as 16-bit integers since it's unlikely that any document would have more than 65,000 collaborators. (And frankly, in most cases 8 or even 4 bits would do.) However, this is not enough for any reasonable definition of a UUID. Without coordination, you'll need a minimum of 128 bits to generate a truly unique value, but storing the full 128-bit UUID in each atom — once for its own site and once for its cause — would balloon it to 3x the original size!

I've solved this with the help of a secondary CRDT that is stored and transferred along with the CT: an ordered, insert-only array of known UUIDs called the **site map**. The 16-bit site identifier corresponding to a UUID is simply its index in this array.

<img src="../images/blog/causal-trees/site-map.png" width="800">

When two CTs merge, their site maps merge as well. This means that our site identifiers are only unique locally, not globally: if a new UUID gets added at another site and then merged into ours, the sorted order of the existing UUIDs in the site map might change. When this happens, I traverse each CT and remap any outdated site identifiers to their new values — a simple *O*(*n*) operation. This is facilitated by the following interface:

```swift
public protocol IndexRemappable
{
    mutating func remapIndices(_ map: [SiteId:SiteId])
}
```

Any CRDT that makes use of the site map needs to implement this protocol. Whenever a merge is invoked that would cause some of the site IDs to change, the `remapIndices` method gets called on the CRDT before the merge is actually executed. We're running *O*(*n*) operations when receiving remote data anyway, so performance is not a huge factor. Nonetheless, I made one additional tweak to ensure that remapping only happens very rarely. Instead of storing just the UUID in the site map, I also store the wall clock time at which the UUID was added. These tuples are sorted first by time, then by UUID. Assuming that modern connected devices tend to have relatively accurate clocks (but not relying on this fact for correctness), we can ensure that new sites almost always get appended to the end of the ordered list and thus avoid shifting any of the existing UUIDs out of their previous spots. The only exception is when multiple sites happen to be added concurrently or when the wall clock on a site is significantly off.

In summary, the final interface to our CT ends up looking something like this:

```swift
public protocol CausalTreeSiteUUIDT: Hashable, Comparable, Codable {}
public protocol CausalTreeValueT: IndexRemappable, Codable {}

public final class SiteIndex
    <S: CausalTreeSiteUUIDT> :
    CvRDT, NSCopying
{
    // etc.
}

public final class Weave
    <S: CausalTreeSiteUUIDT, V: CausalTreeValueT> :
    OperationalCvRDT, IndexRemappable, NSCopying
{
    public private(set) var lamportTimestamp: CRDTCounter<Int32>
  
    // etc.
}

public final class CausalTree
    <S: CausalTreeSiteUUIDT, V: CausalTreeValueT> :
    OperationalCvRDT, IndexRemappable, NSCopying
{
    public private(set) var siteIndex: SiteIndex<S>
    public private(set) var weave: Weave<S, V>
    
    // etc., with CvRDT interface calls forwarded to the site index and weave
}
```

One last feature specific to CTs is the priority flag for atoms. If an atom has priority, it gets sorted ahead of all its siblings in the parent's causal block, even if it has a lower Lamport timestamp. (Put another way, a priority flag is simply another variable to be used in the sorting comparator, i.e. timestamp+UUID+priority.) This property gives us a lot of structural control, ensuring that, for instance, delete atoms hug their corresponding insert atoms and never find themselves lost in the weave after a merge of concurrent insert operations. It does require some special casing during weave mutation and merge, however.

With the priority flag in tow, the value enum for our CT string atoms now looks something like this:

```swift
protocol CausalTreePrioritizable { var priority: Bool { get } }

enum StringValue: IndexRemappable, Codable
{
    case null
    case insert(char: UInt16)
    case delete
  
    func priority() -> Bool
    {
        if case .delete = self
        {
            return true
        }
        else
        {
            return false
        }
    }
  
    // insert Codable boilerplate here
}

typealias StringAtom = Atom<StringValue>
```

And that's all we really need to start implementing custom data types!

## Representing Non-String Objects

In order to implement a custom data type as a CT, you first have to "atomize" it, or decompose it into a set of basic operations, then figure out how to link up those operations such that a mostly linear traversal of the CT will produce your output data. (In other words, make the structure analogous to a one- or two-pass parsable format.)

In the demo section, I presented a CT designed for Bézier drawing. Here's how I coded the value enum for each atom:

```swift
enum DrawDatum: Codable, CausalTreePrioritizable
{    
    case null // no-op for grouping other atoms
    case shape
    case point(pos: NSPoint)
    case pointSentinelStart
    case pointSentinelEnd
    case trTranslate(delta: NSPoint, ref: AtomId)
    case attrColor(ColorTuple)
    case attrRound(Bool)
    case delete
  
    var priority: Bool
    {
        switch self
        {
        case .null:
            return true
        case .shape:
            return false
        case .point:
            return false
        case .pointSentinelStart:
            return false
        case .pointSentinelEnd:
            return false
        case .trTranslate:
            return true
        case .attrColor:
            return true
        case .attrRound:
            return true
        case .delete:
            return true
        }
    }
  
    // insert Codable boilerplate here
}

typealias DrawAtom = Atom<DrawDatum>
```

Swift is kind enough to compress this down to about 23 bytes: the maximum size of an associated value tuple (opTranslate, which has a 16-byte `NSPoint` and a 6 byte `AtomId`) plus a byte for the case.

Note that `trTranslate` has an atom ID as an associated value. Since atom IDs are unique, you can reference them from other atoms without issue[^causalpast]. It's a great way to represent ranged operations: just pick an atom that represents the outer position of your range, add the ID to the operation's value, and handle it in your mapping/evaluation code. (This should especially come in handy when dealing with text formatting in rich text editors.) The only caveat is that the atom has to update this value in the `IndexRemappable` implementation. (Incidentally, I still need to port this functionality to my string CT's delete operation: ranged deletes are so much more performant than deleting each character individually!)

[^causalpast]: Well, as long as the referenced atom is in the new atom's causal past. What this means is that you shouldn't reference atoms that aren't already part of your CT, which — why would anyone do that? Are you smuggling atom IDs through a side channel or something? I suppose it might be a case worth adding to the `validate` method to help detect Byzantine faults.

Anyway, back to shapes. For the following sample document...

<img src="../images/blog/causal-trees/shape-example.png" width="400">

...we might end up with a tree shaped like this. (For completeness, I've added a few extra transformation and attribute operations that aren't directly visible in the user-facing data.)

<img src="../images/blog/causal-trees/draw-tree.svg" width="700">

Just a few simple rules define the higher-level structures that represent shapes, points, and properties in this tree. A `shape` atom can only be parented to other `shape` atoms or to the root starting atom. Each `shape` has a null atom as its only child, acting as the root node for all property subtrees relevant to that shape. This atom can contain three child subtrees at most: a chain of transformations, a chain of attributes, and a chain of points. Transformation and attribute chains hug their parent in the weave via the priority flag while points go last. Any new transformations and attributes are parented to the last member of their corresponding chain. The value for a chain of operations (currently only `trTranslate`) is cumulative, while the value for a chain of attributes (`attrColor` or `attrRound`) is just the last atom in the chain. Point chains act more like traditional sequences. A point chain is seeded with a start and end sentinel to cleanly delineate it from its neighbors, and the traversal order corresponds to the order of the points in the eventual output `NSBezierPath`. Like shapes, points can have child transformation and attribute chains. Points can also have child delete atoms. (Shapes aren't currently deletable: you can individually remove all the points anyway and I got lazy.)

In essence, this CT consists of a bunch of superimposed operational CRDTs: sequences for shapes and points, LWW registers for attributes, and a reducing CRDT for transformations. 

Here is the weave we get from reading the tree in DFS order:

<img src="../images/blog/causal-trees/shape-example-weave.png">

The rules for generating the output image from this weave are very simple. If you hit a shape atom, you're in a shape block until you run into another shape atom or the end of the weave. The shape's operation and attribute chains are traversed first on account of their priority flag, and the results are cached for use in the next step. An `NSBezierPath` is created once you start reading points. Each point block has to read forward a bit to parse its operation and attribute chains (if any). If a delete atom is found, you can simply move on to the next point. Otherwise, the point's position is determined by combining its origin and transform (if any) with the parent shape's transform (if any). The point is added to the `NSBezierPath` either as as a line or as a Bézier curve if it has the rounded attribute. Then, once the next shape block or the end of weave is reached, the path is drawn and stroked.

When I first started reading up on CRDTs, it was unclear to me how conflict resolution was formalized. Every CRDT seemed to do something a bit different — often laden with dense theory — and it was rare to find an approach that the developer could tweak depending on their needs. In CTs, the answer is refreshingly simple: conflicts occur when an atom has more children than expected, and the presentation of this fact is delegated to a higher layer. (My understanding is that the MV-Register CRDT behaves in a similar way.) Translation operations in the Bézier CT are a good example. Let's say three different sites concurrently move the same point in the same direction. By default, the CT would produce a weave with three consecutive translations. Applying them in order would be consistent, but it would also triple the magnitude of the translation and match none of the sites' intended actions. Instead, we can detect when a translation atom has multiple children and then simply average out those values. This would cause the final translation to reasonably approximate each of the original values and hopefully leave all three sites satisfied. If some user still finds this merge offensive, they can manually adjust the translation and implicitly "commit" the change with their new operation.

This is only one possible approach, however, and the developer is free to do anything when a conflict is detected: present a selection to the user, pick the value with the lowest timestamp, use some special function for combining the values. The underlying CT will *always* remain consistent under concurrency; doing something with this information is entirely up to the app.

Finally, my implementation includes a [new, stateless layer](https://github.com/archagon/crdt-playground/blob/master/CRDTPlayground/TestingExtras/Data%20Interfaces/CausalTreeBezierWrapper.swift) on top of the CT that provides a more model-appropriate API and sanity checking. Since the Bézier tree has more constraints on its structure than the underlying CT, there's an additional, higher-level `validate` method that verifies all the new preconditions after the CT is itself validated. Other helper functions ensure that the consistency of the tree is not compromised when new points, shapes, or attributes are added. From the outside, callers can safely use methods like `addShape` or `updateAttributes` on the wrapper without having to worry about the CT at all. It looks just like any other model object. (Incidentally, this approach to layering CRDTs is discussed in [this paper][layering], though the technique isn't exactly novel.)

It's possible that the use case of representing custom data types as CTs is a bit esoteric. Certainly, I wouldn't use a CT for something like a PSD or DOC file. But just as with structs versus objects, I can imagine a number of scenarios where a small, custom CT might make the code so much cleaner and more performant than a higher-level collection of array, map, and register CRDTs. Quick, versatile, and simple data structures often turn out to be very practical tools!

## Performance

OT and CRDT papers often cite 50ms as the point at which people start to notice latency in their text editors. Therefore, any code we might want to run on a CT — including merge, initialization, and serialization — has to fall within this range. Except for trivial cases, this precludes *O*(*n*<sup>2</sup>) or slower complexity: a 10,000 word article at 0.01ms per character would take 8 hours to process! The essential CT functions therefore have to be *O*(*n*log*n*) at the very worst.

The simplest implementation of a weave is a contiguous array of atoms. Since every mutation resolves to an atom insertion, *O*(*n*) is the baseline for any mutation (except for appends to the end). On account of spatial locality, this should be fine for the majority of use cases: [Mike Ash's benchmarks][benchmarks] show that an iPhone 6s can `memcpy` 1MB in 0.12ms, meaning that performance will probably be fine as long as the CT stays under ≈400MB. It also helps that the CT involves only a limited number of heap allocations and no pointer-chasing at all. If that's not good enough, it should be possible to switch out the array for something like [xi's copy-on-write rope][xi-rope] for specialized use cases.

My CT implementation maintains a cache of site yarns alongside the weave which incurs a slight performance penalty. Yarns are also stored as one contiguous array, meaning that there's an additional *O*(*n*) cost for every weave mutation. Additionally, whenever a CT is received from another site, its yarns have to be regenerated on initialization. (Yarns are not part of the serialized data for reasons mentioned at the end of the RDT section.) Yarn generation is *O*(*n*log*n*) since it's isomorphic to sorting the weave. In exchange, the yarns give us *O*(1) for the very common operation of looking up atoms by their identifier. Finding an atom's weave index is still *O*(*n*), but this is a minor issue since the index is only really used when inserting new operations, and that's an *O*(*n*) process already.

Merging with another CT is almost always *O*(*n*log*n*). This involves iterating the two weaves together, comparing atoms by parentage and timestamp, constructing a new interwoven weave, and then regenerating the yarn cache. On occasion, a priority atom conflict might require finding the least common ancestor between two atoms in *O*(*n*), but this should be exceedingly rare. (And in any case, it's unlikely that the two operations will differ by more than a couple of ancestors.)

Weave validation is only *O*(*n*). All we have to do is look at each atom and keep track of a few counters to ensure that sibling order is correct and that causality is not violated. This is usually invoked on deserialization.

As state-based CRDTs, CTs have a large memory footprint, both on account of the operation size and accumulated garbage. Assuming that a document is unlikely to contain more than 30% garbage, a 20,000 word article (like this one!) would eat up about 2.5MB versus 125KB as a simple C-string. While perhaps egregious in principle, I don't think this is really that big of a deal in practice. First, even a 400,000-word, novel-length document would "only" take up 50MB of memory in the absolute worst case — easily digestible by modern devices. Also, the eminently compressible CT format would be shrunk to a fraction of its full size during network transmission and storage. As a quick test, I saved a 125,000-atom, book-length CT to disk. Uncompressed, it took up 3.3MB; compressed via zip, a mere 570KB, or ~6x the size of the equivalent C-string.

While we could be a lot more efficient by using CTs in an operational CmRDT context, I think the resiliency of the CvRDT approach makes the memory footprint worth it. Just imagine being able to treat document merge between networked computers, physically local devices, different apps on the same machine, and perhaps even multiple threads in an almost identical manner! In the worst case — if the network is too congested to deal with these large files — we could set a target upload/download rate and exchange state snapshots less frequently when the CT gets too large.

If this isn't acceptable — and if random atom access isn't essential to the task — a RON-style compression strategy ought to be pursued.

[atom-buffers]: http://blog.atom.io/2017/10/12/atoms-new-buffer-implementation.html
[benchmarks]: https://www.mikeash.com/pyblog/friday-qa-2016-04-15-performance-comparisons-of-common-operations-2016-edition.html

## Missing Features & Future Improvements

Finally, it's worth noting a few features that my CT currently lacks.

For the moment, I've decided to omit garbage collection altogether. I'll mainly be using CTs in document-based applications with relatively small files and a limited number of collaborators, so the CTs will only be expected to grow until the document is complete. This is not just a matter of laziness: I'm very interested in building apps for mesh network style environments without any connectivity guarantees, and garbage collection immediately places constraints on the architecture of such a system. If you were using the CT for long-lived tasks such as database replication, messaging, or even preference syncing, you'd certainly want to implement the baselining strategy as described in the RDT section. 

Some CRDTs offer native undo and redo functionality, but I'm quite happy with this being delegated to a higher level. For example, in the case of string CTs, `UITextView` seamlessly turns undo and redo commands into conventional deletes and inserts. Although this may result in excess garbage compared to explicit undo and redo operations, I think this sort of strictly local approach is more architecturally correct than the alternative. (I'm not in the camp that believes remote changes should be locally undoable.) As a performance tweak and compromise, it might make sense to keep new operations separate from the main CT and only merge them when some set amount of time has passed or when the user has paused their editing. If an undo happens, these pending operations could simply be dropped. My feeling is that this would significantly increase the complexity of certain functions in the CT and create a new vector for consistency issues, but it's certainly worth investigating.

The atom priority flag adds so much to the CT's expressiveness, and I think it could be improved even further by switching it to a full integer. `INT_MIN` atoms would stick to their parent, `INT_MAX` atoms would float to the back, and the rest would be sorted in numeric order. I’m also eager to play around with alternate tree traversal orders — to see, for example, if a BFS weave might be faster than the current DFS weave for certain kinds of data. It's not yet clear to me whether these changes might break some of our invariants or intractably slow down merge.

One huge advantage to storing the weave as a contiguous array is that it could be memory-mapped and used as an object's backing data without having to deserialize it first. Better yet: if something like [Cap'n Proto](https://capnproto.org) were used to represent the atoms, this property could even be retained across the network! A user would be able to receive CT data from a peer or from disk, work with those bytes directly, and then send them right back the way they came. In preparation for this scenario, it would be a good idea to leave a bit of extra space in each atom's value for possible expansion of operations in the future. The validation function should also be made to throw an exception if an atom is discovered with an unknown case for its value enum.

# Conclusion

Whew, that was a bit more than I intended to write!

I didn't even think such a thing was possible, but CRDTs have proven to be that mythical, all-encompassing convergent data type I set out to find. You can use them in practically any computing environment and they will happily merge. They work offline just as well as online. They're relatively easy to understand without having to write a dissertation. They're composable with each other. You can use them for real-time collaboration, cloud sync, or local file sharing — all without requiring any network coordination.

But even more remarkable is the discovery of Causal Trees and operation-based CRDTs. With this formulation of CRDTs, there's finally a way to understand, design, and implement arbitrary replicated data types. By breaking up conventional data types into atomic operations and arranging them in an efficient order, CRDTs can be made out of practically anything. Operations can be used as-is or condensed into state snapshots, combining all the benefits of CmRDTs, CvRDTs, and even OT. Version vectors can be used to perform garbage collection and past revision viewing in an almost trivial way, while uniquely-identified operations can be used to diff and blame any arbitrary change in a document's history. Even conflict resolution can be precisely tailored to fit the needs of the app.

Sure, you have some tradeoffs compared to server-based sync techniques. For instance, CRDT data is always "live", even while offline. A user could accidentally edit their document on two offline devices, then find that they've merged into a mess on reconnection without any way to revert. For good and ill, users will never see the familiar version conflict dialog box. The lack of a guaranteed server also gives malicious users a whole lot more power, since they can irrevocably screw up a document without any possibility of a rollback. Servers can better manage resources by sending partial updates or by only giving a user the data they actually need. You'd also be hard-pressed to avoid servers whenever large amounts of data are concerned, such as in screen sharing or video editing.

But in exchange for a totally peer-to-peer computing future? A world full of systems finally able to freely collaborate with one another? Data-centeric code that's entirely free from network concerns?

I'd say: it's surely worth it!

---

If you find value in this article, please consider buying something through my Amazon affiliate link. (Might I suggest a nice [Roost stand](http://amzn.to/2EKIHx6) for your café-working needs?) Either way, thank you for reading! 😊

# References

OT Algorithm Papers

* [Tombstone Transformation Functions for Ensuring Consistency in Collaborative Editing Systems][ttf]

CRDT Algorithm Papers

* [Real time group editors without Operational transformation (WOOT)][woot]
* [Replicated abstract data types: Building blocks for collaborative applications (RGA)][rga]
* [Deep Hypertext with Embedded Revision Control Implemented in Regular Expressions (Causal Trees)][ct]
* [The Xi Text Engine CRDT][xi]

Meta-CRDTs

* [Pure Operation-Based Replicated Data Types][pure-op]

Distributed Networking

* [Distributed Algorithms](http://disi.unitn.it/~montreso/ds/handouts/03-gpe.pdf) (I thought this was a great primer)

Other Papers

* [Operation Transformation in Real-Time Group Editors: Issues, Algorithms, and Achievements (CP2/TP2)][cp2]
* [Controlled conflict resolution for replicated document (CRDT Layering)][layering]

Articles

* [A simple approach to building a real-time collaborative text editor][easy-collab]





[sec-ct]: #causal-trees-ct
[sec-demo]: #demo



[convergence]: https://medium.com/@raphlinus/towards-a-unified-theory-of-operational-transformation-and-crdt-70485876f72f
[ot]: https://en.wikipedia.org/wiki/Operational_transformation
[crdt]: https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type
[ct]: https://ai2-s2-pdfs.s3.amazonaws.com/6534/c371ef78979d7ed84b6dc19f4fd529caab43.pdf
[diffsync]: https://neil.fraser.name/writing/sync/
[cp2]: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.53.933&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;rep=rep1&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;type=pdf
[woot]: https://hal.archives-ouvertes.fr/inria-00108523/document
[rga]: https://pdfs.semanticscholar.org/8470/ae40470235604f40382aea4747275a6f6eef.pdf
[layering]: https://arxiv.org/pdf/1212.2338.pdf
[easy-collab]: http://digitalfreepen.com/2017/10/06/simple-real-time-collaborative-text-editor.html
[xi]: https://github.com/google/xi-editor/blob/master/doc/crdt-details.md
[xi-rope]: asdf

[ttf]: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.103.2679&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;rep=rep1&amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;amp;type=pdf
[pure-op]: https://arxiv.org/pdf/1710.04469.pdf
[lamport]: https://en.wikipedia.org/wiki/Lamport_timestamps

[crdt-playground]: https://github.com/archagon/crdt-playground

[string-wrapper]: https://github.com/archagon/crdt-playground/blob/master/CloudKitRealTimeCollabTest/Model/CausalTreeStringWrapper.swift
[container-wrapper]: https://github.com/archagon/crdt-playground/blob/master/CloudKitRealTimeCollabTest/Model/CausalTreeCloudKitTextStorage.swift
[cap]: https://en.wikipedia.org/wiki/CAP_theorem
[hlc]: http://sergeiturukin.com/2017/06/26/hybrid-logical-clocks.html
[treedoc]: http://about:blank
[logoot]: http://about:blank
[lseq]: http://about:blank
[yjs]: http://about:blank
[ron]: https://github.com/gritzko/ron
[rope]: https://en.wikipedia.org/wiki/Rope_(data_structure)