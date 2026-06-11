# TOML Standard Usage Hints

TOML (Tom's Obvious, Minimal Language) is designed to be easy to read and write.

## Basic Syntax

### Key/Value Pairs
```toml
key = "value"
bare_key = 123
"quoted key" = true
```

### Sections (Tables)
Sections are defined with brackets.
```toml
[section]
key = "value"

[section.sub]
another = "one"
```

### Arrays
```toml
list = [ 1, 2, 3 ]
mixed = [ "a", 1.5 ]
```

### Comments
Use the `#` character for comments.
```toml
# This is a comment
name = "Django" # End-of-line comment
```

### Common Data Types
- **Strings**: `"Hello"` (double quotes)
- **Integers**: `42`, `+99`, `-17`
- **Floats**: `3.1415`, `5e+22`
- **Booleans**: `true`, `false`
- **Dates/Times**: `1979-05-27T07:32:00Z`
