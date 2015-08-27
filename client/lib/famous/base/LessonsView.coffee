
class @LessonsView extends Node
  constructor: ()->
    @[name] = method for name, method of Node.prototype
    Node.apply @

    @.STEP = .03
    @.THUMBNAILS_PER_ROW = 3

    alignTransitionable = new Transitionable 0

    @.setOrigin .5, .5, .5
     .setMountPoint .5, .5, .5
     .setAlign .5, .5, .5
     .setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.RELATIVE_SIZE
     .setProportionalSize .8, .8, 1

    @.thumbnails = []
    @.lessons = []

  setLessons: (lessons)->
    @.lessons = lessons
    @.thumbnails = []
    for lesson, index in lessons
      @.addThumbnail lesson

  addThumbnail: (lesson)->
    thumb = new LessonThumbnail(lesson)
    @.addChild thumb
    index = ( @.thumbnails.push thumb ) - 1
    proportion = ( 1 - @.STEP * @.THUMBNAILS_PER_ROW ) / @.THUMBNAILS_PER_ROW
    thumb.setProportionalSize proportion, proportion

    col = index %% @.THUMBNAILS_PER_ROW
    row = Math.floor(index / @.THUMBNAILS_PER_ROW)
    numCols = @.THUMBNAILS_PER_ROW
    numRows = Math.ceil(@.thumbnails.length / @.THUMBNAILS_PER_ROW)
    thumb.moveToPosition col, row, numCols, numRows

  getRenderable: ()->
    return @.node

  getCurrentLessonIndex: ()->
    lessonsComplete = Meteor.user().getCompletedLessons().length
    if lessonsComplete < @.lessons.length
      return lessonsComplete
    else
      return 0

  direction: ()->
    if Meteor.Device.isPhone()
      return 1
    else
      return 0

  goToNextPage: (i)->
    @.scroll.goToNextPage i

  goToPage: (i)->
    @.scroll.goToPage i

  buildScrollview: ()->
    height = LessonThumbnail.getHeight()
    width = LessonThumbnail.getWidth() * (@.lessons.length+1)
    direction = @.direction()

    modifier = new StateModifier {
      align: [.5,.75]
    }

    node = new RenderNode modifier
    scroll = new Scrollview {
      direction: direction
      size: [width, height]
      paginated: true
    }
    node.add(scroll)

    return [node, scroll, modifier]