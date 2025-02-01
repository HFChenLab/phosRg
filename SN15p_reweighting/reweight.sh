system=$1 # the original directory's name [e.g. FB18CMAP_term_barostat]
# vdw=$2
# elec=$3 # electricity of P atom

wkdir=${system}_re_tip4pd
  
mkdir $wkdir
cd $wkdir
cp ../General/reweight/* .
cp ../General/sub_rerun.slurm .
cp ../${system}/SN15p.top .
mkdir OUTFILE
mkdir TRAJFILE

#source /dssg/home/acct-clschf/clschf/junximu/software/module_amber
source ~/tmp2019/software/module_amber

#for vdw in 1.6600 1.6800 1.7000 1.7200 1.7400 1.7600 1.7800 1.8000 1.8200 1.8400 1.8600 1.8800 1.9000 1.9200 1.9400
for vdw in 1.8401
do
#for elec in 1.200000 1.240000 1.280000 1.320000 1.360000 1.400000 1.440000 1.480000
#for elec in 1.200000 1.220000 1.240000 1.260000 1.280000 1.300000 1.320000 1.340000 1.360000 1.380000 1.400000 1.420000 1.440000 1.460000 1.480000
	for elec in 1.387088
	do
    # Initial set up
#cp ../General/FB18CMAP/* .
    cp ../General/ff99SBildn/* .
	cp ../General/reweight/tleap.in .
    cp ../${system}/SN15p_sim.pdb .
    
    sed -i "s/SN15p.top/SN15p_${vdw}_${elec}.top/g" tleap.in
    
    # Modify the force field parameters
#sed -i "373s/1.8401/${vdw}/g" frcmod.phosfb18 # VdW radius of terminal oxygen
	sed -i "78s/1.8401/${vdw}/g" frcmod.phosaa10 # VdW radius of terminal oxygen   
#sed -i "314s/1.387088/${elec}/g" phos_aminofb18.lib # partial charge of P atom in SEP
    sed -i "314s/1.387088/${elec}/g" phos_amino94.lib # partial charge of P atom in SEP
	elec_oxp=`echo | awk "{print (-1.561771-${elec})/3}"` # keeping the total charge of PO3 group
#sed -i "315,317s/-0.982953/${elec_oxp}/g" phos_aminofb18.lib # partial charge of three OXP atoms in SEP
	sed -i "315,317s/-0.982953/${elec_oxp}/g" phos_amino94.lib # partial charge of three OXP atoms in SEP   
    # generate the topology
#tleap -s -f tleap.in
    #correct box info
	box_ori=`grep -A 2 'BOX' SN15p.top | tail -1`
	box_new=`grep -A 2 'BOX' SN15p_${vdw}_${elec}.top | tail -1`
#sed -i  "s/${box_new}/${box_ori}/g" SN15p_${vdw}_${elec}.top
    # Add cmap parameters
#python ADD_CMAP.py -p SN15p_${vdw}_${elec}.top -c fb18cmap.para -o SN15p_${vdw}_${elec}_cmap.top -s
#mv SN15p_${vdw}_${elec}_cmap.top SN15p_${vdw}_${elec}.top
    
    # rerun the trajectory with new parameters
    echo "sander -O -i reweight.in -o OUTFILE/md_merged_re_${vdw}_${elec}.out -p SN15p_${vdw}_${elec}.top -c ../${system}/equ.ncrst -y ../md_merged_new.nc -x TRAJFILE/md_merged_re_${vdw}_${elec}.nc -inf md_1.info &" >> sub_rerun.slurm  # -y inptraj
  done
done

echo "wait" >> sub_rerun.slurm
