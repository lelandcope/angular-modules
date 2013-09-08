lcTouch
===============

An Angular.js touch library

### Build Instructions

<pre>
grunt build
</pre>

This will build a normal version and a minified version of the module and place it in the dist folder.

### Directives List
[lcTap](#lcTap) - Adds tap support with a fallback to clicks for desktop browsers

---------------

## lcTap

Adds tap support with a fallback to clicks for desktop browsers

Restricted to: Attribute

### Usage:

<pre>
&lt;button type="button" lc-tap="doSomething()">Click Me&lt;/button>
</pre>

### Parameters:

- lcTap - {string} - An expression representing what you would like to do when the element is tapped or clicked
