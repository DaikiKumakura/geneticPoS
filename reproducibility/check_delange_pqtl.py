"""Extract source coefficients and the matching Minikel locus from public files."""
import csv
import gzip
import math
from pathlib import Path

from openpyxl import load_workbook

data = Path(__file__).parent / "data"
book = load_workbook(data / "zheng_s3.xlsx", read_only=True, data_only=True)
rows = book["TableS1.Instruments"].values
next(rows)
next(rows)
header = next(rows)
exposure, = [
    dict(zip(header, row)) for row in rows
    if (row[0], row[10], row[11], row[20]) == ("IL23R", "Sun", "rs11581607", "cis")
]
book.close()
marker = f"{exposure['CHR_SNP']}:{exposure['POS_SNP']}_G_A"
with gzip.open(data / "delange_cd_GCST004132.txt.gz", "rt") as source:
    outcome = next(row for row in csv.DictReader(source, delimiter="\t")
                   if row["MarkerName"] == marker)
assert (outcome["Allele1"].upper(), outcome["Allele2"].upper()) == (
    exposure["Effect_allele"], exposure["Other_allele"])
with gzip.open(data / "minikel_assoc.tsv.gz", "rt") as source:
    locus, = [row for row in csv.DictReader(source, delimiter="\t")
              if (row["gene"], row["mesh_id"], row["source"], row["pval"]) ==
              ("IL23R", "D003424", "OTG", outcome["P.value"])
              and row["original_link"].endswith("/GCST004132")]
assert abs(abs(math.log(float(locus["odds_ratio"]))) - abs(float(outcome["Effect"]))) < .0001

record = {
    "assay": exposure["Platform_id"], "variant": exposure["SNP"], "marker": marker,
    "beta_x": exposure["Beta"], "se_x": exposure["SE"], "beta_y": outcome["Effect"],
    "se_y": outcome["StdErr"], "gwas_p": outcome["P.value"],
    "minikel_arow": locus["arow"], "l2g_share": locus["l2g_share"],
}
with (data / "delange_il23r_source.csv").open("w", newline="") as output:
    writer = csv.DictWriter(output, fieldnames=record)
    writer.writeheader()
    writer.writerow(record)
