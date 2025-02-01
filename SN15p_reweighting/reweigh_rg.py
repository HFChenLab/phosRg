#coding:utf-8
import numpy as np
import sys

vdw = sys.argv[1]
elec = sys.argv[2]

ene_ori = np.loadtxt('md_1.8401_1.387088_energy.txt')
ene_new = np.loadtxt('md_' + str(vdw) + '_' + str(elec) + '_energy.txt')

k = 0.0019865 # kcal/mol K
T = 298.15 # K
kT = k * T

rg_ori = np.loadtxt('TRAJFILE/Rg_' + str(vdw) + '_' + str(elec) + '.dat') # 不用每个参数下都保存一次所有构象的Rg，都是一样的
rg_ori = rg_ori[:, 1]

# print(ene_ori.shape)
# print(ene_new.shape)
# print(rg_ori.shape)

rg_new_avg = np.mean(rg_ori*np.exp(-1*(ene_new-ene_ori)/kT)) / np.mean(np.exp(-1*(ene_new-ene_ori)/kT))
print('Original Rg: %.3f' %np.mean(rg_ori))
#print(str(vdw) + ' ' str(elec) + 'Reweighted Rg: %.3f' %rg_new_avg)
print(str(vdw) + ' ' + str(elec) + ' Reweighted Rg: %.3f' % rg_new_avg)

