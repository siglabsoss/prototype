
% run this to load our functions (there is a better way)
o_fifo

fifoObj = o_fifo_create();


fifoObj

disp(o_fifo_available(fifoObj));

o_fifo_add_one(fifoObj, 3);

fifoObj