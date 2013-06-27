    @Offline or= {}


TODO not supporting unit tests with shared web worker yet.

    if (not @SharedWorker? or
        Meteor.settings?.public?.offlineData?.disableWorker or
        @Tinytest?)
      Offline._usingSharedWebWorker = false
      return


    Offline._usingSharedWebWorker = true


Reference the boot script with the same "cache busting" URL that the
appcache generates for the app manifest.

    worker = new SharedWorker(
      '/packages/offline-data/worker/boot.javascript?' +
      __meteor_runtime_config__.offlineDataWorker.hashes.boot
    )


    messageHandlers = {}


    Offline._sharedWebWorker = Worker = {}


    Worker.addMessageHandler = (msg, callback) ->
      messageHandlers[msg] = callback
      return


    Worker.addMessageHandler 'log', (data) ->
      for entry in data.log
        Meteor._debug "worker log: #{entry}"
      return


    worker.port.onmessage = (event) ->
      handler = messageHandlers[event.data?.msg]
      if handler?
        handler(event.data)
      else
        Meteor._debug(
          "unknown message received from shared web worker: " +
          JSON.stringify(event.data)
        )


    Worker.post = (data) ->
      worker.port.postMessage data
      return


    Worker.post {
      msg: 'boot'
      __meteor_runtime_config__
    }
