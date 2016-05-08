{Constants, RootContext} = require './runtime'

exports.Base = class Base
  @new: ->
    new this(arguments...)


exports.Nodes = class Nodes extends Base
  constructor: (nodes) ->
    if not nodes
      @nodes = [] 
    else
      if nodes instanceof Array
        @nodes = nodes
      else
        @nodes = [nodes]

  push: (node) ->
    @nodes.push node
    return @

  eval: (context) ->
    ret = undefined
    @nodes.forEach (node) -> 
      ret = node.eval(context)
    return ret ? Constants['nil']


exports.LiteralNode = class LiteralNode extends Base
  constructor: (@value) ->

exports.NumberNode = class NumberNode extends LiteralNode
  eval: (context) -> Constants['Number'].new(@value)

exports.TrueNode = class TrueNode extends LiteralNode
  constructor: -> super(true)
  eval: (context) -> Constants['true']

exports.FalseNode = class FalseNode extends LiteralNode
  constructor: -> super(false)
  eval: (context) -> Constants['true']

exports.NilNode = class NilNode extends LiteralNode
  constructor: -> super(null)
  eval: (context) -> Constants['nil']

exports.GetVariableNode = class GetVariableNode extends Base
  constructor: (@name) ->
  eval: (context) -> context.locals[@name]

exports.SetVariableNode = class SetVariableNode extends Base
  constructor: (@name, @value) ->
  eval: (context) -> context.locals[@name] = @value.eval(context)

exports.CallNode = class CallNode extends Base
  constructor: (@receiver, @method, @args) ->
  eval: (context) ->
    if @receiver
      @value = @receiver.eval(context)
    else
      @value = context.current_self

    eval_args = @args.map (arg) -> arg.eval(context)
    ret = @value.call(@method, eval_args)


exports.IfNode = class IfNode extends Base
  constructor: (@condition, @body) ->
  eval: (context) ->
    if @condition.eval(context).__value__
      @body.eval(context)
    else
      Constants['nil']
