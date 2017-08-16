function [ txSig ] = o_rrc_mod(data, rrcFilter, rolloff, span, sps, M )

% See openExample('comm/InterpRcosdesignExample')

% rrcFilter = rcosdesign(rolloff, span, sps);

modData = pskmod(data, double(M), pi/4);

txSig = upfirdn(modData, rrcFilter, sps, 1);

end

