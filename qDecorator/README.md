infiniteScroll
===============

Infinite Scroll Module for Angular JS

### Build Instructions

<pre>
grunt build
</pre>

This will build a normal version and a minified version of the module and place it in the dist folder.

---------------

## infiniteScroll

Adds an infinite scroll listener to an element

Restricted to: Attribute

### Usage:

HTML
<pre>
&lt;div infinite-scroll="getMore()" infinite-scroll-threshold="200" infinite-scroll-disabled="disableInfiniteScroll" style="overflow: hidden; overflow-y: scroll;">
    &lt;div>
        ...... Content ......
    &lt;/div>
&lt;/div>
</pre>

JS
<pre>
$scope.getMore = function() {
	$scope.disableInfiniteScroll = true;
    
    $http.get('/some/path', {}).then(function(response) {
    	...... Add Items to the dom or $scope vars array ......
        $scope.disableInfiniteScroll = false;
    });
}
</pre>

### Parameters:

- infiniteScroll - {string} - An expression representing what you would like to do when the elements child.
- infiniteScrollThreshold - optional - {int} - deafaults to 100 - the amout of pixels before the bottom when you want to fire your function.
- infiniteScrollDisabled - optional - {string} - An expression to let the module know when to remove the scroll listener. This is best used when you need to hit an API.
