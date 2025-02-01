import math, sys
import os.path
import numpy as np
from math import sqrt

#to use the script, choose the right filename prefix
#################################################################################################################
## loops over "fn" of output files .
## fn = file number
## lambda is the name of a function in python!!!!don't use it as a variable. 
 
def read_report():

    lamb=[]
    dvdl = []
    err = []
    
    for i in range(1, 10):
        lamb.append(float(i)/10)

        dvdl_cur = []

        file_op = open('report_l'+str(i)+'.dat', 'r');

        lines  =  file_op.readlines();
        last_time = 1100
        for line in lines:
            linesplit = line.split() #split on white space
            time = float(linesplit[5])
            if time > last_time:
                
                dvdl_cur.append(float(linesplit[14]));
                last_time = time
        dvdl_cur = np.array(dvdl_cur)
        dvdl.append(np.mean(dvdl_cur))
        err.append(np.std(dvdl_cur))
        
        file_op.close();

    if ( lamb[0] != 0 ):
        ynew = (lamb[0]*dvdl[1]-lamb[1]*dvdl[0])/(lamb[0]-lamb[1]);

        lamb.insert(0, float(0));
        dvdl.insert(0, ynew);
        err.insert(0, err[0]);

    if  lamb[len(lamb)-1] != 1:
        i = len(lamb);
        ynew = ( dvdl[i-1]*(lamb[i-2]-1)+dvdl[i-2]*(1-lamb[i-1]) )/(lamb[i-2]-lamb[i-1]);
 
        lamb.append(float(1));
        dvdl.append(ynew);
        err.append(err[i-1]);

    i = len(lamb);
    # print(i);
    width = [];
    for j in range(0,i):
        if (i == 1 ):
            width.insert(j,1);
        elif (j == 0 ):
            width.insert(j,0.5 * (lamb[j] + lamb[j+1]));
        elif (j == i-1):
            width.insert(j,1-0.5*(lamb[j]+lamb[j-1]));
        else:
            width.insert(j,0.5*(lamb[j+1]-lamb[j-1]));

    return lamb,dvdl,err,width;
#################################################################################################################
def integration_dvdl( lamb,dvdl,err,width ):
    tot_dvdl = 0;
    tot_err = 0;
    i = len(lamb);
    for j in range(0,i):
        tot_dvdl += width[j]*dvdl[j];
        tot_err += width[j]*err[j];
    return tot_dvdl, tot_err;
    
######
def write_dvdl_prep( dvdl,rms_dvdl,filename):
    file = open(filename, 'w')
    length = len(dvdl);

    for i in range(length):
        file.write( "%5.3f%12.3f%9.3f" %(i/10.0,dvdl[i],rms_dvdl[i]) );
        file.write( "\n" );
    return;
#################################################################################################################
def main():

########integration for dvdl at different lambda values

    lamb,dvdl,err,width = read_report();

    tot_dvdl, tot_err = integration_dvdl(lamb,dvdl,err,width);
    print("Total DV/DL:" + str(tot_dvdl) + " +- " + str(tot_err));

#################################################################################################################
main()
