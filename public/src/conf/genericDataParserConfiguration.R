getFormatSettings <- function() {
  formatSettings <- list(
    "DNS In Vivo Behavior" = list(
      stateGroups = list(list(entityKind = "subject",
                              stateType = "metadata", 
                              stateKind = "animal information", 
                              valueKinds = c("Animal ID"),
                              includesOthers = FALSE,
                              includesCorpName = FALSE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "treatment",
                              valueKinds = c("Condition", "Dose", "Vehicle", "Administration route","Treatment Time"),
                              includesOthers = FALSE,
                              includesCorpName = TRUE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "raw data",
                              includesOthers = TRUE,
                              includesCorpName = FALSE),
                         list(entityKind = "container",
                              stateType = "metadata",
                              stateKind = "animal information",
                              valueKinds = c("Species","Strain","Sex","Vendor","Date of Arrival", "Date of Birth", "Animal ID"),
                              includesOthers = FALSE,
                              includesCorpName = FALSE))
    ), "In Vivo Full PK" = list(
      stateGroups = list(list(entityKind = "subject",
                              stateType = "metadata", 
                              stateKind = "animal information", 
                              valueKinds = c("Animal"),
                              includesOthers = FALSE,
                              includesCorpName = FALSE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "treatment",
                              valueKinds = c("Formulation", "Route", "Dose", "food_effect"),
                              includesOthers = FALSE,
                              includesCorpName = TRUE),
                         list(entityKind = "subject",
                              stateType = "data",
                              stateKind = "raw data",
                              includesOthers = TRUE,
                              includesCorpName = FALSE),
                         list(entityKind = "container",
                              stateType = "metadata",
                              stateKind = "animal information",
                              valueKinds = c("Gender", "Animal"),
                              includesOthers = FALSE,
                              includesCorpName = FALSE))
    )
  )
  return(formatSettings)
} 