{Constants, RootContext} = require './runtime'

code = """
if 0 {
  7;
  print(2*3);
}
"""
console.log '===== THE CODE =====\n\n' + code + '\n\n===== END CODE =====\n\n\n\n'



fs = require('fs')
jison = require("jison")
bnf = fs.readFileSync("./grammar.jison", "utf8")
parser = new jison.Parser(bnf)

parser.yy = require './nodes'

parser.yy.parseError = (message, {token}) ->
  console.log message
  {errorToken, tokens} = parser
  [errorTag, errorText, errorLoc] = errorToken

  errorText = switch
    when errorToken is tokens[tokens.length - 1]
      'end of input'
    when errorTag in ['INDENT', 'OUTDENT']
      'indentation'
    when errorTag in ['IDENTIFIER', 'NUMBER', 'INFINITY', 'STRING', 'STRING_START', 'REGEX', 'REGEX_START']
      errorTag.replace(/_START$/, '').toLowerCase()
    else
      helpers.nameWhitespaceCharacter errorText

  helpers.throwSyntaxError "unexpected #{errorText}", errorLoc

# console.log parser
ast = parser.parse(code)
# json = JSON.stringify(ast, null, 2)

ast.eval(RootContext)
