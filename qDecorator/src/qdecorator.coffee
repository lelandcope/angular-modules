'use strict'

angularQDecorator = angular.module 'qDecorator', []

angularQDecorator.config ['$provide', ($provide)->
	# Add Success and Error Callbacks to $q

	$provide.decorator '$q', ['$delegate', ($delegate)->
		defer = $delegate.defer

		$delegate.defer = ()->
			deferred = defer()

			deferred.promise.success = (cb)->
				deferred.promise.then (response)->
					if cb then cb response

				deferred.promise

			deferred.promise.error = (cb)->
				deferred.promise.then null, (response)->
					if cb then cb response

				deferred.promise

			deferred.promise.notify = (cb)->
				deferred.promise.then null, null, (response)->
					if cb then cb response

				deferred.promise

			deferred

		$delegate
	]
]