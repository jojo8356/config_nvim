;; Language injection: inject CSS parser inside style blocks
(style_block
  (css_rule) @injection.content
  (#set! injection.language "css"))
