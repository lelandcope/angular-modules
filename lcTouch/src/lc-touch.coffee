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
	ngDbltap

	Description: A replacement for ngDblclick. This directive will take into account taps and clicks so it
	will work for both mobile and desktop browsers.

	Usage:
	<button type="button" ng-dbltap="doSomething()">Click Me</button>
###

lcTouch.directive 'ngDbltap', ['$timeout', ($timeout)->
	(scope, elem, attrs)->
		distanceThreshold    = 25
		timeThreshold        = 500
		tapped               = false
		tapcount			 = 0

		elem.on 'touchstart', (startEvent)->
			target      = startEvent.target
			touchStart  = startEvent.originalEvent.touches[0]
			startX      = touchStart.pageX
			startY      = touchStart.pageY

			removeTapHandler = ()->
				$timeout.cancel()
				elem.off 'touchmove', moveHandler
				elem.off 'touchend', tapHandler
				tapcount = 0

			tapHandler = (endEvent)->
				endEvent.preventDefault()
				tapcount++

				if tapcount >= 2
					removeTapHandler()
					if target is endEvent.target
						tapped = true
						scope.$apply attrs["ngDbltap"]

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


		elem.bind 'dblclick', ()->
			unless tapped
				scope.$apply attrs["ngDbltap"]
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


###
	ngSwipeDown, ngSwipeUp, ngSwipeLeft, ngSwipeRight

	Description: Adds swipe directives

	Usage:
	<div ng-swipe-down="onswipedown()">
		...... HTML ......
	</div>
###

lcTouch.factory '$swipe', [()->
	return {
		bind: (elem, events)->
			startX       = 0
			startY       = 0
			endX         = 0
			endY         = 0

			ontouchstart = (e)->
				touch   = e.originalEvent.touches[0]
				startX  = touch.pageX
				startY  = touch.pageY

				elem.on 'touchmove', ontouchmove
				elem.on 'touchend', ontouchend

				if events.start then events.start elem, [startX, startY]

			ontouchmove = (e)->
				touch   = e.originalEvent.touches[0]
				endX  = touch.pageX
				endY  = touch.pageY

				if events.move then events.move elem, [endX, endY]

			ontouchend = (e)->
				elem.off 'touchmove', ontouchmove
				elem.off 'touchend', ontouchend

				if events.end then events.end elem, [startX - endX, startY - endY]

				startX       = 0
				startY       = 0
				endX         = 0
				endY         = 0

			elem.on 'touchstart', ontouchstart
	}
]

lcTouch.directive 'ngSwipeDown', ['$swipe', ($swipe)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			threshold = Number(attrs.ngSwipeDownThreshold) or 70

			onend = (elem, amounts)->
				amount = amounts[1]

				if amount < 0 and Math.abs(amount) >= threshold
					scope.$apply attrs["ngSwipeDown"]

			$swipe.bind elem, { end: onend }
	}
]

lcTouch.directive 'ngSwipeUp', ['$swipe', ($swipe)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			threshold = Number(attrs.ngSwipeUpThreshold) or 70

			onend = (elem, amounts)->
				amount = amounts[1]

				if amount > 0 and Math.abs(amount) >= threshold
					scope.$apply attrs["ngSwipeUp"]

			$swipe.bind elem, { end: onend }
	}
]

lcTouch.directive 'ngSwipeRight', ['$swipe', ($swipe)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			threshold = Number(attrs.ngSwipeRightThreshold) or 70

			onend = (elem, amounts)->
				amount = amounts[0]

				if amount < 0 and Math.abs(amount) >= threshold
					scope.$apply attrs["ngSwipeRight"]

			$swipe.bind elem, { end: onend }
	}
]

lcTouch.directive 'ngSwipeLeft', ['$swipe', ($swipe)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			threshold = Number(attrs.ngSwipeLeftThreshold) or 70

			onend = (elem, amounts)->
				amount = amounts[0]

				if amount > 0 and Math.abs(amount) >= threshold
					scope.$apply attrs["ngSwipeLeft"]

			$swipe.bind elem, { end: onend }
	}
]
