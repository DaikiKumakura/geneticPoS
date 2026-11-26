# Keep source identifiers and use explicit, reusable mappings for foreign tables.
read_table <- function(x, mapping, required, label) {
  if (is.character(x) && length(x) == 1L) {
    sep <- if (grepl("\\.csv$", x, ignore.case = TRUE)) "," else "\t"
    x <- utils::read.table(x, header = TRUE, sep = sep, quote = '"',
                           comment.char = "", check.names = FALSE)
  }
  if (!is.data.frame(x) || anyDuplicated(names(x))) stop("Invalid ", label, " table.")
  if (length(mapping)) {
    if (is.null(names(mapping)) || any(!mapping %in% names(x)))
      stop("Invalid column mapping for ", label, ".")
    for (key in names(mapping)) x[[key]] <- x[[mapping[[key]]]]
  }
  missing <- setdiff(required, names(x))
  if (length(missing)) stop(label, " missing: ", paste(missing, collapse = ", "))
  x
}

pair_indices <- function(links, mr, coloc) {
  if (is.null(links)) return(rep(NA_integer_, nrow(mr)))
  links <- read_table(links, NULL, c("mr_id", "coloc_id", "basis"), "links")
  key_check(links, "mr_id")
  if (!is.character(links$basis) || anyNA(links$basis) ||
      any(!nzchar(trimws(links$basis)))) stop("Each link requires a documented basis.")
  if (any(!links$mr_id %in% mr$mr_id) || any(!links$coloc_id %in% coloc$coloc_id))
    stop("links contains an unknown MR or coloc ID.")
  match(links$coloc_id[match(mr$mr_id, links$mr_id)], coloc$coloc_id)
}

key_check <- function(x, id) {
  value <- x[[id]]
  if (!is.character(value) || anyNA(value) || any(!nzchar(trimws(value))) ||
      anyDuplicated(value)) stop("Expected a unique nonempty character key: ", id)
}

native_table <- function(x, mapping, metadata, id, aliases, keys, value, label) {
  x <- read_table(x, mapping, character(), label)
  for (field in setdiff(names(aliases), names(x))) {
    candidates <- intersect(aliases[[field]], names(x))
    if (length(candidates) == 1L) x[[field]] <- x[[candidates]]
  }
  rows <- seq_len(nrow(x))
  if (!"source_row" %in% names(x)) x$source_row <- rows
  allowed <- c(keys, id, "target_id", "indication_id", "signal_id", "qtl_type",
               "coloc_id", "l2g_share", "mesh_similarity", "measured")
  if (!is.null(metadata)) {
    if (!is.list(metadata) || is.null(names(metadata)) || anyDuplicated(names(metadata)))
      stop(label, " metadata requires named fields.")
    if (is.data.frame(metadata)) {
      row <- metadata$source_row
      if (!is.numeric(row) || anyNA(row) || anyDuplicated(row) ||
          any(!row %in% rows)) stop(label, " metadata has invalid source_row.")
      index <- match(rows, row)
    } else {
      if (any(lengths(metadata) != 1L)) stop(label, " metadata constants must be scalar.")
      index <- rep(1L, nrow(x))
    }
    for (field in setdiff(names(metadata), "source_row")) {
      if (!field %in% allowed) stop("Unsupported metadata field: ", field)
      supplied <- metadata[[field]][index]
      if (!field %in% names(x)) x[[field]] <- supplied
      else {
        if (any(x[[field]] != supplied, na.rm = TRUE)) stop(label, " metadata conflicts: ", field)
        missing <- is.na(x[[field]])
        x[[field]][missing] <- supplied[missing]
      }
    }
  }
  if (!id %in% names(x)) x[[id]] <- paste0(label, ":", rows)[rows]
  for (field in setdiff(keys, names(x))) x[[field]] <- rep(NA_character_, nrow(x))
  if (!value %in% names(x)) stop(label, " requires ", value, " or a column mapping.")
  x
}
