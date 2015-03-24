###
# Lesson
#
# A lesson is a collection of modules, and may or 
# may not contain sublessons
###

LessonSchema = new SimpleSchema
  short_title:
    type: String
    optional: true
  title:
    type:String
  description:
    type:String
    optional:true
  image:
    type: String
    regEx:  /^([/]?\w+)+[.]png/
  tags:
    type:[String]
    minCount:0
    optional:true
  has_sublessons:
    type:String
    defaultValue: "false"
  lessons:
    type:[String]
    optional:true
    #custom: ()->
#      if this.field('has_sublessons').value == "true"
        #return "required"
  first_module:
    type:String
    optional:true
#    custom: ()->
      #if this.field('has_sublessons').value == "true"
        #return "required"
  nh_id:
    type:String
    min:0

Lessons.attachSchema LessonSchema

Lessons.helpers {
  getSublessonDocuments: ()->
    
    if !this.has_sublessons
      return []

    lessons = []
    _.each this.lessons, (lessonID) ->
      lesson = Lessons.findOne {nh_id: lessonID}
      if lesson
        lessons.push lesson

    return lessons

  getModulesSequence: ()->
    if !this.first_module
      Meteor.Error "This lesson does not have any modules"

    else
      modules = []
      module = @.getFirstModule()
      modules.push module
      until module.isLastModule()
        module = module.nextModule()
        modules.push module
      console.log typeof modules
      return modules

  getFirstModule: ()->
    return Modules.findOne {nh_id: @.first_module}

  hasSublessons: ()->
    if @.has_sublessons
      return @.has_sublessons == 'true'
    else
      return false

  imgSrc: ()->
    return MEDIA_URL + @.image
}



