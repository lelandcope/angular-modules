'use strict'

angularInfiniteScroll = angular.module 'infiniteScroll', []

angularInfiniteScroll.directive 'infiniteScroll', ()->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			threshold = attrs.infiniteScrollThreshold or 100

			if angular.isDefined attrs.infiniteScrollDisabled
				scope.$watch attrs.infiniteScrollDisabled, (newValue)->
					unless newValue
						elem.on 'scroll', handleScroll
					else
						elem.off 'scroll', handleScroll
			else
				elem.on 'scroll', handleScroll

			handleScroll = (event)->
				scrolllocation = ((elem[0].scrollHeight - elem.height()) - elem.scrollTop())

				if scrollLocation <= threshold
					scope.$eval attrs.infiniteScroll
					scope.$apply()
	}
