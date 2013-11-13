describe "Events.EventForm", ->

  beforeEach () ->
    loadFixtures 'app_fixture'
    FK.App.Events.EventForm.start()
 
  afterEach () ->
    FK.App.Events.EventForm.stop()

  describe "when shown with an event model", () ->

    beforeEach () ->
      @event = new FK.Models.Event
        name: 'Ball drop'
        location_type: 'national'
        country: 'AE'
      FK.App.Events.EventForm.show @event

    it "should have the event name shown", () ->
      expect($('#name').val()).toBe(@event.get('name'))

    it "should have the correct location shown (location type)", () ->
      expect($('[value="national"]').is(':checked')).toBeTruthy()
      expect($('[name="location_type"]:checked').length).toBe(1)

    it "should have the correct country selected", () ->
      expect($('[name="country"]').attr('disabled')).toBeFalsy()
      expect($('[name="country"] :selected').val()).toBe('AE')