final geneColumns = [
  ["gene_ncbi", "geneNcbi"],
  ["gene_ensembl", "geneEnsembl"],
  ["taxon_ncbi", "taxonNcbi"],
  ["symbol_ncbi", "symbolNcbi"],
  ["locustag", "locustag"],
  ["chromosome", "chromosome"],
  ["map_location", "mapLocation"],
  ["description", "description"],
  ["type_of_gene", "typeOfGene"],
  ["symbol_from_nomenclature_authority", "symbolFromNomenclatureAuthority"],
  [
    "full_name_from_nomenclature_authority",
    "fullNameFromNomenclatureAuthority"
  ],
  ["nomenclature_status", "nomenclatureStatus"],
  ["other_designations", "otherDesignations"],
  ["modification_date", "modificationDate"],
  ["feature_type", "featureType"],
  ["p_de", "pDe"],
  ["n_pubs", "nPubs"],
  ["defined_hugo", "definedHugo"],
  ["n_synonyms", "nSynonyms"],
  ["n_mouse_pheno", "nMousePheno"],
  ["mouse_pheno", "mousePheno"],
  ["n_gwas", "nGwas"],
  ["detectable_portion", "detectablePortion"],
  ["tissue_median", "tissueMedian"],
  ["hela_expression", "helaExpression"],
  ["mendelian_inheritance", "mendelianInheritance"],
  ["mouse", "mouse"],
  ["rat", "rat"],
  ["c_elegans", "cElegans"],
  ["d_melanogaster", "dMelanogaster"],
  ["yeast", "yeast"],
  ["zebrafish", "zebrafish"],
  ["primate_specific", "primateSpecific"],
  ["n_mouse_pubs", "nMousePubs"],
  ["n_rat_pubs", "nRatPubs"],
  ["n_c_elegans_pubs", "nCElegansPubs"],
  ["n_d_melanogaster_pubs", "nDMelanogasterPubs"],
  ["n_zebrafish_pubs", "nZebrafishPubs"],
  ["n_yeast_pubs", "nYeastPubs"],
  ["nextprot_evidence", "nextprotEvidence"],
  ["hpa_evidence", "hpaEvidence"],
  ["uniprot_evidence", "uniprotEvidence"],
  ["membrane_protein", "membraneProtein"],
  ["antibody", "antibody"],
  ["approved_ih", "approvedIh"],
  ["approved_if", "approvedIf"],
  ["idg_understudied", "idgUnderstudied"],
  ["plasmid", "plasmid"],
  ["compound", "compound"],
  ["n_biocarta", "nBiocarta"],
  ["n_reactome", "nReactome"],
  ["n_hpo", "nHpo"],
  ["n_wikipathways", "nWikipathways"],
  ["n_pid", "nPid"],
  ["n_kegg", "nKegg"],
  ["n_go", "nGo"],
  ["protein_coding", "proteinCoding"],
  ["gene_length", "geneLength"],
  ["loss_of_function_intolerant", "lossOfFunctionIntolerant"],
  ["previously_patented", "previouslyPatented"],
  ["normalized_gravy", "normalizedGravy"],
  ["druggable", "druggable"],
  ["Abnormalities, Multiple", "abnormalitiesMultiple"],
  ["Abortion, Habitual", "abortionHabitual"],
  ["Acute Coronary Syndrome", "acuteCoronarySyndrome"],
  ["Acute Disease", "acuteDisease"],
  ["Acute Kidney Injury", "acuteKidneyInjury"],
  ["Adenocarcinoma", "adenocarcinoma"],
  ["Adenocarcinoma of Lung", "adenocarcinomaofLung"],
  ["Adenocarcinoma, Mucinous", "adenocarcinomaMucinous"],
  ["Adenoma", "adenoma"],
  ["Albuminuria", "albuminuria"],
  ["Alcoholism", "alcoholism"],
  ["Alzheimer Disease", "alzheimerDisease"],
  ["Amyotrophic Lateral Sclerosis", "amyotrophicLateralSclerosis"],
  ["Arthritis, Rheumatoid", "arthritisRheumatoid"],
  ["Asthma", "asthma"],
  ["Astrocytoma", "astrocytoma"],
  ["Atherosclerosis", "atherosclerosis"],
  ["Atrial Fibrillation", "atrialFibrillation"],
  ["Autoimmune Diseases", "autoimmuneDiseases"],
  ["Bile Duct Neoplasms", "bileDuctNeoplasms"],
  ["Body Weight", "bodyWeight"],
  ["Bone Neoplasms", "boneNeoplasms"],
  ["Brain Ischemia", "brainIschemia"],
  ["Brain Neoplasms", "brainNeoplasms"],
  ["Breast Neoplasms", "breastNeoplasms"],
  ["Calcinosis", "calcinosis"],
  ["Carcinogenesis", "carcinogenesis"],
  ["Carcinoma", "carcinoma"],
  ["Carcinoma, Ductal, Breast", "carcinomaDuctalBreast"],
  ["Carcinoma, Hepatocellular", "carcinomaHepatocellular"],
  ["Carcinoma, Non-Small-Cell Lung", "carcinomaNonSmallCellLung"],
  ["Carcinoma, Ovarian Epithelial", "carcinomaOvarianEpithelial"],
  ["Carcinoma, Pancreatic Ductal", "carcinomaPancreaticDuctal"],
  ["Carcinoma, Papillary", "carcinomaPapillary"],
  ["Carcinoma, Renal Cell", "carcinomaRenalCell"],
  ["Carcinoma, Squamous Cell", "carcinomaSquamousCell"],
  ["Carcinoma, Transitional Cell", "carcinomaTransitionalCell"],
  ["Cardiomyopathy, Dilated", "cardiomyopathyDilated"],
  ["Cardiovascular Diseases", "cardiovascularDiseases"],
  ["Carotid Artery Diseases", "carotidArteryDiseases"],
  ["Cataract", "cataract"],
  ["Cell Transformation, Neoplastic", "cellTransformationNeoplastic"],
  ["Cervical Intraepithelial Neoplasia", "cervicalIntraepithelialNeoplasia"],
  ["Charcot-Marie-Tooth Disease", "charcotMarieToothDisease"],
  ["Cholangiocarcinoma", "cholangiocarcinoma"],
  ["Chromosome Aberrations", "chromosomeAberrations"],
  ["Chromosome Deletion", "chromosomeDeletion"],
  ["Chronic Disease", "chronicDisease"],
  ["Cleft Palate", "cleftPalate"],
  ["Colitis", "colitis"],
  ["Colitis, Ulcerative", "colitisUlcerative"],
  ["Colonic Neoplasms", "colonicNeoplasms"],
  ["Colorectal Neoplasms", "colorectalNeoplasms"],
  ["Coronary Artery Disease", "coronaryArteryDisease"],
  ["Coronary Disease", "coronaryDisease"],
  ["Crohn Disease", "crohnDisease"],
  ["Cystadenocarcinoma, Serous", "cystadenocarcinomaSerous"],
  ["Cystic Fibrosis", "cysticFibrosis"],
  ["Deafness", "deafness"],
  ["Dementia", "dementia"],
  ["Dermatitis, Atopic", "dermatitisAtopic"],
  ["Diabetes Mellitus", "diabetesMellitus"],
  ["Diabetes Mellitus, Experimental", "diabetesMellitusExperimental"],
  ["Diabetes Mellitus, Type 1", "diabetesMellitusType1"],
  ["Diabetes Mellitus, Type 2", "diabetesMellitusType2"],
  ["Diabetes, Gestational", "diabetesGestational"],
  ["Diabetic Nephropathies", "diabeticNephropathies"],
  ["Diabetic Retinopathy", "diabeticRetinopathy"],
  ["Disease Models, Animal", "diseaseModelsAnimal"],
  ["Disease Progression", "diseaseProgression"],
  ["Disease Susceptibility", "diseaseSusceptibility"],
  ["Down Syndrome", "downSyndrome"],
  ["Endometrial Neoplasms", "endometrialNeoplasms"],
  ["Endometriosis", "endometriosis"],
  ["Epilepsy", "epilepsy"],
  ["Esophageal Neoplasms", "esophagealNeoplasms"],
  ["Esophageal Squamous Cell Carcinoma", "esophagealSquamousCellCarcinoma"],
  ["Fatty Liver", "fattyLiver"],
  ["Fibrosis", "fibrosis"],
  ["Frontotemporal Dementia", "frontotemporalDementia"],
  ["Gastrointestinal Neoplasms", "gastrointestinalNeoplasms"],
  ["Genetic Diseases, X-Linked", "geneticDiseasesXLinked"],
  ["Genetic Predisposition to Disease", "geneticPredispositiontoDisease"],
  ["Genomic Instability", "genomicInstability"],
  ["Glaucoma, Open-Angle", "glaucomaOpenAngle"],
  ["Glioblastoma", "glioblastoma"],
  ["Glioma", "glioma"],
  ["Graves Disease", "gravesDisease"],
  ["HIV Infections", "hIVInfections"],
  ["Head and Neck Neoplasms", "headandNeckNeoplasms"],
  ["Hearing Loss", "hearingLoss"],
  ["Hearing Loss, Sensorineural", "hearingLossSensorineural"],
  ["Heart Defects, Congenital", "heartDefectsCongenital"],
  ["Heart Failure", "heartFailure"],
  ["Helicobacter Infections", "helicobacterInfections"],
  ["Hepatitis B", "hepatitisB"],
  ["Hepatitis B, Chronic", "hepatitisBChronic"],
  ["Hepatitis C", "hepatitisC"],
  ["Hepatitis C, Chronic", "hepatitisCChronic"],
  ["Huntington Disease", "huntingtonDisease"],
  ["Hyperglycemia", "hyperglycemia"],
  ["Hyperplasia", "hyperplasia"],
  ["Hypertension", "hypertension"],
  ["Hypertension, Pulmonary", "hypertensionPulmonary"],
  ["Hypoxia", "hypoxia"],
  ["Infertility, Male", "infertilityMale"],
  ["Inflammation", "inflammation"],
  ["Inflammatory Bowel Diseases", "inflammatoryBowelDiseases"],
  ["Insulin Resistance", "insulinResistance"],
  ["Intellectual Disability", "intellectualDisability"],
  ["Kidney Diseases", "kidneyDiseases"],
  ["Kidney Failure, Chronic", "kidneyFailureChronic"],
  ["Kidney Neoplasms", "kidneyNeoplasms"],
  ["Laryngeal Neoplasms", "laryngealNeoplasms"],
  ["Leukemia", "leukemia"],
  ["Leukemia, Lymphocytic, Chronic, B-Cell", "leukemiaLymphocyticChronicBCell"],
  [
    "Leukemia, Myelogenous, Chronic, BCR-ABL Positive",
    "leukemiaMyelogenousChronicBCRABLPositive"
  ],
  ["Leukemia, Myeloid", "leukemiaMyeloid"],
  ["Leukemia, Myeloid, Acute", "leukemiaMyeloidAcute"],
  ["Liver Cirrhosis", "liverCirrhosis"],
  ["Liver Neoplasms", "liverNeoplasms"],
  ["Lung Neoplasms", "lungNeoplasms"],
  ["Lupus Erythematosus, Systemic", "lupusErythematosusSystemic"],
  ["Lymphatic Metastasis", "lymphaticMetastasis"],
  ["Lymphoma", "lymphoma"],
  ["Lymphoma, B-Cell", "lymphomaBCell"],
  ["Lymphoma, Large B-Cell, Diffuse", "lymphomaLargeBCellDiffuse"],
  ["Macular Degeneration", "macularDegeneration"],
  ["Mammary Neoplasms, Experimental", "mammaryNeoplasmsExperimental"],
  ["Melanoma", "melanoma"],
  ["Mesothelioma", "mesothelioma"],
  ["Metabolic Syndrome", "metabolicSyndrome"],
  ["Microcephaly", "microcephaly"],
  ["Microsatellite Instability", "microsatelliteInstability"],
  ["Mouth Neoplasms", "mouthNeoplasms"],
  ["Multiple Myeloma", "multipleMyeloma"],
  ["Multiple Sclerosis", "multipleSclerosis"],
  ["Myelodysplastic Syndromes", "myelodysplasticSyndromes"],
  ["Myeloproliferative Disorders", "myeloproliferativeDisorders"],
  ["Myocardial Infarction", "myocardialInfarction"],
  ["Nasopharyngeal Carcinoma", "nasopharyngealCarcinoma"],
  ["Nasopharyngeal Neoplasms", "nasopharyngealNeoplasms"],
  ["Necrosis", "necrosis"],
  ["Neoplasm Invasiveness", "neoplasmInvasiveness"],
  ["Neoplasm Metastasis", "neoplasmMetastasis"],
  ["Neoplasm Recurrence, Local", "neoplasmRecurrenceLocal"],
  ["Neoplasms", "neoplasms"],
  ["Neoplasms, Experimental", "neoplasmsExperimental"],
  ["Neoplasms, Glandular and Epithelial", "neoplasmsGlandularandEpithelial"],
  ["Neovascularization, Pathologic", "neovascularizationPathologic"],
  ["Nerve Degeneration", "nerveDegeneration"],
  ["Neuroblastoma", "neuroblastoma"],
  ["Neurodegenerative Diseases", "neurodegenerativeDiseases"],
  ["Non-alcoholic Fatty Liver Disease", "nonalcoholicFattyLiverDisease"],
  ["Obesity", "obesity"],
  ["Osteoarthritis", "osteoarthritis"],
  ["Osteoarthritis, Knee", "osteoarthritisKnee"],
  ["Osteoporosis", "osteoporosis"],
  ["Osteosarcoma", "osteosarcoma"],
  ["Ovarian Neoplasms", "ovarianNeoplasms"],
  ["Overweight", "overweight"],
  ["Pancreatic Neoplasms", "pancreaticNeoplasms"],
  ["Papillomavirus Infections", "papillomavirusInfections"],
  ["Parkinson Disease", "parkinsonDisease"],
  ["Pituitary Neoplasms", "pituitaryNeoplasms"],
  ["Plaque, Atherosclerotic", "plaqueAtherosclerotic"],
  ["Polycystic Ovary Syndrome", "polycysticOvarySyndrome"],
  ["Postoperative Complications", "postoperativeComplications"],
  ["Pre-Eclampsia", "preEclampsia"],
  ["Precancerous Conditions", "precancerousConditions"],
  [
    "Precursor Cell Lymphoblastic Leukemia-Lymphoma",
    "precursorCellLymphoblasticLeukemiaLymphoma"
  ],
  ["Prostatic Hyperplasia", "prostaticHyperplasia"],
  ["Prostatic Neoplasms", "prostaticNeoplasms"],
  ["Psoriasis", "psoriasis"],
  [
    "Pulmonary Disease, Chronic Obstructive",
    "pulmonaryDiseaseChronicObstructive"
  ],
  ["Recurrence", "recurrence"],
  ["Renal Insufficiency, Chronic", "renalInsufficiencyChronic"],
  ["Retinitis Pigmentosa", "retinitisPigmentosa"],
  ["Sarcoma", "sarcoma"],
  ["Scleroderma, Systemic", "sclerodermaSystemic"],
  ["Seizures", "seizures"],
  ["Sepsis", "sepsis"],
  ["Skin Neoplasms", "skinNeoplasms"],
  ["Spondylitis, Ankylosing", "spondylitisAnkylosing"],
  [
    "Squamous Cell Carcinoma of Head and Neck",
    "squamousCellCarcinomaofHeadandNeck"
  ],
  ["Stomach Neoplasms", "stomachNeoplasms"],
  ["Stroke", "stroke"],
  ["Syndrome", "syndrome"],
  ["Thrombosis", "thrombosis"],
  ["Thyroid Cancer, Papillary", "thyroidCancerPapillary"],
  ["Thyroid Neoplasms", "thyroidNeoplasms"],
  ["Translocation, Genetic", "translocationGenetic"],
  ["Triple Negative Breast Neoplasms", "tripleNegativeBreastNeoplasms"],
  ["Tuberculosis", "tuberculosis"],
  ["Tuberculosis, Pulmonary", "tuberculosisPulmonary"],
  ["Urinary Bladder Neoplasms", "urinaryBladderNeoplasms"],
  ["Uterine Cervical Neoplasms", "uterineCervicalNeoplasms"],
  ["Uterine Neoplasms", "uterineNeoplasms"],
  ["Venous Thrombosis", "venousThrombosis"],
  ["Weight Loss", "weightLoss"]
];
