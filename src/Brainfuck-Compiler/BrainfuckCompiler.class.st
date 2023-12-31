Class {
	#name : #BrainfuckCompiler,
	#superclass : #Object,
	#instVars : [
		'gen',
		'source',
		'index',
		'maxIdx',
		'optimizing',
		'compiles'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Brainfuck-Compiler'
}

{ #category : #accessing }
BrainfuckCompiler >> arraySize [
	^ 30000
]

{ #category : #accessing }
BrainfuckCompiler >> byteCodeMap [
	^ {
		$. -> #genPeriod:.
		$- -> #genMinus:.
		$+ -> #genPlus:.
		$> -> #genGt:.
		$< -> #genLt:.
		$[ -> #genBracket:.
		$_ -> #genZero:.
	} asDictionary
]

{ #category : #accessing }
BrainfuckCompiler >> compile: aString [
	| compiledMethod |
	gen := IRBuilder new.
	source := optimizing
			ifTrue: [ self optimizeInput: aString ]
			ifFalse: [ aString ].
	index := 1.

	self setupGenerator.
	self generate.
	self finalizeGenerator.
	
	compiledMethod := gen ir compiledMethod.
	
	compiles add: (aString -> compiledMethod).

	^ compiledMethod
]

{ #category : #accessing }
BrainfuckCompiler >> computeIndex [
	| depth idx |
	depth := 1.
	idx := index + 1.

	[ depth = 0 ]
		whileFalse: [ | char |
			char := source at: idx.

			char = $[ ifTrue: [ depth := depth + 1 ].

			char = $] ifTrue: [ depth := depth - 1 ].
			idx := idx + 1 ].

	^ idx - 1
]

{ #category : #accessing }
BrainfuckCompiler >> defaultText [
	^ '++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.'
]

{ #category : #accessing }
BrainfuckCompiler >> disableOptimizations [
	optimizing := false
]

{ #category : #accessing }
BrainfuckCompiler >> enableOptimizations [
	optimizing := true
]

{ #category : #accessing }
BrainfuckCompiler >> finalizeGenerator [
	gen
		pushTemp: #tape;
		returnTop
]

{ #category : #accessing }
BrainfuckCompiler >> genBracket: aNumber [
	| indexLabel backLabel oldIdx |
	indexLabel := index asString.
	backLabel := indexLabel, 'back'.
	gen
		jumpBackTarget: backLabel;
		pushTemp: #tape;
		pushTemp: #head;
		send: #at:;
		pushLiteral: 0;
		send: #=;
		jumpAheadTo: indexLabel if: true.

	oldIdx := maxIdx.
	maxIdx := self computeIndex.
	index := index + 1.
	self generate.
	maxIdx := oldIdx.

	gen jumpBackTo: backLabel.
	gen jumpAheadTarget: indexLabel
]

{ #category : #accessing }
BrainfuckCompiler >> genGt: aNumber [
	gen
		pushTemp: #head;
		pushLiteral: aNumber;
		send: #+;
		storeTemp: #head;
		popTop
]

{ #category : #accessing }
BrainfuckCompiler >> genLt: aNumber [
	gen
		pushTemp: #head;
		pushLiteral: aNumber;
		send: #-;
		storeTemp: #head;
		popTop
]

{ #category : #accessing }
BrainfuckCompiler >> genMinus: aNumber [
	gen
		pushTemp: #tape;
		pushTemp: #head;
		send: #byteAt:;
		storeTemp: #val;
		popTop;
		pushTemp: #tape;
		pushTemp: #head;
		pushTemp: #val;
		pushLiteral: aNumber;
		send: #-;
		pushLiteral: 255;
		send: #&;
		send: #byteAt:put:;
		popTop
]

{ #category : #accessing }
BrainfuckCompiler >> genPeriod: aNumber [
	aNumber
		timesRepeat: [ gen
				pushTemp: #tape;
				pushTemp: #head;
				send: #at:;
				storeTemp: #val;
				popTop;
				pushLiteralVariable: (self class environment associationAt: #Transcript);
				pushTemp: #val;
				send: #asCharacter;
				send: #show:;
				popTop ]
]

{ #category : #accessing }
BrainfuckCompiler >> genPlus: aNumber [
	gen
		pushTemp: #tape;
		pushTemp: #head;
		send: #byteAt:;
		storeTemp: #val;
		popTop;
		pushTemp: #tape;
		pushTemp: #head;
		pushTemp: #val;
		pushLiteral: aNumber;
		send: #+;
		pushLiteral: 255;
		send: #&;
		send: #byteAt:put:;
		popTop
]

{ #category : #accessing }
BrainfuckCompiler >> genZero: aNumber [
	aNumber
		timesRepeat: [ gen
				pushTemp: #tape;
				pushTemp: #head;
				pushLiteral: 0;
				send: #byteAt:put:;
				popTop ]
]

{ #category : #accessing }
BrainfuckCompiler >> generate [
	| size |
	size := source size.
	optimizing
		ifTrue: [ [ size >= index and: [ maxIdx isNil or: [ maxIdx > index ] ] ]
				whileTrue: [ | blockSize |
					blockSize := self getBlockSize.
					self generateChar: (source at: index) size: blockSize.
					index := index + blockSize ] ]
		ifFalse: [ [ size >= index and: [ maxIdx isNil or: [ maxIdx > index ] ] ]
				whileTrue: [ self generateChar: (source at: index) size: 1.
					index := index + 1 ] ]
]

{ #category : #accessing }
BrainfuckCompiler >> generateChar: aCharacter size: aNumber [
	| dispatch |
	dispatch := self byteCodeMap at: aCharacter ifAbsent: [ ^ self ].
	self perform: dispatch withArguments: {aNumber}
]

{ #category : #accessing }
BrainfuckCompiler >> getBlockSize [
	| currentChar idx size |
	currentChar := source at: index.
	idx := index + 1.
	size := source size.

	[ idx < size and: [ (source at: idx) = currentChar ] ]
		whileTrue: [ idx := idx + 1 ].

	^ idx - index
]

{ #category : #accessing }
BrainfuckCompiler >> gtActionOptimizeFor: anAction [
	<gtAction>
	^ anAction button
		priority: 1;
		icon: BrGlamorousVectorIcons performance;
		tooltip: 'Toggle Optimizations';
		action: [ optimizing
				ifTrue: [ self disableOptimizations ]
				ifFalse: [ self enableOptimizations ] ]
]

{ #category : #accessing }
BrainfuckCompiler >> gtCompileFor: aView [
	<gtView>
	^ aView textEditor
		title: 'Compile';
		priority: 1;
		text: [ self defaultText ];
		actionButtonIcon: BrGlamorousIcons inspect
			action: [ :aButton :aTab | 
				| aTabGroup anEditor |
				aTabGroup := aTab
						withAllParentsDetect: [ :aParent | aParent isKindOf: BrTabGroup ]
						ifFound: #yourself
						ifNone: [ nil ].
				anEditor := aTabGroup
						allChildrenBreadthFirstDetect: [ :anElement | anElement isKindOf: BrEditor ]
						ifFound: #yourself.
				aButton phlow spawnObject: (self compile: anEditor text asString) ];
		actionButtonIcon: BrGlamorousIcons play
			action: [ :aButton :aTab | 
				| aTabGroup anEditor |
				aTabGroup := aTab
						withAllParentsDetect: [ :aParent | aParent isKindOf: BrTabGroup ]
						ifFound: #yourself
						ifNone: [ nil ].
				anEditor := aTabGroup
						allChildrenBreadthFirstDetect: [ :anElement | anElement isKindOf: BrEditor ]
						ifFound: #yourself.
				aButton phlow
					spawnObject: ((self compile: anEditor text asString) valueWithReceiver: self arguments: #()) ];
		aptitude: [ BrGlamorousCodeEditorAptitude ]
]

{ #category : #accessing }
BrainfuckCompiler >> gtCompilesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Historical Compiles';
		priority: 2;
		items: [ compiles ];
		column: 'Input' text: #key;
		column: 'Result' text: #value;
		column: 'Run'
			stencil: [ :aCompile | 
				BrButton new
					aptitude: BrGlamorousButtonWithIconAptitude;
					icon: BrGlamorousVectorIcons play;
					action: [ :aButton | 
						aButton phlow
							spawnObject: (aCompile value valueWithReceiver: self arguments: #()) ] ];
		send: #value
]

{ #category : #accessing }
BrainfuckCompiler >> initialize [
	optimizing := false.
	compiles := OrderedCollection new
]

{ #category : #accessing }
BrainfuckCompiler >> optimizations [
	^ {
		'[+]' -> '_'.
		'[-]' -> '_'.
	} asDictionary
]

{ #category : #accessing }
BrainfuckCompiler >> optimizeInput: aString [
	|res|
	res := aString.
	
	self optimizations keysAndValuesDo: [:aKey :aValue |
		res := res copyReplaceAll: aKey with: aValue
	].
	
	^ res
]

{ #category : #accessing }
BrainfuckCompiler >> setupGenerator [
	gen
		addTemp: #tape;
		addTemp: #head;
		addTemp: #val;
		pushLiteralVariable: ByteArray binding;
		pushLiteral: self arraySize;
		pushLiteral: 0;
		send: #new:withAll:;
		storeTemp: #tape;
		popTop;
		pushLiteral: 1;
		storeTemp: #head;
		popTop
]
