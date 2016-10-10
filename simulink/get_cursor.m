function [ output_args ] = get_cursor( fig )
%GET_CURSOR Summary of this function goes here
%   Detailed explanation goes here

dcm_obj = datacursormode(fig);
info_struct = getCursorInfo(dcm_obj);
disp('Cursor info:');
disp('  Position:');
disp(info_struct.DataIndex);
disp('  Data:');
disp(info_struct.Position);


end

