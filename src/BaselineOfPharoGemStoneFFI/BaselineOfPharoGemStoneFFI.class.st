Class {
	#name : 'BaselineOfPharoGemStoneFFI',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoGemStoneFFI'
}

{ #category : 'baselines' }
BaselineOfPharoGemStoneFFI >> baseline: spec [

	<baseline>
	spec for: #pharo do: [ 
		spec
			package: 'GemStoneFFI';
			package: 'GemStoneFFI-Tests'
			with: [ spec requires: 'GemStoneFFI' ];
			yourself
	]
]
