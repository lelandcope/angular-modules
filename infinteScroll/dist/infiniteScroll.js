/*! 
 infinteScroll v0.0.2 
 Author: Leland Cope @lelandcope 
 2013-09-17 
 */

"use strict";

var angularInfiniteScroll;

angularInfiniteScroll = angular.module("infiniteScroll", []);

angularInfiniteScroll.directive("infiniteScroll", function() {
    return {
        restrict: "A",
        link: function(scope, elem, attrs) {
            var handleScroll, threshold;
            threshold = attrs.infiniteScrollThreshold || 100;
            if (angular.isDefined(attrs.infiniteScrollDisabled)) {
                scope.$watch(attrs.infiniteScrollDisabled, function(newValue) {
                    if (!newValue) {
                        return elem.on("scroll", handleScroll);
                    } else {
                        return elem.off("scroll", handleScroll);
                    }
                });
            } else {
                elem.on("scroll", handleScroll);
            }
            return handleScroll = function(event) {
                var scrollLocation;
                scrollLocation = elem[0].scrollHeight - elem.height() - elem.scrollTop();
                if (scrollLocation <= threshold) {
                    scope.$eval(attrs.infiniteScroll);
                    return scope.$apply();
                }
            };
        }
    };
});