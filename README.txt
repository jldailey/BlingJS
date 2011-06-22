
BlingJS is meant to be as useful as jQuery, but more consistent.

In particular, it is more consistent about doing set-based operations:
All operations return sets wherever possible.

So, while it supports all the same basic operations as jQuery,
these operations behave slightly differently.

For instance, the .html() operation in jQuery just returns the
innerHTML of the first item in the set, in Bling, you get a set of
html, one for each DOM node in the input set.

There are also a couple things that are wholly new, and awesome. Like,
the .zip() and .zap() operations.

The .zip() operation will grab a single property from every item in
a set.  So, html() is defined as zip('innerHTML').

The .zap() operation is a way to do assignment and stay in a loosely
functional context.  So, html("new html") is defined as
zap('innerHTML', "new html").  But more than just simple assignment,
it can also 'stripe' values across a set; a common thing to want to
accomplish across list items: $("li").zap('className', ["odd", "even"]).

http://blingjs.com
