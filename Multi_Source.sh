#!/bin/bash
snippet="""
COMPONENT cassette_source_INDEX = Source_simple(yheight = sampleSizeY, xwidth = sampleSizeX, E0 = middleEnergy, dE = deltaEnergy,
                                            dist = focusdistance, focus_xw = slitSizeX, focus_yh = 2*tan(2 * DEG2RAD) * focusdistance)
WHEN INDEX==cassette AT (0, 0, 0) RELATIVE Origin ROTATED (0, params_channel[INDEX]*RAD2DEG + slitAngle, 0) RELATIVE Origin
"""

outfile="Multi_Source.snippet"

echo "//Auto generated file, Edit Multi_Source.sh instead!" > $outfile
for i in {0..8}; do
  echo "${snippet//INDEX/"$i"}" >> $outfile
done

