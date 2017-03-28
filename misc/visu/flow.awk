{
  wait  = int($3)
  run   = int($4)
  flow  = wait + run
  denom = (run <= 10) ? 10 : run
  ratio = flow / denom
  bsld  = (ratio <= 1) ? 1 : ratio

  if(max_wait=="")
  {max_wait=wait};
  if(wait>max_wait)
  {max_wait=wait};
  total_wait+=wait;

  if(max_bsld=="")
  {max_bsld=bsld};
  if(bsld>max_bsld)
  {max_bsld=bsld};
  total_bsld+=bsld;

  if(max_flow=="")
  {max_flow=flow};
  if(flow>max_flow)
  {max_flow=flow};
  total_flow+=flow;
}
  END {print total_wait/NR, max_wait, total_bsld/NR, max_bsld, total_flow/NR, max_flow}
