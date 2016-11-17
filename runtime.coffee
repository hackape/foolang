Constants = {}

class BaseObjecta
  constructor: (__class__, __value__) ->
    @__class__ = __class__
    @__value__ = if arguments.length == 1 then this else __value__ 

  call: (method_name, args=[]) ->
    @__class__.lookup(method_name)(this, args)

  @new: ->
    new this(arguments...)

class BaseClass extends BaseObject
  constructor: ->
    @__methods__ = {}
    @__class__ = Constants['Class']

  lookup: (method_name) ->
    method = @__methods__[method_name]
    throw "Method #{method_name} not found" if not method
    return method

  def: (method_name, method) ->
    @__methods__[method_name] = method

  new: (value) ->
    if arguments.length
      BaseObject.new(this, value)
    else
      BaseObject.new(this)

  new_with_value: (value) ->
    BaseObject.new(this, value)


class BaseMethod
  constructor: (@params, @body) ->

  call: (receiver, args) ->
    context = Context.new(receiver)

    @params.forEach (param, i) ->
      context.locals[param] = args[i]

    @body.eval(context)


class Context
  constructor: (current_self, current_class=current_self.__class__) ->
    @locals = {}
    @current_self = current_self
    @current_class = current_class

  @new: ->
    new this(arguments...)


# Bootstrapping

Constants['Class'] = BaseClass.new()
Constants['Object'] = BaseClass.new()
Constants['Number'] = BaseClass.new()
Constants['String'] = BaseClass.new()
Constants['TrueClass'] = BaseClass.new()
Constants['FalseClass'] = BaseClass.new()
Constants['NilClass'] = BaseClass.new()

root_self = Constants['Object'].new()
RootContext = Context.new(root_self)

Constants['true'] = Constants['TrueClass'].new(true)
Constants['false'] = Constants['TrueClass'].new(false)
Constants['nil'] = Constants['NilClass'].new(null)

for key of Constants
  Constants[key].__name__ = key

Constants['Class'].def 'new', (receiver, args) -> receiver.new()
Constants['Object'].def 'print', (receiver, args) -> console.log(args[0].__value__);Constants['nil']

binaryOperatorFactory = (operator) ->
  Constants['Number'].def operator, (receiver, args) -> 
    expression = String(receiver.__value__) + operator + String(args[0].__value__)
    result = eval(expression)
    return Constants['Number'].new(result)

['+', '-', '*', '/'].forEach (operator) -> binaryOperatorFactory(operator)


exports.Constants = Constants
exports.RootContext = RootContext
