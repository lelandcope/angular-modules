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
						elem.bind 'touchstart mousedown', onElementTouchStart
						$('html').bind 'touchend mouseup', onTouchEnd
				else
					elem.unbind 'touchstart mousedown', onElementTouchStart
					$('html').unbind 'touchend mouseup', onTouchEnd
		else
			elem.bind 'touchstart mousedown', onElementTouchStart
			$('html').bind 'touchend mouseup', onTouchEnd


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

				if events.start then events.start elem, [startX, startY], e

			ontouchmove = (e)->
				touch   = e.originalEvent.touches[0]
				endX  = touch.pageX
				endY  = touch.pageY

				if events.move then events.move elem, [endX, endY], e

			ontouchend = (e)->
				elem.off 'touchmove', ontouchmove
				elem.off 'touchend', ontouchend

				if events.end then events.end elem, [startX - endX, startY - endY], e

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



###
	ngDragSwipeHorizontal

	Description: Drag Swipe Horizontally
###

lcTouch.factory '$ngDragSwipeHorizontal', ['$swipe', '$timeout', ($swipe, $timeout)->
	cleanArray = (arr)->
		tmp = []

		for el, i in arr
			if el
				tmp.push el

		return tmp

	notInArray = (arr1, arr2)->
		tmp = []

		for el, i in arr1
			if arr2.indexOf(el) is -1
				tmp.push el

		return tmp

	class DSH
		offset: 0
		totalChildren: 0
		wrapperWidth: 0
		minDistance: 0
		minInertia: 0
		movable: []
		infiniteScroll: false
		animating: false
		elem: null
		attrs: null

		bind: (elem, attrs, infScroll)->
			self			 	  = @
			self.elem			  = elem
			self.attrs			  = attrs
			self.totalChildren    = self.elem.children().length
			self.wrapperWidth     = self.elem.parent().width()
			self.minDistance      = attrs.ngDragSwipeHorizontalMinDistance or self.wrapperWidth*0.5
			self.minInertia       = attrs.ngDragSwipeHorizontalMinInertia or 0.65
			self.infiniteScroll   = infScroll or false

			onstart = (el, amounts, e)->
				e.stopPropagation()

				$(e.currentTarget).data('touchStart', { x: amounts[0], y: amounts[1], timeStamp: e.timeStamp })

			onend = (el, amounts, e)->
				e.stopPropagation()

				startEvent      = $(e.currentTarget).data('touchStart')
				x1              = self.offset*self.wrapperWidth
				x2              = Math.abs(parseInt($(self.elem.children()[self.offset]).css('x')))
				distanceMoved   = x1 - x2
				speed           = Math.abs(Math.max(Math.min((x2 - x1) / Math.max(e.timeStamp - startEvent.timeStamp, 1), 1), -1))

				if distanceMoved < 0 and (Math.abs(distanceMoved) >= self.minDistance or speed >= self.minInertia) and self.totalChildren isnt self.offset+1
					self.offset++
				else if distanceMoved > 0 and (Math.abs(distanceMoved) >= self.minDistance or speed >= self.minInertia) and self.offset isnt 0
					self.offset--

				if distanceMoved != 0
					time = 500 - 500*((75*speed)/100)

					$(self.movable).transition({ x: self.offset*(-self.wrapperWidth)+'px' }, time, 'out')
					$timeout ()->
						$(notInArray(self.elem.children(), self.movable)).css { x: self.offset*(-self.wrapperWidth)+'px' }
						if self.infiniteScroll then self.resetOrder(self.elem, attrs)
					, time

			onmove = (el, amounts, e)->
				e.stopPropagation()

				startEvent = $(e.currentTarget).data('touchStart')
				placement  = amounts[0]-startEvent.x+self.offset*(-self.wrapperWidth)

				if placement <= 0 and placement >= (self.totalChildren-1)*(-self.wrapperWidth)
					self.movable = cleanArray([self.elem.children()[self.offset], self.elem.children()[self.offset-1], self.elem.children()[self.offset+1]])

					$(self.movable).css { x: placement+'px' }


			if self.infiniteScroll then self.resetOrder()
			$swipe.bind self.elem.children(), { move: onmove, start: onstart, end: onend }


		resetOrder: ()->
			self = @

			if self.elem.children().length > 2
				if self.offset is 0 and self.infiniteScroll
					self.elem.prepend self.elem.children().last()
					self.offset = 1
				else if self.offset > 1 and self.infiniteScroll
					self.elem.append self.elem.children().first()
					self.offset = 1

				$(self.elem.children()).css { x: self.offset*(-self.wrapperWidth)+'px' }


		next: ()->
			self = @

			if self.animating then return

			self.offset++
			time = 500
			self.animating = true

			self.movable = cleanArray([self.elem.children()[self.offset], self.elem.children()[self.offset-1], self.elem.children()[self.offset+1]])
			$(self.movable).transition({ x: self.offset*(-self.wrapperWidth)+'px' }, time, 'out')

			$timeout ()->
				if self.infiniteScroll then self.resetOrder()
				self.animating = false
			, time


		previous: ()->
			self = @

			if self.animating then return

			self.offset--
			time = 500
			self.animating = true

			self.movable = cleanArray([self.elem.children()[self.offset], self.elem.children()[self.offset-1], self.elem.children()[self.offset+1]])
			$(self.movable).transition({ x: self.offset*(-self.wrapperWidth)+'px' }, time, 'out')

			$timeout ()->
				if self.infiniteScroll then self.resetOrder()
				self.animating = false
			, time


	# Done this way so it gets a unique class
	return ()->
		return new DSH()

]

lcTouch.directive 'ngDragSwipeHorizontal', ['$ngDragSwipeHorizontal', ($ngDragSwipeHorizontal)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			$ngDragSwipeHorizontal().bind elem, attrs
	}
]



###
	lcCarouselHorizontal

	Description: Horizontal Carousel
###

lcTouch.directive 'lcCarouselHorizontal', ['$ngDragSwipeHorizontal', '$compile', '$timeout', ($ngDragSwipeHorizontal, $compile, $timeout)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			scope.forceArrows 			= attrs.forceArrows
			scope.lcCarouselHorizontal 	= attrs.lcCarouselHorizontal
			scope.carouselWidth			= '0px'
			scope.carouselHeight		= '0px'

			autoScrollUntilClick = scope.$eval(attrs.lcCarouselAutoScroll) or false
			autoScrollTimeout = null

			$dsh = $ngDragSwipeHorizontal()
			scope.items = scope.$eval(attrs.lcCarouselHorizontal)

			scope.itemsRendered = ()->
				$timeout start, 100

			start = ()->
				$dsh.bind elem, attrs, true

				$parent = elem.parent()
				forceArrows = attrs.forceArrows

				scope.carouselWidth  = $parent.width()+'px'
				scope.carouselHeight = $parent.height()+'px'

				arrowInner = $('<div/>').css
					display: 'table-cell'
					verticalAlign: 'middle'
					height: $parent.height()


				lArrow = $('<div class="arrow" ng-click="prevCarouselSlide()" />').css
					position: 'absolute'
					top: 0
					left: 0
					height: $parent.height()
					padding: '0 0 0 10px'
					cursor: 'pointer'
				.append arrowInner.clone()
				.append '<i class="icon-chevron-sign-left"></i>'


				rArrow = $('<div class="arrow" ng-click="nextCarouselSlide()" />').css
					position: 'absolute'
					top: 0
					right: 0
					height: $parent.height()
					display: 'table-cell'
					verticalAlign: 'middle'
					padding: '0 10px 0 0'
					cursor: 'pointer'
				.append arrowInner.clone()
				.append '<i class="icon-chevron-sign-right"></i>'

				$parent.css
					position: 'relative'

				elem.css
					width: $parent.width()*elem.children().length
					height: $parent.height()
					display: 'block'
					opacity: 0

				$timeout ()->
					scope.$apply()
				, 100

				$timeout ()->
					$dsh.resetOrder()

					if typeof(window.ontouchstart) is 'undefined' and elem.children().length > 2
						$parent.append $compile(lArrow)(scope)
						$parent.append $compile(rArrow)(scope)

					elem.animate { opacity: 1 }, 300

					if autoScrollUntilClick
						autoScrollTimeout = $timeout autoScroll, autoScrollUntilClick
				, 999


				# Functions
				autoScroll = ()->
					$timeout.cancel autoScrollTimeout
					scope.nextCarouselSlide(false)

					autoScrollTimeout = $timeout autoScroll, autoScrollUntilClick



				# Scope Functions
				scope.nextCarouselSlide = (cancelAutoScroll)->
					cancelAutoScroll or= true

					if cancelAutoScroll
						$timeout.cancel autoScrollTimeout

					$timeout ()->
						$dsh.next()
						scope.$emit('event:lcCarouselNext', elem)
					, 1

				scope.prevCarouselSlide = (cancelAutoScroll)->
					cancelAutoScroll or= true

					if cancelAutoScroll
						$timeout.cancel autoScrollTimeout

					$timeout ()->
						$dsh.previous()
						scope.$emit('event:lcCarouselPrevious', elem)
					, 1



			# $timeout start, 1
	}
]

lcTouch.directive 'lcCarouselItemsRendered', ['$timeout', ($timeout)->
	return {
		restrict: 'A'
		link: (scope, elem, attrs)->
			if scope.$last is true
				elem.ready ()->
					$timeout ()->
						scope.$apply attrs["lcCarouselItemsRendered"]
					, 200
	}
]







