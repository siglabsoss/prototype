function [ dout ] = brute_cfo( din )

c1 = din(1:1024);
c2 = din(1024+1:1024+1024);
c3 = din(1024+1024+1:1024+1024+1024);


xcr2 = xcorr(c1,c2);
[r1, r2] = max(abs(xcr2));

a1 = angle(xcr2(1024))


xcr3 = xcorr(c1,c3);

a2 = angle(xcr3(1024))



end