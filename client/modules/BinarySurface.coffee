
###
# Binary Choice Surface
###
class @BinarySurface
  @get: ( module, parent )->
    if not @.surface
      @.surface = new PrivateSurface module
      parent.addChild @.surface
    else
      @.surface.setModule module

    return @.surface

  class PrivateSurface extends ModuleSurface
    constructor: ( @_module )->
      super @._module
      @.extend BasicQuestion

      @.TITLE_HEIGHT = 60

      @.setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.RELATIVE_SIZE
      .setProportionalSize .8, .7, 1

      @.domElement.addClass "card"

      @.image = new ModuleImage @._module.image
      @.title = new TitleBar @._module.question, { x: 600, y: @.TITLE_HEIGHT }
      @.noBtn = new NoButton "No"
      @.yesBtn = new YesButton "Yes"

      @.addChild @.image
      @.addChild @.title
      @.addChild @.noBtn
      @.addChild @.yesBtn

      @.buttons = [ @.noBtn, @.yesBtn ]
      for button in @.buttons
        button.setSizeMode Node.RELATIVE_SIZE, Node.RELATIVE_SIZE, Node.ABSOLUTE_SIZE
        button.setProportionalSize .4, .075

    setModule: ( module )=>
      super
      @._module = module
      @.resetContent()
