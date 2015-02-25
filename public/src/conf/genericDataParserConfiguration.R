getFormatSettings <- function() {
  formatSettings <- list(rawOnly = list(
    "Custom Example" = list(
      annotationType = "",
      hideAllData = FALSE,
      extraHeaders = data.frame(),
      sigFigs = 3,
      stateGroups = list(list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "treatment",
                              valueKinds = c("Dose"),
                              includesOthers = FALSE,
                              includesCorpName = TRUE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "raw data",
                              valueKinds = c("Weight", "Force", "Favorite Color", "Mouse Name"),
                              includesOthers = TRUE,
                              includesCorpName = FALSE))
    ),
    "Example2" = list(
      annotationType = "s_general",
      hideAllData = FALSE,
      extraHeaders = data.frame(),
      sigFigs = 3,
      curveNames = c("first curve id", "second curve id", "third curve id"),
      stateGroups = list(list(entityKind = "analysis group",
                              stateType = "data",
                              stateKind = "calculated data",
                              valueKinds = c("PO - Bioavailability", "IV - C0", "PO - Cmax", "IV - HL_Lambda_z", 
                                             "PO - HL_Lambda_z", "PO - Tmax", 
                                             "IV - AUClast", "PO - AUClast", "IV - AUCINF_obs", "PO - AUCINF_obs",
                                             "IV - MRTlast", "PO - MRTlast", "IV - Cl_obs", "PO - Cl_obs",
                                             "IV - Vss_obs", "PO - Vss_obs"),
                              includesOthers = FALSE,
                              includesCorpName = TRUE),
                         list(entityKind = "container",
                              stateType = "metadata", 
                              stateKind = "animal information", 
                              valueKinds = c("Gender", "Species"),
                              includesOthers = FALSE,
                              includesCorpName = FALSE),
                         list(entityKind = "container",
                              labelType = "name",
                              labelKind = "container name",
                              labelText = "Animal",
                              valueKinds = c("Animal"),
                              includesOthers = FALSE,
                              includesCorpName = FALSE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "treatment",
                              valueKinds = c("Formulation", "IV - Route", "PO - Route", "Dose", "IV - food_effect", "PO - food_effect"),
                              includesOthers = FALSE,
                              includesCorpName = TRUE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "raw data",
                              valueKinds = c("PO - Bioavailability", "IV - C0", "PO - Cmax", "IV - HL_Lambda_z", 
                                             "PO - HL_Lambda_z", "IV - Tmax", "PO - Tmax", 
                                             "IV - AUClast", "PO - AUClast", "IV - AUCINF_obs", "PO - AUCINF_obs",
                                             "IV - MRTlast", "PO - MRTlast", "IV - Cl_obs", "PO - Cl_obs",
                                             "IV - Vss_obs", "PO - Vss_obs"),
                              includesOthers = TRUE,
                              includesCorpName = FALSE))
    ), 
    doseResponseRender = list(
      "Ki Fit" = list(
        doseResponseKinds = list(
          "Fitted Min", "SST", "Rendering Hint", "rSquared", "SSE", "Ki",
          "curve id", "fitSummaryClob", "Ligand Conc", "Kd", "Fitted Ki",
          "parameterStdErrorsClob", "fitSettings", "flag", "Min", "Fitted Max", 
          "curveErrorsClob", "category", "Max", "reportedValuesClob", "IC50"
        )
      )
    )
  ))
  return(formatSettings)
} 