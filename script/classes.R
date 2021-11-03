
#OnlineResource class definition
setClass(
  "OnlineResource",
  slots = list(
    urlDownload = "character",
    urlInfo = "character",
    doi = "character",
    webservices = "list"
  )
)

#Producer class definition
setClass(
  "Producer",
  slots = list(
    producerId = "character",
    name = "character",
    title = "character",
    description = "character",
    objectives = "character",
    measuredVariables = "character",
    fundings = "list",
    email = "character",
    contacts = "list",
    onlineResource = "OnlineResource"
  )
)

#Pivot class definition
setClass(Class = "Pivot",
         slots= list(
           datasets="list",
           producer="Producer",
           version="character"
         ))

#Organisation class definition
setClass(
  "Organisation",
  slots = list(
    role = "character",
    name = "character",
    acronym = "character",
    idScanR = "character",
    iso3166 = "character"
  )
)

#Funding class definition
setClass(
  "Funding",
  slots = list(
    type = "character",
    name = "character",
    acronym = "character",
    idScanR = "character",
    iso3166 = "character"
  )
)
setClassUnion("OrganisationOrNull",c("Organisation","NULL"))

#Contact class definition
setClass(
  "Contact",
  slots = list(
    firstName = "character",
    lastName = "character",
    email = "character",
    role = "character",
    orcId = "character",
    organisation = "OrganisationOrNull"
  )
)

#Licence class definition
setClass("Licence", slots = list(title = "character",
                                 url = "character"))

setClassUnion("LicenceOrNull",c("Licence","NULL"))

#DataConstraint class definition
setClass(
  "DataConstraint",
  slots = list(
    accessUseConstraint = "character",
    urlDataPolicy = "character",
    licence = "LicenceOrNull"
  )
)

#Keyword class definition
setClass("Keyword", slots = list(keyword = "character",
                                 uri = "character"))

#Document class definition
setClass("Document", slots = list(type = "character",
                                  url = "character"))

#Webservice class definition
setClass("Webservice",
         slots = list(description = "character",
                      url = "character"))

#Metadata class definition
setClass(
  "Metadata",
  slots = list(
    title = "character",
    description = "character",
    objective = "character",
    datasetLineage = "character",
    contacts = "list",
    topicCategories = "list",
    inspireTheme = "character",
    keywords = "list",
    documents = "list",
    onlineResource = "OnlineResource",
    dataConstraint = "DataConstraint",
    spatialExtent = "list"
  )
)

#Dataset class definition
setClass(
  "Dataset",
  slots = list(
    datasetId = "character",
    metadata = "Metadata",
    observations = "list"
  )
)

#ObservedProperty class definition
setClass(
  "ObservedProperty",
  slots = list(
    name = "character",
    unit = "character",
    description = "character",
    theiaCategories = "list"
  )
)

#FeatureOfInterest class definition
setClass(
  "FeatureOfInterest",
  slots = list(
    samplingFeature = "list"
  )
)

#Temporal extent class definition
setClass(
  "TemporalExtent",
  slots = list(
    dateBeg = "character",
    dateEnd = "character"
  )
)


#Sensor class definition
setClass(
  "Sensor",
  slots = list(
    model = "character",
    manufacturer = "character",
    serialNumber = "character",
    sensorType = "character",
    documents = "list",
    calibration = "character",
    activityPeriods = "list",
    name = "character",
    parametrisationDescription = "character"
  )
)

#DataProduction class definition
setClass(
  "DataProduction",
  slots = list(
    method = "character",
    sensors = "list"
  )
)

setClassUnion("DataProductionOrNull", c("DataProduction","NULL"))

#LineageInformation class definition
setClass(
  "LineageInformation",
  slots = list(
    processingDescription = "character",
    processingDate = "character"
  )
)

#Procedure class definition
setClass(
  "Procedure",
  slots = list(
    lineageInformations = "list",
    dataProduction = "DataProductionOrNull"
  )
)

setClassUnion("ProcedureOrNull", c("Procedure","NULL"))

#AdditionalValue class definition
setClass(
  "AdditionalValue",
  slots = list(
    name = "character",
    columnName = "character",
    unit = "character",
    description = "character"
  )
)

#QualityFlag class definition
setClass(
  "QualityFlag",
  slots = list(
    code = "character",
    description = "character"
  )
)

#DataFile class definition
setClass(
  "DataFile",
  slots = list(
    name = "character"
  )
)

#Result class definition
setClass(
  "Result",
  slots = list(
    dataFile = "DataFile",
    missingValue = "character",
    qualityFlags = "list",
    additionalValues = "list"
  )
)

#Observation class definition
setClass(
  "Observation",
  slots = list(
    observationId = "character",
    processingLevel = "character",
    dataType = "character",
    temporalExtent = "TemporalExtent",
    timeSerie = "logical",
    observedProperty = "ObservedProperty",
    featureOfInterest = "FeatureOfInterest",
    procedure = "ProcedureOrNull",
    result="Result"
  )
)