describe "Event Store", ->
  
  describe "top ranked events", ->
    beforeEach ->
      @vent = _.clone(Backbone.Events)
      @store = new FK.EventStore(events: FK.SpecHelpers.Events.UpvotedEvents, howManyStartingBlocks: 3, vent: @vent, country: "CA", subkasts: ["ST", "SE"])
      @store.events.trigger "sync"
      @topRanked = @store.topRanked

    it "should have 10 events in the top ranked collection", ->
      expect(@topRanked.length).toBe(10)

    it "should not have events outside the date range no matter their ranking", ->
      expect(@topRanked.where({upvotes: 12})).toEqual([])

    it "should have the highest ranked event as the first event in the collection", ->
      expect(@topRanked.first().upvotes()).toBe(11)

    it "should have the lowest of the top ranked events as the last event in the collection", ->
      expect(@topRanked.last().upvotes()).toBe(3)

    it "should include events that were set for earlier today", ->
      expect(@topRanked.pluck('name')).toContain('event 2a')

    xdescribe "when adding an event", ->
      beforeEach ->
        @store.events.add upvotes: 20, datetime: moment().add('days', 5)

      it "should have the new highest event as the first item in the collection", ->
        expect(@topRanked.first().upvotes()).toBe(20)

      it "should have the lowest event bumped out of the collection", ->
        expect(@topRanked.last().upvotes()).toBe(3)

    describe "filter by country", ->
      beforeEach ->
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr
 
        @vent = _.clone(Backbone.Events)
        @store = new FK.EventStore vent: @vent, country: "CA"

        @store.refresh()

        @requests[0].respond(200, "Content-Type": "application/json", JSON.stringify(
          FK.SpecHelpers.Events.UpvotedEventsWithCountries
        ))
        @topRanked = @store.topRanked
      
      it "should only have top ranked events with the country CA", ->
        expect(@topRanked.length).toBe(6)

      it "should not have any events of another country", ->
        countries = []
        @topRanked.each((event) =>
          countries.push event.get('country') if event.get('location_type') is 'national'
        )

        extras = _.without(countries, "CA")
        expect(extras.length).toBe(0)

    describe "filter by subkasts", ->
      beforeEach ->
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr

        @vent = _.clone(Backbone.Events)

        @store = new FK.EventStore vent: @vent, country: 'CA'

        @store.filterBySubkasts(['HA', 'PRP', 'ST'])

        @requests[0].respond(200, "Content-Type": "application/json", JSON.stringify(
          FK.SpecHelpers.Events.UpvotedEventsWithCountries
        ))
        @topRanked = @store.topRanked
      
      it "should only have top ranked events with the filtered subkasts", ->
        expect(@topRanked.length).toBe(4)

  describe "blocks", ->
    beforeEach ->
      @vent = _.clone(Backbone.Events)
      @store = new FK.EventStore events: FK.SpecHelpers.Events.BlockEvents, vent: @vent, country: 'CA'
      @store.events.trigger "sync"
      @blocks = @store.blocks

    it "should have the earliest event date as the date of the first block", ->
      expect(@blocks.first().get('date').format('YYYY-MM-DD')).toBe(moment().format('YYYY-MM-DD'))

    it "should have the latest event date as the date of the last block", ->
      expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 3).format('YYYY-MM-DD'))

    describe "adding events to a block", ->
      beforeEach ->
        @blocks.last().increaseLimit 3

      it "should have the new events in the block", ->
        expect(@store.blocks.last().events.length).toBe(7)

      it "should have the event with the new highest number of upvotes first", ->
        expect(@store.blocks.last().events.first().upvotes()).toBe(10)

      describe "beyond the number of events already fetched", ->
        beforeEach ->
          @xhr = sinon.useFakeXMLHttpRequest()
          @requests = []
          @xhr.onCreate = (xhr) =>
            @requests.push xhr
          @blocks.last().increaseLimit 4

          
        afterEach ->
          @xhr.restore()

        it "should have to issue a request for more events", ->
          expect(@requests.length).toBe(1)

        describe "responding with less than the number of events requested", ->
          beforeEach ->
            @requests[0].respond(200, "Content-Type": "application/json", JSON.stringify([
              { _id: 20, upvotes: 5, datetime: moment().add('days', 3), subkast: 'OTH' }
              { _id: 21, upvotes: 4, datetime: moment().add('days', 3), subkast: 'OTH' }
            ]))

          it "should be able to add the events from the response to the block", ->
            expect(@blocks.last().events.length).toBe(9)

          it "should have the event with the highest number of upvotes first", ->
            expect(@blocks.last().events.first().upvotes()).toBe(10)

          it "should have the event with the lowest number of upvotes last", ->
            expect(@blocks.last().events.last().upvotes()).toBe(2)

          xit "should have the limit of the block in question reduced", ->
            expect(@blocks.last().get('event_limit')).toBe(9)

          it "should know that no more events are available", ->
            expect(@blocks.last().get('more_events_available')).toBeFalsy()

        describe "respond with exactly the number of events requested", ->
          beforeEach ->
            @requests[0].respond(200, "Content-Type": "application/json", JSON.stringify([
              { _id: 20, upvotes: 5, datetime: moment().add('days', 3) }
              { _id: 21, upvotes: 4, datetime: moment().add('days', 3) }
              { _id: 22, upvotes: 3, datetime: moment().add('days', 3) }
            ]))

          xit "should check if any more events are available", ->
            expect()

    describe "increasing the number of blocks beyond the number of already fetched blocks", ->
      beforeEach ->
        @vent = _.clone(Backbone.Events)
        @store = new FK.EventStore events: FK.SpecHelpers.Events.UpvotedEvents, country: 'CA', subkasts: ['ST', 'SE'], vent: @vent
        @store.events.trigger "sync"
        @blocks = @store.blocks
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr
        
        @store.loadNextEvents(7)

      afterEach ->
        @xhr.restore()
      
      it "should be able to get events by date from the server when there aren't enough events locally", ->
        expect(@requests.length).toBe(1)

      describe "when the server responds", ->
        beforeEach ->
          @requests[0].respond(200, { "Content-Type": "application/json"}, JSON.stringify([
            { datetime: moment().add('days', 12) }
            { datetime: moment().add('days', 12) }
            { datetime: moment().add('days', 12) }
          ]))

        it "should also add all the new events to the events collection", ->
          expect(@store.events.length).toBe(19)

        it "should be able to add more blocks after more events have come back from the server", ->
          expect(@blocks.length).toBe(8)

        it "should create blocks with the filtering country", ->
          expect(@blocks.last().get('country')).toBe('CA')

        it "should create blocks with the filtering subkast", ->
          expect(@blocks.last().get('subkasts')).toEqual(['ST', 'SE'])

        it "should have the events loaded into the newly created block", ->
          expect(@blocks.last().events.length).toBe(1)

        it "should have a date on the new event block", ->
          expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 10).format('YYYY-MM-DD'))

    describe "filter by country", ->
      beforeEach ->
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr

        @vent = _.clone(Backbone.Events)
        @store = new FK.EventStore vent: @vent
        @store.filterByCountry("CA")
        @requests[0].respond(200, "Content-Type": "application/json", JSON.stringify(
          FK.SpecHelpers.Events.UpvotedEventsWithCountries
        ))
        @blocks = @store.blocks
      
      it "should only have blocks that contain events with the country CA", ->
        expect(@blocks.length).toBe(6)

      it "should have only events with the country CA in the blocks or that are international", ->
        expect(@blocks.at(0).events.length).toBe(2)
        expect(@blocks.at(1).events.length).toBe(2)

      it "should not have any events of another country", ->
        countries = []
        @blocks.each((block) =>
          block.events.each( (event) =>
            countries.push event.get('country') if event.get('location_type') is 'national'
          )
        )

        extras = _.without(countries, "CA")
        expect(extras.length).toBe(0)

    describe "filter by subkasts", ->
      beforeEach ->
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr

        @vent = _.clone(Backbone.Events)
        @store = new FK.EventStore vent: @vent, country: 'CA'
        @store.filterBySubkasts(['TVM', 'ST', 'HA'])
        @requests[0].respond(200, "Content-Type": "application/json", JSON.stringify(
          FK.SpecHelpers.Events.UpvotedEventsWithCountries
        ))
        @blocks = @store.blocks

      it "should only have blocks that contain events with the filtered subkasts", ->
        expect(@blocks.length).toBe(5)

      it "should only have events in blocks that have one of the fitlered subkasts", ->
        expect(@blocks.at(0).events.length).toBe(1)

      it "should not have any events of another subkast", ->
        subkasts = []
        @blocks.each((block) =>
          block.events.each( (event) =>
            subkasts.push event.get('subkast')
          )
        )

        extras = _.without(subkasts, 'TVM', 'ST', 'HA')
        expect(extras.length).toBe(0)
