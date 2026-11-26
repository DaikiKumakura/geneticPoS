"""Export only the reference columns consumed by geneticPoS."""
from argparse import ArgumentParser
from pathlib import Path

import duckdb

parser = ArgumentParser(description=__doc__)
parser.add_argument("parquet_dir", type=Path)
parser.add_argument("output_dir", type=Path)
args = parser.parse_args()
out = args.output_dir
out.mkdir(parents=True, exist_ok=True)
db = duckdb.connect()
for name in ("evidence", "pos"):
    path = args.parquet_dir / f"karim_{name}.parquet"
    db.from_parquet(str(path)).create_view(name)

sources = {
    "benchmarks": "SELECT * FROM pos ORDER BY pos_id",
    "measured": """
        SELECT gene AS target_id, bool_and(measured_on_proteomic_platform) AS measured
        FROM evidence WHERE evidence_record_type = 'CLINICAL_MAPPING' AND gene IS NOT NULL
        GROUP BY gene HAVING count(DISTINCT measured_on_proteomic_platform) = 1
    """,
    "mapping": """
        SELECT gene AS target_id, indication_mesh_id AS indication_id, outcome_id,
          CASE WHEN count(DISTINCT l2g_share)=1 THEN min(l2g_share) END AS l2g_share,
          CASE WHEN count(DISTINCT mesh_similarity)=1 THEN min(mesh_similarity) END AS mesh_similarity
        FROM evidence WHERE evidence_record_type='CLINICAL_MAPPING'
          AND gene IS NOT NULL AND indication_mesh_id IS NOT NULL AND outcome_id IS NOT NULL
        GROUP BY gene, indication_mesh_id, outcome_id
    """,
}
for name, query in sources.items():
    db.execute(f"COPY ({query}) TO ? (FORMAT CSV, HEADER, DELIMITER '\t', COMPRESSION GZIP)",
               [str(out / f"{name}.tsv.gz")])
    print(name, db.execute(f"SELECT count(*) FROM ({query})").fetchone()[0])
