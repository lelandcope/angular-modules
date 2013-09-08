lcTouch
===============

An Angular.js touch library

### Build Instructions

<pre>
grunt build
</pre>

This will build a normal version and a minified version of the module and place it in the dist folder.

---------------

### Directives List
[ngTap](#ngtap) - Adds tap support with a fallback to clicks for desktop browsers

[ngTapOutside](#ngtapoutside) - Adds tap support for when a user taps or clicks outside a designated area

---------------

## ngTap

Adds tap support with a fallback to clicks for desktop browsers

Restricted to: Attribute

### Usage:

<pre>
&lt;button type="button" ng-tap="doSomething()">Click Me&lt;/button>
</pre>

### Parameters:

- ngTap - {string} - An expression representing what you would like to do when the element is tapped or clicked

===============

## ngTapOutside

Adds tap support for when a user taps or clicks outside a designated area

Restricted to: Attribute

### Usage:

<pre>
&lt;button type="button" ng-tap-outside="closeDropdown()" when="dropdownOpen == true">Show Dropdown&lt;/button>
</pre>

### Parameters:

- ngTapOutside - {string} - An expression representing what you would like to do when the element is tapped or clicked
- when - optional - {string} - An expression that will return a boolean which represents when it should listen for tap outside events
