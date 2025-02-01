compound=$1
vdw=$2
elec=$3
#rad_P=$2
#epsilon_P=$3 # electricity of P atom

new_dir=SEP_tip4pd
mkdir ${new_dir}
#new_dir=SEP_P_3
# Initial set up
wkdir=${new_dir}/TI_${compound}_${vdw}_${elec}
#wkdir=${new_dir}/TI_${compound}_${rad_P}_${epsilon_P}
rm -rf $wkdir
mkdir $wkdir
cp General/ff99SBildn/* $wkdir
cp General/*.sh $wkdir
cp General/*.py $wkdir
#cp /lustre/home/acct-clschf/clschf/Songge/SN15p/ff99SB_reweight_re1/force_file/* $wkdir
cd $wkdir
    
sed -i "s/XXX/${compound}/g" tleap.in
sed -i "s/XXX/${compound}/g" tleap_gas.in

# Modify the force field parameters
sed -i "78s/1.8401/${vdw}/g" frcmod.phosaa10 # VdW radius of terminal oxygen
#sed -i "78s/0.2100/${elec}/g" frcmod.phosaa10 修改O_epsilon
if [ "$compound" == "SEP" ];then
sed -i "314s/1.387088/${elec}/g" phos_amino94.lib # partial charge of P atom in SEP
elec_oxp=`echo | awk "{print (-1.561771-${elec})/3}"` # keeping the total charge of PO3 group
sed -i "315,317s/-0.982953/${elec_oxp}/g" phos_amino94.lib # partial charge of three OXP atoms in SEP
#	sed -i "702s/2.1000/${rad_P}/g" parm99.dat
#	sed -i "702s/0.2000/${epsilon_P}/g" parm99.dat
#	sed -i "95s/0.0000/${rad_H}/" frcmod.phosaa10
#	sed -i "95s/0.0000/${epsilon_H}/" frcmod.phosaa10
fi
    
# generate the topology
source ~/tmp2019/software/module_amber
tleap -s -f tleap.in
tleap -s -f tleap_gas.in
    
# Free energy Perturbation MD simulation for steps 1-3
for i in 3 2 1
do
  mkdir step_${i}
  mv inputgen_step${i}.sh step_${i}
  cp TIMD_extraction.sh step_${i}
  cp integration.py step_${i}
  
  cd step_${i}
  
  # Modify input files
  sed -i "3,6s/XXX/${compound}/g" inputgen_step${i}.sh
  sed -i "s/XXX/${compound}/g" TIMD_extraction.sh
  if [[ $i -gt 2 ]];then
    sed -i "s/yyyy/gas/g" TIMD_extraction.sh
  else
    sed -i "s/yyyy/solv/g" TIMD_extraction.sh
  fi
  
  # Run simulation
  if [[ $i -eq 1 ]];then
    bash inputgen_step1.sh
    for X in 1 2 3 4 5 6 7 8 9
    do
      mpirun -n 40 sander.MPI -O -ng 2 -groupfile group_min_l${X}
      mpirun -n 40 sander.MPI -O -ng 2 -groupfile group_heat_l${X}  
      mpirun -n 40 sander.MPI -O -ng 2 -groupfile group_equi_l${X}  
      mpirun -n 40 sander.MPI -O -ng 2 -groupfile group_prod_l${X}
    done
    
    bash TIMD_extraction.sh
    python integration.py | tail -1 >> result
  
  elif [[ $i -eq 2 ]];then
    bash inputgen_step2.sh
    pre0="${compound}_solv"
    pre1="${compound}_solv"
    for X in 1 2 3 4 5 6 7 8 9
    do
      mpirun -np 40 pmemd.MPI -O -i mdin_min_v0_l${X} -o ${pre0}_min_v0_l${X}.out -p ../${pre0}.top -c ../${pre0}.crd -r ${pre0}_min_v0_l${X}.rst
      mpirun -np 40 pmemd.MPI -O -i mdin_heat_v0_l${X} -o ${pre0}_heat_v0_l${X}.out -p ../${pre0}.top -c ${pre0}_min_v0_l${X}.rst -r ${pre0}_heat_v0_l${X}.rst
      mpirun -np 40 pmemd.MPI -O -i mdin_equi_v0_l${X} -o ${pre0}_equi_v0_l${X}.out -p ../${pre0}.top -c ${pre0}_heat_v0_l${X}.rst -r ${pre0}_equi_v0_l${X}.rst
      mpirun -np 40 pmemd.MPI -O -i mdin_prod_v0_l${X} -o ${pre0}_prod_v0_l${X}.out -x ${pre0}_prod.nc -p ../${pre0}.top -c ${pre0}_equi_v0_l${X}.rst -r ${pre0}_prod_v0_l${X}.rst -x ${pre0}_prod_v0_l${X}.crd
    done
    
    bash TIMD_extraction.sh
    python integration.py | tail -1 >> result
  
  else
    bash inputgen_step3.sh
    for X in 1 2 3 4 5 6 7 8 9
    do
      mpirun -n 2 sander.MPI -O -ng 2 -groupfile group_min_l${X}
      mpirun -n 2 sander.MPI -O -ng 2 -groupfile group_heat_l${X}
      mpirun -n 2 sander.MPI -O -ng 2 -groupfile group_equi_l${X}
      mpirun -n 2 sander.MPI -O -ng 2 -groupfile group_prod_l${X}
    done
    bash TIMD_extraction.sh
    python integration.py | tail -1 >> result
  fi
  cd ..
done
