Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

TEMPLATE_CONTROLLER_EVENTS = {}


_.extend(Backbone.Validation.callbacks, {
  valid: (view, attr, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group');

    $group.removeClass('has-error');
    $group.find('.help-block').html('').addClass('hidden');

  invalid: (view, attr, error, selector) ->
    $el = view.$('[name=' + attr + ']')
    $group = $el.closest('.form-group');

    $group.addClass('has-error');
    $group.find('.help-block').html(error).removeClass('hidden');

})


class TemplateController extends Backbone.View
  template: _.template(require('html!./TemplateView.tmpl'))

  initialize: (options) ->


  events: {}

  render: =>
    $(@el).html @template()

    @



module.exports =
  TemplateController: TemplateController
  TEMPLATE_CONTROLLER_EVENTS: TEMPLATE_CONTROLLER_EVENTS