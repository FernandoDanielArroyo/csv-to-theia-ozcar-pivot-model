
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

