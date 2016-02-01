
###
# Home
# Displays all lessons in curriculum
###
FlowRouter.route '/', {
  name: "home"
  action: ( params, qparams )->
    BlazeLayout.render "layout", { main : "lessonsView" }
}

###
# module sequence
###

FlowRouter.route '/modules/:_id', {
  name: "module"
  action: ( params, qparams )->
    Scene.get().stopAudio()
    BlazeLayout.render "layout", { main: "modulesSequence" , footer: "moduleFooter" }
}

FlowRouter.route '/loading',
  name: "loading"
  action: ()->
    BlazeLayout.render "layout", { main: "loading" }

