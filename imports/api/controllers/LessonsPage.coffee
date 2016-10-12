

{ AppConfiguration } = require '../AppConfiguration.coffee'
{ Translator } = require '../utilities/Translator.coffee'
{ Curriculums } = require("meteor/noorahealth:mongo-schemas")
{ LessonsPageModel } = require '../models/lessons/LessonsPage.coffee'
{ Analytics } = require '../analytics/Analytics.coffee'
{ Award } = require('../../ui/components/lessons/popups/award.coffee')
{ AudioController } = require './Audio.coffee'
{ VideoController } = require './Video.coffee'
{ IntroductionToQuestions } = require('../../ui/components/lessons/popups/introduction_to_questions.coffee')
{ correctSoundEffectFilename } = require '../content/AudioContent.coffee'
{ incorrectSoundEffectFilename } = require '../content/AudioContent.coffee'

class LessonsPageController
  ## ------------- PUBLIC METHODS ------------ ##

  onFinishExplanation: ( module, lesson, completedAudio, filename, duration ) ->
    console.log "IN the on finish explanation"
    isCurrent = @model.isCurrentModule module
    if isCurrent
      @model.animate "nextButton", true
    console.log "About to track audio stopped"
    @audioController.trackAudioStopped( module, lesson, @language, @condition, completedAudio, filename, duration )

  onLevelSelected: ( index )->
    if not @model.levelHasLessons index
      swal {
        title: "Oops"
        text: "We don't have lessons available for that level yet"
      }
    else
      @model.startLevel index
      @autoplayMedia()
      @trackStartedLesson( @model.getCurrentLesson() )

  onWrongChoice: ( module, choice )->
    @audioController.playAudio( incorrectSoundEffectFilename , 1, true)
    if module.type != "MULTIPLE_CHOICE"
      swal {
        title: ""
        type: "error"
        timer: 3000
        confirmButtonText: Translator.translate "ok", @model.getLanguage()
      }
    @trackChoice module, choice

  onCorrectChoice: ( module, choice )->
    @audioController.playAudio( correctSoundEffectFilename , 1, true)
    if module.type != "MULTIPLE_CHOICE"
      swal {
        title: ""
        type: "success"
        timer: 3000
        confirmButtonText: Translator.translate "ok", @model.getLanguage()
      }
    @trackChoice module, choice

  onCompletedQuestion: ( module )->
    @audioController.stopAudio()
    audio = @audioController.playAudio module.correct_audio, 1, false, @onFinishExplanation.bind(@, module), @onFinishExplanation.bind(@, module)
    @

  celebrateCompletion: ->
    onConfirm = =>
      if @model.onLastLesson()
        @goToSelectLevelSlide(null, true)
      else
        @model.goToNextLesson()
        @trackStartedLesson( @model.getCurrentLesson() )
        @autoplayMedia()

    onCancel = =>
      @goToSelectLevelSlide(null, false)

    numLessons = @model.getCurrentLessons().length
    numLessonsCompleted = @model.getLessonIndex() + 1
    if @model.onLastLesson()
      new Award(@language).sendAward( null, null, numLessonsCompleted, numLessons)
      @goToSelectLevelSlide( null, true )
    else
      new Award(@language).sendAward( onConfirm, onCancel, numLessonsCompleted, numLessons )

  onNextButtonClicked: ->
    lessonComplete = @model.onLastModule()
    currentModule = @model.getCurrentModule()
    @audioController.destroyAudio()
    @model.disable "nextButton", true
    if currentModule.type == "VIDEO"
      @videoController.stopVideo currentModule
    else if @model.onLastModule()
      @celebrateCompletion()
    else
      @model.goToNextModule()
      @autoplayMedia()

  onReplayButtonClicked: ->
    @audioController.replayCurrentAudio()

  onVideoEnd: ->
    if not @model.onLastModule() and not @model.onSelectLevelSlide()
      @showIntroductionToQuestions()
    else
      @celebrateCompletion()

  onPageRendered: ->
    @audioController.playAudio correctSoundEffectFilename, 0, true

  onSlideToNext: ->
    @model.disable "nextButton", false

  #######################################
  ### CONSTRUCTOR AND PRIVATE METHODS ###
  #######################################

  constructor: ( @curriculum, @language, @condition ) ->
    @audioController = new AudioController()
    @videoController = new VideoController()
    @model = new LessonsPageModel @curriculum, @language, @condition

    @showIntroductionToQuestions = ->
      goToNext = ()=>
        @model.goToNextModule()
        @autoplayMedia()

      new IntroductionToQuestions().send( goToNext, goToNext, @language )

    @goToSelectLevelSlide = ( event, completedLevel) ->
      lesson = @model.getCurrentLesson()
      module = @model.getCurrentModule()
      @trackGoingToSelectLevel lesson, module, completedLevel
      if completedLevel then @model.goToNextLevel()
      else @model.goToSelectLevelSlide()
      @audioController.destroyAudio()

    @autoplayMedia = ->
      module = @model.getCurrentModule()
      lesson = @model.getCurrentLesson()
      if module?.type == "VIDEO"
        @videoController.playVideo module
      if module?.hasAudio()
        onFinishAudio = if module.hasExplanation() then @audioController.trackAudioStopped.bind(@, module, lesson, @language, @condition) else @onFinishExplanation.bind(@, module, lesson)
        audio = @audioController.playAudio module.audio, 1, false, onFinishAudio, onFinishAudio

    @trackStartedLesson = ( lesson )->
      Analytics.registerEvent "TRACK", "Left Lesson For Home", {
        lessonTitle: lesson?.title
        lessonId: lesson?._id
      }

    @trackGoingToSelectLevel = ( lesson, module, completedLevel )->
      text = if module?.title then module?.title else module?.question
      Analytics.registerEvent "TRACK", "Left Lesson For Home", {
        lessonTitle: lesson?.title
        lessonId: lesson?._id
        lastModuleId: module?._id
        lastModuleText: text
        lastModuleType: module?.type
        completedLevel: completedLevel
        numberOfModulesInLesson: lesson?.modules.length
      }

    @trackChoice = ( module, choice )->
      lesson = @model.getCurrentLesson()
      text = if module?.title then module?.title else module?.question
      Analytics.registerEvent "TRACK", "Responded to Question", {
        moduleId: module._id
        moduleText: text
        choice: choice
        lessonTitle: lesson.title
        lessonId: lesson._id
        condition: @condition
        language: @language
        type: module.type
      }


  module.exports.LessonsPageController = LessonsPageController
