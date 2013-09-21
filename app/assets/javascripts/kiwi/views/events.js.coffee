class FK.Views.Events extends Backbone.Marionette.Layout
  className: "row-fluid"
  regions:
    event_block: '#event_blocks'

  template: FK.Template('events')

  initialize: =>
    FK.Data.events.on('all',@render)

  onRender: ->
    @event_block.show(new FK.Views.EventBlocks(collection: FK.Data.events.asBlocks()))
