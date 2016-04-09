
AppState = require('../../api/AppState.coffee').AppState
Lessons = require('../../api/lessons/lessons.coffee').Lessons
Modules = require('../../api/modules/modules.coffee').Modules
Award = require('../components/lesson/awards/award.coffee').Award

require './lesson_view.html'
require '../components/lesson/modules/binary.coffee'
require '../components/lesson/modules/scenario.coffee'
require '../components/lesson/modules/multiple_choice/multiple_choice.coffee'
require '../components/lesson/modules/slide.html'
require '../components/lesson/modules/video.coffee'
require '../components/lesson/footer/footer.coffee'

Template.Lesson_view_page.onCreated ()->
  @state = new ReactiveDict()
  @state.setDefault {
    moduleIndex: 0
    correctlySelectedClasses: 'correctly-selected expanded'
    incorrectClasses: 'faded'
    incorrectlySelectedClasses: 'incorrectly-selected'
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

  @onCorrectAnswer = ->
    console.log "On correct answer!!"
    swal {
      title: ""
      type: "success"
      timer: 3000
    }

  @onWrongAnswer = ->
    console.log "On wrong answer!!"
    swal {
      title: ""
      type: "error"
      timer: 3000
    }

  @lessonComplete = =>
    lesson = @getLesson()
    index = @state.get "moduleIndex"
    return index == lesson?.modules?.length-1

  @getModules = =>
    return @getLesson()?.getModulesSequence()

  @getLesson = =>
    id = FlowRouter.getParam "_id"
    lesson = Lessons.findOne { _id: id }
    return lesson

  @celebrateCompletion = =>
    AppState.get().incrementLesson()
    new Award().sendAward()
    @goHome()

  @goHome = ->
    FlowRouter.go "home"

  @goToNextModule = =>
    index = @state.get "moduleIndex"
    @state.set "moduleIndex", ++index

  @onNextButtonRendered = =>
    mySwiper = App.swiper '.swiper-container', {
        lazyLoading: true,
        preloadImages: false,
        nextButton: '.swiper-button-next',
    }

Template.Lesson_view_page.helpers
  footerArgs: ->
    instance = Template.instance()
    onNextButtonClicked = if instance.lessonComplete() then instance.celebrateCompletion else instance.goToNextModule
    return {
      onHomeButtonClicked: instance.goHome
      onNextButtonClicked: onNextButtonClicked
      onReplayButtonClicked: =>
      pages: instance.getPagesForPaginator()
      lessonComplete: instance.lessonComplete
      onNextButtonRendered: instance.onNextButtonRendered
    }

  lessonTitle: ->
    instance = Template.instance()
    return instance.getLesson()?.title

  moduleArgs: (module) ->
    instance = Template.instance()
    isQuestion = (type) ->
      return type == "BINARY" or type == "SCENARIO" or type == "MULTIPLE_CHOICE"

    shouldRespondWithPopups = (type)->
      return type == "BINARY" or type == "SCENARIO"

    if isQuestion module.type
      args = {
        module: module
        incorrectClasses: instance.state.get "incorrectClasses"
        incorrectlySelectedClasses: instance.state.get "incorrectlySelectedClasses"
        correctlySelectedClasses: instance.state.get "correctlySelectedClasses"
      }
      if shouldRespondWithPopups module.type
        args["onWrongAnswer"] = instance.onWrongAnswer
        args["onCorrectAnswer"] = instance.onCorrectAnswer
      return args
    else
      return {module: module}

  modules: ->
    instance = Template.instance()
    console.log "Getting the modules", instance.getModules()
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
