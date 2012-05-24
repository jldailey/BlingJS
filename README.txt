BlingJS is meant to be as useful as jQuery, but more consistent.

In particular, it is more consistent about doing set-based operations:
All operations return sets wherever possible.

So, while it supports all the same basic operations as jQuery,
these operations behave slightly differently.

For instance, the .html() operation in jQuery just returns the
innerHTML of the first item in the set, in Bling, you get a set of
html, one for each DOM node in the input set.

This means that basic set primitives like .intersect() and .union()
become more powerful.  For instance, .parents() returns the chain of all
parents up to the document node; intersecting this with some other set of nodes
(say, a set of <li> elements, will find the exact list-item(s) you are within)

There are also a couple things that are wholly new, and awesome. Like,
the .select() and .zap() operations.

The .select() operation will grab a single property from every item in
a set.  So, html() is defined as select('innerHTML').  You can also extract
nested values easily, as in select('style.color'), arbitrary nesting depth
is supported [e.g. select('foo.bar.baz.bok')].

The .zap() operation is a way to do assignment and stay in a loosely
functional context.  So, html("new html") is defined as
zap('innerHTML', "new html").  But more than just simple assignment,
it can also 'stripe' values across a set; a common thing to want to
accomplish across list items: $("li").zap('className', ["odd", "even"]).

For a more complete listing of what's great about it [like synth()],
please visit the website:

http://blingjs.com
