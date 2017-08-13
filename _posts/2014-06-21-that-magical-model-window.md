---
layout: post
title: "That Magical Model Window"
date: 2014-06-21
categories: programming
---
I recently ran into the following issue in my Objective-C code. Let’s say you have a model class[^1] that has (among other things) an `NSMutableArray` of other model classes. How do you let outside objects modify this collection? One obvious solution is to add your own custom accessors: `addObject:`, `removeObject:`, and so forth. But that’s a little sad, since it’s essentially a simplified, non-standard duplicate of the `NSMutableArray` interface. The other obvious choice is to expose the array directly. But oh boy! If you do any pre- or post-processing on add or delete, there’s a world of pain waiting for you. It’s just not wise to let users mess around with the internals of your model like that. Maybe if `NSMutableArray` had a delegate, we could expose the array and then let the model object (as the delegate) have the final say on any changes, but sadly, to my knowledge, it does not. (`NSArrayController` on OSX and `CFArray` might have that functionality, but that’s just too much work for too little gain.) Finally, there’s the issue of key-value observation. How do we observe changes to the array? If we simply observe the array property, we’ll only get notifications when it’s set. Do we observe the array’s `count` property? (Doesn’t work, and wouldn’t handle replacement even if it did.) Do we add manual KVO calls to our custom accessors? Do we set a property somewhere whenever the array is modified?

It turns out there’s a solution to all these problems, and it involves something called key-value coding of collections.

<!--more-->

Let’s backtrack a bit. You might know that when you declare (and optionally synthesize) a property, you automatically get a “key” to access that property — basically, the name of the property as a string. This means that any outside class can access and observe your property by using key path notation. (If `object1` contains `object2`, and `object2` contains `myProperty`, you can access `myProperty` from `object1` by using the  “object2.myProperty” key path in a `valueForKeyPath:` call on `object1`.) As it turns out, this automatic property coding is not the only type of key-value coding available. There are also special kinds of key-value coding for ordered and unordered collections, and these do *not* get generated automatically, even for properties that are arrays or sets. (This is what Apple means when they talk about “to-many relationships” in their KVC documentation. When discussing model objects, a “to-many relationship” is simply an array or set property that contains other model objects. It seems that Apple prefers to think of the model object graph as a series of relationships instead of objects with array or set properties, which explains the slightly odd terminology.)

KVC is based heavily on naming conventions. You enable KVC for an array or set property by simply adding a small set of methods in the containing class with the corresponding property name in the selector. For example, if you have an `NSMutableArray` called `names` in your model object, all you have to do is (at minimum) implement the following methods[^2] in the class containing the array:

* `countOfNames`
* `objectInNamesAtIndex:`
* `insertObject:inNamesAtIndex:`
* `removeObjectFromNamesAtIndex:`

…and voilà! Not only can you now access the array members using key path notation, but you also get KVO of insertions, removals, and replacements (along with the affected indices) for free. The `NSMutableArray` interface already contains all these methods, so you can simply forward the calls to `names`, along with any pre- or post-processing as needed. Now you can declare these methods as the public interface to your array and feel good that you’re using a documented standard. (You can read about a few optional methods you can implement, as well as the corresponding methods for sets, in Apple’s [“Key-Value Coding Programming Guide”](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html).)

But here’s the best part. Once you’ve implemented these passthrough methods, you get access to `mutableArrayValueForKey:`. This method returns an object that looks and acts like an `NSMutableArray`, but instead of modifying your array directly, it proxies all its calls through the KVC methods you implemented earlier. This means that you can *safely* present this faux-`NSMutableArray` as the interface to your collection, allowing users to exploit the full power of `NSMutableArray`‘s interface while still maintaining direct control over how the data gets added and removed!

Here’s a sample implementation that I particularly like. (Pardon the lack of ARC-ness, I’m still getting on that train.) Public header:

    // MyModelClass.h

    @interface MyModelClass : NSObject

    @property (nonatomic, readonly, getter=namesProxy) NSMutableArray* names;

    // optional declarations to make your public interface explicit
    -(NSUInteger) countOfNames;
    -(NSString*) objectInNamesAtIndex:(NSUInteger)index;
    -(void) insertObject:(NSString*)object inNamesAtIndex:(NSUInteger)index;
    -(void) removeObjectFromNamesAtIndex:(NSUInteger)index;

    @end

Private header[^3]:

    // MyModelClass_.h

    #import "MyModelClass.h"

    @interface MyModelClass ()

    @property (nonatomic, retain) NSMutableArray* namesMutable;

    @end

Implementation:

    // MyModelClass.m

    #import "MyModelClass_.h"

    @implementation MyModelClass

    @dynamic names;

    -(id) init
    {
        self = [super init];
        if (self)
        {
            self.namesMutable = [NSMutableArray array];
        }
        return self;
    }

    -(NSMutableArray*) namesProxy
    {
        return [self mutableArrayValueForKey:@"names"];
    }

    -(NSUInteger) countOfNames
    {
        return [self.namesMutable count];
    }

    -(NSString*) objectInNamesAtIndex:(NSUInteger)index
    {
        return [self.namesMutable objectAtIndex:index];
    }

    -(void) insertObject:(NSString*)object inNamesAtIndex:(NSUInteger)index
    {
        return [self.namesMutable insertObject:object atIndex:index];
    }

    -(void) removeObjectFromNamesAtIndex:(NSUInteger)index
    {
        return [self.namesMutable removeObjectAtIndex:index];
    }

    @end

With this design, you can observe `names` and get notifications whenever the `namesMutable` array is modified, *even though there’s no actual property named `names`!* You can also retrieve the `names` property directly from the object (which creates the proxy array) and modify it to your liking. (The getter is called `namesProxy` to avoid confusing the `mutableArrayValueForKey:` call.) Nobody without the private header has access to the internal `namesMutable` array; everything is instead handled either through the standard KVC collection methods or through the proxy array.

With this pattern, we can have it all: a standard interface to mutate our model’s collections while still giving the model final authority, the ability to leverage the full power of `NSArray` and `NSSet` for these mutations without having to write a ton of custom code, and the ability to key-value observe collections in detail. Pretty useful![^4]

For a detailed look at KVO and KVC, [read this excellent article on objc.io](http://www.objc.io/issue-7/key-value-coding-and-observing.html). They cover a similar pattern in the last section of the article, but my implementation is superior [to their sample code](https://github.com/objcio/issue-7-contact-editor/blob/master/Contact%20Editor/ContactList.mm#L51) in that it allows you to both access `names` directly *and* observe it. Their “Primes” example also does not work.

**Post-script.** In my case, I had one additional complication: my array had to always be sorted. This left me with a bit of a dilemma. If I sorted the proxy array right in the `insertObject:in<Key>AtIndex:`, my receivers would get two KVO calls: one for the initial insert, and one for the re-insert from the sort. This meant that if my observers always expected my data to be sorted, the first call would give them bad data. On the other hand, if I sorted my real array instead of the proxy array, there would be no KVO notifications for the changes from the sort, and so the index passed to my observers would be wrong. I tried implementing the interface as an unordered collection (while leaving my data as an array) and everything worked correctly, but the interface mismatch irked me. Finally, I found the one true solution: if you implement the class method `automaticallyNotifiesObserversOf<Key>` and return a big fat `NO`, you can implement your own notifications for all the passthrough calls, meaning that you can sort on insert and only send a single notification. This required a bit more boilerplate code, but it was a small price to pay for a perfect implementation!

[^1]: As in MVC model.
[^2]: Incidentally, these KVC passthrough methods are almost identical to the methods you need to override if you’re subclassing `NSArray` or `NSSet`. The whole process feels oddly like multiple inheritance.
[^3]: In case you’re confused, you can create multiple header files using class extensions (otherwise known as anonymous categories) to simplify your public interface. Read more about ‘em in Apple’s [“Customizing Existing Classes”](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html) documentation.
[^4]: With key-value coding of collections, you can do a few more interesting things with key paths. Check out the [NSHipster article on KVC collection operators](http://nshipster.com/kvc-collection-operators/) for a brief overview.