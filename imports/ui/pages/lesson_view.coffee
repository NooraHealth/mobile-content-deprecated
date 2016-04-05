
Lessons = require('../../api/lessons/lessons.coffee').Lessons
require './lesson_view.html'

Template.Lesson_view_page.onCreated ()->
  @state = new ReactiveDict()
  @state.setDefault {
    moduleIndex: 0
  }

  @getLesson = ()=>
    console.log "Getting the lesson"
    id = FlowRouter.getParam "_id"
    console.log id
    lesson = Lessons.findOne { _id: id }
    console.log Lessons.find({}).count()
    console.log lesson
    return lesson

  @onClickNext = ()=>
    index = @state.get "moduleIndex"
    @state.set "moduleIndex", ++index

Template.Lesson_view_page.helpers
  lessonTitle: ()->
    instance = Template.instance()
    return instance.getLesson().title

  modules: ()->
    lesson = Template.instance().getLesson()
    return lesson.getModulesSequence()

  getTemplate: ( module )->
    console.log "getting the template"
    if module?.type == "BINARY"
      return "Lessons_view_page_binary"
    if module?.type == "MULTIPLE_CHOICE"
      return "Lessons_view_page_multiple_choice"
    if module?.type == "SCENARIO"
      return "Lessons_view_page_scenario"
    if module?.type == "VIDEO"
      return "Lessons_view_page_video"
    if module?.type == "SLIDE"
      return "Lessons_view_page_slide"

Template.Lesson_view_page.onRendered ()->
  mySwiper = App.swiper '.swiper-container', {
      lazyLoading: true,
      preloadImages: false,
      nextButton: '.swiper-button-next',
  }
