karim_ref <- local({
  cache <- new.env(parent = emptyenv())
  function(name) {
    if (!exists(name, cache, inherits = FALSE)) {
      path <- system.file("extdata", paste0(name, ".tsv.gz"), package = "geneticPoS",
                          mustWork = TRUE)
      data <- utils::read.delim(path, quote = '"', na.strings = "", encoding = "UTF-8")
      if (name == "mapping") data$key <- do.call(paste, c(data[1:3], sep = "\r"))
      if (name == "measured") data$measured <- tolower(data$measured) == "true"
      assign(name, data, cache)
    }
    get(name, cache, inherits = FALSE)
  }
})

resolve_karim <- function(mr) {
  fields <- c("l2g_share", "mesh_similarity", "measured")
  origins <- lapply(mr[fields], function(x) ifelse(is.na(x), "unavailable", "user"))
  keys <- c("target_id", "indication_id", "outcome_id")
  if (anyNA(mr$l2g_share) || anyNA(mr$mesh_similarity)) {
    ref <- karim_ref("mapping")
    i <- match(do.call(paste, c(mr[keys], sep = "\r")), ref$key)
    exact <- Reduce(`&`, lapply(keys, function(k) mr[[k]] == ref[[k]][i]))
    i[which(is.na(exact) | !exact)] <- NA_integer_
    for (field in fields[1:2]) {
      use <- which(is.na(mr[[field]]) & !is.na(ref[[field]][i]))
      mr[[field]][use] <- ref[[field]][i[use]]
      origins[[field]][use] <- "karim_mapping"
    }
  }
  if (anyNA(mr$measured)) {
    ref <- karim_ref("measured")
    values <- ref$measured[match(mr$target_id, ref$target_id)]
    use <- which(is.na(mr$measured) & !is.na(values))
    mr$measured[use] <- values[use]
    origins$measured[use] <- "karim_measured"
  }
  for (field in fields) mr[[paste0(field, "_source")]] <- origins[[field]]
  mr
}

karim_pos <- function(mr, coloc, mapping = list(), metadata = list(), links = NULL) {
  keys <- c("exposure_id", "outcome_id", "build", "locus_id")
  aliases <- list(exposure_id = "id.exposure", outcome_id = "id.outcome")
  mr <- native_table(mr, mapping$mr, metadata$mr, "mr_id",
                     c(aliases, list(mr_p = c("pval", "bxy_pval", "Pval", "P value"),
                                     target_id = c("gene", "hgnc_protein", "Protein"))),
                     c(keys, "target_id", "indication_id"), "mr_p", "MR")
  coloc <- native_table(coloc, mapping$coloc, metadata$coloc, "coloc_id",
                        c(aliases, list(h4 = c("PP.H4", "PP.H4.abf", "coloc_h4", "PPH4"))),
                        keys, "h4", "coloc")
  key_check(mr, "mr_id")
  key_check(coloc, "coloc_id")
  linked <- pair_indices(links, mr, coloc)
  if (!is.numeric(mr$mr_p) || !is.numeric(coloc$h4))
    stop("mr_p and h4 must be numeric.")
  defaults <- list(l2g_share = NA_real_, mesh_similarity = NA_real_,
                   measured = NA, coloc_id = NA_character_)
  for (key in setdiff(names(defaults), names(mr))) {
    mr[[key]] <- rep(defaults[[key]], nrow(mr))
  }
  if (!is.numeric(mr$l2g_share) || !is.numeric(mr$mesh_similarity) ||
      !is.logical(mr$measured)) stop("Use numeric L2G/MeSH and logical measured.")
  original_mr <- mr
  mr <- resolve_karim(mr)
  if ("signal_id" %in% names(mr) || "signal_id" %in% names(coloc)) {
    if (!all(c("signal_id" %in% names(mr), "signal_id" %in% names(coloc))))
      stop("Supply signal_id in both tables or neither.")
    keys <- c(keys, "signal_id")
  }
  all_references <- karim_ref("benchmarks")
  # The candidate rule refers specifically to the published v2 Figure 1a contrast.
  chosen <- all_references[which(all_references$source_figure == "Figure 1a (published v2)" &
                                  all_references$source_label == "MR+coloc"), ]
  stopifnot(nrow(chosen) == 1L)
  reference <- data.frame(
    reference_id = "karim2026_v2_fig1a_mr_coloc",
    group = c("supported", "comparison"),
    phase1_n = c(chosen$supported_start_n, chosen$unsupported_start_n),
    launched_n = c(chosen$supported_success_n, chosen$unsupported_success_n),
    relative_success = chosen$relative_success, rs_lower = chosen$rs_ci_lower,
    rs_upper = chosen$rs_ci_upper, pos_id = chosen$pos_id,
    source = "https://www.medrxiv.org/content/10.64898/2026.02.23.26346731v2.full",
    stringsAsFactors = FALSE
  )
  reference$historical_launch_rate <- reference$launched_n / reference$phase1_n
  present <- function(x) !is.na(x) & nzchar(trimws(as.character(x)))
  valid <- function(x) is.finite(x) & x >= 0 & x <= 1
  candidates <- mr
  candidates$matched_coloc_id <- rep(NA_character_, nrow(mr))
  candidates$h4 <- rep(NA_real_, nrow(mr))
  candidates$status <- rep("missing_inputs", nrow(mr))
  candidates$missing_fields <- rep("", nrow(mr))
  candidates$match_basis <- rep(NA_character_, nrow(mr))
  candidates$reference_group <- rep(NA_character_, nrow(mr))
  for (i in seq_len(nrow(mr))) {
    fields <- c("target_id", "indication_id",
                if (is.na(linked[i])) keys else "outcome_id")
    absent <- fields[!present(unlist(mr[i, fields]))]
    if ("qtl_type" %in% names(mr) && present(mr$qtl_type[i]) &&
        tolower(mr$qtl_type[i]) != "pqtl") {
      candidates$status[i] <- "outside_pqtl_reference"
      candidates$missing_fields[i] <- paste(absent, collapse = ", ")
      next
    }
    if (!is.na(linked[i])) {
      j <- linked[i]
      conflict <- vapply(keys, function(k) {
        a <- mr[[k]][i]; b <- coloc[[k]][j]
        present(a) && present(b) && a != b
      }, logical(1))
      if (any(conflict) || (present(mr$coloc_id[i]) && mr$coloc_id[i] != coloc$coloc_id[j])) {
        candidates$status[i] <- "link_conflict"
        next
      }
      candidates$match_basis[i] <- "user_confirmed"
    } else {
      if (length(absent)) {
        candidates$missing_fields[i] <- paste(absent, collapse = ", ")
        next
      }
      matched <- Reduce(`&`, lapply(keys, function(key)
        present(coloc[[key]]) & coloc[[key]] == mr[[key]][i]))
      if (present(mr$coloc_id[i])) matched <- matched & coloc$coloc_id == mr$coloc_id[i]
      j <- which(matched)
      if (length(j) == 1L) candidates$match_basis[i] <- "exact_identifiers"
    }
    if (length(j) != 1L) {
      candidates$status[i] <- if (length(j)) "coloc_ambiguous" else "coloc_unmatched"
      next
    }
    candidates$matched_coloc_id[i] <- coloc$coloc_id[j]
    candidates$h4[i] <- coloc$h4[j]
    if ("qtl_type" %in% names(coloc) && present(coloc$qtl_type[j]) &&
        tolower(coloc$qtl_type[j]) != "pqtl") {
      candidates$status[i] <- "outside_pqtl_reference"
      next
    }
    if (length(absent)) {
      candidates$missing_fields[i] <- paste(absent, collapse = ", ")
      next
    }
    if (identical(mr$measured[i], FALSE)) {
      candidates$status[i] <- "outside_measured_background"
      next
    }
    values <- c(mr$mr_p[i], coloc$h4[j], mr$l2g_share[i], mr$mesh_similarity[i])
    if (any(!is.na(values) & !valid(values))) {
      candidates$status[i] <- "invalid_input"
      next
    }
    missing <- is.na(c(values, mr$measured[i]))
    if (any(missing)) {
      candidates$missing_fields[i] <- paste(c("mr_p", "h4", "l2g_share",
                                               "mesh_similarity", "measured")[missing], collapse = ", ")
      next
    }
    supported <- all(values <= c(0.05 / 47e6, 1, 1, 1)) &&
      all(values[-1L] >= c(0.8, 0.5, 0.8))
    candidates$status[i] <- if (supported) "thresholds_met" else "thresholds_not_met"
    # A single row cannot establish absence of support across a pair's other analyses.
    if (supported) candidates$reference_group[i] <- "supported"
  }
  candidates$reference_id <- ifelse(is.na(candidates$reference_group), NA_character_,
                                    reference$reference_id[1L])
  candidates$historical_launch_rate <- reference$historical_launch_rate[
    match(candidates$reference_group, reference$group)]
  list(candidates = candidates, benchmark = reference, references = all_references,
       inputs = list(mr = original_mr, coloc = coloc, links = links))
}
