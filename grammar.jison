%lex

%%
\s+        {/* whitespace */}
^[0-9]+    {return 'NUMBER'}
"("        {return '('}
")"        {return ')'}
"-"        {return '-'}
"+"        {return '+'}
"*"        {return '*'}
"/"        {return '/'}
"="        {return '='}
"if"       {return 'IF'}
"\n"       {return 'NEWLINE'}
"{"        {return '{'}
"}"        {return '}'}
";"        {return ';'}
^[a-z]\w*  {return 'IDENTIFIER';}
<<EOF>>    {return 'EOF'}
.          {return 'INVALID'}

/lex

%right '='
%left '+' '-'
%left '*' '/'

%start Program
%%

Program:
  /* nothing */       {return yy.Nodes.new([])}
| Expressions EOF     {return $1}
;



Expressions:
  Expression                        {$$ = yy.Nodes.new($1)}
| Expressions Terminator Expression {$$ = $1.push($3)}
| Expressions Terminator            {$$ = $1}
| Terminator                        {$$ = yy.Nodes.new([])}
;

Expression:
  GetVariable                       {$$ = $1}
| SetVariable                       {$$ = $1}
| Literal                           {$$ = $1}
| Call                              {$$ = $1}
| Operator                          {$$ = $1}
| If                                {$$ = $1}
| '(' Expression ')'                {$$ = $2}
;

Operator:
  Expression '+' Expression         {$$ = yy.CallNode.new($1, $2, [$3])}
| Expression '-' Expression         {$$ = yy.CallNode.new($1, $2, [$3])}
| Expression '*' Expression         {$$ = yy.CallNode.new($1, $2, [$3])}
| Expression '/' Expression         {$$ = yy.CallNode.new($1, $2, [$3])}
;

SetVariable:
  IDENTIFIER '=' Expression         {$$ = yy.SetVariableNode.new($1, $3)}
;

GetVariable:
  IDENTIFIER                        {$$ = yy.GetVariableNode.new($1)}
;

Literal:
  NUMBER                            {$$ = yy.NumberNode.new(Number($1))}
;

Block:
  '{' Expressions '}'               {$$ = $2}
;

Terminator:
  NEWLINE                           {$$ = $1}
| ';'                               {$$ = $1}
;

If:
  IF Expression Block               {$$ = yy.IfNode.new($2, $3)}
;

Call:
  IDENTIFIER Arguments              {$$ = yy.CallNode.new(null, $1, $2)}
;

Arguments:
  '(' ')'                           {$$ = []}
| '(' ArgList ')'                   {$$ = $2}
;

ArgList:
  Expression                       {$$ = [$1]}
| ArgList ',' Expression           {$$ = $1.push($3)}
;


