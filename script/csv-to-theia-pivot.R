##################################
# CSV to theia pivot JSON workflow
##################################
library("stringr")
library("RJSONIO")
library("wellknown")

# 1 - Import all csv files into data.frames
##################################

csvFileNames <- list.files(path = "../csv")

for (fileName in csvFileNames) {
  assign(
    sub('\\.csv$', '', fileName),
    read.csv(
      paste("../csv", fileName, sep = "/"),
      stringsAsFactors = FALSE,
      sep = ",",
      na.strings = c("NA", "")
    )
  )
}
rm(fileName, csvFileNames)

# 2 - Class declaration
#################################

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

# 3 - Declare useful functions for the rest of the workflow
##################################

#' The function load an underscore (_) line feed (LF = \n) separated string and return
#' a vector of character. Each element of the character vector corresponds to
#' the character separated underscore LF in the string initially loaded.
#'
#' @param underscore_LF_separated_string Underscore line feed (LF) separated string
#' @return A vector of character
#' @export
#' @examples
#'  underscore_LF_separated_string_to_vector("email:charly.coussot@univ-grenoble-alpes.fr_\norcid:1111-0002-5870-5762")
underscore_LF_separated_string_to_vector <-
  function(underscore_LF_separated_string) {
    stringVector <-
      unlist(strsplit(underscore_LF_separated_string, "\\_\n"))
    for (i in (1:length(stringVector))) {
      stringVector[i] <- gsub('\\_$', '', stringVector[i])
    }
    return(stringVector)
  }

#' The function load an identifier and a data frame that represents organisations.
#' If the identifier match an organisation$Identifier from the data frame, an
#' Organisation class is instantiated with the corresponding information from
#' the organisation data frame and is returned. Otherwise the function return NULL.
#' The identifer should contain the role of the organisation.
#'
#' @param identifier identifier containing the role of the organisation - ex: researchGroup:201722374A
#' @param organisationDataFrame the organisation dataframe
#' @return A S4 Organisation object
#' @export
setOrganisationUsingIdentifier <-
  function(identifier, organisationDataFrame) {
    index <-
      match(TRUE, str_detect(
        organisationDataFrame$Identifier,
        gsub("^(.*?)\\:", "", identifier)
      ))
    if (!is.na(index)) {
      roleCSV <- gsub("\\:(.*)", "", identifier)
      role <- switch (
        roleCSV,
        "ResearchGroup" = "Research group"
      )
      return(
        new(
          "Organisation",
          name = organisationDataFrame$Name[index],
          acronym = organisationDataFrame$Acronym[index],
          idScanR = organisationDataFrame$IdScanR[index],
          iso3166 = organisationDataFrame$Iso3166[index],
          role = role
        )
      )
    } else {
      return(NULL)
    }
  }

#' The function load an identifier and a data frame that represents funding
#' If the identifier match an organisation$Identifier from the data frame, an
#' Funding class is instantiated with the corresponding information from
#' the funding data frame and is returned. Otherwise the function return NULL.
#' The identifer should contain the role of the organisation.
#'
#' @param identifier identifier containing the role of the funding - ex: ResearchUnit:201722374A
#' @param organisationDataFrame the organisation dataframe
#' @return A S4 Organisation object
#' @export
setFundingUsingIdentifier <-
  function(identifier, organisationDataFrame) {
    index <-
      match(TRUE, str_detect(
        organisationDataFrame$Identifier,
        gsub("^(.*?)\\:", "", identifier)
      ))
    if (!is.na(index)) {
      roleCSV <- gsub("\\:(.*)", "", identifier)
      role <- switch (
        roleCSV,
        "FrenchResearchInstitutes" = "French research institutes",
        "FederativeStructure" = "Federative structure",
        "ResearchUnit" = "Research unit",
        "Other" = "Other",
        "OtherUniversitiesAndSchools" = "Other universities and schools",
        "ResearchProgram" = "Research program",
        "FrenchUniversitiesAndSchools" = "French universities and schools",
        "OtherResearchInstitutes" = "Other research institutes"
      )
      return(
        new(
          "Funding",
          name = organisationDataFrame$Name[index],
          acronym = organisationDataFrame$Acronym[index],
          idScanR = organisationDataFrame$IdScanR[index],
          iso3166 = organisationDataFrame$Iso3166[index],
          type = role
        )
      )
    } else {
      return(NULL)
    }
  }

#' The function load an identifier and a data frame that represents contacts
#' If the identifier match an contacts$Identifier from the data frame, an
#' Contact class is instantiated with the corresponding information from
#' the contact data frame and is returned. Otherwise the function return NULL.
#' The identifer should contain the role of the contact.
#'
#' @param identifier identifier containing the role of the contact - ex: publisher:veronique.chaffard@ird.fr
#' @param contactDataFrame the contact dataframe
#' @param organisationDataFrame the organisation dataframe
#' @return A S4 Contact object
#' @export
setContactUsingIdentifier <-
  function(identifier,
           contactDataFrame,
           organisationDataFrame) {
    index <-
      match(TRUE, str_detect(
        contactDataFrame$Identifier,
        gsub("^(.*?)\\:", "", identifier)
      ))
    if (!is.na(index)) {
      roleCSV <- gsub("\\:(.*)", "", identifier)
      role <- switch (
        roleCSV,
        "projectLeader" = "Project leader",
        "principalInvestigator" = "Principal investigator",
        "dataManager" = "Data manager",
        "publisher" = "Data manager",
        "dataManager" = "Data manager",
        "dataCollector" = "Data collector"
      )
      return(
        new(
          "Contact",
          firstName = contactDataFrame$FirstName[index],
          lastName = contactDataFrame$LastName[index],
          email = contactDataFrame$Email[index],
          role = role,
          orcId = contactDataFrame$ORCID[index],
          organisation = setOrganisationUsingIdentifier(
            contactDataFrame$OrganisationIdentifier[index],
            organisationDataFrame
          )
        )
      )
    }
  }

#' The function load a String composed of two element separated with the @
#' character. The first element corresponds to the keyword prefLabel, the second
#' element corresponds to the uri of the keywords if it exists
#'
#' @param atSeparatedString a String composed of two element separated with the @
#' character
#' @return A S4 Keyword object
#' @export
setKeywordUsingAtSeparatedString <- function(atSeparatedString) {
  if (str_detect(atSeparatedString, "@")) {
    return(new(
      "Keyword",
      keyword = gsub("\\@(.*)", "", atSeparatedString),
      uri = gsub("^(.*?)\\@", "", atSeparatedString)
    ))
  } else {
    return(new("Keyword",
               keyword = atSeparatedString,
               uri = as.character(NA)))
  }
}


#' The function load a String composed of two element separated with the /
#' character. The first element corresponds to the begin date, the second
#' element corresponds to the end date
#'
#' @param slashSeparatedString a String composed of two element separated with the /
#' character
#' @return A S4 TemporalExtent object
#' @export
setTemporalExtentUsingSlashSeparatedString <- function(slashSeparatedString) {
  
  if(is.na(str_detect(slashSeparatedString,"\\/"))){
    return(NULL)
  } else {
    return(new("TemporalExtent",
               dateBeg=str_match(slashSeparatedString,"(.*?)\\/")[,2],
               dateEnd=str_match(slashSeparatedString,"\\/(.*)")[,2]))
  }
}

#' The function load a String indentifier and a dataframe containing different
#' observed properties. The dataframe has an Identifier column that must contains
#' the string identifier. The function returns the corresponding S4 ObservedProperty
#' object
#'
#' @param identifier observedProperty identifier
#' #' @param observedPropertyDataFrame observedProperties dataframe
#' @return A S4 ObservedProperty object
#' @export
setObservedPropertyUsingIdentifier <- function(identifier, observedPropertyDataFrame) {
  index <-
    match(TRUE, str_detect(
      observedPropertyDataFrame$Identifier,
      identifier)
    )
  return(new("ObservedProperty",
             name = observedPropertyDataFrame$Name[index],
             unit = observedPropertyDataFrame$Unit[index],
             description = observedPropertyDataFrame$Description[index],
             theiaCategories = as.list(underscore_LF_separated_string_to_vector(
               observedPropertyDataFrame$TheiaCategories[index]
             ))
  ))
}

#' The function load a String identifier and a dataframe containing different
#' sampling features. The dataframe has an Identifier column that must contains
#' the string identifier. The function returns the corresponding S4 FeatureOfInterest
#' object
#'
#' @param identifier samplingFeature identifier
#' #' @param samplingFeatureDataFrame samplingFeature dataframe
#' @return A S4 FeatureOfInterest object
#' @export
setFeatureOfInterestUsingIdentifier <- function(identifier, samplingFeatureDataFrame) {
  index <-
    match(TRUE, str_detect(
      samplingFeatureDataFrame$Identifier,
      identifier)
    )
  if (gsub("\\:(.*)", "", samplingFeatureDataFrame$Geometry[index]) == "wkt") {
    return(
      new("FeatureOfInterest",
          samplingFeature = fromJSON(
            gsub("^\\{", paste("{\n \"properties\": {},\n \"name\": \"",paste(samplingFeatureDataFrame$Name[index],"\",")), toJSON(wkt2geojson(
              gsub("Z \\(", "Z\\(", gsub("^(.*?)\\:", "", samplingFeatureDataFrame$Geometry[index])))
            )))))
  }
  
}

#' The function load a String composed of two elements, the first
#' element is between brackets [ ] and is followed by the second element after the 
#' closing bracket. The first element corresponds to the processing date, the second
#' element processing description
#'
#' @param bracketSeparatedString a String composed of two elements, the first
#' element is between brackets [ ]
#' @return A S4 LineageInformation object
#' @export
setLineageInformationUsingBracketSeparatedString <- function(bracketSeparatedString) {
  
  return(new("LineageInformation",
             processingDate=str_match(bracketSeparatedString,"^\\[(.*?)\\]")[,2],
             processingDescription=gsub("^\\[(.*?)\\]","",bracketSeparatedString)))
}

#' The function load a String composed of two elements, the first
#' element is the sensor identifier. The second element is between bracket and 
#' is optional and corresponds to all the activity periods of the sensor separated with a comma.
#' ex:ThalimedesOTT[2016-06-19T10:14:00Z/2017-10-15T12:59:00Z,2017-10-16T12:59:00Z/2018-10-15T12:59:00Z]
#' The second parameter of the function is the sensor dataframe containing a Identifier
#' list that must container the identifier parameter of the fucntion.
#' 
#' The method return a S4 sensor object
#' 
#' @param identifier String composed of two elements, the first
#' element is the sensor identifier. The second element is between bracket and 
#' is optional and corresponds to all the activity periods of the sensor separated with a comma.
#' element is between brackets [ ]
#' @param sensorDataFrame the sensor data frame
#' @return A S4 LineageInformation object
#' @export
setSensorUsingIdentifier <- function(identifier, sensorDataFrame) {
  index <-
    match(TRUE, str_detect(
      sensorDataFrame$Identifier,
      gsub("\\[(.*?)\\]","",identifier))
    )
  activityPeriods = str_match(identifier,pattern = "\\[(.*?)\\]")[,2]
  documents = underscore_LF_separated_string_to_vector(sensorDataFrame$Documents[index])
  if (!is.na(sensorDataFrame$SensorType[index])){
    return(new("Sensor",
               model=sensorDataFrame$Model[index],
               manufacturer=sensorDataFrame$Manufacturer[index],
               serialNumber=sensorDataFrame$SerialNumber[index],
               sensorType=sensorDataFrame$SensorType[index],
               calibration=sensorDataFrame$Calibration[index],
               documents = lapply(as.list(underscore_LF_separated_string_to_vector(sensorDataFrame$Documents[index])),setDocumentsUsingAtSeperatedString),
               activityPeriods = lapply(as.list(strsplit(activityPeriods,"\\,")[[1]]),setTemporalExtentUsingSlashSeparatedString),
               name=as.character(NA),
               parametrisationDescription=as.character(NA)
    ))
    
  } else if(!is.na(sensorDataFrame$ModelName[index])){
    return(new("Sensor",
               name=sensorDataFrame$ModelName[index],
               parametrisationDescription=sensorDataFrame$ModelParametrisationDescription[index],
               documents = lapply(as.list(underscore_LF_separated_string_to_vector(sensorDataFrame$Documents[index])),setDocumentsUsingAtSeperatedString),
               model=as.character(NA),
               manufacturer=as.character(NA),
               serialNumber=as.character(NA),
               sensorType=as.character(NA),
               calibration=as.character(NA)
    ))
  }
}

#' The function load a String composed of two elements separated with a at character (@).
#' The first element is the document type and second is the document url
#' ex: publication:http://publication.address
#' @param AtSeparatedString String composed of two elements separated with a colon character
#' @return A S4 Document object
#' @export
setDocumentsUsingAtSeperatedString <-  function(AtSeparatedString) {
  return(new("Document",
             type=gsub("\\@(.*)","",AtSeparatedString),
             url=gsub("^(.*?)\\@","",AtSeparatedString))
  )
}


#' The function load a String indentifier and a dataframe containing different
#' additional values. The dataframe has an Identifier column that must contains
#' the string identifier. The function returns the corresponding S4 AdditionalValues
#' object
#'
#' @param identifier additional value identifier
#' #' @param additionalValuesDataFrame additional values dataframe
#' @return A S4 AdditionalValue object
#' @export
setAdditionalValueUsingIdentifier <- function(identifier, additionalValuesDataFrame) {
  index <-
    match(TRUE, str_detect(
      additionalValuesDataFrame$Identifier,
      identifier)
    )
  return(new("AdditionalValue",
             name=as.character(additionalValuesDataFrame$Name[index]),
             columnName=as.character(additionalValuesDataFrame$NameInDatafile[index]),
             unit=as.character(additionalValuesDataFrame$Unit[index]),
             description=as.character(additionalValuesDataFrame$Description[index])
  ))
}

#' The function load a String composed of two elements, the first
#' element and the second element that is between brackets [ ].
#' The first element corresponds to the qualityFlag code, the second
#' element is the qualityFlag description
#'
#' @param bracketSeparatedString String composed of two elements, the first
#' element and the second element that is between brackets [ ].
#' @return A S4 QualityFlag object
#' @export
setQualityFlagsUsingBracketSeparatedString <- function(bracketSeparatedString) {
  return(new("QualityFlag",
             description=str_match(bracketSeparatedString,"\\[(.*?)\\]")[,2],
             code=gsub("\\[(.*?)\\]","",bracketSeparatedString)))
}

#' The function load a list of String representing online resources.
#' Each element of the list is built such as:
#' http:typeOfOnlieResouce@URLOfTheOnlineResource
#' The different types of online resource are, info, download, doi, and webservice
#' For webservice type, a description of the webservice is mandatory. Hence, the 
#' webservices elements are built such as:
#' http:webservice[description]@URLOfTheWebservice
#' @param urlList list online resource string
#' @return A S4 OnlineResource object
#' @export
setOnlineResourceUsingURLList <- function(urlList) {
  onlineResourceObject <- new("OnlineResource")
  webservicecount <- 1
  webserviceCSVList <- vector(mode = "list",
                              length = sum(str_count(urlList,"webservice")))
  
  for (i in (1:length(urlList))) {
    ### get charactère string between http: and @  = type of onlineresource
    urlType <- str_match(urlList[i], "^http\\:(.*?)\\@")[,2]
    ### switch on the type of online resource
    switch(
      urlType,
      #-------------------------------
      # simple + unique string pattern
      #-------------------------------
      "info" = {
        onlineResourceObject@urlInfo <- gsub("(.*?)\\@", "", urlList[i])
      },
      "download" = {
        onlineResourceObject@urlDownload <- gsub("(.*?)\\@", "", urlList[i])
      },
      "doi" = {
        onlineResourceObject@doi <- gsub("(.*?)\\@(http|https)\\:\\/\\/dx\\.doi\\.org\\/", "", urlList[i])
      },
      # default case for webservices
      {
        if(gsub("\\[(.*?)]", "", urlType) == "webservice"){
          webserviceCSVList[[webservicecount]] <- 
            new(
              "Webservice",
              description = str_match(urlType, "\\[(.*?)\\]")[,2],
              url = gsub("^(.*?)\\@", "", urlList[i])
            )
          webservicecount <-  webservicecount + 1
        }
      }
    )
  }
  onlineResourceObject@webservices <- webserviceCSVList
  return(onlineResourceObject)
}



# 4 - Extract producer metadata
##################################

### get producer contact identifiers
CSVproducerContactIdentfier <-
  underscore_LF_separated_string_to_vector(producer$Contacts)
### get producer funding identifiers
CSVproducerFunderIdentifier <-
  underscore_LF_separated_string_to_vector(producer$Funders)


### for each contact identifier from the producer csv the corresponding contact
### information are loaded from the contacts csv and stored in Contact S4 object
contactList <-
  vector(mode = "list",
         length = length(CSVproducerContactIdentfier))
for (i in (1:length(CSVproducerContactIdentfier))) {
  contactList[[i]] <-
    setContactUsingIdentifier(CSVproducerContactIdentfier[i], contacts, organisations)
}

fundingList <-
  vector(mode = "list",
         length = length(CSVproducerFunderIdentifier))
for (i in (1:length(CSVproducerFunderIdentifier))) {
  fundingList[[i]] <-
    setFundingUsingIdentifier(CSVproducerFunderIdentifier[i], organisations)
}


###Store the producer metadata in the Pivot object
pivotObject <- new("Pivot",
                   version="1.0",
                   producer= new(
                     "Producer",
                     producerId = producer$Identifier,
                     name = producer$Name,
                     title = producer$Title,
                     description = producer$Description,
                     objectives = as.character(producer$Objective),
                     measuredVariables = as.character(producer$MeasuredVariable),
                     email = as.character(producer$Email),
                     fundings = fundingList,
                     contacts = contactList,
                     onlineResource = setOnlineResourceUsingURLList(underscore_LF_separated_string_to_vector(producer$OnlineResource))
                   ))
rm(
  contactList,
  fundingList,
  CSVproducerContactIdentfier,
  CSVproducerFunderIdentifier
)


# 5 - Extract datasets metadata
##################################

### Declare the list of Dataset
datasetList <- vector(mode="list",length = nrow(datasets))

###Loop over each row of the datasets data.frame
for (indexDat in 1:nrow(datasets)) {
  # cut all underscore LF separated values
  CSVdatasetContactIdentfier <-
    underscore_LF_separated_string_to_vector(datasets$Creator[indexDat])
  CSVdatasetDescription <-
    underscore_LF_separated_string_to_vector(datasets$Description[indexDat])
  CSVdatasetKeywords <-
    underscore_LF_separated_string_to_vector(datasets$Subject[indexDat])
  CSVdatasetSpatialCoverage <-
    underscore_LF_separated_string_to_vector(datasets$SpatialCoverage[indexDat])
  CSVdatasetUrls <-
    underscore_LF_separated_string_to_vector(datasets$Relation[indexDat])
  CSVdatasetRights <-
    underscore_LF_separated_string_to_vector(datasets$Rights[indexDat])
  CSVdatasetProvenance <-
    underscore_LF_separated_string_to_vector(datasets$Provenance[indexDat])
  
  ### instanciate Metadata class and Dataset class
  datasetObject <-  new('Dataset',
                        datasetId=datasets$Identifier[indexDat])
  metadataObject <- new("Metadata")
  
  # a - dataset contacts
  ### for each contact identifier from the producer csv the corresponding contact
  ### information are loaded from the contacts csv and stored in Contact S4 object
  contactList <-
    vector(mode = "list",
           length = length(CSVdatasetContactIdentfier))
  for (i in (1:length(CSVdatasetContactIdentfier))) {
    contactList[[i]] <-
      setContactUsingIdentifier(CSVdatasetContactIdentfier[i], contacts, organisations)
  }
  metadataObject@contacts <- contactList
  rm(i, contactList, CSVdatasetContactIdentfier)
  
  # b - dataset descriptions and title
  ### extract different metadata elements using the datasets$Description value
  for (i in (1:length(CSVdatasetDescription))) {
    switch(
      gsub("\\:(.*)", "", CSVdatasetDescription[i]),
      "abstract" = {
        metadataObject@description <- 
          gsub("^(.*?)\\:", "", CSVdatasetDescription[i])
      },
      "purpose" = {
        metadataObject@objective <- 
          gsub("^(.*?)\\:", "", CSVdatasetDescription[i])
      }
    )
  }
  metadataObject@title <- datasets$Title[indexDat]
  rm(i, CSVdatasetDescription)
  
  # c - dataset keywords
  ### extract different metadata keywords using the datasets$Subject value
  keywordCSVList <- vector(mode = "list")
  for (i in (1:length(CSVdatasetKeywords))) {
    switch(
      gsub("\\:(.*)", "", CSVdatasetKeywords[i]),
      "topicCategories" = {
        metadataObject@topicCategories <- as.list(strsplit(
          gsub("^(.*?)\\:", "", CSVdatasetKeywords[i]), "\\,"
        )[[1]])
      },
      "inspireTheme" = {
        metadataObject@inspireTheme <- gsub("^(.*?)\\:", "", CSVdatasetKeywords[i])
      },
      { 
        if(!is.na(CSVdatasetKeywords[i])){
          keywordCSVList <-
            c(keywordCSVList, strsplit(
              gsub("^(.*?)\\:", "", CSVdatasetKeywords[i]), "\\,"
            )[[1]])
        }
      }
    )
  }
  # remove NA values from the list of keywords
  metadataObject@keywords <-
    lapply(keywordCSVList, setKeywordUsingAtSeparatedString)
  
  rm(i, keywordCSVList, CSVdatasetKeywords)
  
  # d - dataset spatial coverage
  ### extract dataset coverage in geojson using the datasets$SpatialCoverage
  ### WKT value
  for (i in (1:length(CSVdatasetSpatialCoverage))) {
    if (gsub("\\:(.*)", "", CSVdatasetSpatialCoverage[i]) == "wkt") {
      metadataObject@spatialExtent <- fromJSON(
        gsub("^\\{", "{\n \"properties\": {},", toJSON(wkt2geojson(
          gsub("^(.*?)\\:", "", CSVdatasetSpatialCoverage[i])
        ))))
    }
  }
  rm(i, CSVdatasetSpatialCoverage)
  
  # e - dataset url metadata element
  ### extract the dataset url metadata element that are stored in datasets$Relation
  ### http:info = OnlineResource.urlInfo
  ### http:download = OnlineResource.urlDownload
  ### http:doi = OnlineResource.doi
  ### http:webservice[] = OnlineResource.webservices.*
  ### http:publication = documents.*
  ### http:manual = documents.*
  ### http:licence[] = DataConstraint.Licence
  ### http:dataPolicy = DataConstraint.urlDataPolicy
  
  onlineResourceObject <- new("OnlineResource")
  dataConstraintObject <- new("DataConstraint")
  documentCount <- 1
  webservicecount <- 1
  documentCSVList <- vector(mode = "list", 
                            length = sum(str_count(CSVdatasetUrls,"publication|manual")) )
  webserviceCSVList <- vector(mode = "list",
                              length = sum(str_count(CSVdatasetUrls,"webservice")))
  
  for (i in (1:length(CSVdatasetUrls))) {
    
    urlType <- str_match(CSVdatasetUrls[i], "^http\\:(.*?)\\@")[,2]
    switch(
      urlType,
      #-------------------------------
      # simple + unique string pattern
      #-------------------------------
      "info" = {
        onlineResourceObject@urlInfo <- gsub("(.*?)\\@", "", CSVdatasetUrls[i])
      },
      "download" = {
        onlineResourceObject@urlDownload <- gsub("(.*?)\\@", "", CSVdatasetUrls[i])
      },
      "doi" = {
        onlineResourceObject@doi <- gsub("(.*?)\\@(http|https)\\:\\/\\/dx\\.doi\\.org\\/", "", CSVdatasetUrls[i])
      },
      "dataPolicy" = {
        dataConstraintObject@urlDataPolicy <- gsub("(.*?)\\@", "", CSVdatasetUrls[i])
      },
      #-------------------------------
      # simple + multiple string pattern
      #-------------------------------
      "publication" = {
        documentCSVList[[documentCount]] <- setDocumentsUsingAtSeperatedString(CSVdatasetUrls[i])
        # <- new(
        #   "Document",
        #   type = "publication",
        #   url = gsub("^(.*?)\\@", "", CSVdatasetUrls[i])
        # )
        documentCount <- documentCount + 1
        
      },
      "manual" = {
        documentCSVList[[documentCount]] <- setDocumentsUsingAtSeperatedString(CSVdatasetUrls[i])
        # documentCSVList[[documentCount]] <- new(
        #   "Document",
        #   type = "manual",
        #   url = gsub("^(.*?)\\@", "", CSVdatasetUrls[i])
        # )
        documentCount <- documentCount + 1
      },
      {
        #-------------------------------
        # descriptive + simple string pattern
        #-------------------------------
        switch(
          gsub("\\[(.*?)]", "", urlType),
          "licence" = {
            dataConstraintObject@licence <- 
              new(
                "Licence",
                title = str_match(urlType, "\\[(.*?)\\]")[,2],
                url = gsub("^(.*?)\\@", "", CSVdatasetUrls[i])
              )
          },
          #-------------------------------
          # descriptive + multiple string pattern
          #-------------------------------
          "webservice" = {
            webserviceCSVList[[webservicecount]] <- 
              new(
                "Webservice",
                description = str_match(urlType, "\\[(.*?)\\]")[,2],
                url = gsub("^(.*?)\\@", "", CSVdatasetUrls[i])
              )
            webservicecount <-  webservicecount + 1
          }
        )
      }
    )
  }
  onlineResourceObject@webservices <- webserviceCSVList
  metadataObject@onlineResource <- onlineResourceObject
  rm(i,documentCount, documentCSVList, webservicecount,webserviceCSVList,urlType,CSVdatasetUrls,onlineResourceObject)
  
  # f - dataset access and use constraint
  ### extract access and use constraint using datasets$Rights
  dataConstraintObject@accessUseConstraint <- str_match(CSVdatasetRights,"^accessConstraint\\:(.*)")[,2]
  metadataObject@dataConstraint <-dataConstraintObject
  rm(dataConstraintObject,CSVdatasetRights)
  
  # g - dataset lineage
  ### extract dataset lineage using datasets$Provenance
  metadataObject@datasetLineage <- str_match(CSVdatasetProvenance,"^statement\\:(.*)")[,2]
  rm(CSVdatasetProvenance)
  
  ### Store the metadataObject in the datasetObejct
  datasetObject@metadata <- metadataObject
  rm(metadataObject)
  
  # 6 - Extract observations metadata for the current dataset
  ##################################
  
  ### Get the observations of the dataset from the observations dataframe
  datasetObservationsCSV <- observations[which(sapply(observations$Dataset, function(y) datasets$Identifier[indexDat] %in% y)),]
  observationList <-  vector(mode= "list", length = nrow(datasetObservationsCSV) )
  for(indexObs in (1:nrow(datasetObservationsCSV))){
    
    # a - Instantiate an Observation class
    ### with the elements that can be directly copied from the csv 
    observationObject <- new("Observation")
    observationObject@observationId <- datasetObservationsCSV$Identifier[indexObs]
    observationObject@processingLevel <-  datasetObservationsCSV$ProcessingLevel[indexObs]
    observationObject@dataType <-  datasetObservationsCSV$DataType[indexObs]
    observationObject@timeSerie <-  datasetObservationsCSV$TimeSerie[indexObs]
    
    # b - Observation temporalExtent
    observationObject@temporalExtent <- setTemporalExtentUsingSlashSeparatedString(datasetObservationsCSV$TemporalExtent[indexObs])
    
    # c - ObservedProperty
    observationObject@observedProperty <- setObservedPropertyUsingIdentifier(datasetObservationsCSV$ObservedProperty[indexObs], observed_properties)
    
    # d - Feature of interest
    observationObject@featureOfInterest <- setFeatureOfInterestUsingIdentifier(datasetObservationsCSV$StationName[indexObs], sampling_features)
    
    # e - Procedure
    
    ### Lineage information list is left empty if there is no lineage information
    lineageInformationList <- vector(mode = "list")
    if(!is.na(datasetObservationsCSV$LineageInformation[indexObs])){
      lineageInformationList <- lapply(underscore_LF_separated_string_to_vector(datasetObservationsCSV$LineageInformation[indexObs]),setLineageInformationUsingBracketSeparatedString)
    }
    ### Sensor list is left empty if there is no sensor information
    sensorList <- lineageInformationList <- vector(mode = "list")
    if(!is.na(datasetObservationsCSV$Sensor[indexObs])){
      sensorList <- lapply(underscore_LF_separated_string_to_vector(datasetObservationsCSV$Sensor[indexObs]),setSensorUsingIdentifier, sensors)
    }
    ### dataProduction obect is decalred null if there is no method information and no sensor information
    dataProductionObject <- NULL
    if(length(sensorList) < 0 || !is.na(datasetObservationsCSV$Method[indexObs])) {
      dataProductionObject <- new("DataProduction",
                                  method=datasetObservationsCSV$Method[indexObs],
                                  sensors = sensorList
      )
    }
    rm(sensorList)
    ### if dataProduction object is null and lineageInformation list is empty the procedure object is set to null
    procedureObject <- NULL
    if(length(lineageInformationList) < 0 || !is.null(dataProductionObject)) {
      procedureObject <- new("Procedure",
                             lineageInformations = lineageInformationList,
                             dataProduction = dataProductionObject
      )
    }
    observationObject@procedure <-  procedureObject
    rm(procedureObject,lineageInformationList,dataProductionObject)
    
    # d - Result
    additionalValueList <- vector(mode = "list")
    qualityFlagList <- vector(mode = "list")
    if(!is.na(datasetObservationsCSV$AdditionalValue[indexObs])){
      additionalValueList <- lapply(underscore_LF_separated_string_to_vector(datasetObservationsCSV$AdditionalValue[indexObs]),setAdditionalValueUsingIdentifier, additional_values)
    }
    if(!is.na(datasetObservationsCSV$QualityFlags[indexObs])){
      qualityFlagList <- lapply(underscore_LF_separated_string_to_vector(datasetObservationsCSV$QualityFlags[indexObs]),setQualityFlagsUsingBracketSeparatedString)
    }
    observationObject@result <-new("Result",
                                   dataFile = new("DataFile",name = datasetObservationsCSV$DataFileName[indexObs]),
                                   missingValue = as.character(datasetObservationsCSV$MissingValue[indexObs]),
                                   qualityFlags = qualityFlagList,
                                   additionalValues = additionalValueList
    )
    
    
    ### Store the observation in the list of observation of the dataset
    observationList[[indexObs]] <- observationObject
    rm(indexObs, observationObject,additionalValueList,qualityFlagList)
  }
  
  ###Store the observation list in the dataset object
  datasetObject@observations <- observationList
  ###Store the datasetObject list in the dataset list
  datasetList[[indexDat]] <- datasetObject
  rm(observationList,datasetObject,datasetObservationsCSV)
  
}
pivotObject@datasets <- datasetList
rm(indexDat, datasetList)

# 7 - print the json file
##################################

# fileConn<-file(paste(producer$Identifier,"_en.json",sep = ""))
fileConn<-file("pivot.json")
writeLines(toJSON(pivotObject), fileConn)
close(fileConn)
rm(fileConn)

# 8 - correct the json using some javascript code
##################################
system("node correct_json.js")
system("rm pivot.json")
system(paste("mv pivot_corrected.json",paste(producer$Identifier,"_en.json",sep = "")))