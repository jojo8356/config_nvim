;; ====================================================================
;; Tree-sitter Highlights Query for Wex
;; Compatible with Neovim (>=0.9), Helix, Zed, Emacs 29+
;; ====================================================================

;; --- Keywords ---
"import" @keyword.import
"type" @keyword
"seo" @keyword
"tokens" @keyword
"page" @keyword
"component" @keyword
"fixture" @keyword
"table" @keyword
"repeat" @keyword
"actions" @keyword
"Event[]" @keyword
"events" @keyword
"state" @keyword
"view" @keyword
"style" @keyword

[
  "client"
  "server"
  "scoped"
  "uses"
] @keyword.modifier

[
  "if"
  "else"
  "match"
  "when"
] @keyword.conditional

[
  "for"
  "in"
  "key"
] @keyword.repeat

"return" @keyword.return

;; --- Option Constructors & Constants ---
[
  "Some"
  "None"
] @constructor

[
  "true"
  "false"
] @boolean

"null" @constant.builtin

;; --- Types ---
(type_identifier) @type
(type_field name: (identifier) @property)
(annotation_identifier) @attribute

;; --- View Elements & Tags ---
(view_element tag: (identifier) @tag)
(arrow_element tag: (identifier) @tag)

;; --- Attributes & Event Handlers ---
(attribute
  key: (identifier) @attribute)

(attribute
  key: (attribute_name) @attribute)

(attribute
  key: (identifier) @function.method
  (#match? @function.method "^on[A-Z]"))

;; --- Built-in Helpers & Functions ---
(call_expression
  function: (identifier) @function.call)

(member_expression
  property: (identifier) @property)

(token_call
  "token" @function.builtin
  token: (_) @string.special.symbol)

(tw_call
  "tw" @function.builtin)

;; --- Parameters & Variables ---
(parameter
  name: (identifier) @variable.parameter)

(state_declaration
  name: (identifier) @variable)

(arrow_function
  parameter: (identifier) @variable.parameter)

(match_arm
  binding: (identifier) @variable)

(for_statement
  item: (identifier) @variable)

;; --- SEO & Tokens ---
(seo_property
  key: (identifier) @property)

(token_property
  key: (token_key) @property)

;; --- CSS Rules ---
(css_declaration
  property: (identifier) @property)

(css_media_query
  "@media" @keyword.directive)

(color) @constant.other.color

;; --- Literals ---
(string) @string
(escape_sequence) @string.escape
(interpolation) @string.special

(number) @number
(comment) @comment

;; --- Delimiters & Operators ---
[
  "->"
  "=>"
] @operator.arrow

[
  "="
  "+="
  "-="
  "*="
  "/="
  "=="
  "!="
  "<"
  "<="
  ">"
  ">="
  "&&"
  "||"
  "!"
  "+"
  "-"
  "*"
  "/"
] @operator

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  ";"
  ":"
  "."
] @punctuation.delimiter
