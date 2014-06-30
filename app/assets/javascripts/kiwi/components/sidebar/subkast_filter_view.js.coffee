FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.SubkastFilterView extends Marionette.CompositeView
    template: FK.Template('subkast_filter')
    itemViewContainer: '.subkast-list'
    itemView: Sidebar.SingleSubkastView
    className: 'subkast-filter filter'
