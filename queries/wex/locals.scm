;; Definition and Reference scopes for Wex
(component_declaration
  name: (type_identifier) @local.definition.type) @local.scope

(page_declaration
  name: (type_identifier) @local.definition.type) @local.scope

(parameter
  name: (identifier) @local.definition.parameter)

(state_declaration
  name: (identifier) @local.definition.var)

(match_arm
  binding: (identifier) @local.definition.var) @local.scope

(for_statement
  item: (identifier) @local.definition.var) @local.scope

(arrow_function
  parameter: (identifier) @local.definition.parameter) @local.scope

(identifier) @local.reference
