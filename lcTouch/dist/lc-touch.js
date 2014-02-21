/*! 
 lcTouch v0.4.23 
 Author: Leland Cope @lelandcope 
 2014-02-21 
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
                        elem.bind("touchstart mousedown", onElementTouchStart);
                        return $("html").bind("touchend mouseup", onTouchEnd);
                    });
                } else {
                    elem.unbind("touchstart mousedown", onElementTouchStart);
                    return $("html").unbind("touchend mouseup", onTouchEnd);
                }
            });
        } else {
            elem.bind("touchstart mousedown", onElementTouchStart);
            $("html").bind("touchend mouseup", onTouchEnd);
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
                    return events.start(elem, [ startX, startY ], e);
                }
            };
            ontouchmove = function(e) {
                var touch;
                touch = e.originalEvent.touches[0];
                endX = touch.pageX;
                endY = touch.pageY;
                if (events.move) {
                    return events.move(elem, [ endX, endY ], e);
                }
            };
            ontouchend = function(e) {
                elem.off("touchmove", ontouchmove);
                elem.off("touchend", ontouchend);
                if (events.end) {
                    events.end(elem, [ startX - endX, startY - endY ], e);
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

	Description: Drag Swipe Horizontally
*/
lcTouch.factory("$ngDragSwipeHorizontal", [ "$swipe", "$timeout", function($swipe, $timeout) {
    var DSH, cleanArray, notInArray;
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
    DSH = function() {
        function DSH() {}
        DSH.prototype.offset = 0;
        DSH.prototype.totalChildren = 0;
        DSH.prototype.wrapperWidth = 0;
        DSH.prototype.minDistance = 0;
        DSH.prototype.minInertia = 0;
        DSH.prototype.movable = [];
        DSH.prototype.infiniteScroll = false;
        DSH.prototype.animating = false;
        DSH.prototype.elem = null;
        DSH.prototype.attrs = null;
        DSH.prototype.bind = function(elem, attrs, infScroll) {
            var onend, onmove, onstart, self;
            self = this;
            self.elem = elem;
            self.attrs = attrs;
            self.totalChildren = self.elem.children().length;
            self.wrapperWidth = self.elem.parent().width();
            self.minDistance = attrs.ngDragSwipeHorizontalMinDistance || self.wrapperWidth * .5;
            self.minInertia = attrs.ngDragSwipeHorizontalMinInertia || .65;
            self.infiniteScroll = infScroll || false;
            onstart = function(el, amounts, e) {
                e.stopPropagation();
                return $(e.currentTarget).data("touchStart", {
                    x: amounts[0],
                    y: amounts[1],
                    timeStamp: e.timeStamp
                });
            };
            onend = function(el, amounts, e) {
                var distanceMoved, speed, startEvent, time, x1, x2;
                e.stopPropagation();
                startEvent = $(e.currentTarget).data("touchStart");
                x1 = self.offset * self.wrapperWidth;
                x2 = Math.abs(parseInt($(self.elem.children()[self.offset]).css("x")));
                distanceMoved = x1 - x2;
                speed = Math.abs(Math.max(Math.min((x2 - x1) / Math.max(e.timeStamp - startEvent.timeStamp, 1), 1), -1));
                if (distanceMoved < 0 && (Math.abs(distanceMoved) >= self.minDistance || speed >= self.minInertia) && self.totalChildren !== self.offset + 1) {
                    self.offset++;
                } else if (distanceMoved > 0 && (Math.abs(distanceMoved) >= self.minDistance || speed >= self.minInertia) && self.offset !== 0) {
                    self.offset--;
                }
                if (distanceMoved !== 0) {
                    time = 500 - 500 * (75 * speed / 100);
                    $(self.movable).transition({
                        x: self.offset * -self.wrapperWidth + "px"
                    }, time, "out");
                    return $timeout(function() {
                        $(notInArray(self.elem.children(), self.movable)).css({
                            x: self.offset * -self.wrapperWidth + "px"
                        });
                        if (self.infiniteScroll) {
                            return self.resetOrder(self.elem, attrs);
                        }
                    }, time);
                }
            };
            onmove = function(el, amounts, e) {
                var placement, startEvent;
                e.stopPropagation();
                startEvent = $(e.currentTarget).data("touchStart");
                placement = amounts[0] - startEvent.x + self.offset * -self.wrapperWidth;
                if (placement <= 0 && placement >= (self.totalChildren - 1) * -self.wrapperWidth) {
                    self.movable = cleanArray([ self.elem.children()[self.offset], self.elem.children()[self.offset - 1], self.elem.children()[self.offset + 1] ]);
                    return $(self.movable).css({
                        x: placement + "px"
                    });
                }
            };
            if (self.infiniteScroll) {
                self.resetOrder();
            }
            return $swipe.bind(self.elem.children(), {
                move: onmove,
                start: onstart,
                end: onend
            });
        };
        DSH.prototype.resetOrder = function() {
            var self;
            self = this;
            if (self.elem.children().length > 2) {
                if (self.offset === 0 && self.infiniteScroll) {
                    self.elem.prepend(self.elem.children().last());
                    self.offset = 1;
                } else if (self.offset > 1 && self.infiniteScroll) {
                    self.elem.append(self.elem.children().first());
                    self.offset = 1;
                }
                return $(self.elem.children()).css({
                    x: self.offset * -self.wrapperWidth + "px"
                });
            }
        };
        DSH.prototype.next = function() {
            var self, time;
            self = this;
            if (self.animating) {
                return;
            }
            self.offset++;
            time = 500;
            self.animating = true;
            self.movable = cleanArray([ self.elem.children()[self.offset], self.elem.children()[self.offset - 1], self.elem.children()[self.offset + 1] ]);
            $(self.movable).transition({
                x: self.offset * -self.wrapperWidth + "px"
            }, time, "out");
            return $timeout(function() {
                if (self.infiniteScroll) {
                    self.resetOrder();
                }
                return self.animating = false;
            }, time);
        };
        DSH.prototype.previous = function() {
            var self, time;
            self = this;
            if (self.animating) {
                return;
            }
            self.offset--;
            time = 500;
            self.animating = true;
            self.movable = cleanArray([ self.elem.children()[self.offset], self.elem.children()[self.offset - 1], self.elem.children()[self.offset + 1] ]);
            $(self.movable).transition({
                x: self.offset * -self.wrapperWidth + "px"
            }, time, "out");
            return $timeout(function() {
                if (self.infiniteScroll) {
                    self.resetOrder();
                }
                return self.animating = false;
            }, time);
        };
        return DSH;
    }();
    return function() {
        return new DSH();
    };
} ]);

lcTouch.directive("ngDragSwipeHorizontal", [ "$ngDragSwipeHorizontal", function($ngDragSwipeHorizontal) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            return $ngDragSwipeHorizontal().bind(elem, attrs);
        }
    };
} ]);

/*
	lcCarouselHorizontal

	Description: Horizontal Carousel
*/
lcTouch.directive("lcCarouselHorizontal", [ "$ngDragSwipeHorizontal", "$compile", "$timeout", function($ngDragSwipeHorizontal, $compile, $timeout) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var $dsh, autoScrollTimeout, autoScrollUntilClick, start;
            scope.forceArrows = attrs.forceArrows;
            scope.lcCarouselHorizontal = attrs.lcCarouselHorizontal;
            scope.carouselWidth = "0px";
            scope.carouselHeight = "0px";
            autoScrollUntilClick = scope.$eval(attrs.lcCarouselAutoScroll) || false;
            autoScrollTimeout = null;
            $dsh = $ngDragSwipeHorizontal();
            scope.items = scope.$eval(attrs.lcCarouselHorizontal);
            scope.itemsRendered = function() {
                return $timeout(start, 100);
            };
            return start = function() {
                var $parent, arrowInner, autoScroll, forceArrows, lArrow, rArrow;
                $dsh.bind(elem, attrs, true);
                $parent = elem.parent();
                forceArrows = attrs.forceArrows;
                scope.carouselWidth = $parent.width() + "px";
                scope.carouselHeight = $parent.height() + "px";
                arrowInner = $("<div/>").css({
                    display: "table-cell",
                    verticalAlign: "middle",
                    height: $parent.height()
                });
                lArrow = $('<div class="arrow" ng-click="prevCarouselSlide()" />').css({
                    position: "absolute",
                    top: 0,
                    left: 0,
                    height: $parent.height(),
                    padding: "0 0 0 10px",
                    cursor: "pointer"
                }).append(arrowInner.clone().append('<i class="icon-chevron-sign-left"></i>'));
                rArrow = $('<div class="arrow" ng-click="nextCarouselSlide()" />').css({
                    position: "absolute",
                    top: 0,
                    right: 0,
                    height: $parent.height(),
                    display: "table-cell",
                    verticalAlign: "middle",
                    padding: "0 10px 0 0",
                    cursor: "pointer"
                }).append(arrowInner.clone().append('<i class="icon-chevron-sign-right"></i>'));
                $parent.css({
                    position: "relative"
                });
                elem.css({
                    width: $parent.width() * elem.children().length,
                    height: $parent.height(),
                    display: "block",
                    opacity: 0
                });
                $timeout(function() {
                    return scope.$apply();
                }, 100);
                $timeout(function() {
                    $dsh.resetOrder();
                    if (typeof window.ontouchstart === "undefined" && elem.children().length > 2) {
                        $parent.append($compile(lArrow)(scope));
                        $parent.append($compile(rArrow)(scope));
                    }
                    elem.animate({
                        opacity: 1
                    }, 300);
                    if (autoScrollUntilClick) {
                        return autoScrollTimeout = $timeout(autoScroll, autoScrollUntilClick);
                    }
                }, 999);
                autoScroll = function() {
                    $timeout.cancel(autoScrollTimeout);
                    scope.nextCarouselSlide(false);
                    return autoScrollTimeout = $timeout(autoScroll, autoScrollUntilClick);
                };
                scope.nextCarouselSlide = function(cancelAutoScroll) {
                    cancelAutoScroll || (cancelAutoScroll = true);
                    if (cancelAutoScroll) {
                        $timeout.cancel(autoScrollTimeout);
                    }
                    return $timeout(function() {
                        $dsh.next();
                        return scope.$emit("event:lcCarouselNext", elem);
                    }, 1);
                };
                return scope.prevCarouselSlide = function(cancelAutoScroll) {
                    cancelAutoScroll || (cancelAutoScroll = true);
                    if (cancelAutoScroll) {
                        $timeout.cancel(autoScrollTimeout);
                    }
                    return $timeout(function() {
                        $dsh.previous();
                        return scope.$emit("event:lcCarouselPrevious", elem);
                    }, 1);
                };
            };
        }
    };
} ]);

lcTouch.directive("lcCarouselItemsRendered", [ "$timeout", function($timeout) {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            if (scope.$last === true) {
                return elem.ready(function() {
                    return $timeout(function() {
                        return scope.$apply(attrs["lcCarouselItemsRendered"]);
                    }, 200);
                });
            }
        }
    };
} ]);