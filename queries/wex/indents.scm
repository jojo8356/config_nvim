;; Indentation queries for Wex
[
  (type_record)
  (seo_declaration)
  (tokens_declaration)
  (page_declaration)
  (component_declaration)
  (actions_declaration)
  (events_declaration)
  (view_block)
  (style_block)
  (view_children_block)
  (inline_style_block)
  (match_statement)
  (array_literal)
  (object_literal)
  (arrow_element)
] @indent.begin

[
  "}"
  "]"
  ")"
] @indent.branch @indent.end
