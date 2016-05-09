
{ ContentInterface } = require('../../api/content/ContentInterface.coffee')
{ ContentDownloader } = require('../../api/cordova/ContentDownloader.coffee')
{ Curriculums } = require("meteor/noorahealth:mongo-schemas")
{ AppState } = require('../../api/AppState.coffee')

# TEMPLATE
require './home.html'

# COMPONENTS
require '../../ui/components/shared/navbar.html'
require '../../ui/components/home/footer.html'
require '../../ui/components/home/thumbnail.coffee'
require '../../ui/components/home/menu/menu.coffee'
require '../../ui/components/home/menu/list_item.coffee'
require '../../ui/components/audio/audio.coffee'
require '../../ui/components/shared/loading.coffee'

Template.Home_page.onCreated ->
  
  #loads the soundeffects, circumventing a howler.js bug that prevents
  #them from loading in lessons_view.coffee
  new Howl {
    src: ['incorrect_soundeffect.mp3']
  }
  new Howl {
    src: ['correct_soundeffect.mp3']
  }

  @getLessonDocuments = =>
    curriculum = @getCurriculumDoc()
    docs = curriculum?.getLessonDocuments()
    return docs

  @getCurriculumDoc = =>
    id = AppState.get().getCurriculumId()
    return Curriculums?.findOne {_id: id }

  @currentLessonId = =>
    curriculum = @getCurriculumDoc()
    numLessons = if curriculum then curriculum.lessons.length else 0
    if not curriculum? then return 0
    lessonIndex = AppState.get().getLessonIndex()
    if lessonIndex >= numLessons
      lessonIndex = 0
      AppState.get().setLessonIndex lessonIndex
    return curriculum?.lessons?[lessonIndex]

  @onLessonSelected = (id) ->
    FlowRouter.go "lesson", {_id: id}

  @onCurriculumSelected = (id) ->
    AppState.get().setCurriculumId id
    AppState.get().setLessonIndex 0

  @autorun =>
    id = AppState.get().getCurriculumId()
    if not Meteor.isCordova
      @subscribe "curriculums.all"
      @subscribe "lessons.inCurriculum", id

  @autorun =>
    subscriptionsReady = @subscriptionsReady()
    id = AppState.get().getCurriculumId()
    curriculumDownloaded = AppState.get().getCurriculumDownloaded(id)
    loading = AppState.get().loading()
    if subscriptionsReady and
      Meteor.isCordova and
      id? and not
      curriculumDownloaded and not
      loading
        if not Meteor.status().connected
          AppState.get().setError(new Meteor.Error("Not Connected", "Please connect to data in order to download your curriculum."))
        else
          onError = (e) ->
            console.log "ERROR LOADING"
            console.log e
            AppState.get().setError e
            AppState.get().setLoading false
          onSuccess = (e) ->
            console.log "SUCCESS LOADING"
            AppState.get().setCurriculumDownloaded id, true
            AppState.get().setLoading false
          AppState.get().setLoading true
          Tracker.flush()
          ContentDownloader.get().loadCurriculum id, onSuccess, onError

  @autorun =>
    id = AppState.get().getCurriculumId()
    if Meteor.isCordova and @subscriptionsReady() and not id
      if not Meteor.status().connected
        AppState.get().setError(new Meteor.Error("Not Connected", "Please connect to data in order to view and download curriculums"))

Template.Home_page.helpers
  curriculumsReady: ->
    instance = Template.instance()
    if Meteor.isCordova
      id = AppState.get().getCurriculumId()
      console.log "In the curriculums ready: is curriculum downloaded?", AppState.get().getCurriculumDownloaded(id)
      return instance.subscriptionsReady() and not AppState.get().loading()
    else
      return instance.subscriptionsReady()

  isLoading: ->
    return AppState.get().loading()

  menuArgs: ->
    instance = Template.instance()
    curriculumsToList = Curriculums.find({title:{$ne: "Start a New Curriculum"}})
    return {
      onCurriculumSelected: instance.onCurriculumSelected
      curriculums: curriculumsToList
    }

  thumbnailArgs: (lesson) ->
    instance = Template.instance()
    isCurrentLesson = ( lesson?._id == instance.currentLessonId() )
    return {
      lesson: lesson
      onLessonSelected: instance.onLessonSelected
      isCurrentLesson: isCurrentLesson
    }

  audioArgs: ->
    instance = Template.instance()
    setPlayIntroToFalse = -> AppState.get().setShouldPlayIntro false
    return {
      attributes: {
        src: ContentInterface.get().introPath()
      }
      playing: AppState.get().getShouldPlayIntro()
      whenPaused: setPlayIntroToFalse
      whenFinished: setPlayIntroToFalse
    }

  lessons: ->
    instance = Template.instance()
    return instance.getLessonDocuments()

Template.Home_page.events
  'click #open_side_panel': (e, template) ->
    #hackaround Framework7 bugs on ios where active state is not removed
    console.log("removing the activestate")
    active = template.find(".active-state")
    if active? then $(active).removeClass "active-state"

Template.Home_page.onDestroyed ->
  AppState.setLoading false
