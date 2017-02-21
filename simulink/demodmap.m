function x = demodmap(y, Fd, Fs, method, M, opt2, opt3) 
%DEMODMAP Demaps a modulation mapped signal to the closest digit number. 
%       DEMODMAP(Y, Fd, Fs) plots eye-pattern diagram for the signal Y. The 
%       sampling frequency for Y is Fs (Hz) and the digital sampling frequency  
%       is Fd (Hz). 
% 
%       Z = DEMODMAP(Y, Fd, Fs, METHOD, OPT1, OPT2, OPT3) is a reverse mapping 
%       of function MODMAP. This function demaps a sampling frequency Fs (Hz) 
%       analog signal into a sampling frequency Fd (Hz) digit signal Z. Y is 
%       a two column matrix with the first column is an in-phase component and 
%       second column is a quadrature component. When METHOD = 'ask', 'fsk', 
%       or 'msk', Y is a one column vector instead of a matrix. When Fd is a  
%       two element vector, the second element is the offset value for the 
%       decision point. The offset timing in the plot is offset/Fs. The 
%       default offset is 0. The received digital signal is sampled at time 
%       point i/Fd + offset/Fs. The sample value keeps until time  
%       (i+1)/Fd +offset/Fs when the next sample point is taken place. The 
%       demapping process finds the distance from the sample value to 
%       all of the possible digital symbols. The digital symbols with the  
%       shortest distance to the current sampling point is the demodulated 
%       output.  
% 
%       METHOD is a string, which can be one of the following: 
%       'ask'       Amplitude shift keying modulation. 
%       'psk'       Phase shift keying modulation. 
%       'qask'      Quadrature amplitude shift keying modulation, with choice 
%                   of 'qask/cir', 'qask/arb' for different mapping table. 
%       'fsk'       Frequency shift keying modulation. 
%       'msk'       Minimum shift keying modulation. 
%       'sample'    Down sampling from a higher sampling frequency signal. 
%       'eye'       Eye-pattern plot. 
%       'scatter'   Scatter plot. 
% 
%       Use DEMODMAP(METHOD) to view the help for a specific method. 
% 
%       See also MODMAP, DMOD, DDEMOD, AMOD, ADEMOD, MODCE, DEMODCE. 
% 
 
%       Wes Wang 1/9/95, 10/3/95 
%       Copyright (c) 1995-96 by The MathWorks, Inc. 
%       $Revision: 1.1 $  $Date: 1996/04/01 17:56:38 $ 
 
%position for optional parameters. 
opt_pos = 5; 
plot_const = 0; 
if nargin < 1 
    feval('help','demodmap'); 
    return; 
elseif isstr(y) 
    method = lower(deblank(y)); 
    if length(method) < 3 
        error('Invalid method option for demodmap.') 
    else 
        method = method(1:3); 
    end 
    if nargin == 1 
        addition = 'See also MODMAP, AMOD, ADEMOD, MODCE, DEMODCE.'; 
        callhelp('demodmap.hlp', method, addition); 
        return; 
    else 
        disp('Warning: Worng number of input variable, use MODMAP for plotting constellations.'); 
        return 
    end; 
end; 
if length(Fd) > 1 
    offset = Fd(2); 
    Fd = Fd(1); 
else 
    offset = 0; 
end; 
if (Fs == 0) | (Fd == 0) | isempty(Fd) | isempty(Fs) 
    FsDFd = 1; 
else 
    Fs = Fs(1); 
    FsDFd = Fs / Fd; 
    if (ceil(FsDFd) ~= FsDFd) | (FsDFd <= 0) 
        error('Fs / Fd must be a positive integer.') 
    end; 
end; 
offset = rem(offset, FsDFd); 
if offset < 0 
    offset = rem(offset + FsDFd, FsDFd); 
end; 
[r, c] = size(y); 
if r * c == 0 
    y = []; 
    return; 
end; 
if r == 1 
    y = y(:)'; 
    len_y = c; 
else 
    len_y = r; 
end; 
 
if nargin < 3 
    disp('Usage: Y=DEMODMAP(X, Fd, Fs, METHOD, OPT1, OPT2, OPT3) for modulation mapping'); 
    return; 
elseif nargin < opt_pos-1 
    method = 'sample'; 
end; 
 
method = lower(method); 
 
if length(method) < 3 
    method = [method '   ']; 
end; 
 
if strcmp(method(1:3), 'ask') 
    if offset == 0 
        offset = FsDFd; 
    end; 
    yy = y([offset : FsDFd : len_y], :); 
    if nargin < opt_pos 
        error('Not enough input varibale for DEMODMAP.') 
    end; 
    index = ([0 : M - 1] - (M - 1) / 2) * 2 / (M - 1); 
    x = []; 
    for i = 1 : size(y, 2) 
        [tmp, x_p] = min(abs(yy(:, i*ones(1, M)) - index(ones(1, size(yy, 1)), :))'); 
        x = [x x_p'-1]; 
    end; 
elseif findstr(method, 'fsk') 
    if nargin < opt_pos + 1 
        Tone = 2 * Fd / M; 
    else 
        Tone = opt2; 
    end; 
    if offset == 0 
        offset = FsDFd; 
    end; 
    yy = y([offset : FsDFd : len_y], :); 
    if findstr(method, 'max') 
        % in case yy is the correlation output. 
        [tmp, x] = max(yy'); 
        x = (x-1)'; 
    else 
        index = [0:M-1] * Tone; 
        x = []; 
        for i = 1 : size(y, 2) 
            [tmp, x_p] = min(abs(yy(:, i*ones(1, M)) - index(ones(1, size(yy, 1)), :))'); 
            x = [x x_p'-1]; 
        end;         
    end; 
%psk has combined with qask. 
elseif findstr(method, 'msk') 
    %This is a special case of fsk call back to get fsk 
    method(1) = 'f'; 
    M = 2; 
    Tone = Fd; 
    x = demodmap(y, Fd, Fs, method, M, Tone); 
elseif ~isempty(findstr(method, 'qask')) |... 
         ~isempty(findstr(method, 'qam')) |... 
         ~isempty(findstr(method, 'qsk')) |... 
         ~isempty(findstr(method, 'psk')) 
    if findstr(method, '/ar') 
        % arbitraryly defined I, Q.  
        if nargin < opt_pos + 1 
            error('In correct format for METHOD=''qask/arbitrary''.'); 
        end; 
        I = M; 
        Q = opt2; 
        M = length(I); 
    elseif ~isempty(findstr(method, '/ci')) | ~isempty(findstr(method, 'psk')) 
        % circle defined NIC, AIC, PIC. 
        if nargin < opt_pos 
            if findstr(method, 'psk') 
                error('M-ary number must be specified for psk demap.') 
            else 
                error('Incorrect format for METHOD=''qask/arbitrary''.'); 
            end; 
        end; 
        NIC = M; 
        M = length(NIC); 
        if nargin < opt_pos+1 
            AIC = [1 : M]; 
        else 
            AIC = opt2; 
        end; 
        if nargin < opt_pos + 2 
            PIC = NIC * 0; 
        else 
            PIC = opt3; 
        end; 
        inx = apkconst(NIC, AIC, PIC); 
        I = real(inx); 
        Q = imag(inx); 
        M = sum(NIC); 
    else 
        %consider as square style. 
        [I, Q] = qaskenco(M); 
    end; 
    if offset <= 0  
        offset = FsDFd; 
    end; 
    yy = y([offset : FsDFd : len_y], :); 
    [len_y, wid_y] = size(yy); 
    if (ceil(wid_y/2) ~= wid_y/2) 
        error('qask demap requires input is a matrix with even number of columns.'); 
    end; 
    x = []; I = I(:)'; Q = Q(:)'; 
    for i = 1 : 2 : wid_y 
        [tmp, x_p] = min(... 
            ((yy(:, i*ones(1, M)) - I(ones(1, len_y), :)).^2 + ... 
            (yy(:, (i+1)*ones(1, M)) - Q(ones(1, len_y), :)).^2)'); 
        x = [x x_p'-1]; 
    end; 
elseif findstr(method, 'samp') 
    %This is made possible to convert an input signal from sampling frequency Fd 
    %to sampling frequency Fs. 
    if offset <= 0  
        offset = FsDFd; 
    end; 
    yy = y([offset : FsDFd : len_y], :); 
elseif findstr(method, 'eye') 
    % plot eye-pattern plot 
    eyescat(y, Fd, Fs, offset, offset); 
elseif findstr(method, 'scat') 
    if nargin >= opt_pos 
        if isstr(M) 
            M = M(1); 
        else 
            M = '.'; 
        end; 
    else 
        M = '.'; 
    end; 
    eyescat(y, Fd, Fs, offset, M); 
else 
    %The choice is not a valid one. 
    disp('You have used an invalid method. The method should be one of the following string:') 
    disp('  ''ask'' Amplitude shift keying modulation;') 
    disp('  ''psk'' Phase shift keying modulation;') 
    disp('  ''qask'' Quadrature amplitude shift-keying modulation, square constellation;') 
    disp('  ''qask/cir'' Quadrature amplitude shift-keying modulation, circle constellation;') 
    disp('  ''qask/arb'' Quadrature amplitude shift-keying modulation, user defined constellation;') 
    disp('  ''fsk'' Frequency shift keying modulation;') 
    disp('  ''msk'' Minimum shift keying modulation;') 
    disp('  ''sample'' Convert sample frequency Fd input to sample frequency Fs output.') 
end; 
 