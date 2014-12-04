class window.InternalizationAgentParent extends Thing
	className: "InternalizationAgentParent"
	lsProperties:
		defaultLabels: [
			key: 'internalization agent name'
			type: 'name'
			kind: 'internalization agent name'
			preferred: true
#			labelText: "" #gets created when createDefaultLabels is called
		]
		defaultValues: [
			key: 'internalization agent type'
			stateType: "parent attributes"
			stateKind: 'internalization agent parent attributes'
			type: 'codeValue' #used to set the lsValue subclass of the object
			kind: 'internalization agent type'
#			value: "" #will be set by the user
		,
			key: 'conjugation type'
			stateType: 'parent attributes'
			stateKind: 'internalization agent parent attributes'
			type: 'codeValue'
			kind: 'conjugation type'
		,
			key: 'conjugation site'
			stateType: 'parent attributes'
			stateKind: 'internalization agent parent attributes'
			type: 'codeValue'
			kind: 'conjugation site'
		,
			key: 'protein aa sequence'
			stateType: 'parent attributes'
			stateKind: 'internalization agent parent attributes'
			type: 'stringValue'
			kind: 'protein aa sequence'
		,
			key: 'scientist'
			stateType: 'parent attributes'
			stateKind: 'internalization agent parent attributes'
			type: 'codeValue'
			kind: 'scientist'
		,
			key: 'notebook'
			stateType: 'parent attributes'
			stateKind: 'internalization agent parent attributes'
			type: 'stringValue'
			kind: 'notebook'
		,
			key: 'completion date'
			stateType: 'parent attributes'
			stateKind: 'internalization agent parent attributes'
			type: 'dateValue'
			kind: 'completion date'
		]
