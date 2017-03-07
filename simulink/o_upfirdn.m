function [ txSig ] = o_upfirdn(data, rrcFilter, rolloff, span, sps, M )

txSig = upfirdn(data, rrcFilter, sps, 1);

end

