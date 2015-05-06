% Prevent Octave from thinkign that this is a function file:
1;



function [ fifoObj ] = o_fifo_create(  )





fifoSize = 12;
 
fifoData = zeros(fifoSize,1); % samples

% zero index position
fifoObj = struct('size',fifoSize,'data',fifoData,'head',0,'tail',0);




% fifoObj.data(1) = 40;
% fifo_add(fifoObj, [2 35 383 29 24 2 2 2 290]);




end



function [] = o_fifo_add(fifoObj, data)
  [~,sz] = size(data);
%   fifoObj.data(pos+1, = [fifoObj.data data];
end

function [] = o_fifo_add_one(fifoObj, data)
  sz = 1;
  next = mod((fifoObj.head + 1), fifoObj.size);
  if( next ~= fifoObj.tail )
      fifoObj.data(next+1) = data;
      fifoObj.head = next;
  end
end

function [available] = o_fifo_available(fifoObj)
    available = mod((fifoObj.size + fifoObj.head - fifoObj.tail), fifoObj.size);
end