#!/bin/bash
vdw=$1
elec=$2  #传参

dir=$(pwd)
dir_out=$dir/OUTFILE
dir_traj=$dir/TRAJFILE
k=1.380649E-23
T=298.15
beta=$(echo "scale=10; 1/($k*$T)" | bc)
change=43.3634
sum1=0
sum2=0

module load amber/2022-gcc-8.5.0-cuda

frame_num=$(grep -o 'ENERGY' $dir_out/md_merged_re_${vdw}_${elec}.out | wc -l)  #-o string
echo "$frame_num"
#temp_line=$(grep -n 'ENERGY' $dir_out/md_merged_re_1.7000_1.200000_1.out | head -n 1 | cut -d ':' -f1)  #-n line
#energy_new_all=$(grep -A 1 'ENERGY' $dir_out/md_merged_re_1.7000_1.200000_1.out | grep -v 'ENERGY' | awk '{print $2}')
#energy_all=$(grep -A 1 'ENERGY' $dir_out/md_merged_re_1.7000_1.220000_1.out | grep -v 'ENERGY' | awk '{print $2}')

if [ -f "md_${vdw}_${elec}_energy.txt" ]; then
	echo "File 'example.txt' exists."
#read -r -a energy_new_all < md_${vdw}_${elec}_energy.txt
	while IFS= read -r line; do
		energy_new_all+=("$line")
	done < "md_${vdw}_${elec}_energy.txt"
else
	echo "generate new start"
	energy_new_all=()
	while IFS= read -r line; do
		# 检查当前行是否包含"ENERGY"
		if [[ $line == *"ENERGY"* ]]; then
			# 获取下一行
			read -r next_line
			# 使用awk提取下一行的第二个字符并添加到数组中
			energy_value=$(awk '{print $2}' <<< "$next_line")
			energy_new_all+=("$energy_value")
		fi
	done < "$dir_out/md_merged_re_${vdw}_${elec}.out"
	printf "%s\n" "${energy_new_all[@]}" > md_${vdw}_${elec}_energy.txt
	echo "done"
fi

if [ -f "origin_energy.txt" ]; then
    echo "File 'example.txt' exists."
#read -r -a energy_all < origin_energy.txt
	while IFS= read -r line; do
		energy_all+=("$line")
	done < "origin_energy.txt"
else
	echo "generate ori start"
	energy_all=()
	while IFS= read -r line; do
		# 检查当前行是否包含"ENERGY"
		if [[ $line == *"ENERGY"* ]]; then
			# 获取下一行
			read -r next_line
			# 使用awk提取下一行的第二个字符并添加到数组中
			energy_value1=$(awk '{print $2}' <<< "$next_line")
			energy_all+=("$energy_value1")
		fi
#	done < "$dir_out/md_merged_re_origin.out"
		done < "$dir_out/md_merged_re_origin.out"
		printf "%s\n" "${energy_all[@]}" > origin_energy.txt
	echo "done"
fi
if [ -f "$dir_traj/Rg_${vdw}_${elec}.dat" ];then
	echo "rg.dat exists"
else
	cpptraj <<_EOF
parm $dir/SN15p_${vdw}_${elec}.top
trajin $dir_traj/md_merged_re_${vdw}_${elec}.nc
autoimage
strip :WAT:NA:CL:Na+:Cl-
radgyr out $dir_traj/Rg_${vdw}_${elec}.dat mass nomax
run
quit
_EOF
fi

python reweigh_rg.py ${vdw} ${elec} | tail -n 1 >> output_rg1.txt

