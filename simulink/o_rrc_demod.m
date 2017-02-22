function [ rxFilt ] = o_rrc_demod(rf, rrcFilter, rolloff, span, sps, M )

% See openExample('comm/InterpRcosdesignExample')

% rrcFilter = rcosdesign(rolloff, span, sps);

rxFilt = upfirdn(rf, rrcFilter, 1, sps);

rxFilt = rxFilt(span+1:end-span);

end

