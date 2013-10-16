/*! 
 qDecorator v1.0.0 
 Description: Adds success and error callbacks to the $q service in Angular JS. 
 Author: Leland Cope @lelandcope 
 URL: https://github.com/lelandcope/angular-modules/tree/master/qDecorator 
 2013-10-04 
 */

"use strict";

var angularQDecorator;

angularQDecorator = angular.module("qDecorator", []);

angularQDecorator.config([ "$provide", function($provide) {
    return $provide.decorator("$q", [ "$delegate", function($delegate) {
        var defer;
        defer = $delegate.defer;
        $delegate.defer = function() {
            var deferred;
            deferred = defer();
            deferred.promise.success = function(cb) {
                deferred.promise.then(function(response) {
                    if (cb) {
                        return cb(response);
                    }
                });
                return deferred.promise;
            };
            deferred.promise.error = function(cb) {
                return deferred.promise.then(null, function(response) {
                    if (cb) {
                        return cb(response);
                    }
                });
            };
            return deferred;
        };
        return $delegate;
    } ]);
} ]);