NUM_OBJECTS_PER_ROW = 3

Modules = require('../collections.coffee').Modules

###
# Module
#
# A single unit of instructional material, 
# such as a question, a slide, an audio clip, 
# or a video.
###

Modules.helpers {
  videoUrl: ()->
    #return this.video_url + "?autoplay=1"
    return this.video_url

  isEmbedded: ()->
    if this.video or !this.video_url
      return false
    else
      return this.video_url.startsWith "http"

  isLastModule: ()->
    return @.next_module == -1

  imgSrc: ()->
    if not @.image
      return ""
    url = Meteor.getContentSrc()
    return url+ @.image

  audioSrc: ()->
    if not @.audio
      return ""
    url = Meteor.getContentSrc()
    return url + @.audio

  incorrectAnswerAudio: ()->
    if not @.incorrect_audio
      return ""

    url = Meteor.getContentSrc()
    return url + @.incorrect_audio

  correctAnswerAudio: ()->
    if not @.correct_audio
      return ""
    url = Meteor.getContentSrc()
    return url + @.correct_audio
  
  videoSrc: ()->
    if not @.video
      return ""
    url = Meteor.getContentSrc()
    return url  + @.video

  isCorrectAnswer: (response)->
    return response in @.correct_answer

  getOptions: (start, end)->
    url = Meteor.getContentSrc()
    module = @

    if not @.options
      return []

    isCorrect = (option)=>
      return option in @.correct_answer

    newArr = ({option: option, optionImgSrc: url + option, nh_id: module.nh_id, i: i, correct: isCorrect(option)} for option, i in @.options when i >= start and i < end)
    return {options: newArr}

  option: (i)->
    return @.options[i]

  isVideoModule: ()->
    return @.type == "VIDEO"

  isBinaryModule: ()->
    return @.type == "BINARY"

  isMultipleChoiceModule: ()->
    return @.type == "MULTIPLE_CHOICE"

  isSlideModule: ()->
    return @.type == "SLIDE"
  
  isGoalChoiceModule: ()->
    return @.type == "GOAL_CHOICE"

  isScenarioModule: ()->
    return @.type == "SCENARIO"

  isLastModule: ()->
    return @.next_module == '-1' or @.next_module == -1

  nextModule: ()->
    return Modules.findOne {nh_id: @.next_module}
    
}