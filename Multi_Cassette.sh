#!/bin/bash
per_cassette="""
COMPONENT CassetteArm@C = Arm()
WHEN @C==cassette AT (0, 0, 0) RELATIVE Origin ROTATED (0, params_channel[@C]*RAD2DEG, 0) RELATIVE Origin

COMPONENT CassettePSD@C = PSD_monitor(nx=140, ny=90, filename=\"CassettePSD@C.dat\", restore_neutron=1,
                                     yheight=params_analyzer[@C][0][2],
                                     xwidth=params_analyzer[@C][0][2])
WHEN @C==cassette AT (0, 0, 0.95*params_distances[@C][0][0]) RELATIVE CassetteArm@C

COMPONENT CassetteEmon@C = E_monitor(nE=100, filename=\"CassetteEmon@C.dat\", restore_neutron=1,
                                     xwidth=params_analyzer[@C][0][2], yheight=params_analyzer[@C][0][2],
                                     Emin=middleEnergy-deltaEnergy, Emax=middleEnergy+deltaEnergy)
WHEN @C==cassette AT (0, 0, 0.96*params_distances[@C][0][0]) RELATIVE CassetteArm@C

// CASSETTE @C
"""

per_pair="""
COMPONENT AnaPoint@C@A = Arm() WHEN noBS && @C==cassette AT (0,0,params_distances[@C][@A][0]) RELATIVE CassetteArm@C

COMPONENT AnaArm@C@A = Arm() WHEN noBS && @C==cassette AT (0, 0, 0) RELATIVE PREVIOUS ROTATED (0, 0, 90) RELATIVE PREVIOUS

COMPONENT Analyzer@C@A = Monochromator_Rowland(
  NH = params_analyzer[@C][@A][0],
  zwidth = params_analyzer[@C][@A][1],
  yheight = params_analyzer[@C][@A][2],
  mosaic = Mos, DM = 3.335, NV = 1, gap=0.002,
  show_construction=construction, focush=focus_type, RH=focus_radius,
  angle_h=params_analyzer[@C][@A][5] * RAD2DEG,
  source=\"Origin\", sink=\"DetPoint@C@A\"
)
WHEN noBS && @C==cassette AT (0, 0, 0) RELATIVE PREVIOUS ROTATED (0, -0.5*params_two_theta[@C][@A]*RAD2DEG, 0) RELATIVE PREVIOUS
EXTEND %{
noBS = (SCATTERED) ? 0 : 1;
analyzer = (SCATTERED) ? @A : -1;
%}

COMPONENT AnalyzerEmon@C@A = E_monitor(nE=100, filename=\"AnalyzerEmon@C@A.dat\", restore_neutron=1,
                                     xwidth=params_analyzer[@C][@A][2], yheight=params_analyzer[@C][@A][2],
                                     Emin=middleEnergy-deltaEnergy, Emax=middleEnergy+deltaEnergy)
WHEN noBS && @C==cassette AT (0, 0, 1.1*params_distances[@C][@A][0]) RELATIVE CassetteArm@C

// ============================ SCATTERING ANGLE REORIENTATION ======================  
COMPONENT DetAngle@C@A = Arm() WHEN @C==cassette && @A==analyzer AT (0, 0, 0) RELATIVE AnaPoint@C@A ROTATED (0, -params_two_theta[@C][@A]*RAD2DEG, 0) RELATIVE AnaArm@C@A
// =================================== DETECTOR ==================================== 
COMPONENT DetPoint@C@A = Arm() WHEN @C==cassette && @A==analyzer AT (0, 0, params_distances[@C][@A][1]) RELATIVE DetAngle@C@A
COMPONENT PSD@C@A = PSD_monitor(nx=140, ny=90, filename=\"PSD@C@A.dat\", restore_neutron=1,
                              xwidth=2.1*params_detector[@C][@A][1][1][1],
                              yheight=2.1*params_detector[@C][@A][1][1][1]
) WHEN @C==cassette && @A==analyzer AT (0, 0, 0) RELATIVE DetPoint@C@A


// Cassette @C Analyzer @A Triplet Detectors & Event recorders

COMPONENT Triplet@C@A = Detector_triplet(filename=\"triplet@C@A.dat\", charge_a=charge_a_name, charge_b=charge_b_name, detection_time=detection_time_name,
  radius = detdiam / 2,
  x0 = params_detector[@C][@A][0][0], e0 = params_detector[@C][@A][0][1],
  x1 = params_detector[@C][@A][1][0], e1 = params_detector[@C][@A][1][1],
  x2 = params_detector[@C][@A][2][0], e2 = params_detector[@C][@A][2][1])
WHEN @C==cassette && @A==analyzer AT (0, 0, 0) RELATIVE DetPoint@C@A
EXTEND
%{
  flag = (SCATTERED) ? 1 : 0;
%}
COMPONENT Events@C@A = Monitor_nD(xwidth=2.1*params_detector[@C][@A][1][1][1], yheight=2.1*params_detector[@C][@A][1][1][1],
  user1=charge_a_name, username1=\"A\", user2=charge_b_name, username2=\"B\", user3=detection_time_name, username3=\"T\", options=nd_options)
WHEN 1==flag && @C==cassette && @A==analyzer AT (0, 0, params_detector[@C][@A][1][1][1]) RELATIVE PREVIOUS
"""


outfile="Multi_Cassette.snippet"

echo "//Auto generated file, Edit Multi_Cassette.sh instead!" > $outfile
#for c in {0..8}; do
for c in 1; do
  echo "${per_cassette//@C/"$c"}" >> $outfile
  this_cassette="${per_pair//@C/"$c"}"
#  for a in {0..4}; do
  for a in 0; do
    echo "${this_cassette//@A/"$a"}" >> $outfile
  done
done

