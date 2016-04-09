
Lessons = require('../../../api/lessons/lessons.coffee').Lessons
require './thumbnail.html'

Template.Home_thumbnail.onCreated ->
  # Data context validation
  @autorun =>
    console.log "validating the thumbnail"
    schema = new SimpleSchema({
      lesson: {type: Lessons._helpers}
      isCurrentLesson: {type: Boolean}
      onLessonSelected: {type: Function}
    }).validate(Template.currentData())

Template.Home_thumbnail.events
  'click' : ( e )->
    data = Template.currentData()
    data.onLessonSelected data.lesson._id

Template.Home_thumbnail.onRendered ->
  if Template.currentData().isCurrentLesson
    Template.instance().$(".js-scroll-into-view").scrollintoview {
      duration: 2500,
      direction: "vertical"
    }
    


  
