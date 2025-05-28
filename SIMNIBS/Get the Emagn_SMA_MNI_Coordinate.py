from simnibs import sim_struct, run_simnibs
import os
from simnibs import sim_struct, localite
import numpy as np
import simnibs
from scipy.spatial import cKDTree
import nibabel as nib
import pandas as pd
conds=['E1_XML','SMA_AVG_E2_XML','SMA_AVG_E2_XML_','SMA_AVG_R_XML']
condlable=['SMA_AVG','','','','']
condsf=['E1_XML','E2_XML','D_XML','R_XML']
condsflab=['E1','E2','D','R']
import scipy.io
R_intensity=[98 ,   70 ,   77 ,   70  ,  98  ,  98   , 81  ,  85 ,   88 ,   68,    84 ,   84 ,   62 ,   91,    70]
D_intensity=[91,    67,    91 ,   74 ,   98 ,   91,    84 ,   87,    84,    77,    63,    70 ,   84,    82,    63 ,   80 ,   72,    70,    84]
E1_intensit=[96,91,98,80,84,84,60,81,67,80]
E2_intensit=[95,70,88,75,98,95,89,84,84,66,71]
all_intensit=[E1_intensit,E2_intensit,D_intensity,R_intensity]
for idxx,condit in enumerate(condsf):
   condsadd='./Localite/'
   directory = os.listdir(condsadd+condit)
   directory.sort()
   print(directory)

   fields_save=[]
   fieldsmax = []
   fieldsmin = []
   for idx,subs in enumerate(directory):

    
    field_name = 'E_magn'
    field_name1 = 'magnE'
   
    # read mesh with results transformed to fsaverage space
    if  len(subs[5:6])==0:
        results_fsavg = simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+'/', 'fsavg_overlays/',
        subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_fsavg.msh')
     )  
        results_fsavg2 = simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+'/', 'subject_overlays/',
        subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_central.msh')
     )

        head_mesh=simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+'/fsavg_overlays/',subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_fsavg.msh')
    )
        head_mesh2=simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+ '/subject_overlays/',subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_central.msh')
    )
        output_dir = './region_outputs/'+condsflab[idxx]+'/'
        print(output_dir)
    else: 
       results_fsavg = simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+'_/', 'fsavg_overlays/',
        subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_fsavg.msh')      
     )  
       results_fsavg2 = simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+'_/','subject_overlays',
        subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_central.msh')
     )
       head_mesh=simnibs.read_msh(
    os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+'_/fsavg_overlays/',subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_fsavg.msh')
     )
       head_mesh2=simnibs.read_msh(
   os.path.join('./Nifti/'+ subs[0:5].lower()+'/SMA_AVG_'+condit+ '_/subject_overlays/',subs[0:5].lower()+'_TMS_1-0001_MagVenture_Cool-B35_scalar_central.msh')
     )
       output_dir = './region_outputs/'+condsflab[idxx]+'/'
       print(output_dir)
       print(condit)
   
    results=results_fsavg2
    head=head_mesh2

    fields=results.field[field_name].value

    # Calculate average in an ROI defined using an atlas
    # load atlas and define a region
    atlas = simnibs.subject_atlas('HCP_MMP1','./Nifti/'+subs[0:5].lower()+'/m2m_'+subs[0:5].lower()) #convert to the subjects space for difference atlas 
    #atlas = simnibs.get_atlas('HCP_MMP1')
    region_name = 'lh.6ma'
    region_name2='lh.6mp'
    roi1 = atlas[region_name]
    roi2 = atlas[region_name2]
    roi = np.logical_or(roi1, roi2)
 

    coords=head.nodes.node_coord
    roi_coords=coords[roi]
    coords_MNI = simnibs.subject2mni_coords(roi_coords, './Nifti/'+subs[0:5].lower()+'/m2m_'+subs[0:5].lower())
   #  print(coords) subject2mni_coords
   # print(roi_coords)
    node_areas = results.nodes_areas()
   
   # Extract corresponding e_magn
    e_magn = head.field['E_magn'][roi]

   # Combine and save
   # output_dir = 'region_outputs/'+condsflab[idxx]+'/'+subs[0:5].lower()+'/'
    os.makedirs(output_dir, exist_ok=True)
    output = np.column_stack((coords_MNI, e_magn*(0.96*all_intensit[idxx][idx]-2.87)))
    if  len(subs[5:6])==0:
     output_file = os.path.join(output_dir, f'{region_name,region_name2}_MNIcoords_emagn_{subs[0:5].lower()}.txt')
    else: 
     output_file = os.path.join(output_dir,  f'{region_name,region_name2}_MNIcoords_emagn_{subs[0:5].lower()}_.txt')
    np.savetxt(output_file, output, header='x, y, z, e_magn', fmt='%.4f', delimiter=',')
    print(f'  ✅ Saved: {output_file} ({output.shape[0]} points)')
   # calculate mean field using a weighted mean
    node_areas = results.nodes_areas()
   #print(fields[roi])
   #print(node_areas[roi])
    avg_field_roi = np.average(fields[roi], weights=node_areas[roi])
    max_field_roi = np.max(fields[roi])
    min_field_roi = np.min(fields[roi])
    max_field = np.max(fields)
    mean_magnE = np.average(fields)
    print(f'Average {field_name} in {region_name}: ', avg_field_roi)
    print(f'Max {field_name} in {region_name}: ', max_field_roi)
    print(f'min {field_name} in {region_name}: ',min_field_roi)
    print(f'Max {field_name} in all region: ', max_field)
    fields_save.append([avg_field_roi,max_field_roi,min_field_roi,max_field,mean_magnE])
    print(fields_save)

   scipy.io.savemat(condit+'_SIMNIBS.mat',  {condsflab[idxx]: fields_save})