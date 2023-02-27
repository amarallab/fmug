# Find My Understudied Genes

This repository contains the code to generate the Find My Understudied Genes app for Windows, iOS and macOS platforms.

If you are looking for the code and data for the accompanying manuscript for FMUG, go to [github.com/amarallab/fmug_analysis](https://github.com/amarallab/fmug_analysis).

Find My Understudied Genes (**FMUG**) is a data-driven tool to helps biologists identify understudied genes and characterize their tractability for future research.

More information is available at [fmug.amaral.northwestern.edu](https://fmug.amaral.northwestern.edu/).


## Generate MySQL database

The `scripts` folder contains the `convert_csv_to_sqllite.py` script that generates the genes information MySQL database from the CSV files. To create it, 
update the database version (currently, 1.4) and run the following in a terminal:

    $ python scripts/convert_csv_to_sqlite.py --main data/main_table.csv --columns data/main_table_columns.csv --sqlite assets/db.sqlite --overwrite --dbversion x.x


## Generate the binary

To generate the binary using this code, please refer to the Flutter documentation at [flutter.dev](https://flutter.dev).
