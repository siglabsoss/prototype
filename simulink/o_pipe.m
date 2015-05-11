fn=tempname
sleep(0.5);
[ERR, MSG] = mkfifo(fn, base2dec("744",8))
stat(fn)

fid = fopen(fn, "a+");
fcntl(fid, F_SETFL, O_NONBLOCK);

wrcount = fwrite(fid, uint8([1 2 3 4]), 'uint8');
disp("wrote");
disp(wrcount);

[val, rdcount] = fread(fid, 5, 'uint8');
disp("got back");
disp(rdcount);
disp(val);

fclose(fid);
