# obf

An optimizing compiler for Brainfuck in Pharo. Compiles to Pharo VM bytecode.
## Usage
You can generate compiled code like this:
```smalltalk
"a regular compile"
BrainfuckCompiler new compile: '++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.'.

"or enable optimizations"
BrainfuckCompiler new enableOptimizations compile: '++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.'.

```

The resulting code can be executed using `valueWithReceiver: arguments:`. It doesn’t take any
arguments and the receiver does not matter, so I usually use `self valueWithReceiver: 1 arguments: #()`.
## Installation```smalltalkMetacello new	repository: 'github://hellerve/obf:main/src';	baseline: 'Brainfuck';	load```
<hr/>

Have fun!