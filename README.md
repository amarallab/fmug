# Find My Understudied Genes

This repository contains the code to generate the Find My Understudied Genes app for Windows, iOS and macOS platforms. Pre-compiled and installable versions of FMUG can be downloaded at [fmug.amaral.northwestern.edu](https://fmug.amaral.northwestern.edu/).

If you are looking for the code and data for the accompanying manuscript for FMUG, go to [github.com/amarallab/fmug_analysis](https://github.com/amarallab/fmug_analysis).

Find My Understudied Genes (**FMUG**) is a data-driven tool to helps biologists identify understudied genes and characterize their tractability for future research.

More information is available at [fmug.amaral.northwestern.edu](https://fmug.amaral.northwestern.edu/).


## Generate MySQL database

The `scripts` folder contains the `convert_csv_to_sqllite.py` script that generates the genes information MySQL database from the CSV files. To create it, 
update the database version (currently, 1.8) and run the following in a terminal:

    $ python scripts/convert_csv_to_sqlite.py --main data/main_table.csv --columns data/main_table_columns.csv --sqlite assets/db.sqlite --overwrite --dbversion x.x


## Generate the binary

To generate the binary using this code, please refer to the Flutter documentation at [flutter.dev](https://flutter.dev).


## Citing FMUG

If you use FMUG in your work, please cite our [paper in eLife](https://doi.org/10.7554/eLife.93429).

Reese Anthony Keith Richardson, Heliodoro Tejedor Navarro, Luis A. Nunes Amaral, Thomas Stoeger. Meta-Research: understudied genes are lost in a leaky pipeline between genome-wide assays and reporting of results *eLife* **12**:RP93429; doi: [10.7554/eLife.93429](https://doi.org/10.7554/eLife.93429)

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
