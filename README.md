BlingJS is meant to be as useful as jQuery, but more consistent.

In particular, it is more consistent about doing set-based operations:
* All operations return sets wherever possible.
* As much as possible is a plugin, even core operations.

So, while it supports all the same basic operations as jQuery, they behave
slightly different.

For instance, the `.html()` operation.
* in jQuery, returns the innerHTML of the _first_ DOM node in the input
* here, you get a set of html strings, one from _each_ node.

This **set philosophy** means that set operations are useful:
* `.intersect()`
* `.union()`

These kinds of set operations are part of the "core" plugin, and there also some
new things, like the `.select()` and `.zap()` operations.

The `.select()` operation will collect a single property from every item in
a set.
> `.html()` is a shortcut for `.select('innerHTML')`.
* You can extract nested values, e.g. `.select('style.color')`.
* Arbitrary nesting depth, and arrays, e.g. `.select('foo.bar.0.baz')`.

The `.zap()` operation is a way to do assignment and stay in a loosely
functional context.
> `.html("new html")` is a shortcut for `.zap('innerHTML', "new html")`.

More than just simple assignment, it can also 'stripe' values across a set;
a common thing to want to accomplish across list items.
> `$("li").zap('className', ["odd", "even"])`.

It can map a function across nested properties of your set items:
> `$("li").zap('style.top', -> $.px @+10 )`
This example moves every list-item up 10 pixels, and allows you to continue chaining
on the list-items.

http://blingjs.com
