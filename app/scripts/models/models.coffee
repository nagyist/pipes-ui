class pipes.models.Integration extends Backbone.Model

  pipes: null

  accountsUrl: ->
    pipes.apiUrl("/integrations/#{@id}/accounts")

  authorizationsUrl: ->
    pipes.apiUrl("/integrations/#{@id}/authorizations")

  setPipes: (@pipes) ->
  getPipes: -> @pipes

class pipes.models.IntegrationCollection extends Backbone.Collection

  model: pipes.models.Integration

  url: ->
    pipes.apiUrl("/integrations")

  parse: (response) ->
    # Turn 'pipes' array into a PipeCollection
    models = []
    for iObj in response
      iModel = new @model(_.omit iObj, ['pipes'])
      pipeCollection = new pipes.models.PipeCollection iObj.pipes
      pipeCollection.integration = iModel
      iModel.setPipes pipeCollection
      models.push iModel
    models


class pipes.models.Pipe extends Backbone.Model

  getStatus: ->
    @get('pipe_status')?.status or 'success'

  setStatus: (v, message = null, options=null) ->
    diff = status: v
    diff.message = message if message?
    @set(pipe_status: _.extend({}, @get('pipe_status'), diff), options)

  getStatusMessage: ->
    @get('pipe_status')?.message or if @getStatus() == 'running' then 'Running' else 'Ready'

  setStatusMessage: (v, options=null) ->
    @set(pipe_status: _.extend({}, @get('pipe_status'), message: v), options)

  getLastSync: ->
    str = @get('pipe_status')?.sync_date
    return null if not str
    moment(str)

  setLastSync: (v, options=null) ->
    @set(pipe_status: _.extend({}, @get('pipe_status'), sync_date: v), options)

  getLogLink: ->
    @get('pipe_status')?.sync_log or null

  setLogLink: (v, options=null) ->
    @set(pipe_status: _.extend({}, @get('pipe_status'), sync_log: v), options)

  getLastSyncHuman: ->
    d = @getLastSync()
    if d then d.calendar() else null

class pipes.models.PipeCollection extends Backbone.Collection
  model: pipes.models.Pipe
  integration: null

  url: ->
    pipes.apiUrl("/integrations/#{@integration.id}/pipes")


pipes.models.integrations = new pipes.models.IntegrationCollection()
