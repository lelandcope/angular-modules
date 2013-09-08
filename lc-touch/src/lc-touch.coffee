lcTouch = angular.module 'lcTouch', []

###
	lcTap Directive

	Description: A replacement for ngClick. This directive will take into account taps and clicks so it
	will work for both mobile and desktop browsers.

	Parameters:
	- lcTap - {string} - An expression representing what you would like to do when the element is tapped or clicked

	Usage:
	<button type="button" lc-tap="doSomething()">Click Me</button>
###

lcTouch.directive 'lcTap', ($timeout)->
	(scope, elem, attrs)->
		distanceThreshold    = 25
		timeThreshold        = 500
		tapped               = false

		elem.on 'touchstart', (startEvent)->
			target      = startEvent.target
			touchStart  = startEvent.originalEvent.touches[0]
			startX      = touchStart.pageX
			startY      = touchStart.pageY

			removeHandler = ()->
				$timeout.cancel()
				elem.off 'touchmove', moveHandler
				elem.off 'touchend', tapHandler

			tapHandler = (endEvent)->
				endEvent.preventDefault()
				removeTapHandler()

				if target is endEvent.target
					tapped = true
					scope.$apply attrs["lcTap"]

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
				scope.$apply attrs["lcTap"]