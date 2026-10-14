#!/usr/bin/env bash
# Télécharge les données du fil rouge dans data/raw :
#   - un mois de courses Yellow Taxi (Parquet)
#   - le référentiel des 265 zones (CSV) et leurs contours (shapefile)
#   - la météo horaire de New York sur le même mois (Open-Meteo, CSV)
#
# Usage :  bash scripts/telecharger_donnees.sh            (mois par défaut : 2025-01)
#          bash scripts/telecharger_donnees.sh 2025-02
# Sources : https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
#           https://open-meteo.com/
set -euo pipefail

cd "$(dirname "$0")/.."
MOIS="${1:-2025-02}"
TLC="https://d37ci6vzurychx.cloudfront.net"
mkdir -p data/raw

echo "→ Courses Yellow Taxi ${MOIS}"
curl -fL -o "data/raw/yellow_tripdata_${MOIS}.parquet" "${TLC}/trip-data/yellow_tripdata_${MOIS}.parquet"

echo "→ Référentiel des zones"
curl -fL -o data/raw/taxi_zone_lookup.csv "${TLC}/misc/taxi_zone_lookup.csv"

echo "→ Contours des zones (shapefile)"
curl -fL -o data/raw/taxi_zones.zip "${TLC}/misc/taxi_zones.zip"

echo "→ Météo horaire de New York (${MOIS})"
DEBUT="${MOIS}-01"
FIN=$(python3 -c "import calendar,sys; a,m=map(int,'${MOIS}'.split('-')); print(f'{a}-{m:02d}-{calendar.monthrange(a,m)[1]}')")
curl -fL -o "data/raw/meteo_nyc_${MOIS}.csv" \
  "https://archive-api.open-meteo.com/v1/archive?latitude=40.71&longitude=-74.01&start_date=${DEBUT}&end_date=${FIN}&hourly=temperature_2m,precipitation&timezone=America%2FNew_York&format=csv"

echo
echo "Terminé :"
ls -lh data/raw
