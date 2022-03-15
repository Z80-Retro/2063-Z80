#!/bin/bash


V3_TAG=v3
V4_TAG=v4rc1
SCRATCH=/tmp/$$-2063

V3_TMP=${SCRATCH}/${V3_TAG}
V4_TMP=${SCRATCH}/${V4_TAG}

mkdir -p ${V3_TMP}
mkdir -p ${V4_TMP}

# if only want the gerbers directory:
#git --work-tree=${V3_TMP} checkout ${V3_TAG} -- gerbers
#git --work-tree=${V4_TMP} checkout ${V4_TAG} -- gerbers

git --work-tree=${V3_TMP} checkout ${V3_TAG}
git --work-tree=${V4_TMP} checkout ${V4_TAG}

# Generate a .pdf showing the diffs in the schematic drawings

compare ${V3_TMP}/2063-Z80.pdf ${V4_TMP}/2063-Z80.pdf ${SCRATCH}/2063-Z80-v3-v4-delta.pdf

# Generate .png files showing the diffs between the v3 and v4rc1 PCBs

gerbv --dpi=600 --border=0 --export=png --output=${SCRATCH}/${V3_TAG}.png ${V3_TMP}/gerbers/*.{gtl,gbl}
gerbv --dpi=600 --border=0 --export=png --output=${SCRATCH}/${V4_TAG}.png ${V4_TMP}/gerbers/*.{gtl,gbl}

compare ${SCRATCH}/${V3_TAG}.png ${SCRATCH}/${V4_TAG}.png ${SCRATCH}/2063-Z80-${V3_TAG}-${V4_TAG}-delta.png

git checkout main
cp ${SCRATCH}/*-delta.png ${SCRATCH}/*.pdf .


rm -rf ${SCRATCH}
