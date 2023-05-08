# mapping for simple cases with a 1:1 relation between text and token
class Regexp::Scanner
  MAPPING = {
    anchor: {
      '\A' => :bos,
      '\B' => :nonword_boundary,
      '\G' => :match_start,
      '\Z' => :eos_ob_eol,
      '\b' => :word_boundary,
      '\z' => :eos,
    },
    assertion: {
      '(?='  => :lookahead,
      '(?!'  => :nlookahead,
      '(?<=' => :lookbehind,
      '(?<!' => :nlookbehind,
    },
    conditional: {
      '(?' => :open,
    },
    escape: {
      '\.'   => :dot,
      '\|'   => :alternation,
      '\^'   => :bol,
      '\$'   => :eol,
      '\?'   => :zero_or_one,
      '\*'   => :zero_or_more,
      '\+'   => :one_or_more,
      '\('   => :group_open,
      '\)'   => :group_close,
      '\{'   => :interval_open,
      '\}'   => :interval_close,
      '\['   => :set_open,
      '\]'   => :set_close,
      '\\\\' => :backslash,
      '\a'   => :bell,
      '\b'   => :backspace,
      '\e'   => :escape,
      '\f'   => :form_feed,
      '\n'   => :newline,
      '\r'   => :carriage,
      '\t'   => :tab,
      '\v'   => :vertical_tab,
    },
    group: {
      '(?:' => :passive,
      '(?>' => :atomic,
      '(?~' => :absence,
    },
    meta: {
      '|' => :alternation,
      '.' => :dot,
    },
    quantifier: {
      '?'  => :zero_or_one,
      '??' => :zero_or_one_reluctant,
      '?+' => :zero_or_one_possessive,
      '*'  => :zero_or_more,
      '*?' => :zero_or_more_reluctant,
      '*+' => :zero_or_more_possessive,
      '+'  => :one_or_more,
      '+?' => :one_or_more_reluctant,
      '++' => :one_or_more_possessive,
    },
    set: {
      '['  => :character,
      '-'  => :range,
      '&&' => :intersection,
    },
    type: {
      '\d' => :digit,
      '\D' => :nondigit,
      '\h' => :hex,
      '\H' => :nonhex,
      '\s' => :space,
      '\S' => :nonspace,
      '\w' => :word,
      '\W' => :nonword,
      '\R' => :linebreak,
      '\X' => :xgrapheme,
    }
  }
  ANCHOR_MAPPING     = MAPPING[:anchor]
  ASSERTION_MAPPING  = MAPPING[:assertion]
  ESCAPE_MAPPING     = MAPPING[:escape]
  GROUP_MAPPING      = MAPPING[:group]
  QUANTIFIER_MAPPING = MAPPING[:quantifier]
  TYPE_MAPPING       = MAPPING[:type]
end
