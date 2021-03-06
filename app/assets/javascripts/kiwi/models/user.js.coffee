class FK.Models.User extends Backbone.Model
  idAttribute: "_id"
  url: () => return (if @isNew() then '/users/' else '/users/' + @get('_id')["$oid"])
  defaults: () =>
    email: ''
    provider: ''
    logged_in: false
    username: ''
    country: 'US'
    moderator: false
    last_posted_country: null
    subkasts: []

  sync: (method, model, options) =>

    if method is 'update'
      formData = new FormData()

      _.each(model.pick('country', 'subkasts', 'last_posted_country'), (v, k) ->
        formData.append(k, v)
      )

      xhr = new XMLHttpRequest()
      xhr.open('PUT', @url(), true)
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

      xhr.send(formData)

  userId: () =>
    @get('_id')["$oid"]

  hasLastPostedCountry: () =>
    !! @get('last_posted_country')

  lastPostedCountry: () =>
    @get('last_posted_country')

  setLastPostedCountry: (country) =>
    @save({ last_posted_country: country })
