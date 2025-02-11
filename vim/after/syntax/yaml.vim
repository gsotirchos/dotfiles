"syn match MembOperator "\." containedin=yamlFlowMappingKey display


hi! link yamlKeyValueDelimiter        OtherType
hi! link yamlFlowIndicator            Comment
hi! link yamlFlowCollection           MembOperator
hi! link yamlBlockCollectionItemStart MembOperator
hi! link yamlBlockMappingKey          Function
