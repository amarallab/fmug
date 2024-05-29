import argparse
import pathlib
import sqlite3
import csv
import sys

from stringcase import camelcase
	
source_types = {
    "gene_ncbi": int,
    "gene_ensembl": str,
    "taxon_ncbi": int,
    "symbol_ncbi": str,
    "locustag": str,
    "synonyms": None,
    "dbxrefs": None,
    "chromosome": str,
    "map_location": str,
    "description": str,
    "type_of_gene": str,  #TypeOfGene
    "symbol_from_nomenclature_authority": str,
    "full_name_from_nomenclature_authority": str,
    "nomenclature_status": str,
    "other_designations": str,
    "modification_date": str,  #date?
    "feature_type": str,
    "p_de": float,
    "n_pubs": int,
    "defined_hugo": bool,
    "n_synonyms": int,
    "n_mouse_pheno": int,
    "mouse_pheno": bool,
    "n_gwas": int,
    "detectable_portion": float,
    "tissue_median": float,
    "hela_expression": float,
    "mendelian_inheritance": bool,
    "mouse": bool,
    "rat": bool,
    "c_elegans": bool,
    "d_melanogaster": bool,
    "yeast": bool,
    "zebrafish": bool,
    "primate_specific": bool,
    "n_mouse_pubs": int,
    "n_rat_pubs": int,
    "n_c_elegans_pubs": int,
    "n_d_melanogaster_pubs": int,
    "n_zebrafish_pubs": int,
    "n_yeast_pubs": int,
    "nextprot_evidence": bool,
    "hpa_evidence": bool,
    "uniprot_evidence": bool,
    "membrane_protein": bool,
    "antibody": bool,
    "approved_ih": bool,
    "approved_if": bool,
    "idg_understudied": bool,
    "plasmid": bool,
    "compound": bool,
    "n_biocarta": int,
    "n_reactome": int,
    "n_hpo": int,
    "n_wikipathways": int,
    "n_pid": int,
    "n_kegg": int,
    "n_go": int,
    "protein_coding": bool,
    "gene_length": int,
    "loss_of_function_intolerant": bool,
    "previously_patented": bool,
    "normalized_gravy": float,
    "druggable": bool,
    "n_pubs_gene2pubmed":int,
    "evolution_constrained":bool,
    "uncharacterized":bool,
    "n_pdb_entries":int

    # "global_rna_rank": float,
    # "de": bool,
    # "de_mentioned": bool,
    # "log_n_pubs": float,
    # "color_code": str
}


PRIMARY = "gene_ncbi"
CAN_BE_NONE = {
    "n_c_elegans_pubs",
    "n_d_melanogaster_pubs",
    "n_zebrafish_pubs",
    "n_yeast_pubs",
    "normalized_gravy",
    "p_de",
    "detectable_portion",
    "tissue_median",
    "hela_expression",
    "n_mouse_pubs",
    "n_rat_pubs",
    "loss_of_function_intolerant",
    "gene_length",
    "evolution_constrained"
}
MULTIVALUES = {"synonyms", "dbxrefs"}


def convert_name(name):
    NONVALID = set(", -")
    if NONVALID & set(name):
        result = name
        for current in NONVALID:
            result = result.replace(current, "")
        return camelcase(result)
    return camelcase(name)


def convert_to_int(s):
    v = int(float(s))
    ss = float(v)
    if float(s) != ss:
        raise ValueError(f"The value {s} is not an int")
    return v


def main(main_csv_file, columns_csv_file, database, print_flutter_pairs, overwrite, dbversion):
    if database.exists() and not overwrite:
        return

    database.unlink(missing_ok=True)
    conn = sqlite3.connect(database)

    with columns_csv_file as f:
        reader = csv.reader(f, delimiter=",", quotechar="\"")
        headers = next(reader)

        create_table_sql = """
            CREATE TABLE filter_columns (
                columnName TEXT PRIMARY KEY,
                commonName TEXT NOT NULL,
                dtype TEXT NOT NULL,
                display TEXT NOT NULL,
                addBeforeLogTransform REAL,
                factorClass TEXT NOT NULL,
                trueText TEXT,
                falseText TEXT,
                defaultValue INT,
                tooltipText TEXT
            )
            """
        conn.execute(create_table_sql)

        for line in reader:
            params = [x for x in line]
            # if len(params) == 10:
            #     params += [None]
            column_name, enabled, common_name, dtype, display, is_filter_factor, add_before_log_transform, factor_class, true_text, false_text, default_value, tooltip_text = params
            if is_filter_factor != "TRUE" or enabled == "FALSE":
                continue
            default_value = 1 if default_value == "TRUE" else 0
            column_name = convert_name(column_name)
            values = (column_name, common_name, dtype, display, add_before_log_transform or 0, factor_class or "", true_text or "", false_text or "", default_value, tooltip_text)
            insert_sql = f"""
                INSERT INTO filter_columns (columnName, commonName, dtype, display, addBeforeLogTransform, factorClass, trueText, falseText, defaultValue, tooltipText) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
            conn.execute(insert_sql, values)    
    with main_csv_file as f:
        reader = csv.reader(f, delimiter=",", quotechar="\"")
        
        headers = next(reader)
        create_table_fields_values = []
        flutter_genes_columns = []
        relations = {}
        for header in headers:
            field_name = convert_name(header)
            type_ = source_types.get(header, int)
            relations[header] = (field_name, type_)

            if header in MULTIVALUES:
                continue

            if type_ is bool: type_str = "INTEGER"
            elif type_ is int: type_str = "INTEGER"
            elif type_ is str: type_str = "TEXT"
            elif type_ is float: type_str = "REAL"
            else: raise ValueError(f"Cannot use type {type_}")

            field_sql_values = [f"{field_name} {type_str}"]
            if header == PRIMARY:
                field_sql_values.append("PRIMARY KEY")
            elif header not in CAN_BE_NONE:
                field_sql_values.append("NOT NULL")
            field_sql = " ".join(field_sql_values)
            create_table_fields_values.append(field_sql)
            flutter_pair = ",".join([f"\"{header}\"", f"\"{field_name}\""])
            flutter_genes_columns.append(f"[{flutter_pair}]")

        create_table_fields = ", ".join(create_table_fields_values)
        create_table_sql = f"CREATE TABLE genes ({create_table_fields})"
        conn.execute(create_table_sql)
        inside_flutter_array = ", ".join(flutter_genes_columns)
        if print_flutter_pairs:
            print(f"[{inside_flutter_array}]")
        
        create_table_sql = """
            CREATE TABLE gene_names (
                geneNcbi INTEGER PRIMARY KEY,
                geneEnsembl	TEXT NOT NULL,
                description TEXT NOT NULL,
                FOREIGN KEY(geneNcbi) REFERENCES genes(geneNcbi)
            )
            """
        conn.execute(create_table_sql)

        create_table_sql = """
            CREATE TABLE genes_synonyms (
                geneNcbi INTEGER NOT NULL, 
                name TEXT NOT NULL,
                PRIMARY KEY(geneNcbi, name),
                FOREIGN KEY(geneNcbi) REFERENCES genes(geneNcbi)
            )
            """
        conn.execute(create_table_sql)

        create_table_sql = """
            CREATE TABLE dbxs (
                dbx TEXT PRIMARY KEY
            )
            """
        conn.execute(create_table_sql)

        dbxs_insert_sql = """
            INSERT INTO dbxs(dbx) VALUES
                ("MIM"), 
                ("Ensembl"),
                ("miRBase"),
                ("IMGT/GENE-DB"),
                ("HGNC"),
                ("AllianceGenome")
            """
        conn.execute(dbxs_insert_sql)

        create_table_sql = """
            CREATE TABLE genes_dbxrefs (
                geneNcbi INTEGER NOT NULL,
                dbx TEXT NOT NULL,
                ref TEXT NOT NULL,
                PRIMARY KEY(geneNcbi, dbx, ref),
                FOREIGN KEY(geneNcbi) REFERENCES genes(geneNcbi),
                FOREIGN KEY(dbx) REFERENCES dbxs(dbx)
            )
            """
        conn.execute(create_table_sql)

        for line in reader:
            saving_columns = ["gene_ncbi", "gene_ensembl", "description"]
            saving_values = {}
            synonyms = []
            dbxrefs = []
            columns = []
            values = []
            for header, value in zip(headers, line):
                if header == "synonyms":
                    for synonym in value.split("|"):
                        synonyms.append(synonym)
                    continue

                if header == "dbxrefs":
                    for dbxref in value.split("|"):
                        i = dbxref.index(":")
                        dbx = dbxref[0:i]
                        value = dbxref[i+1:]
                        dbxrefs.append((dbx, value))
                    continue

                column, type_ = relations[header]
                columns.append(column)

                #print(f"I dont know so {header}{column}{type_}")
                if header in CAN_BE_NONE:
                    if len(value) == 0:
                        values.append("NULL")
                        continue
                elif len(value) == 0:
                    raise ValueError(f"{header=} must be None")
                if type_ is bool: values.append(value)
                elif type_ is int: values.append(str(convert_to_int(value)))
                elif type_ is float: values.append(str(float(value)))
                elif type_ is str: values.append(f'"{value}"')

                # Save for later usage
                if header in saving_columns:
                    saving_values[header] = value

            insert_sql = f"""
                INSERT INTO genes ({", ".join(columns)}) VALUES ({", ".join(values)})
                """
            conn.execute(insert_sql)

            geneNcbi = saving_values["gene_ncbi"]
            geneEnsembl = saving_values["gene_ensembl"]
            description = saving_values["description"]

            insert_values = []
            for synonym in synonyms:
                insert_values.append(f'({geneNcbi}, "{synonym}")')    
            insert_sql = f"""INSERT INTO genes_synonyms (geneNcbi, name) VALUES {", ".join(insert_values)}"""
            conn.execute(insert_sql)

            insert_sql = f"""INSERT INTO gene_names (geneNcbi, geneEnsembl, description) VALUES ({geneNcbi}, "{geneEnsembl}", "{description}")"""
            conn.execute(insert_sql)

            insert_values = []
            for dbxref in dbxrefs:
                dbx, ref = dbxref
                insert_values.append(f'({geneNcbi}, "{dbx}", "{ref}")')
            insert_sql = f"""INSERT INTO genes_dbxrefs (geneNcbi, dbx, ref) VALUES {", ".join(insert_values)}"""
            conn.execute(insert_sql)
    
    create_view_sql = """
        CREATE VIEW genes_filtering_view AS
        SELECT DISTINCT g.geneNcbi, g.geneEnsembl, g.description, data.value, data.source
        FROM (
            SELECT g.geneNcbi, g.symbolFromNomenclatureAuthority AS value, 'symbolFromNomenclatureAuthority' AS source
            FROM genes g
            UNION
            SELECT g.geneNcbi, gs.name AS value, 'synonyms' AS source
            FROM genes_synonyms gs INNER JOIN genes g ON gs.geneNcbi = g.geneNcbi
            UNION
            SELECT g.geneNcbi, gd.ref AS value, 'dbxrefs' AS source
            FROM genes_dbxrefs gd INNER JOIN genes g ON gd.geneNcbi = g.geneNcbi
        ) data
        INNER JOIN genes g ON (data.geneNcbi = g.geneNcbi)
        ORDER BY g.geneNcbi
        """
    conn.execute(create_view_sql)

    create_table_sql = """
        CREATE TABLE genes_filtering_table AS 
        SELECT * 
        FROM genes_filtering_view
    """
    conn.execute(create_table_sql)

    create_index_sql = """
        CREATE INDEX genes_filtering_table_index ON genes_filtering_table(value) 
    """
    conn.execute(create_index_sql)

    create_selected_genes_sql = """
        CREATE TABLE selected_genes (
            geneNcbi INT NOT NULL PRIMARY KEY
        )
         """
    conn.execute(create_selected_genes_sql)

    create_version_sql = """
        CREATE TABLE version_table (
            value TEXT NOT NULL
        )
    """
    conn.execute(create_version_sql)

    version_insert_sql = """
        INSERT INTO version_table(value) VALUES
            (?)
        """
    conn.execute(version_insert_sql, [dbversion])

    conn.commit()
    conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert gene main table from CSV format to SQLite database")
    parser.add_argument("--main", type=argparse.FileType("r"), help="gene main table in CSV format", required=True)
    parser.add_argument("--columns", type=argparse.FileType("r"), help="gene main table columsn in CSV format", required=True)
    parser.add_argument("--sqlite", type=pathlib.Path, help="SQLite database destination", required=True)
    parser.add_argument("--print-flutter-pairs", help="prints on console the gene column pairs to use in Flutter", action="store_true", default=False)
    parser.add_argument("--overwrite", help="overwrite the SQLlite database file if exists", action="store_true", default=False)
    parser.add_argument("--dbversion", help="Version of the database", required=True)
    args = parser.parse_args()

    main(args.main, args.columns, args.sqlite, args.print_flutter_pairs, args.overwrite, args.dbversion)
