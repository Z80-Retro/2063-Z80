#!/bin/bash


A_TAG=v3
B_TAG=v4rc1a
SCRATCH=/tmp/$$-2063

A_TMP=${SCRATCH}/${A_TAG}
B_TMP=${SCRATCH}/${B_TAG}

mkdir -p ${A_TMP}
mkdir -p ${B_TMP}

git show ${A_TAG}:gerbers/2063-Z80-F_Cu.gtl > ${A_TMP}/2063-Z80-F_Cu.gtl
git show ${A_TAG}:gerbers/2063-Z80-B_Cu.gbl > ${A_TMP}/2063-Z80-B_Cu.gbl
git show ${A_TAG}:2063-Z80.pdf> ${A_TMP}/2063-Z80.pdf

git show ${B_TAG}:gerbers/2063-Z80-F_Cu.gtl > ${B_TMP}/2063-Z80-F_Cu.gtl
git show ${B_TAG}:gerbers/2063-Z80-B_Cu.gbl > ${B_TMP}/2063-Z80-B_Cu.gbl
git show ${B_TAG}:2063-Z80.pdf> ${B_TMP}/2063-Z80.pdf

# Generate a .pdf showing the diffs in the schematic drawings

compare ${A_TMP}/2063-Z80.pdf ${B_TMP}/2063-Z80.pdf 2063-Z80-${A_TAG}-${B_TAG}-delta.pdf

# Generate .png files showing the diffs between the v3 and v4rc1 PCBs

gerbv --dpi=600 --border=0 --export=png --output=${A_TMP}.png ${A_TMP}/*.{gtl,gbl}
gerbv --dpi=600 --border=0 --export=png --output=${B_TMP}.png ${B_TMP}/*.{gtl,gbl}

compare ${A_TMP}.png ${B_TMP}.png 2063-Z80-${A_TAG}-${B_TAG}-delta.png

rm -rf ${SCRATCH}
