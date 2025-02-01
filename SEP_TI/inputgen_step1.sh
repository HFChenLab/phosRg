#!/bin/bash
wd=`pwd`
pre0='SEP_solv'
pre1='SEP_solv'
mask0=
mask1=':SEP'

for X in 1 2 3 4 5 6 7 8 9

do

cat << EOF > group_min_l${X}
-O -i mdin_min_v0_l${X} -o ${pre0}_min_v0_l${X}.out -p ../${pre0}.top -c ../${pre0}.crd -r ${pre0}_min_v0_l${X}.rst
-O -i mdin_min_v1_l${X} -o ${pre1}_min_v1_l${X}.out -p ../${pre1}.top -c ../${pre1}.crd -r ${pre1}_min_v1_l${X}.rst
EOF
cat << EOF > group_heat_l${X}
-O -i mdin_heat_v0_l${X} -o ${pre0}_heat_v0_l${X}.out -p ../${pre0}.top -c ${pre0}_min_v0_l${X}.rst -r ${pre0}_heat_v0_l${X}.rst
-O -i mdin_heat_v1_l${X} -o ${pre1}_heat_v1_l${X}.out -p ../${pre1}.top -c ${pre1}_min_v1_l${X}.rst -r ${pre1}_heat_v1_l${X}.rst
EOF
cat << EOF > group_equi_l${X}
-O -i mdin_equi_v0_l${X} -o ${pre0}_equi_v0_l${X}.out -p ../${pre0}.top -c ${pre0}_heat_v0_l${X}.rst -r ${pre0}_equi_v0_l${X}.rst
-O -i mdin_equi_v1_l${X} -o ${pre1}_equi_v1_l${X}.out -p ../${pre1}.top -c ${pre1}_heat_v1_l${X}.rst -r ${pre1}_equi_v1_l${X}.rst
EOF
cat << EOF > group_prod_l${X}
-O -i mdin_prod_v0_l${X} -o ${pre0}_prod_v0_l${X}.out -p ../${pre0}.top -c ${pre0}_equi_v0_l${X}.rst -r ${pre0}_prod_v0_l${X}.rst -x ${pre0}_prod_v0_l${X}.crd
-O -i mdin_prod_v1_l${X} -o ${pre1}_prod_v1_l${X}.out -p ../${pre1}.top -c ${pre1}_equi_v1_l${X}.rst -r ${pre1}_prod_v1_l${X}.rst -x ${pre1}_prod_v1_l${X}.crd
EOF

cat << EOF > mdin_min_v0_l${X}
density minlibration
 &cntrl
  imin = 1,	ntx = 1,
  maxcyc=500, ntmin=2,
  ntpr = 100,
  ntf = 2,      ntc = 2,
  ntb = 1,	cut = 9.0,
  icfe=1,	clambda = 0.${X},
EOF

cp mdin_min_v0_l${X} mdin_min_v1_l${X}

cat << EOF >> mdin_min_v0_l${X}
  ifsc=0,
  crgmask='${mask0}',
 &end
EOF
cat << EOF >> mdin_min_v1_l${X}
  ifsc=0,
  crgmask='${mask1}',
 &end
EOF

cat << EOF > mdin_heat_v0_l${X}
density equilibration
 &cntrl
  imin = 0,	ntx = 1,	irest = 0,
  ntpr = 2500,	ntwr = 10000,	ntwx = 0,
  ntf = 2,      ntc = 2,
  ntb = 1,	cut = 9.0,
  nstlim = 25000,	dt = 0.002,
  temp0 = 300.0,	ntt = 3,	gamma_ln = 2,
  ntp = 0,
  icfe=1,	clambda = 0.${X},
EOF

cp mdin_heat_v0_l${X} mdin_heat_v1_l${X}

cat << EOF >> mdin_heat_v0_l${X}
  ifsc=0,
  crgmask='${mask0}',
 &end
EOF
cat << EOF >> mdin_heat_v1_l${X}
  ifsc=0,
  crgmask='${mask1}',
 &end
EOF

cat << EOF > mdin_equi_v0_l${X}
density equilibration
 &cntrl
  imin = 0,	ntx = 5,	irest = 1,
  ntpr = 2500,	ntwr = 10000,	ntwx = 0,
  ntf = 2,      ntc = 2,
  ntb = 2,	cut = 9.0,
  nstlim = 25000,	dt = 0.002,
  temp0 = 300.0, ntt = 3,	gamma_ln = 2,
  ntp = 1,	pres0 = 1.0,	taup = 2.0,
  icfe=1,	clambda = 0.${X},
EOF

cp mdin_equi_v0_l${X} mdin_equi_v1_l${X}

cat << EOF >> mdin_equi_v0_l${X}
  ifsc=0,
  crgmask='${mask0}',
 &end
EOF
cat << EOF >> mdin_equi_v1_l${X}
  ifsc=0,
  crgmask='${mask1}',
 &end
EOF

cat << EOF > mdin_prod_v0_l${X}
NPT production
 &cntrl
  imin = 0,	ntx = 5,	irest = 1,
  ntpr = 5000,	ntwr = 10000,	ntwx = 10000,
  ntf = 2,	ntc = 2,
  ntb = 2,	cut = 9.0,
  nstlim = 2500000,	dt = 0.002,
  temp0 = 300.0,	ntt = 3,	gamma_ln = 2,
  ntp = 1,	pres0 = 1.0,	taup = 2.0,
  icfe=1,       clambda = 0.${X},
EOF

cp mdin_prod_v0_l${X} mdin_prod_v1_l${X}

cat << EOF >> mdin_prod_v0_l${X}
  ifsc=0,
  crgmask='${mask0}',
 &end
EOF
cat << EOF >> mdin_prod_v1_l${X}
  ifsc=0,
  crgmask='${mask1}',
 &end
EOF

done
