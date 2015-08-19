k = message length
n = transmitted code worth length

==Some things this folder can do==

Make a parity check matrix H with n=800,k=80 :

H = ldpcgen(800, 80);


Make a generator matrix from H:

G = ldpcpar2gen(H);


Look at them with
spy(H);
spy(G);





== Actual working example ==

Start with H:

  H = [0 1 0 1 0 1 1 1 0 0 0 1;1 0 1 1 0 0 0 0 1 0 0 0;0 1 0 0 1 0 1 0 0 0 0 1;1 0 0 1 0 0 0 0 0 1 1 0;0 0 1 0 1 1 0 0 0 1 0 0;1 0 1 0 0 0 1 1 0 0 1 0;0 1 0 0 0 1 0 1 1 1 0 0;0 0 0 0 1 0 0 0 1 0 1 1];
  G = ldpcpar2gen(H);
 
H is a 8 by 12 matrix.  This means that 4 bits of cw.  Make a random user message (u) of 4 bits:

  u = (rand(1,4) - 0.5) > 0

Encode into a code word (v or cw or c) which we actually tansmit
  cw = ldpcencode( G, u );


Check that the transmission is ok:

ldpccheck(H,cw)







== Also ==

Make a parity check matrix from generator.  This is a standard form for H

H = gen2par(G);
