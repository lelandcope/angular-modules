/*! 
 lcTouch v0.0.1 
 Author: Leland Cope @lelandcope 
 2013-09-08 
 */

var lcTouch;

lcTouch = angular.module("lcTouch", []);

/*
	lcTap Directive

	Description: A replacement for ngClick. This directive will take into account taps and clicks so it
	will work for both mobile and desktop browsers.

	Parameters:
	- lcTap - {string} - An expression representing what you would like to do when the element is tapped or clicked

	Usage:
	<button type="button" lc-tap="doSomething()">Click Me</button>
*/
lcTouch.directive("lcTap", function($timeout) {
    return function(scope, elem, attrs) {
        var distanceThreshold, tapped, timeThreshold;
        distanceThreshold = 25;
        timeThreshold = 500;
        tapped = false;
        elem.on("touchstart", function(startEvent) {
            var moveHandler, removeHandler, startX, startY, tapHandler, target, touchStart;
            target = startEvent.target;
            touchStart = startEvent.originalEvent.touches[0];
            startX = touchStart.pageX;
            startY = touchStart.pageY;
            removeHandler = function() {
                $timeout.cancel();
                elem.off("touchmove", moveHandler);
                return elem.off("touchend", tapHandler);
            };
            tapHandler = function(endEvent) {
                endEvent.preventDefault();
                removeTapHandler();
                if (target === endEvent.target) {
                    tapped = true;
                    return scope.$apply(attrs["lcTap"]);
                }
            };
            moveHandler = function(moveEvent) {
                var moveX, moveY, touchMove;
                touchMove = moveEvent.originalEvent.touches[0];
                moveX = touchMove.pageX;
                moveY = touchMove.pageY;
                if (Math.abs(moveX - startX) > distanceThreshold || Math.abs(moveY - startY) > distanceThreshold) {
                    tapped = true;
                    return removeTapHandler();
                }
            };
            $timeout(removeTapHandler, timeThreshold);
            elem.on("touchmove", moveHandler);
            return elem.on("touchend", tapHandler);
        });
        return elem.bind("click", function() {
            if (!tapped) {
                return scope.$apply(attrs["lcTap"]);
            }
        });
    };
});