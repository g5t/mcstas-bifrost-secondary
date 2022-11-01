#!/bin/bash
# The extend block adds the time-of-flight from the real source to the sample position
# plus some estimate for the long-pulse width transmitted by the choppers.
# For BIFROST the source to sample distance is ~160 m.
# The ESS source has a maximum usable pulse width of ~3 microseconds, and BIFROST can pass them all in its coarsest setting
snippet="""
COMPONENT cassette_source_INDEX = Source_simple(
yheight = sampleSizeY, 
xwidth = sampleSizeX, 
E0 = middleEnergy, 
dE = deltaEnergy, 
flux = 1e9, 
dist = slitDistance, 
focus_xw = 1.01*slitSizeX, 
focus_yh = 2*tan(2 * DEG2RAD) * slitDistance
)
WHEN INDEX==cassette AT (0, 0, 0) RELATIVE Origin ROTATED (0, params_channel[INDEX]*RAD2DEG + slitAngle, 0) RELATIVE Origin
EXTEND
%{
  double v2 = vx*vx + vy*vy + vz*vz;
//  t += (160.0 / sqrt(v2)) + 1.5e-3 * randpm1(); 
  t += (160.0 / sqrt(v2));
%}
"""

outfile="Multi_Source.snippet"

echo "//Auto generated file, Edit Multi_Source.sh instead!" > $outfile
for i in {0..8}; do
  echo "${snippet//INDEX/"$i"}" >> $outfile
done

