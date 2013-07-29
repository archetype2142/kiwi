window.FK = { 
  Data:{}
  Views:{}
  Models:{}
  Collections:{}
  Configs: {}
  Controllers: {}
  Routers: {}
  Utils: {}                                                                                                                                                                                                                                                                                                                                                                 
}
FK.Template = (file) ->
  JST["kiwi/templates/#{file}"]


FK.App = new Backbone.Marionette.Application()
FK.App.addRegions({ layout: '#layout' })

@init = (prefetch) ->  
  FK.Data.events = new FK.Collections.EventList(prefetch.events)
  FK.App.layout.show(new FK.Views.Layout())
  FK.App.appRouter = new FK.Routers.AppRouter()
  Backbone.history.start() if (!Backbone.History.started)


FK.Controllers.MainController = { 
}

class FK.Routers.AppRouter extends Backbone.Marionette.AppRouter
  controller: FK.Controllers.MainController
  appRoutes: {
  } 


moment.lang('en', {
    calendar : {
        lastDay : '[Yesterday at] LT',
        sameDay : '[Today at] LT',
        nextDay : '[Tomorrow at] LT',
        lastWeek : '[last] dddd [at] LT',
        nextWeek : 'dddd [at] LT',
        sameElse : 'dddd, MMMM D '
    }
});
