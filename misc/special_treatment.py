#!/usr/bin/python3

import sys
from shutil import copyfile

if "CEA-Curie-2011-2.1-cln.swf" in sys.argv[1]:
  copyfile(sys.argv[1],sys.argv[2])
elif "CTC-SP2-1996-3.1-cln.swf" in sys.argv[1]:
# keep the last part of the file
  copyfile(sys.argv[1],sys.argv[2])
elif "KTH-SP2-1996-2.1-cln.swf" in sys.argv[1]:
  copyfile(sys.argv[1],sys.argv[2])
elif "Sandia-Ross-2001-1.1-cln.swf" in sys.argv[1]:
  # keep the last part of the file
  # we keep only the part that seems to have 960procs (30 cabinet of 32 procs)
  #it starts around 28500000
  import pandas as pd

  df = pd.read_csv(sys.argv[1], sep=" ", skipinitialspace=True, comment=";", header=None, names=['job_id','submit_time','wait_time','run_time','proc_alloc','cpu_time_used','mem_used','proc_req','time_req','mem_req','status','user_id','group_id','exec_id','queue_id','partition_id','previous_job_id','think_time'])

  df = df[df.submit_time >= 28500000]
  print("Deleted jobs that are bigger than the machine:", len( df[df.proc_req > 960]))
  df = df[df.proc_req <= 960]

  f = open(sys.argv[2], 'w')

  f.write(';Version: SWF v2\n')
  f.write(';MaxNodes: 960\n')
  f.write('; MaxProcs: 960\n')
  f.write(';Note: This is a cutted version of '+str(sys.argv[1])+' (cutted at 28500000)\n')
  df.to_csv(f, sep=" ", header=None, index=False)
  f.close()

elif "SDSC-BLUE-2000-4.2-cln.swf" in sys.argv[1]:
  copyfile(sys.argv[1],sys.argv[2])
elif "SDSC-SP2-1998-4.2-cln.swf" in sys.argv[1]:
  copyfile(sys.argv[1],sys.argv[2])
else:
  print(sys.argv[1],sys.argv[2])
  # copyfile(sys.argv[1],sys.argv[2])
