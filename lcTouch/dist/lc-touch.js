/*! 
 lcTouch v0.0.7 
 Author: Leland Cope @lelandcope 
 2013-09-15 
 */

var lcTouch;

lcTouch = angular.module("lcTouch", []);

/*
	ngTap Directive

	Description: A replacement for ngClick. This directive will take into account taps and clicks so it
	will work for both mobile and desktop browsers.

	Parameters:
	- ngTap - {string} - An expression representing what you would like to do when the element is tapped or clicked

	Usage:
	<button type="button" ng-tap="doSomething()">Click Me</button>
*/
lcTouch.directive("ngTap", [ "$timeout", function(a) {
    return function(b, c, d) {
        var e, f, g;
        e = 25;
        g = 500;
        f = false;
        c.on("touchstart", function(h) {
            var i, j, k, l, m, n, o;
            n = h.target;
            o = h.originalEvent.touches[0];
            k = o.pageX;
            l = o.pageY;
            j = function() {
                a.cancel();
                c.off("touchmove", i);
                return c.off("touchend", m);
            };
            m = function(a) {
                a.preventDefault();
                removeTapHandler();
                if (n === a.target) {
                    f = true;
                    return b.$apply(d["ngTap"]);
                }
            };
            i = function(a) {
                var b, c, d;
                d = a.originalEvent.touches[0];
                b = d.pageX;
                c = d.pageY;
                if (Math.abs(b - k) > e || Math.abs(c - l) > e) {
                    f = true;
                    return removeTapHandler();
                }
            };
            a(removeTapHandler, g);
            c.on("touchmove", i);
            return c.on("touchend", m);
        });
        return c.bind("click", function() {
            if (!f) {
                return b.$apply(d["ngTap"]);
            }
        });
    };
} ]);

/*
	ngTapOutside

	Description: A directive that listens when a user clicks or taps
	outside the area.

	Usage:
	<button type="button" ng-tap-outside="closeDropdown()">Show Dropdown</button>
*/
lcTouch.directive("ngTapOutside", [ "$timeout", function(a) {
    return function(b, c, d) {
        var e, f, g;
        g = false;
        if (angular.isDefined(d.when)) {
            b.$watch(d.when, function(b, d) {
                if (b === true) {
                    return a(function() {
                        c.bind("touchstart click", e);
                        return $("html").bind("touchend click", f);
                    });
                } else {
                    c.unbind("touchstart click", e);
                    return $("html").unbind("touchend click", f);
                }
            });
        } else {
            c.bind("touchstart click", e);
            $("html").bind("touchend click", f);
        }
        f = function(c) {
            if (!g) {
                return a(function() {
                    return b.$eval(d.ngTapOutside);
                }, 10);
            } else {
                return g = false;
            }
        };
        e = function(a) {
            a.stopPropagation();
            return g = true;
        };
        return b.$on("event:stopTapOutside", function() {
            return g = true;
        });
    };
} ]);