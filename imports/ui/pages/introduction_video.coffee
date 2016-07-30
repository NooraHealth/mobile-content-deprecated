
{ Modules } = require("meteor/noorahealth:mongo-schemas")
{ ContentInterface }= require('../../api/content/ContentInterface.coffee')
{ AppState }= require('../../api/AppState.coffee')
{ TAPi18n } = require("meteor/tap:i18n")

require '../components/lesson/modules/video.coffee'
require '../components/lesson/footer/footer.coffee'
require './introduction_video.html'

Template.Introduction_video_page.onCreated ()->

  @state = new ReactiveDict()
  @state.setDefault {
    playingVideo: false
    letsBeginButtonAnimated: false
  }

  @onPlayVideo = =>
    @state.set "playingVideo", true

  @onStopVideo = =>
    @state.set "playingVideo", false

  @onVideoEnd = =>
    @state.set "playingVideo", false
    @state.set "letsBeginButtonAnimated", true

  @videoPlaying = =>
    playing = @state.get "playingVideo"
    if playing? then return playing else return false

  @autorun =>
   if Meteor.isCordova and Meteor.status().connected
    console.log "Subscribing!!"
    @subscribe "curriculums.all"
    @subscribe "lessons.all"
    @subscribe "modules.all"

Template.Introduction_video_page.helpers
  modulesReady: ->
    instance = Template.instance()
    return instance.subscriptionsReady()
  
  introModule: ->
    return AppState.getIntroductionModule()

  footerArgs: ->
    instance = Template.instance()
    language = AppState.getLanguage()
    return {
      language: language
      homeButton: {
        onClick: ->
        shouldShow: -> return false
        text: ""
      }
      nextButton: {
        onClick: -> FlowRouter.go "home"
        text: AppState.translate "begin", language
        onRendered: ->
        animated: instance.state.get("letsBeginButtonAnimated")
      }
      replayButton: {
        onClick: ->
        shouldShow: -> return false
      }
      pages: []
    }

  videoArgs: ( module ) ->
    instance = Template.instance()
    language = AppState.getLanguage()
    data = {
      module: module
      language: language
      onPlayVideo: instance.onPlayVideo
      onStopVideo: instance.onStopVideo
      onVideoEnd: instance.onVideoEnd
      playing: instance.videoPlaying()
    }
    return data
