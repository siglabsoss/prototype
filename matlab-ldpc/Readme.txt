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



Make a parity check matrix from generator.  This is a standard form for H

H = gen2par(G);
