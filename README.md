BlingJS is meant to be as useful as jQuery, but more consistent.

In particular, it is more consistent about doing set-based operations:
* All operations return sets wherever possible.

So, while it supports all the same basic operations as jQuery,
these operations behave slightly differently.

For instance, the `.html()` operation in jQuery just returns the
innerHTML of the _first_ DOM node in the input; here, you get a set of
html strings, one from each node.

This **set philosophy** means that basic set primitives like `.intersect()` and `.union()`
are more useful (and they are part of the "core" plugin).

Highly modular, almost everything is a plugin, as much as possible.

There are also some new things, like the `.select()` and `.zap()` operations.

The `.select()` operation will grab a single property from every item in
a set.  So, `.html()` is a shortcut for `.select('innerHTML')`.  You can also extract
nested values easily, as in `.select('style.color')`, arbitrary nesting depth, and 
arrays, are supported, e.g. `.select('foo.bar.0.baz')`.

The `.zap()` operation is a way to do assignment and stay in a loosely
functional context.  So, `.html("new html")` is a shortcut for
`.zap('innerHTML', "new html")`.  But more than just simple assignment,
it can also 'stripe' values across a set; a common thing to want to
accomplish across list items, e.g. `$("li").zap('className', ["odd", "even"])`.

http://blingjs.com
