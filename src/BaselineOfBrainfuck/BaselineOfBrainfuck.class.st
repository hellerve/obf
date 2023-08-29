Class {
	#name : #BaselineOfBrainfuck,
	#superclass : #BaselineOf,
	#category : #BaselineOfBrainfuck
}

{ #category : #baseline }
BaselineOfBrainfuck >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Brainfuck-Compiler'
		]
]
