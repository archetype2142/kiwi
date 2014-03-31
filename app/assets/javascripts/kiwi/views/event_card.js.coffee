FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

    class EventPage.EventCard extends Marionette.ItemView
      template: FK.Template('event_card')
      className: 'event-card row'

      templateHelpers: () =>
        return {
          prettyDateTime: () => @model.get('datetimeAsString')
          editAllowed: () => @model.editAllowed()
          description: () => @model.descriptionParsed()
        }

      ui:
        upvotesIcon: '#upvotes-icon'

      triggers:
        'click [data-action="edit"]': 'click:edit'
        'click [data-tool="reminders"] .event-tool': 'click:reminders'

      events:
        'click .event-upvotes': 'upvoteToggle'
        'click [data-action="destroy"]': 'destroy'

      upvoteToggle: =>
        @model.upvoteToggle()

      destroy: =>
        @model.destroy()

      modelEvents:
        'change:upvotes': 'refreshUpvotes'
        'change:have_i_upvoted': 'refreshUpvoted'

      refreshUpvotes: (event) =>
        @$('.upvote-counter').html event.upvotes()

      refreshUpvoted: (event) =>
        if event.userHasUpvoted()
          @ui.upvotesIcon.removeClass('fa-caret-up')
          @ui.upvotesIcon.addClass('fa-ok')
        else
          @ui.upvotesIcon.addClass('fa-caret-up')
          @ui.upvotesIcon.removeClass('fa-ok')

      refreshUpvoteAllowed: (event) =>
        if event.get 'upvote_allowed'
          @$('.event-upvotes').tooltip 'destroy'
        else
          @$('.event-upvotes').tooltip
            title: 'Login to upvote.'

      onRender: =>
        @refreshUpvotes(@model)
        @refreshUpvoted(@model)
        @refreshUpvoteAllowed(@model)
