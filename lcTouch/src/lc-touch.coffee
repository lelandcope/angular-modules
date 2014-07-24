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
        tapcount             = 0

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

        bind: (scope, elem, attrs, infScroll)->
            @elem           = elem
            @attrs          = attrs
            @totalChildren  = @elem.children().length
            @wrapperWidth   = @elem.parent().width()
            @minDistance    = attrs.ngDragSwipeHorizontalMinDistance or @wrapperWidth*0.5
            @minInertia     = attrs.ngDragSwipeHorizontalMinInertia or 0.65
            @infiniteScroll = infScroll or false

            threshold           = 20
            isVerticalScroll    = false
            isHorizontalScroll  = false
            xStart              = null
            yStart              = null

            onstart = (el, amounts, e)=>
                e.stopPropagation()

                isVerticalScroll    = false
                isHorizontalScroll  = false
                xStart              = amounts[0]
                yStart              = amounts[1]

                $(e.currentTarget).data('touchStart', { x: amounts[0], y: amounts[1], timeStamp: e.timeStamp })

            onend = (el, amounts, e)=>
                e.stopPropagation()

                startEvent      = $(e.currentTarget).data('touchStart')
                x1              = @offset*@wrapperWidth
                x2              = Math.abs(parseInt($(@elem.children()[@offset]).css('x')))
                distanceMoved   = x1 - x2
                speed           = Math.abs(Math.max(Math.min((x2 - x1) / Math.max(e.timeStamp - startEvent.timeStamp, 1), 1), -1))

                if distanceMoved < 0 and (Math.abs(distanceMoved) >= @minDistance or speed >= @minInertia) and @totalChildren isnt @offset+1
                    @offset++
                    scope.$broadcast 'event:lcCarouselNext'

                else if distanceMoved > 0 and (Math.abs(distanceMoved) >= @minDistance or speed >= @minInertia) and @offset isnt 0
                    @offset--
                    scope.$broadcast 'event:lcCarouselPrevious'

                if distanceMoved != 0
                    time = 500 - 500*((75*speed)/100)

                    $(@movable).transition({ x: @offset*(-@wrapperWidth)+'px' }, time, 'out')
                    $timeout ()=>
                        $(notInArray(@elem.children(), @movable)).css { x: @offset*(-@wrapperWidth)+'px' }
                        @resetOrder(@elem, attrs) if @infiniteScroll
                    , time

            onmove = (el, amounts, e)=>
                e.stopPropagation()

                isVerticalScroll    = true if Math.abs(yStart - amounts[1]) > threshold and not isHorizontalScroll
                isHorizontalScroll  = true if Math.abs(xStart - amounts[0]) > threshold and not isVerticalScroll

                return unless isHorizontalScroll

                e.preventDefault() # Stop vertical scroll

                startEvent = $(e.currentTarget).data('touchStart')
                placement  = amounts[0]-startEvent.x+@offset*(-@wrapperWidth)

                if placement <= 0 and placement >= (@totalChildren-1)*(-@wrapperWidth)
                    @movable = cleanArray([@elem.children()[@offset], @elem.children()[@offset-1], @elem.children()[@offset+1]])

                    $(@movable).css { x: placement+'px' }

                scope.$broadcast 'event:lcCarouselStopAutoScroll'


            if @infiniteScroll then @resetOrder()
            $swipe.bind @elem.children(), { move: onmove, start: onstart, end: onend }


        resetOrder: ()->
            if @elem.children().length > 2
                if @offset is 0 and @infiniteScroll
                    @elem.prepend @elem.children().last()
                    @offset = 1
                else if @offset > 1 and @infiniteScroll
                    @elem.append @elem.children().first()
                    @offset = 1

                $(@elem.children()).css { x: @offset*(-@wrapperWidth)+'px' }


        next: ()->
            if @animating then return

            @offset++
            time = 500
            @animating = true

            @movable = cleanArray([@elem.children()[@offset], @elem.children()[@offset-1], @elem.children()[@offset+1]])
            $(@movable).transition({ x: @offset*(-@wrapperWidth)+'px' }, time, 'out')

            $timeout ()=>
                if @infiniteScroll then @resetOrder()
                @animating = false
            , time


        previous: ()->
            if @animating then return

            @offset--
            time = 500
            @animating = true

            @movable = cleanArray([@elem.children()[@offset], @elem.children()[@offset-1], @elem.children()[@offset+1]])
            $(@movable).transition({ x: @offset*(-@wrapperWidth)+'px' }, time, 'out')

            $timeout ()=>
                if @infiniteScroll then @resetOrder()
                @animating = false
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
            scope.forceArrows           = attrs.forceArrows
            scope.lcCarouselHorizontal  = attrs.lcCarouselHorizontal
            scope.carouselWidth         = '0px'
            scope.carouselHeight        = '0px'

            autoScrollUntilClick = scope.$eval(attrs.lcCarouselAutoScroll) or false
            autoScrollTimeout = null

            $dsh = $ngDragSwipeHorizontal()
            scope.items = scope.$eval(attrs.lcCarouselHorizontal)

            scope.itemsRendered = ()->
                $timeout start, 100

            scope.backgroundImage = (img)->
                'url(\"'+img+'\")'

            start = ()->
                infiniteScroll = elem.children().length > 2
                $dsh.bind scope, elem, attrs, infiniteScroll

                $parent = elem.parent()
                forceArrows = attrs.forceArrows

                scope.carouselWidth  = $parent.width()+'px'
                scope.carouselHeight = $parent.height()+'px'

                arrowInner = $('<div/>').css
                    display: 'table-cell'
                    verticalAlign: 'middle'
                    height: $parent.height()


                lArrow = $('<div class="arrow left" ng-tap="prevCarouselSlide()" />').css
                    position: 'absolute'
                    top: 0
                    left: 0
                    height: $parent.height()
                    padding: '0 0 0 10px'
                    cursor: 'pointer'
                .append arrowInner.clone()
                .append '<i class="icon-chevron-sign-left"></i>'


                rArrow = $('<div class="arrow right" ng-tap="nextCarouselSlide()" />').css
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

                    $parent.append $compile(lArrow)(scope)
                    $parent.append $compile(rArrow)(scope)

                    unless infiniteScroll
                        $parent.find('.arrow.left').css 'display', 'none'

                    elem.animate { opacity: 1 }, 300

                    if autoScrollUntilClick
                        autoScrollTimeout = $timeout autoScroll, autoScrollUntilClick
                , 999


                # Functions
                autoScroll = ()->
                    return if elem.children().length < 3

                    $timeout.cancel autoScrollTimeout
                    scope.nextCarouselSlide(false)

                    autoScrollTimeout = $timeout autoScroll, autoScrollUntilClick

                # Scope Functions
                scope.nextCarouselSlide = (cancelAutoScroll)->
                    if cancelAutoScroll is undefined then cancelAutoScroll = true

                    if cancelAutoScroll
                        $timeout.cancel autoScrollTimeout

                    unless infiniteScroll
                        $parent.find('.arrow.left').fadeIn()
                        $parent.find('.arrow.right').fadeOut()

                    $timeout ()->
                        $dsh.next()
                        if cancelAutoScroll then scope.$emit('event:lcCarouselNext', elem)
                    , 1

                scope.prevCarouselSlide = (cancelAutoScroll)->
                    if cancelAutoScroll is undefined then cancelAutoScroll = true

                    if cancelAutoScroll
                        $timeout.cancel autoScrollTimeout

                    unless infiniteScroll
                        $parent.find('.arrow.left').fadeOut()
                        $parent.find('.arrow.right').fadeIn()

                    $timeout ()->
                        $dsh.previous()
                        if cancelAutoScroll then scope.$emit('event:lcCarouselPrevious', elem)
                    , 1


                scope.$on 'event:lcCarouselStopAutoScroll', (e)=>
                    $timeout.cancel autoScrollTimeout


                scope.$on 'event:lcCarouselNext', (e)=>
                    unless infiniteScroll
                        $parent.find('.arrow.left').fadeIn()
                        $parent.find('.arrow.right').fadeOut()

                scope.$on 'event:lcCarouselPrevious', (e)=>
                    unless infiniteScroll
                        $parent.find('.arrow.left').fadeOut()
                        $parent.find('.arrow.right').fadeIn()



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







