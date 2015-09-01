
class @ModulesView extends BaseNode

  constructor: ()->
    super

    @.setOrigin .5, .5, .5
     .setAlign .5, .4, .5
     .setMountPoint .5, .5, .5
     #.setSizeMode Node.ABSOLUTE_SIZE, Node.ABSOLUTE_SIZE, Node.ABSOLUTE_SIZE
     .setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.RELATIVE_SIZE
     .setProportionalSize .8, .7, 1
     #.setAbsoluteSize 600, 500, 0
     .setPosition 0, 0, 0

    #all the rendered module surfaces
    @.surfaces = []
    @._addNextBtn()

    @.positionTransitionable = new Transitionable 1
    @.requestUpdateOnNextTick()

  onUpdate: ()->
    pageWidth = Scene.get().getPageSize().x
    @.setPosition @.positionTransitionable.get() * pageWidth, 0, 0

  moveOffstage: ()->
    @.positionTransitionable.halt()
    @.positionTransitionable.to 1, 'easeOut', 500
    @.hide()
    @.requestUpdateOnNextTick(@)

  moveOnstage: ()->
    @.positionTransitionable.halt()
    @.positionTransitionable.to 0, 'easeIn', 500
    @.show()
    @.requestUpdateOnNextTick(@)

  goToNextModule: ()->
    index = @.currentIndex + 1
    @.showModule index

  showModule: (index)->
    if @.currentIndex? and @.surfaces[@.currentIndex]
      @.surfaces[@.currentIndex].moveOffstage()
    if @.surfaces[index]
      @.surfaces[index].moveOnstage()
      @.currentIndex = index
      return
    else
      Scene.get().goToLessonsPage()

  start: ()->
    @.showModule 0

  _removeNextBtn: ()->
    if @.next
      @.removeChild @.next

  _addNextBtn: ()->
    @.next = new NextBtn()
    @.addChild @.next

  setModules: (modules)->
    @._modules = modules
    @._removeNextBtn()
    @._addNextBtn()
    for surface in @.surfaces
      bool = @.removeChild surface

    for module, index in modules
      surface = SurfaceFactory.get().getModuleSurface(module, index)
      @.surfaces.push surface
      @.addChild surface


  @handleResponse: (moduleSurface, event)=>
    module = moduleSurface.getModule()

    if module.type == "MULTIPLE_CHOICE"
      @.handleMCResponse module, event
    else
      @.handleSingleChoiceResponse module, event

    if event
      event.target.classList.add "disabled"

    NextModuleBtn.show()

  @handleSingleChoiceResponse: (module, event)=>
    @.hideIncorrectResponses(module)
    
    if @.isCorrectResponse(module, event)
      @.displayToast "correct"
      @.handleCorrectResponse module
    else
      @.displayToast "incorrect"
      @.handleIncorrectResponse module

  @handleMCResponse: (module, event)->
    if @.allCorrectResponses module
      @.handleCorrectResponse module
    else
      @.handleIncorrectResponse module

    if event
      event.target.classList.add "faded"


  @stopAllAudio : ()->
    audio = $("audio")
    for elem in audio
      if elem[0]
        elem[0].pause()
      else if elem.pause
        elem.pause()

  @stopAudio: (audio)->
    for elem in audio
      if elem[0]
        elem[0].pause()
      else if elem.pause
        elem.pause()

  @playAudio : (type, module)->
    play = (elem)->
      elem[0].currentTime = 0
      elem[0].play()

    elem = $('#toplay'+module._id)
    if type=="question"
      #@.stopAllAudio()
      src = module.audioSrc()
      if elem[0].paused
        console.log elem.attr("src")
        console.log src
        if elem.attr("src") != src
          elem.attr('src',  src)
          console.log "Just changed the src"
          console.log elem
        play elem
      return
    #else if type=="correct"
      #toPlay  = $('#correcttoplay'+module._id)
      #toStop = questionAudio
    #else if type=="incorrect"
      #elem = $('#incorrecttoplay'+module._id)
      #toStop = questionAudio
      #console.log "Stopping the questionaudio"
      #console.log questionAudio

    else
    #@.stopAudio toStop

      #if type == "question"
        #src = module.audioSrc()
      if type == "correct"
        src = module.correctAnswerAudio()
      else if type == "incorrect"
        src = module.incorrectAnswerAudio()
      else
        src=""

      console.log "About to pause audio"
      if !elem[0].paused
        elem[0].pause()
      if elem.attr("src") != src
        elem.attr('src',  src)
      console.log "Elem"
      console.log elem

      console.log "About toplay the elem"
      play= ()->
        elem[0].currentTime = 0
        elem[0].play()
        
      elem[0].addEventListener "canplay", ()=>
        console.log "Can play event fired"
        play()
      , true

      play()

  @handleCorrectResponse: (module)->
    @.playAudio "correct", module
    handleSuccessfulAttempt(module, 0)
    updateModuleNav "correct"

  @handleIncorrectResponse: (module)->
    @.playAudio "incorrect", module
    updateModuleNav "incorrect"

  @displayToast : (type)->
    if Meteor.Device.isPhone()
      if type=="correct"
        Session.set "success toast is visible", true
      else
        Session.set "fail toast is visible", true
    else
      classes = "left valign rounded"
      if type=="correct"
        Materialize.toast "<i class='mdi-navigation-check medium'></i>", 5000, classes+ " green"
      else
        Materialize.toast "<i class='mdi-navigation-close medium'></i>", 5000, classes+ " red"

  @hideIncorrectResponses : ()->
    responseBtns =  $(".response")
    for btn in responseBtns
      if not $(btn).hasClass "correct"
        $(btn).addClass "faded"
        
      else
        $(btn).addClass "z-depth-2"
        $(btn).addClass "expanded"
      $(btn).unbind "click"

  @updateModuleNav : (responseStatus)->
    moduleIndex = Session.get "current module index"
    correctAnswers = Session.get "correctly answered"
    incorrectlyAnswered = Session.get "incorrectly answered"

    if responseStatus == "correct"
      if moduleIndex in correctAnswers
        return
      #Remove the index from the array of incorrect answers
      if moduleIndex in incorrectlyAnswered
        incorrectlyAnswered = incorrectlyAnswered.filter (i) -> i isnt moduleIndex
        Session.set "incorrectly answered", incorrectlyAnswered
      correctAnswers.push Session.get "current module index"
      Session.set "correctly answered", correctAnswers

    if responseStatus == "incorrect"
      if moduleIndex in incorrectlyAnswered
        return
      incorrectlyAnswered.push Session.get "current module index"
      Session.set "incorrectly answered", incorrectlyAnswered

  @allCorrectResponses: (module)->
    #fade out all the containers of the incorrect options
    [responses, numIncorrect] = @.expandCorrectOptions(module)

    if numIncorrect > 0
      return false
    else
      return true

  @isCorrectResponse: ( module, event ) ->
    return event.target.classList.contains "correct"

  @expandCorrectOptions: (module) ->
      id = module._id
      options = $("#"+id).find("img[name=option]")
      responses = []
      numIncorrect = 0
      for option in options
        #if $(option).hasClass "selected"
          #responses.push $(option).attr "name"
        if not $(option).hasClass "correct"
          $(option).addClass "faded"
        
        else
          $(option).addClass "expanded"
          
          if not $(option).hasClass "selected"
            numIncorrect++
            $(option).addClass "incorrectly_selected"

          else
          $(option).removeClass "selected"
          $(option).addClass "correctly_selected"

      return [responses, numIncorrect]

class NextBtn extends Node
  constructor: ()->
    @[name] = method for name, method of Node.prototype
    Node.apply @
    console.log "Building a NextBtn"

    x = Scene.get().getPageSize().x
    y = Scene.get().getPageSize().y

    @.setOrigin .5, .5, .5
     .setMountPoint 1, 1, .5
     .setAlign 1, 1, .5
     .setSizeMode "absolute", "absolute", "absolute"
     .setAbsoluteSize 200, 50, 0
     .setPosition 40, 100, 20

    @.domElement = ResponseButton.getButtonDomElement(@)
    @.domElement.setContent "NEXT <i class='mdi-navigation-arrow-forward medium'/>"
    @.addUIEvent "click"

  onReceive: (e, payload) ->
    if e == 'click'
      Scene.get().goToNextModule()
      payload.stopPropagation()
