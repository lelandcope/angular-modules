/*! 
 lcTouch v0.3.0 
 Author: Leland Cope @lelandcope 
 2013-12-30 
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
lcTouch.directive("ngTap", [ "$timeout", function($timeout) {
    return function(scope, elem, attrs) {
        var distanceThreshold, tapped, timeThreshold;
        distanceThreshold = 25;
        timeThreshold = 500;
        tapped = false;
        elem.on("touchstart", function(startEvent) {
            var moveHandler, removeTapHandler, startX, startY, tapHandler, target, touchStart;
            target = startEvent.target;
            touchStart = startEvent.originalEvent.touches[0];
            startX = touchStart.pageX;
            startY = touchStart.pageY;
            removeTapHandler = function() {
                $timeout.cancel();
                elem.off("touchmove", moveHandler);
                return elem.off("touchend", tapHandler);
            };
            tapHandler = function(endEvent) {
                endEvent.preventDefault();
                removeTapHandler();
                if (target === endEvent.target) {
                    tapped = true;
                    return scope.$apply(attrs["ngTap"]);
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
                return scope.$apply(attrs["ngTap"]);
            }
        });
    };
} ]);

/*
	ngDbltap

	Description: A replacement for ngDblclick. This directive will take into account taps and clicks so it
	will work for both mobile and desktop browsers.

	Usage:
	<button type="button" ng-dbltap="doSomething()">Click Me</button>
*/
lcTouch.directive("ngDbltap", [ "$timeout", function($timeout) {
    return function(scope, elem, attrs) {
        var distanceThreshold, tapcount, tapped, timeThreshold;
        distanceThreshold = 25;
        timeThreshold = 500;
        tapped = false;
        tapcount = 0;
        elem.on("touchstart", function(startEvent) {
            var moveHandler, removeTapHandler, startX, startY, tapHandler, target, touchStart;
            target = startEvent.target;
            touchStart = startEvent.originalEvent.touches[0];
            startX = touchStart.pageX;
            startY = touchStart.pageY;
            removeTapHandler = function() {
                $timeout.cancel();
                elem.off("touchmove", moveHandler);
                elem.off("touchend", tapHandler);
                return tapcount = 0;
            };
            tapHandler = function(endEvent) {
                endEvent.preventDefault();
                tapcount++;
                if (tapcount >= 2) {
                    removeTapHandler();
                    if (target === endEvent.target) {
                        tapped = true;
                        return scope.$apply(attrs["ngDbltap"]);
                    }
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
        return elem.bind("dblclick", function() {
            if (!tapped) {
                return scope.$apply(attrs["ngDbltap"]);
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
lcTouch.directive("ngTapOutside", [ "$timeout", function($timeout) {
    return function(scope, elem, attrs) {
        var onElementTouchStart, onTouchEnd, stopEvent;
        stopEvent = false;
        if (angular.isDefined(attrs.when)) {
            scope.$watch(attrs.when, function(newValue, oldValue) {
                if (newValue === true) {
                    return $timeout(function() {
                        elem.bind("touchstart click", onElementTouchStart);
                        return $("html").bind("touchend click", onTouchEnd);
                    });
                } else {
                    elem.unbind("touchstart click", onElementTouchStart);
                    return $("html").unbind("touchend click", onTouchEnd);
                }
            });
        } else {
            elem.bind("touchstart click", onElementTouchStart);
            $("html").bind("touchend click", onTouchEnd);
        }
        onTouchEnd = function(event) {
            if (!stopEvent) {
                return $timeout(function() {
                    return scope.$eval(attrs.ngTapOutside);
                }, 10);
            } else {
                return stopEvent = false;
            }
        };
        onElementTouchStart = function(event) {
            event.stopPropagation();
            return stopEvent = true;
        };
        return scope.$on("event:stopTapOutside", function() {
            return stopEvent = true;
        });
    };
} ]);

/*
	ngSwipeDown, ngSwipeUp, ngSwipeLeft, ngSwipeRight

	Description: Adds swipe directives

	Usage:
	<div ng-swipe-down="onswipedown()">
		...... HTML ......
	</div>
*/
lcTouch.factory("$swipe", [ function() {
    return {
        bind: function(elem, events) {
            var endX, endY, ontouchend, ontouchmove, ontouchstart, startX, startY;
            startX = 0;
            startY = 0;
            endX = 0;
            endY = 0;
            ontouchstart = function(e) {
                var touch;
                touch = e.originalEvent.touches[0];
                startX = touch.pageX;
                startY = touch.pageY;
                elem.on("touchmove", ontouchmove);
                elem.on("touchend", ontouchend);
                if (events.start) {
                    return events.start(elem, [ startX, startY ]);
                }
            };
            ontouchmove = function(e) {
                var touch;
                touch = e.originalEvent.touches[0];
                endX = touch.pageX;
                endY = touch.pageY;
                if (events.move) {
                    return events.move(elem, [ endX, endY ]);
                }
            };
            ontouchend = function(e) {
                elem.off("touchmove", ontouchmove);
                elem.off("touchend", ontouchend);
                if (events.end) {
                    events.end(elem, [ startX - endX, startY - endY ]);
                }
                startX = 0;
                startY = 0;
                endX = 0;
                return endY = 0;
            };
            return elem.on("touchstart", ontouchstart);
        }
    };
} ]);

lcTouch.directive("ngSwipeDown", [ "$swipe", function($swipe) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var onend, threshold;
            threshold = Number(attrs.ngSwipeDownThreshold) || 70;
            onend = function(elem, amounts) {
                var amount;
                amount = amounts[1];
                if (amount < 0 && Math.abs(amount) >= threshold) {
                    return scope.$apply(attrs["ngSwipeDown"]);
                }
            };
            return $swipe.bind(elem, {
                end: onend
            });
        }
    };
} ]);

lcTouch.directive("ngSwipeUp", [ "$swipe", function($swipe) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var onend, threshold;
            threshold = Number(attrs.ngSwipeUpThreshold) || 70;
            onend = function(elem, amounts) {
                var amount;
                amount = amounts[1];
                if (amount > 0 && Math.abs(amount) >= threshold) {
                    return scope.$apply(attrs["ngSwipeUp"]);
                }
            };
            return $swipe.bind(elem, {
                end: onend
            });
        }
    };
} ]);

lcTouch.directive("ngSwipeRight", [ "$swipe", function($swipe) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var onend, threshold;
            threshold = Number(attrs.ngSwipeRightThreshold) || 70;
            onend = function(elem, amounts) {
                var amount;
                amount = amounts[0];
                if (amount < 0 && Math.abs(amount) >= threshold) {
                    return scope.$apply(attrs["ngSwipeRight"]);
                }
            };
            return $swipe.bind(elem, {
                end: onend
            });
        }
    };
} ]);

lcTouch.directive("ngSwipeLeft", [ "$swipe", function($swipe) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var onend, threshold;
            threshold = Number(attrs.ngSwipeLeftThreshold) || 70;
            onend = function(elem, amounts) {
                var amount;
                amount = amounts[0];
                if (amount > 0 && Math.abs(amount) >= threshold) {
                    return scope.$apply(attrs["ngSwipeLeft"]);
                }
            };
            return $swipe.bind(elem, {
                end: onend
            });
        }
    };
} ]);

/*
	ngDragSwipeHorizontal

	Description: Adds a drag swipe to a carousal
*/
lcTouch.directive("ngDragSwipeHorizontal", [ "$swipe", "$timeout", function($swipe, $timeout) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var cleanArray, minDistance, minInertia, movable, notInArray, offset, onend, onmove, onstart, totalChildren, wrapperWidth;
            offset = 0;
            totalChildren = elem.children().length;
            wrapperWidth = elem.parent().width();
            minDistance = attrs.ngDragSwipeHorizontalMinDistance || wrapperWidth * .5;
            minInertia = attrs.ngDragSwipeHorizontalMinInertia || .65;
            movable = [];
            onstart = function(el, amounts, e) {
                return $(e.currentTarget).data("touchStart", {
                    x: amounts[0],
                    y: amounts[1],
                    timeStamp: e.timeStamp
                });
            };
            onend = function(el, amounts, e) {
                var distanceMoved, speed, startEvent, time, x1, x2;
                startEvent = $(e.currentTarget).data("touchStart");
                x1 = offset * wrapperWidth;
                x2 = Math.abs(parseInt($(elem.children()[offset]).css("x")));
                distanceMoved = x1 - x2;
                speed = Math.abs(Math.max(Math.min((x2 - x1) / Math.max(e.timeStamp - startEvent.timeStamp, 1), 1), -1));
                if (distanceMoved < 0 && (Math.abs(distanceMoved) >= minDistance || speed >= minInertia) && totalChildren !== offset + 1) {
                    offset++;
                } else if (distanceMoved > 0 && (Math.abs(distanceMoved) >= minDistance || speed >= minInertia) && offset !== 0) {
                    offset--;
                }
                if (distanceMoved !== 0) {
                    time = 500 - 500 * (75 * speed / 100);
                    $(movable).transition({
                        x: offset * -wrapperWidth + "px"
                    }, time, "out");
                    return $timeout(function() {
                        return $(notInArray(elem.children(), movable)).css({
                            x: offset * -wrapperWidth + "px"
                        });
                    }, time);
                }
            };
            onmove = function(el, amounts, e) {
                var placement, startEvent;
                startEvent = $(e.currentTarget).data("touchStart");
                placement = amounts[0] - startEvent.x + offset * -wrapperWidth;
                if (placement <= 0 && placement >= (totalChildren - 1) * -wrapperWidth) {
                    movable = cleanArray([ elem.children()[offset], elem.children()[offset - 1], elem.children()[offset + 1] ]);
                    return $(movable).css({
                        x: placement + "px"
                    });
                }
            };
            cleanArray = function(arr) {
                var el, i, tmp, _i, _len;
                tmp = [];
                for (i = _i = 0, _len = arr.length; _i < _len; i = ++_i) {
                    el = arr[i];
                    if (el) {
                        tmp.push(el);
                    }
                }
                return tmp;
            };
            notInArray = function(arr1, arr2) {
                var el, i, tmp, _i, _len;
                tmp = [];
                for (i = _i = 0, _len = arr1.length; _i < _len; i = ++_i) {
                    el = arr1[i];
                    if (arr2.indexOf(el) === -1) {
                        tmp.push(el);
                    }
                }
                return tmp;
            };
            return $swipe.bind(elem.children(), {
                move: onmove,
                start: onstart,
                end: onend
            });
        }
    };
} ]);