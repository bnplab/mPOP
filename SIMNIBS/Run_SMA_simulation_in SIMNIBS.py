from simnibs import sim_struct, run_simnibs
import os
import simnibs
from simnibs import sim_struct, localite
conds=['E1_XML','E2_XML','D_XML','R_XML']
Matfile=['./Localite/SMA_E1_Loca_AVG.mat','./Localite/SMA_E2_Loca_AVG.mat','./Localite/SMA_D_Loca_AVG.mat','./Localite/SMA_R_Loca_AVG.mat']
arrayname=['AllE1_Simnibs','AllE2_Simnibs','AllD_Simnibs','AllR_Simnibs']

import scipy.io
for idxx,condit in enumerate(conds):
    mat = scipy.io.loadmat(Matfile[idxx])
    print(condit)
    print(mat)
    condsadd='./Localite/'+condit+'/'
    directory = os.listdir(condsadd)
    directory.sort()
    print(directory)
    strindex1='TriggerMarkers_Coil1'

    for idx,subs in enumerate(directory):

        directory2 = os.listdir(condsadd+subs)
        print(subs)
        print(idx)
        # Initalize a session
        s = sim_struct.SESSION()
        tmslist = s.add_tmslist()
        s.subpath = './Nifti/'+subs[0:5].lower()+'/m2m_'+subs[0:5].lower()
        print(s.subpath)
        if len(subs[5:6])==0:
           s.pathfem = './Nifti/'+subs[0:5].lower()+'/SMA_AVG_'+condit
        else: 
           s.pathfem = './Nifti/'+subs[0:5].lower()+'/SMA_AVG_'+condit+subs[5:6]
        print(s.pathfem)
        s.map_to_surf=True
        s.map_to_fsavg = True
        s.map_to_MNI = True
        s.open_in_gmsh = False
        s.fields = 'eEjJ'
        tmslist.fnamecoil = os.path.join('Drakaki_BrainStim_2022','MagVenture_Cool-B35.ccd')
        pos = tmslist.add_position()
        pos.matsimnibs=mat[arrayname[idxx]][0][idx]
        print(arrayname[idxx])
        run_simnibs(s, cpus=15)




             

