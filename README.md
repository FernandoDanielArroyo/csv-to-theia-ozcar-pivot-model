# Documentation du programme d'extraction du modèle pivot à partir de fichiers CSV. E-ENVIR 2021
---

Ce script permet de créer l'implémentation en JSON du modèle pivot Theia/OZCAR à partir des informations contenues dans plusieurs fichiers csv. Ces fichiers et leur contenu sont décrit plus tard dans ce document.
Les fichiers CSV sont contenu dans le répertoire csv et les fichiers de code dans le répertoire script. Le code est écrit en R pour faciliter la maintenance et l'utilisation du programme par les scientifiques. 


## Le modèle de données pivot Theia/OZCAR

Pour permettre l’échange d’information entre les producteurs de données et le SI Theia/OZCAR, un modèle de données pivot commun a été construit sur la base des standards ISO19115/INSPIRE, O&M et DataCite. Il permet de véhiculer les métadonnées nécessaires aux fonctionnalités du portail Theia/OZCAR et à l’implémentation de services d’interopérabilité et de déclaration de DOI.
Ce modèle contient les métadonnées permettant de décrire le "producteur" de données, les "jeux de données" que le "producteur" fourni et les "observations" contenu dans chacun des "jeux de données". Une "observation" décrit à une variable mesurée (Observed property) à un endroit donné (Feature of interest) selon et une procédure données (Procedure) et ses résultats (Result).

![UML-pivot-simple]

Pour plus d'information:https://theia-ozcar.gricad-pages.univ-grenoble-alpes.fr/doc-producer/producer-documentation.html#modele-de-donnees-pivot-description-et-implementation-en-json

La documentation complète du modèle pivot et de son implémentation pour mettre en oeuvre l'échange d'information avec le système d'information Theia/OZCAR est disponible ici: https://theia-ozcar.gricad-pages.univ-grenoble-alpes.fr/doc-producer/_downloads/b57adda313eaf801d6ba4348ab86e8ea/description_champs_JSON_v1.1.pdf

## Description des fichiers csv et des champs de métadonnées

Dans les fichiers suivant, les valeurs des cellules peuvent prendre la forme de valeur unique ou de **liste** de valeur. Dans le cas de liste de valeurs, chaque élément de la liste correspond à une ligne dans la cellule et est terminé par un **underscore (_)**.

### producer.csv

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
| Identifier | Identifiant du fournisseur de données. Les identifiants des observatoires sont fournis par l'équipe Theia OZCAR et sont composé de 4 lettres majuscules | non | CATC |
| Name | Le nom du producteur de données (nom de l'observatoire) | non | AMMA-CATCH |
| Title | Le titre du producteur de données | non | AMMA-CATCH:  a  hydrological,  meteorological  and  ecological  observatory  on  West  Africa |
| Descritpion | La description du producteur de données | non ||
| Objective | Résumé des objectifs scientifiques du producteur de données | recommandé | |
| Measured variables | Résumé des variables mesurées par le producteur de données | recommandé | |
| Email | Email générique de contact du producteur de données | non | contact@amma-catch.org |
| Contacts | **Liste** de contacts pour le producteur de données.  Les  contacts  doivent  être  des  personnes  physiques :  deux  rôles  sont possibles.  Le  Data  manager  est  la  personne  qui  assure  le  rôle  de  gestionnaire  de  données.  Le Project  leader  est  le  responsable  scientifique  de  l'observatoire. Au moins un contact avec le rôle Project leader est requis. Il peut y avoir qu’un seul Project leader.<br />Un contact est décrit de la manière suivante: **role:identifiantDuContact**.<br />Role = projectLeader ou dataManager. identifiantDuContact = une valeur du champ *Identifier* du contact correspondant dans le fichier contact.csv. | non | projectLeader:0000-0002-3100-8510_<br />dataManager:veronique.chaffard@ird.fr |
| Funders | **Liste** des financeurs du producteurs de données. Utile pour la déclaration de DOI ainsi que  pour produire  des  statistiques  sur les tutelles.<br />Un financeur est décrit de la manière suivante: **type:identifianDeLOrganisation**.<br />Type = FrenchResearchInstitutes, FederativeStructure, ResearchUnit, Other, OtherUniversitiesAndSchools, ResearchProgram, FrenchUniversitiesAndSchools, OtherResearchInstitutes<br />identifianDeLOrganisation = valeur du champ *Identifier* de l'organisation correspondante dans le fichier organisation.csv. | non | FrenchResearchInstitutes:180006025_<br />FrenchResearchInstitutes:180089013_<br />FederativeStructure:200310841A_<br />FederativeStructure:200919527R_<br />FederativeStructure:200719584L |

### contacs.csv

La forme de ce fichier a été gardée au plus proche de la forme des fichiers de contacts utilisés dans le le workflow [Geoflow](https://github.com/eblondel/geoflow/). De cette manière les mêmes fichiers pourraient théoriquement être utilisés pour extraire le modèle pivot et dans geoflow (pas testé). De ce fait certains champs du fichier contacts.csv ne sont pas utilisé dans ce programme.

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
| Identifier | Identifiant du contact. L'identifiant est l'email du contact et/ou l'orcid du contact. <br />La valeur de l'email est précédé par **id:**, la valeur de l'orcid est précédé de **orcid:**. Lorsqu'un contact est référencé dans un autre fichier csv, il est nécessaire de mentionner **un seul des deux identifiants sans son préfix**. | non | orcid:0000-0002-3100-8510_<br />id:sylvie.galle@ird.fr |
| Email | Email du contact | non | sylvie.galle@ird.fr | 
| OrganizationName | Pas utilisé |||
| PositionName | Pas utilisé |||
| LastName | Nom de famille du contact |||
| FirstName | Prénom du contact |||
| PostalAddress | Pas utilisé |||
| PostalCode | Pas utilisé |||
| City | Pas utilisé |||
| Country | Pas utilisé |||
| Voice | Pas utilisé |||
| WebsiteUrl | Pas utilisé |||
| WebsiteName | Pas utilisé |||
| ORCID | ORCID du contact | oui | 0000-0002-3100-8510 |
| OrganisationIdentifier | Identifiant de l'organisation du contact. La valeur est formé de la manière suivante: **role:identifianDeLOrganisation**<br />Role = ResearchGroup<br />identifianDeLOrganisation = valeur du champ *Identifier* de l'organisation correspondante dans le fichier organisation.csv.| oui | ResearchGroup:201722374A |


### organisations.csv

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
| Identifier | Identifiant de l'organisation. Valeur libre. L'utilisation de l'indentifiant scanR lorsqu'il existe semble judicieux. | non | |
| Name | Nom de l'organisation | non | Institut de Recherche pour le Développement |
| Acronym | Acronyme de l'organisation | oui | IRD |
| IdScanR | ID scanR de l'organisation - https://scanr.enseignementsup-recherche.gouv.fr/ | oui | 180006025 |
| Iso3166 | code à deux lettres ISO3166 du pays de l'organisation | non | fr|


### datasets.csv

La forme de ce fichier a été gardée au plus proche de la forme des fichiers de metadata utilisés dans le le workflow [Geoflow](https://github.com/eblondel/geoflow/). De cette manière les mêmes fichiers pourraient théoriquement être utilisés pour extraire le modèle pivot et dans geoflow (pas testé). De ce fait certains champs du fichier datasets.csv ne sont pas utilisé dans ce programme.

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
| Identifier | une chaine de caractère composée d'un code formé par les 4 premières lettres du  nom  du  fournisseur  de  données  conforme  à  la  liste  fournie  en  annexe  1,  suivi  par  un  la chaine de caractère « _DAT_ » et d’un identifiant pérenne du jeu de données. Il est obligatoire que  l'identifiant  choisi  pour  le  jeu  de  données  n'évolue  pas  dans  le  temps. | non | CATC_DAT_CE.Run_Nct |
| Title | Le titre du jeux de données | non |Surface water dataset (river discharge), within the Tondikiboro and Mele Haoussa watersheds (< 35 ha), Niger |
| Description | Liste de valeurs permettant de décrire deux éléments de métadonnées différents. Les valeurs sont préfixées de la manière suivante:<br /> - **abstract:** élément obligatoire. Un résumé du jeu de données. Le résumé doit décrire la ressource de façon compréhensible par l’utilisateur. Pour un producteur, il s’agit en particulier de définir au mieux l’information ou le phénomène représenté dans la donnée. On va donc y trouver des éléments de définition, mais aussi éventuellement une indication sommaire de la zone couverte ou le cas échéant, des informations sur les particularités de la version du jeu de données.<br /> - **purpose:** élément optionnel. Résumé des objectifs scientifiques du jeu de donnée. |non|abstract:Flood event measured in 4 (Tondikiboro) and 2 (Mele Haoussa) embeded catchments. Sediment loads are sampled during selected rainfall events in Tondikiboro._<br />purpose:Document the flood events in various geological context : sedimentary (Tondikiboro) and cristaline bedrock (Mele Haoussa), and for cultivated and natural vegetation covers.|
|Subject| Liste de valeurs permettant de décrire les mots clés d'un jeux de données. Les valeurs sont préfixées de la manière suivante:<br /> - **topicCategories**: élément obligatoire: Liste de mot clés représentant les catégories thématiques du jeux de données. Les différents éléments de la liste sont séparés par une virgule. Se référer à la description du modèle de donnée pour obtenir les différentes catégories thématiques disponibles.<br /> - **inspireTheme**: élément obligatoire. Thématique INSPIRE du jeu de données. Se référer à la description du modèle de donnée pour obtenir les différentes thématiques INSPIRE disponibles.<br /> - **keywords**: élément optionel. Liste des mots clés décrivant le jeu de données. Chaque élement de la liste est séparé par une **virgule**. Chaque élément de la liste peu contenir le mot clé et son uri si elle existe séparé par un **@**.|non|keywords:discharge,erosion,turbidity@http://google.fr,Niger_<br />topicCategories:Environment,Geoscientific Information_<br />inspireTheme:Environmental monitoring facilities |
|Creator|Liste de contact pour le jeu de données. Les  contacts  doivent  être  des  personnes  physiques :  deux  rôles  sont possibles.  Le  publisher  est  la  personne  qui  assure  le  rôle  de  gestionnaire  de  données.  Le principal investigator  est  le  référent  scientifique  de  du jeux de données. Au moins un contact avec le rôle principal investigator est requis.<br />Un contact est décrit de la manière suivante: **role:identifiantDuContact**.<br />Role = publisher ou principalInvestigaor.<br />identifiantDuContact = une valeur du champ *Identifier* du contact correspondant dans le fichier contact.csv. | non | principalInvestigator:0000-0002-3100-8510_|
| Date| Pas utilisé |||
| Type| Pas utilisé |||
| Language| Pas utilisé |||
| SpatialCoverage| Étendue du jeu dans l’espace géographique,exprimé en latitude/longitude, exprimée en WKT. L'élément est préfixé par **wkt:** |non|wkt:POLYGON ((1.6043 13.8844,1.6043 13.546,2.7008 13.546,2.7008 13.8844,1.6043 13.8844))|
| TemporalCoverage| Pas utilisé |||
| Format| Pas utilisé |||
|Relation|Liste de valeurs permettant de décrire les éléments de métadonnées du jeu de données représentés par des urls. Aucun de ces éléments n'est obligatoire mais il est fortement recommandé de les renseigner si ils existent. Chacun des éléments de la liste sont préfixées par **http:**. Un élément et son url sont séparé par **@**. Les éléments renseignables les suivant:<br /> - **info** : recommandé. Cet élément de métadonnée fournit un lien vers une page Web décrivant le jeu de données.<br /> - **download** : Cet  élément  de  métadonnée  fournit  un  lien  vers  une  page  Web  de téléchargement du jeu de donnée. Cet élément est recommandé si une telle possibilité existe.<br /> - **doi** : Lien vers le DOI référencant de manière unique le jeu de données<br /> - **publication** : Lien vers une publication utile à la description du jeu de données. Il est possible de renseigner plusieurs élément **publication**.<br />- **webservice** : Lien vers un webservice sur le jeu de données. Le webservice doit être décrit. La description est ajouté entre **crochet []** après **webservice** et avant le **@**. Il est possible de renseigner plusieurs élément **webservice**<br /> - **licence** : Lien vers la licence sur le jeu de données. Le licence doit être décrite. La description est ajouté entre **crochet []** après **licence** et avant le **@**.<br /> - **dataPolicy**: Lien vers la data policy du jeu de données.|oui | http:info@http://bd.amma-catch.org_<br />http:download@http://bd.amma-catch.org/download.jsf?lang=fr&identifier=29&stations=850,851,847,996,848,849&variables=29&begin=&end=_<br />http:doi@http://dx.doi.org/10.17178/AMMA-CATCH.CE.Run_Nct_<br />http:publication@http://dx.doi.org/10.1080/02626667.2014.885654_<br />http:publication@http://dx.doi.org/10.1016/j.jhydrol.2011.11.019_<br />http:licence[CC BY 4.0]@https://creativecommons.org/licenses/by/4.0/_<br />http:dataPolicy@http://www.amma-catch.org/IMG/pdf/data_policy_amma-catch_db_en.pdf |
| Provenance| décrit la généalogie d'un jeu de données, i.e. l’historique du jeu de données et, s’il est connu, le cycle de vie de celui-ci, depuis l’acquisition et la saisie de l’information jusqu’à sa compilation avec d’autres jeux et les variantes de sa forme actuelle. Il s’agit d’apporter une description littérale et concise soit de l’histoire du jeu de données, soit des  moyens,  procédures  ou  traitements  informatiques  mis  en  œuvre  au  moment  de l’acquisition du jeu de données. La généalogie fait état de l’historique du traitement et/ou de la qualité  générale  de  la  série  de  données  géographiques.  Le  cas  échéant,  elle  peut  inclure  une information indiquant si la série de données a été validée ou soumise à un contrôle de qualité, s’il s’agit de la version officielle (dans le cas où il existe plusieurs versions) et si elle a une valeur légale.<br />L'élement est préfixé par **statement:**|non||
| Data| Pas utilisé |||

### observations.csv

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
| Identifier | une chaine  de  caractère  composée  d'un code  formé par les 4 premières lettres  du  nom  du  fournisseur  de  données  conforme  à  la  liste  fournie en  annexe  1, suivi  de  la chaine  de caractère «_OBS_»,  suivi  d’un  identifiant  unique  de  l’observation. | non | CATC_OBS_CE.Run_Nct_2 |
|ProcessingLevel| Niveau de traitement de l’observation. L'élément peut prendre une des valeurs  suivantes :  **Raw data**,  **Quality-controlled data**,  **Derived products**.<br />Raw :  les  données  n'ont  pas  subi  de  contrôle  de  qualité.  Quality-controlled data:  les données  ont  subi  un  contrôle  de  qualité  comme  une  inspection  visuelle  ou  statistique  (ex : correction  de  la  dérive  du capteur,  suppression  des  valeurs  aberrantes.  Derived products: les données sont le résultat d’une interprétation scientifique et/ou technique. Les données issues d’une interprétation scientifique ou basé sur un modèle qui utilise d’autres données et/ou  est  basé  sur  de  fortes  hypothèses.  Ex :  données  construites  à  partir  de  données  de plusieurs capteurs, données gap-filled, données issues de modèle...  |oui||
|DataType| Le format du résultat de l’observation. Ce champ permettra à l’application d’effectuer des opérations sur l’observation comme par exemple de la visualisation.  Ce champ peut  prendre  les  valeurs  suivantes :  **Numeric**,  **Text**,  **Vector**,  **Raster**,  **Photo**, **Video**, **Audio**, **Other**. Actuellement le modèle pivot est construit pour décrire des séries de données (timeseries) numériques. |non||
|TemporalExtent|L'élément est constitué de deux membres séparé par un **/** décrivant l’extension temporelle valide des données de l’observation. Chaque élément est une chaine  de  caractère  décrivant  une  date UTC au  format  ISO  8601  "YYYY-MM-DDThh:mm:ssZ" représentant une date de début et une date de fin. Si l’observation est une série temporelle :  Date  de  début  de  la  série,  date  de  fin  de  la  série.  Si l’observation n’est pas une série temporelle, la période de validité de la mesure selon le scientifique (par exemple : <br />-  Date de la mesure, Date de la mesure + 6 mois pour une mesure que l’on peut considérer constante sur 6 mois.<br />-  Date  de  la  mesure,  9999-12-31T00:00 :00Z pour une mesure que l’on peut considérer  atemporelle.  ).  Si  la  date  de  la  mesure  est  inconnue  9999-12-31T00:00:00Z, 9999-12-31T00:00:00Z.|||
|TimeSeries| booléen égale à TRUE si l’observation est une série de données temporelles. Ce champ permettra à l’application d’effectuer des opérations sur l’observation comme par 
exemple de la visualisation.|non||
|LineageInformation| Liste d'élément permettant de documenter les traitements post-acquisition subis par les données. Chaque élément de la liste est composé d'une date UTC au  format  ISO  8601  "YYYY-MM-DDThh:mm:ssZ" entre **crochet []** suivi d'une chaine de caractère décrivant le traitement.|oui|[2004-12-31T23:40:00Z]The water table depth (WTD) is calculating according to the following equation: WTD=a*H_raw_clean+b where H_raw_clean is the water level measurement by the probe without the aberrant values, a=1 and b=-0.451. The data are integrated at half-hour frequency up to 04/17/2018, then 15 minutes frequency up to 05/31/2018 and then half-hour frequency.|
|Method|chaine de caractère décrivant la méthode d’acquisition|oui|Automatic probe fro water temperature records in the Aven Mazauric.\nMeasurement type: automatic.|
|ObservedProperty| Identifie  la  variable  décrivant  le  phénomène observé. L'élément est la valeur du champ *Identifier* de la propriété observée correspondante dans le fichier observedProperty.csv. |non||
|Sensor| Liste d'éléments décrivant le dispositif ayant été utilisé pour  la  production  de  la  donnée  (capteur  physique  ou  virtuel). Chaque élément de la liste est composé de la période d'aquisition du capteur entre **crochet []** suivi de la valeur du champ *Identifier* du capteur correspondant dans le fichier sensor.csv. La période d'aquisition est composé de deux dates UTC au  format  ISO  8601  "YYYY-MM-DDThh:mm:ssZ" séparées par un **/**.| oui ||
|StationName| Nom de la station d'acquisition de l'observation. L'élément doit correspondre à au champ  *Identifier* de la station de mesure correspondante dans le fichier sampling_features.csv. |non|TONDIKIBORO_TKBODO|
|Dataset|Dataset dans lequel est inclu l'observation. L'élément correspond au champ  *Identifier* du dataset de l'observation correspondante dans le fichier datasets.csv.|non|CATC_DAT_CE.Run_Nct|
|DataFileName|Nom du fichier contenant les données de l'observation|non|HPLU_OBS_ploemeur_chemistry_1.txt|
|MissingValue| code associé aux valeurs manquantes dans les fichiers de données. |oui|-99999|
|QualityFlags| Liste d'élément décrivant les flags de qualité et de leur signification associée  aux  mesures. Chaque élément de la liste est composé du code qualité et de sa description entre **crochet []**.|oui|13[checked data]_<br />11[missing value]_<br />17[dry river]|
|AdditionalValue| Liste d'éléments décrivant des valeurs additionnelles peuvantt être ajoutées  aux mesures de l’observation  (exemples : incertitudes, erreurs, valeurs de paramètres liés à l’instrumentation...).  Ces  valeurs  additionnelles  sont  présentes  dans  le  fichier  de données. Chaque élément de la liste correspond au champ *Identifier* de la valeur additionelle correspondante dans le fichier additionalValues.csv. |oui||

### observed_properties.csv

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
|Identifier|Identifiant de la propriété observée. Valeur libre. Cet identifiant devra être réutilisé dans les fichiers csv mentionnant la propriété observée.|non||
|Name|Nom de la propriété observée. |non|Air Temperature at height 5 m|
|Unit|Unité de la propriété observée. Si la propriété observée est sans unité il faut renseigner "N/A"|non|°C|
|Description|Description de la propriété observée.|oui|| 
|TheiaCategories|Liste d'élément dont chaque  élément est une chaine  de  caractère représente une URI identifiant une catégorie de variable OZCAR/Theia (thésaurus publié en ligne :<br />http://in-situ.theia-land.fr/skosmos/theia_ozcar_thesaurus/en/) et permet  d'associer  le  nom  de  variable  producteur  à  la  taxonomie  de  catégorie  de variable  OZCAR/Theia. |non|https://w3id.org/ozcar-theia/wind |


### sampling_features.csv

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
|Identifier|Identifiant de la station de mesure. Valeur libre. Cet identifiant devra être réutilisé dans les fichiers csv mentionnant la propriété observée. Il est recommandé d'utiliser le nom de la station de mesure.|non||
|Name|Nom de la station de mesure. |non|MELE HAOUSSA_MH1 |
|Geometry| Position/emprise de la station de mesure dans l’espace géographique, exprimé en latitude/longitude, exprimée en WKT. L'élément est préfixé par **wkt:** |non|wkt:POINT Z(1.718 9.7912 414.0)|

### sensors.csv


Un capteur peut soit être un capteur physique, soit un capteur virtuel dans le cadre de données issues de sorties de modèles. Dans le cas de capteur virtuel, seul les champs **ModelName**, **ModelParametrisationDescription** et **Documents** sont renseignés. Dans le cadre de capteurs physiques, les champs **ModelName**, **ModelParametrisationDescription** ne sont pas renseignés.

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
|Identifier|Identifiant du capteur. Valeur libre. Cet identifiant devra être réutilisé dans les fichiers csv mentionnant le capteur.|non||
|Model|Model du capteur physique|oui||
|Manufacturer|Fabriquant du capteur physique|oui||
|SensorType|Type du capteur physique|non|Surface Water Monitoring System|
|Calibration|Champs de texte libre précisant des informations sur la calibration du catpeur physique.|oui||
|ModelName|Nom du capteur virtuel|oui||
|ModelName|Champ de texte libre précisant les informations sur la parametrisation du capteur virtuel|oui||
|Documents|Liste d'éléments permettant de décrire des documents. Chaque élément représente un type de document, soit **publication**, soit **manual**, et l'url du document séparé par un **":"**|oui|publication@http://dx.doi.org/10.1080/02626667.2014.885654|

### additional_values.csv

Nom du champ | Description des valeurs | optionel | exemple
--- | --- | --- | ---
|Identifier|Identifiant de la valeur additionnelle. Valeur libre. Cet identifiant devra être réutilisé dans les fichiers csv mentionnant la valeur additionnelle.|non||
|Name|Nom de la valeur additionnelle|non||
|NameInDatafile|Nom de la valeur additionnelle dans le fichier de donnée|non||
|Unit|Unité de la valeur additionnelle|non||
|Description|Description de la valeur additionnelle|non||











[UML-pivot-simple]: https://theia-ozcar.gricad-pages.univ-grenoble-alpes.fr/doc-producer/_images/datamodel_theia-ozcar_conceptual_schema.png


