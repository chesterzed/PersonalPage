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


## Загрузка проектов

### 1. Для Unity-проектов:
Вам не нужна папка build как таковая, вам нужна сборка под WebGL.

* В Unity откройте File -> Build Settings.
* Выберите платформу WebGL (если ее нет, её нужно доустановить через Unity Hub).
* Нажмите Build.
* Unity создаст папку. Внутри будет index.html, папка Build (с файлами .wasm и .data) и папка TemplateData.
* Вы архивируете всё содержимое этой папки в .zip и загружаете в админку.


### 2. Для C-проектов (Консольные приложения):

Обычный компилятор (GCC или MinGW), который делает .exe, нам не подойдет. Нужен специальный компилятор Emscripten, 
который переводит код на C/C++ в формат WebAssembly (который понимают браузеры).

* Установите Emscripten (Emsdk) (https://emscripten.org/docs/getting_started/downloads.html).
* Скомпилируйте ваш файл main.c командой:

   1   emcc main.c -o index.html

* Emscripten сгенерирует 3 файла: index.html, index.js, index.wasm.
* Вы архивируете эти 3 файла в .zip и загружаете в админку.
* Когда пользователь откроет проект, он увидит черное окно прямо на сайте, которое будет вести себя в точности как терминал, но работать это будет силами движка V8 в его браузере.