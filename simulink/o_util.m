1;


function [fid] = grcdata_save_with_padding(filename, data)
    l = size(data);
    a(37500:87500) = data;
    a(125000) = 0;
    fid = grcdata_save(filename, a');
end

function [fid] = grcdata_save(filename, data)
    a = complex_to_raw(data);
    fid = fopen(filename, "a+");
    fwrite(fid, a, 'uint8');
    fclose(fid);
end

function [floats] = raw_to_float(raw)
    [~,sz] = size(raw);
    
    floats = [];

    for i = [1:8:sz]
        f1 = typecast(uint8(raw(i:i+3)),'single');
        f2 = typecast(uint8(raw(i+4:i+7)),'single');
        floats = [floats;f1;f2];
    end
end

function [floats] = raw_to_complex(raw)

    
    list = typecast(uint8(raw),'single');

    [~,sz] = size(list);
    
    floats = complex(list(1:2:sz),list(2:2:sz)).'; % zomg uze .'
    
end

function [floats] = hex32_to_complex(raw)

    [a b] = size(raw);

    disp(sprintf('dimms %d %d\n\n', a,b));

    floats = [];

    for i = [1:9:b]
        iimag = hex2dec(cellstr(raw(i:i+3)));
        rreal = hex2dec(cellstr(raw(i+4:i+7)));

        if( rreal > 0x7fff )
            rreal = (0x10000 - rreal)*-1;
        end

        if( iimag > 0x7fff )
            iimag = (0x10000 - iimag)*-1;
        end

        % disp(sprintf('imag %d', hex2dec(cellstr(raw(i:i+3)))  ));
        % disp(sprintf('real %d', hex2dec(cellstr(raw(i+4:i+7)))  ));
        % disp(sprintf('rdout %c', raw(i)  ));
        % disp(sprintf('rdout %c', raw(i+1)  ));
        % disp(sprintf('rdout %c', raw(i+2)  ));
        % disp(sprintf('rdout %c', raw(i+3)  ));
        % disp(sprintf('rdout %c', raw(i+4)  ));
        % disp(sprintf('rdout %c', raw(i+5)  ));
        % disp(sprintf('rdout %c', raw(i+6)  ));
        % disp(sprintf('rdout %c', raw(i+7)  ));
        % disp(sprintf('end'   ));

        floats = [floats rreal+1j*iimag];
    end

 
    %list = typecast(uint8(raw),'single');

    %[~,sz] = size(list);
    
    %floats = complex(list(1:2:sz),list(2:2:sz)).'; % zomg uze .'
    % floats = [0]
end

function [raw] = complex_to_raw(floats)

    sing = single([floats;1+1i]);

    % conj(x)*1i is the same as swapping real and imaginary
    % conj(sing)*1i
    list = typecast(sing,'uint8');
    
    raw = list(1:end-8);
end

function [floats] = rawfile_to_complex(filename)
    fid = fopen(filename, 'r');
    if (fid == -1 )
        disp('File does not exist or something else wrong');
        return
    end

    [rawdata, rdcount] = fread(fid, inf, 'uint8');
    fclose(fid);
    disp(sprintf('read %d bytes', rdcount));

    floats = hex_to_complex(rawdata.');
end

function [floats] = hex32file_to_complex(filename)
    fid = fopen(filename, 'r');
    if (fid == -1 )
        disp('File does not exist or something else wrong');
        return
    end
    [rawdata, rdcount] = fread(fid, inf, 'uint8');
    fclose(fid);
    disp(sprintf('read %d bytes', rdcount));

    floats = hex32_to_complex(rawdata.');
end


function [] = complex_to_rawfile(filename, data)
    fid = fopen(filename, 'w');
    bytes = complex_to_raw(data);
    [sz,~] = size(bytes);
    disp(sprintf("Writing %d bytes to file", sz));
    fwrite(fid, bytes, 'uint8');
    fclose(fid);
end

function [ retro_out ] = replace_zero_ones(retro_single )
    [sz,~] = size(retro_single);
    dataStart = 0;
    dataEnd = 0;

%     Scan for the first non 0/0 signal
    for i = [1:sz]
        if( retro_single(i) ~= 0 )
            dataStart = i;
            break;
        end
    end

    % for now we assume signal is 50K samples
    dataEnd = dataStart + 50000;

    leadOnes = dataStart-1;
    trailOnes = sz - dataEnd;

    % rebuild the same packet with 1,1 for the zero portions
    retro_out = [complex(ones(leadOnes,1),ones(leadOnes,1)); retro_single(dataStart:dataEnd); complex(ones(trailOnes,1),ones(trailOnes,1))];
end



function [output] = magic_rx_samples(count)
    single_ones = single(ones(count,1));
    output = complex(single_ones,single_ones);
end

function [output] = magic_tx_samples(count)
    single_ones = single(ones(count,1)*-1);
    output = complex(single_ones,single_ones);
end

function [output] = zero_zero_samples(count)
    single_ones = single(zeros(count,1));
    output = complex(single_ones,single_ones);
end




