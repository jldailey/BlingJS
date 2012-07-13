# About
-------

BlingJS is inspired by jQuery, but more consistent.
In particular, it is more consistent about doing set-based operations.

* All operations return sets wherever possible.
* As much as possible is a plugin, even core operations.

So, while it supports all the same basic operations as jQuery, they behave
slightly different.

For instance, the `.html()` operation.
* in jQuery, returns the innerHTML of the _first_ DOM node in the set.
* in Bling, you get a set of html strings, one from _each_ node.

This **set philosophy** means that set operations are useful:
* `.intersect()`
* `.union()`

These kinds of set operations are part of the "core" plugin.

Everything is a plugin; since plugins can not only extend the prototype (by returning an object full of extensions),
but can also inject code into the Bling constructor (by using $.pipe), there is very little needed outside.

The core plugin also provides some cool new things, like the `.select()` and `.zap()` operations.

The `.select()` operation will collect a single property from every item in
a set.
> `.html()` is short-hand for `.select('innerHTML')`.

* You can extract nested values, e.g. `.select('style.color')`.
* Arbitrary nesting depth, and arrays, e.g. `.select('childNodes.1.className')`.

The `.zap()` operation is a way to do assignment and stay in a loosely
functional context.
> `.html("new html")` is short-hand for `.zap('innerHTML', "new html")`.

More than just simple assignment, it can also 'stripe' values across a set;
a common thing to want to accomplish across list items.

    $("li").zap('className', ["odd", "even"])
    $("li").zap('childNodes.1.style.top', -> $.px @+10 )

This example moves every list-item's 2nd-child up by 10 pixels, and allows you to continue chaining
on the list-items (not the moved children in this case).

# Installation
--------------
    $ npm install bling
    $ node
    > require("bling")
    > $([1,2,3,4]).scale(2.5).sum()
    25

