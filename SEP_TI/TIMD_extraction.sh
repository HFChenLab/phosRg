for i in 1 2 3 4 5 6 7 8 9
do 
  grep 'DV/DL  =' SEP_solv_prod_v0_l${i}.out > tmp_report_l${i}.dat
  grep 'PRESS =' SEP_solv_prod_v0_l${i}.out > base_report_l${i}.dat
  paste base_report_l${i}.dat tmp_report_l${i}.dat > report_l${i}.dat
  rm tmp_report_l${i}.dat
  rm base_report_l${i}.dat
done
