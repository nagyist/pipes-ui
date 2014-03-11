class pipes.steps.DataPollStep extends pipes.steps.Step
  ###
  Generic data polling step.
  Polls data from @pollUrl after @pollDelay ms and by default end()s and stores data in sharedData if any data is received.
  (override @callback to change this behavior)
  Each request can take data from shardData via @requestMap ({'get param': 'sharedData key'})
  Response is stored into sharedData through @responseMap ({'sharedData key': 'response json key'})
  (use blank json key to store the whole response)
  ###

  pollDelay: 1000
  pollDelayIncrement: 0
  # TODO: add limit

  pollUrl: null
  pollTimeout: null
  pollCount: 0 # Used to increase poll interval (3s, 6s, 9s, ...)

  requestMap: null # Mapping 'query string param name': 'key in sharedData'
  responseMap: null

  # Callback to invoke when data has been received
  # Return false if you don't want the step to be automatically end()ed
  # Default behaviour: uses responseMap to map response values to sharedData
  callback: (response, step) ->
    for k, v of @responseMap
      @sharedData[k] = if v then response[v] else response

  constructor: (options = {}) ->
    super(options)
    @requestMap = options.requestMap
    @responseMap = options.responseMap
    @pollUrl = options.url

  getRequestData: ->
    _.mapValues @requestMap, (v, k) => @sharedData[v]

  onRun: ->
    @startPolling()

  onEnd: ->
    @endPolling()

  startPolling: ->
    @pollCount = 0
    @endPolling()
    @ajaxStart()
    @setNextPoll()

  setNextPoll: ->
    @pollTimeout = setTimeout @poll, @pollDelay + @pollCount * @pollDelayIncrement

  endPolling: ->
    @ajaxEnd()
    clearTimeout @pollTimeout

  poll: =>
    @pollCount++
    $.get @pollUrl, @getRequestData(), (@responseData) =>
      if not @responseData
        @setNextPoll()
      else
        if @callback(@responseData, @) != false
          @end()

      error: =>
        @setNextPoll()