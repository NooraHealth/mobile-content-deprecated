
Lessons = require('../../api/lessons/lessons.coffee').Lessons
Modules = require('../../api/modules/modules.coffee').Modules

require './lesson_view.html'
require '../components/lesson/modules/binary.coffee'
require '../components/lesson/modules/scenario.coffee'
require '../components/lesson/modules/multiple_choice.coffee'
require '../components/lesson/modules/slide.html'
require '../components/lesson/modules/video.coffee'
require '../components/lesson/footer/footer.coffee'

Template.Lesson_view_page.onCreated ()->
  @state = new ReactiveDict()
  @state.setDefault {
    moduleIndex: 0
  }

  @isCurrent = (moduleId) =>
    modules = @getLesson().modules
    index = @state.get "moduleIndex"
    return index == modules.indexOf moduleId

  @isCompleted = (moduleId) =>
    modules = @getLesson()?.modules
    index = @state.get "moduleIndex"
    return index > modules?.indexOf moduleId

  @getPagesForPaginator = =>
    modules = @getModules()
    if not modules?
      return []
    else
      getPageData = (module, i) =>
        data = {
          completed: @isCompleted module._id
          current: @isCurrent module._id
          index: i+1
        }
        return data
      pages = ( getPageData(module, i) for module, i in modules )
      return pages

  @lessonComplete = =>
    console.log "Getting whether the lesson is complete in lesson_view.coffee"
    lesson = @getLesson()
    console.log "lesson, ", lesson
    index = @state.get "moduleIndex"
    console.log index
    console.log lesson?.modules?.length-1
    return index == lesson?.modules?.length-1

  @getModules = =>
    return @getLesson()?.getModulesSequence()

  @getLesson = =>
    id = FlowRouter.getParam "_id"
    lesson = Lessons.findOne { _id: id }
    console.log "getting the lesson"
    console.log id
    return lesson

  @onNextButtonClicked = =>
    index = @state.get "moduleIndex"
    @state.set "moduleIndex", ++index

Template.Lesson_view_page.helpers
  footerArgs: ()->
    instance = Template.instance()
    return {
      onHomeButtonClicked: -> FlowRouter.go "home"
      onNextButtonClicked: instance.onNextButtonClicked
      onReplayButtonClicked: =>
      pages: instance.getPagesForPaginator()
      lessonComplete: instance.lessonComplete
    }

  lessonTitle: ()->
    instance = Template.instance()
    return instance.getLesson()?.title

  moduleArgs: (module) ->
    return { module: module }

  modules: ->
    instance = Template.instance()
    console.log instance.getModules()
    return instance.getModules()

  getTemplate: (module) ->
    if module?.type == "BINARY"
      return "Lesson_view_page_binary"
    if module?.type == "MULTIPLE_CHOICE"
      return "Lesson_view_page_multiple_choice"
    if module?.type == "SCENARIO"
      return "Lesson_view_page_scenario"
    if module?.type == "VIDEO"
      return "Lesson_view_page_video"
    if module?.type == "SLIDE"
      return "Lesson_view_page_slide"

Template.Lesson_view_page.onRendered ()->
  mySwiper = App.swiper '.swiper-container', {
      lazyLoading: true,
      preloadImages: false,
      nextButton: '.swiper-button-next',
  }
