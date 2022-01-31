##################################
# CSV to theia pivot JSON workflow
##################################
library("stringr")
library("RJSONIO")
library("wellknown")

# 1 - Import all csv files into data.frames
##################################

csvFileNames <- list.files(path = "../csv-semi-colon")

for (fileName in csvFileNames) {
  assign(
    sub('\\.csv$', '', fileName),
    read.csv(
      paste("../csv-semi-colon", fileName, sep = "/"),
      stringsAsFactors = FALSE,
      sep = ";",
      na.strings = c("NA", "")
    )
  )
}
rm(fileName, csvFileNames)

# 2 - Class declaration
#################################
source("classes.R")

# 3 - Declare useful functions for the rest of the workflow
##################################
source("functions.R")

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