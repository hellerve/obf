# obf

An optimzing compiler for Brainfuck in Pharo. Compiles to Pharo VM bytecode.
## Usage

```
"a regular compile"
BrainfuckCompiler new compile: '++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.'.

"or enable optimizations"
BrainfuckCompiler new enableOptimizations compile: '++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.'.

```
## Installation```Metacello new	repository: 'github://hellerve/obf:main/src';	baseline: 'Brainfuck';	load```
<hr/>

Have fun!