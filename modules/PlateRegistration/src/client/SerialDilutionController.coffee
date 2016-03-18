Backbone = require('backbone')
BackboneValidation = require('backbone-validation')
_ = require('lodash')
$ = require('jquery')

SERIAL_DILUTION_CONTROLLER_EVENTS = {}


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


class SerialDilutionController extends Backbone.View
  template: _.template(require('html!./SerialDilutionView.tmpl'))

  initialize: (options) ->


  events: {}

  render: =>
    $(@el).html @template()

    @



module.exports =
  SerialDilutionController: SerialDilutionController
  SERIAL_DILUTION_CONTROLLER_EVENTS: SERIAL_DILUTION_CONTROLLER_EVENTS