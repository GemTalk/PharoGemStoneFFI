Class {
	#name : 'BaselineOfSparkleFFI',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfSparkle'
}

{ #category : 'baselines' }
BaselineOfSparkle >> baseline: spec [

	<baseline>
	spec for: #pharo do: [ 
		spec
			package: 'GemStoneFFI';
			package: 'GemStoneFFI-Tests'
			with: [ spec requires: 'GemStoneFFI' ];
			yourself
	]
]
