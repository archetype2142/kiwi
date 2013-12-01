describe 'Image Trimmer', () ->

  beforeEach () ->
    FK.App.ImageTrimmer.start()
    $('body').append $('<div id="testbed"></div>')
    @imageTrimmer = FK.App.ImageTrimmer.create("#testbed")

  afterEach () ->
    $('body #testbed').remove()
    FK.App.ImageTrimmer.stop()

  describe 'Memory management', () ->

    it 'should close all instances of the image trimmer when the module stops', () ->
      FK.App.ImageTrimmer.stop()
      expect($('body #image-trimmer-region').length).toBe(0)

  describe 'Image setting', () ->
    it 'should be able to load an image', () ->
      imageUrl = '/images/stubs/averageSize.jpg'
      @imageTrimmer.newImage imageUrl, 'remote'
      expect(@imageTrimmer.value().url).toBe(imageUrl)

    it 'shoule be able to set the images width', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        @imageTrimmer.setWidth 500
        expect(Math.ceil(@imageTrimmer.value().width)).toBe(500)

  describe 'Image loading', () ->

    it 'should be able to show an image in the trimmer from a URL', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        expect($('img').width()).toBeGreaterThan(0)

    it 'should be able to fit a 4x3 image squarely in the image trimmer view on load', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSize.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        trimWidth = $('.image-trim').width()
        trimHeight = $('.image-trim').height()
        leftOffset = $('.image-trim').offset().left + parseInt($('.image-trim').css('border-left-width'))
        topOffset = $('.image-trim').offset().top + parseInt($('.image-trim').css('border-top-width'))

        expect($('img').width()).toBe(trimWidth)
        expect($('img').height()).toBe(trimHeight)
        expect($('img').offset().left).toBe(leftOffset)
        expect($('img').offset().top).toBe(topOffset)

    it 'should be able to fit an image that is not 4x3 and having a greater height', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/averageSizeRotated.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        trimWidth = $('.image-trim').width()
        leftOffset = $('.image-trim').offset().left + parseInt($('.image-trim').css('border-left-width'))
        expect($('img').width()).toBe(trimWidth)
        expect($('img').offset().left).toBe(leftOffset)

    it 'should be able to fit an image that is not 4x3 and having a greater width', () ->
      spy = jasmine.createSpy()
      @imageTrimmer.on 'new:image:ready', spy
      runs () ->
        imageUrl = '/images/stubs/longImage.jpg'
        @imageTrimmer.newImage imageUrl, 'remote'

      waitsFor () ->
        spy.callCount > 0

      runs () ->
        trimHeight = $('.image-trim').height()
        topOffset = $('.image-trim').offset().top + parseInt($('.image-trim').css('border-top-width'))

        expect($('img').height()).toBe(trimHeight)
        expect($('img').offset().top).toBe(topOffset)
