

###
# Binary Choice Surface
###
class @BinarySurface extends ModuleSurface
  constructor: ( @module, index )->
    super @.module, index

    @.setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.RELATIVE_SIZE
     .setProportionalSize .8, 1, 1

    @.domElement.addClass "card"

    @.image = new ModuleImage(@.module)
    @.noBtn = new NoButton("No")
    @.yesBtn = new YesButton("Yes")

    @.addChild @.image
    @.addChild @.noBtn
    @.addChild @.yesBtn

    @.buttons = [ @.noBtn, @.yesBtn ]

  onReceive: ( e, payload )->
    button = payload.node
    @.audio.pause()
    if button.value in @.module.correct_answer
      src = @.module.correct_audio
      @.notifyButtons button, "CORRECT", "INCORRECT"
      @.correctAudio.play()
    else
      src = @.module.incorrect_audio
      @.notifyButtons button, "INCORRECT", "CORRECT"
      @.incorrectAudio.play()

  notifyButtons: (button, response, otherResponse)=>
    for btn in @.buttons
      if btn == button
        btn.respond response
      else
        btn.respond otherResponse
      btn.disable()

class ModuleImage extends Node
  constructor: (@module)->
    @[name] = method for name, method of Node.prototype
    Node.apply @

    @.setOrigin .5, .5, .5
     .setAlign .5, .5, .5
     .setMountPoint .5, .4, .5
     .setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.RELATIVE_SIZE
     .setProportionalSize 1, .8

    img = Scene.get().getContentSrc( @.module.image )
    @.domElement = new DOMElement @, {
      content: "<img src='#{img}' class='binary-image'></img>"
    }

class YesButton extends ResponseButton
  constructor: (@value)->
    super @.value

    @.setOrigin .5, .5, .5
     .setAlign .05, 1, .5
     .setMountPoint 0, 1, .5
     .setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.ABSOLUTE_SIZE
     .setProportionalSize .4, .075

    @.domElement.addClass "green"
    @.domElement.setContent @.value.toUpperCase()

class NoButton extends ResponseButton
  constructor: (@value)->
    super @.value

    @.setOrigin .5, .5, .5
     .setAlign .95, 1, .5
     .setMountPoint 1, 1, .5
     .setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.ABSOLUTE_SIZE
     .setProportionalSize .4, .075

    @.domElement.addClass "red"
    @.domElement.setContent @.value.toUpperCase()
    #@.domElement = new DOMElement @, {
      #content: "<a class='full-width btn red waves-light waves-effect white-text'>NO</a>"
    #}

