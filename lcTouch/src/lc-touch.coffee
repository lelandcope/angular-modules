lcTouch = angular.module 'lcTouch', []

###
	ngTap Directive

	Description: A replacement for ngClick. This directive will take into account taps and clicks so it
	will work for both mobile and desktop browsers.

	Parameters:
	- ngTap - {string} - An expression representing what you would like to do when the element is tapped or clicked

	Usage:
	<button type="button" ng-tap="doSomething()">Click Me</button>
###

lcTouch.directive 'ngTap', ['$timeout', ($timeout)->
	(scope, elem, attrs)->
		distanceThreshold    = 25
		timeThreshold        = 500
		tapped               = false

		elem.on 'touchstart', (startEvent)->
			target      = startEvent.target
			touchStart  = startEvent.originalEvent.touches[0]
			startX      = touchStart.pageX
			startY      = touchStart.pageY

			removeTapHandler = ()->
				$timeout.cancel()
				elem.off 'touchmove', moveHandler
				elem.off 'touchend', tapHandler

			tapHandler = (endEvent)->
				endEvent.preventDefault()
				removeTapHandler()

				alert target is endEvent.target

				if target is endEvent.target
					tapped = true
					scope.$apply attrs["ngTap"]

			moveHandler = (moveEvent)->
				touchMove  = moveEvent.originalEvent.touches[0]
				moveX      = touchMove.pageX
				moveY      = touchMove.pageY

				if Math.abs(moveX - startX) > distanceThreshold or Math.abs(moveY - startY) > distanceThreshold
					tapped = true
					removeTapHandler()

			$timeout removeTapHandler, timeThreshold

			elem.on 'touchmove', moveHandler
			elem.on 'touchend', tapHandler

		elem.bind 'click', ()->
			unless tapped
				scope.$apply attrs["ngTap"]
]


###
	ngTapOutside

	Description: A directive that listens when a user clicks or taps
	outside the area.

	Usage:
	<button type="button" ng-tap-outside="closeDropdown()">Show Dropdown</button>
###

lcTouch.directive 'ngTapOutside', ['$timeout', ($timeout)->
	(scope, elem, attrs)->
		stopEvent = false

		if angular.isDefined attrs.when
			scope.$watch attrs.when, (newValue, oldValue)->
				if newValue is true
					$timeout ()->
						elem.bind 'touchstart click', onElementTouchStart
						$('html').bind 'touchend click', onTouchEnd
				else
					elem.unbind 'touchstart click', onElementTouchStart
					$('html').unbind 'touchend click', onTouchEnd
		else
			elem.bind 'touchstart click', onElementTouchStart
			$('html').bind 'touchend click', onTouchEnd


		# JS Functions
		onTouchEnd = (event)->
			unless stopEvent
				$timeout ()->
					scope.$eval attrs.ngTapOutside
				, 10
			else
				stopEvent = false

		onElementTouchStart = (event)->
			event.stopPropagation()
			stopEvent = true


		# Event Listeners
		scope.$on 'event:stopTapOutside', ()->
			stopEvent = true
]
