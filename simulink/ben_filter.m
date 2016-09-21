
    % used for matlab functions that output a max val of 1.0
    float_scale = 32768;
    float_scale32 = 2^32;

%   The rf front end will mix the center of the 915Mhz spectrum to 40Mhz
%   The ADC will then read this directly
%   902Mhz is 27Mhz
%   915Mhz is 40Mhz
%   928Mhz is 53Mhz

    pre_adc_shift = -875E6;


    fs = 250E6;
    time = 0.001;
    samples = round(fs*time);
    
    
    center = 915E6;
    
    % we want to make 5 channels surrounding the following center freq
    target_freq_center = 916E6;
    
    channel_width = 25E3;
    
    % channel centers with +/- half of channel width on either side
    channels = [
        916E6 - channel_width*2;
        916E6 - channel_width*1;
        916E6;
        916E6 + channel_width*1;
        916E6 + channel_width*2];
    
    
    %snr (not really accurate because the noise is scaled later)
    snr = 6;
    
    % wide-band noise
    data = awgn(ones(samples,1),snr);
    
    % filter noise so that there is noise in 27-35 mhz
    % this is what we might get with a very nice filter on the analog receive chain
    % this is all done with doubles because this state is not reproduced by the FPGA
    % FIXME make this more shitty
    adc_input_coefficients=[-0.00703717093864124;-0.0019492575727853923;-0.00013409491120205036;-0.004386686281678551;-0.0052568478485430729; 0.0035121450199574445; 0.012984865299037182; 0.010274175637658867;-0.0024895251443712617;-0.010217883414478839;-0.0059647097073453692; 0.0001728379778951151;-0.0021289057741126559;-0.0067012953083721034;-0.00077488105390489742; 0.012922274375138354; 0.016816557878042929; 0.0034400298539253682;-0.012129305059266083;-0.012572392591021624;-0.0023616003299639769; 0.00068880414492485424;-0.0060405236980318414;-0.0055947263769464007; 0.010344818024922721; 0.023852811614302045; 0.014014316512446308;-0.010971230113806569;-0.022309466217795271;-0.010445729174535658; 0.0024225230414971362;-0.0024232760362779449;-0.010011271102102466; 0.0046407756227946776; 0.031992594690753287; 0.033543797392543442;-0.0028146028542316132;-0.038200736539296828;-0.032551887676205753;-0.0015838087661996217; 0.0064394714709782213;-0.01310878586343852;-0.007498041963978852; 0.049944864012432894; 0.094987082352015431; 0.039243824549548049;-0.097899178699432821;-0.17482991494238947;-0.082384654152478878; 0.10947696568550366; 0.20799999999999999; 0.10947696568550366;-0.082384654152478878;-0.17482991494238947;-0.097899178699432821; 0.039243824549548049; 0.094987082352015431; 0.049944864012432894;-0.007498041963978852;-0.01310878586343852; 0.0064394714709782213;-0.0015838087661996217;-0.032551887676205753;-0.038200736539296828;-0.0028146028542316132; 0.033543797392543442; 0.031992594690753287; 0.0046407756227946776;-0.010011271102102466;-0.0024232760362779449; 0.0024225230414971362;-0.010445729174535658;-0.022309466217795271;-0.010971230113806569; 0.014014316512446308; 0.023852811614302045; 0.010344818024922721;-0.0055947263769464007;-0.0060405236980318414; 0.00068880414492485424;-0.0023616003299639769;-0.012572392591021624;-0.012129305059266083; 0.0034400298539253682; 0.016816557878042929; 0.012922274375138354;-0.00077488105390489742;-0.0067012953083721034;-0.0021289057741126559; 0.0001728379778951151;-0.0059647097073453692;-0.010217883414478839;-0.0024895251443712617; 0.010274175637658867; 0.012984865299037182; 0.0035121450199574445;-0.0052568478485430729;-0.004386686281678551;-0.00013409491120205036;-0.0019492575727853923;-0.00703717093864124];
    data = filter(adc_input_coefficients,1,data);
    
    % normalize data noise
    data = data / (max(data)*1.1);
    

    
    % at this point, data is real only (int16 scaled) input from our adc of awgn noise after a realistic front end filter
    data = int16(data*float_scale);
    
    % choose some pure sine frequencies to add in
    f1 = 916E6 + 12.5E3;
    f2 = channels(4) + 1e3;
    tone_amplitude = 0.01;
    
    % floats here
    t1 = real( tone_gen( samples, fs, f1 + pre_adc_shift) ) * tone_amplitude;
    t2 = real( tone_gen( samples, fs, f2 + pre_adc_shift) ) * tone_amplitude;    

    % data has our signals added in
    data = data + int16(round((t1 + t2) * float_scale));

    % convert data to complex (twice the memory) but set Q to all 0
    data = complex(data,0);
    
    fplot(double(data), fs);
    title('Spectrum received by ADC');
    
    
    % shift our target region to 0 (this needs to run at 250Mhz)
    shift = int16(tone_gen(samples, fs, -1 * (target_freq_center + pre_adc_shift) ) * float_scale);
    data_shifted = complex_mult16(data,shift);
    
    fplot(double(data_shifted), fs);
    title('Spectrum Shifted to 0');
    
    % book keeping for how far we've already shifted
    applied_shift = -1 * (target_freq_center + pre_adc_shift);
    
    
    % pre filter before cic (last thing that runs at 250)
    
    pre_filter1 = recursive_sum_filter16(data_shifted,64,float_scale);
    
    fplot(double(pre_filter1), fs)
    title('Spectrum after 1st Recursive Sum');
    
    % scale up by 4, bit shift of 2
    pre_filter1_scale = bitsll(pre_filter1,2);
    
    pre_filter2 = recursive_sum_filter16(pre_filter1_scale,63,float_scale);
    
    fplot(double(pre_filter2), fs)
    title('Spectrum after 2nd Recursive Sum');
    
    
    pre_filter3 = recursive_sum_filter16(pre_filter2,62,float_scale);
    
    fplot(double(pre_filter3), fs)
    title('Spectrum after 3rd Recursive Sum');
    
    % could scale by a factor of 2 here if needed
    
    
    
    % use matlabs builtin cic cuz mine is sucking
    % http://www.mathworks.com/help/dsp/ref/dsp.cicdecimator-class.html
    decimation_rate = 64;
    hcicdec = dsp.CICDecimator(decimation_rate);
    hcicdec.NumSections = 2;
    pre_decimation_samples = floor(samples/decimation_rate)*decimation_rate; % needs to be a multiple of filter rate, this does not apply to FPGA
    decimation_fs = round(fs/decimation_rate); % fs after decimation
    
    % run cic but omit last few samples so that data divides evenly
    second_data = step(hcicdec, pre_filter3(1:pre_decimation_samples));
    release(hcicdec); % free memory
    
    fplot(double(second_data), fs/decimation_rate)
    title('Spectrum after CIC');
    
    decimation_samples = length(second_data); % how many samples we have after the cic filter
    
    % this is the gain from the CIC filter.  Joel suggests that 
    % we calculate what the gain would be for an ideal decimator (one bit for every divide by 2 in the signal
    % and then gain down the signal to match that
    gain_cic = (hcicdec.DecimationFactor*hcicdec.DifferentialDelay)^hcicdec.NumSections
    
    gain_cic_bits = log(gain_cic)/log(2)
    
    gain_ideal = log(decimation_rate)/log(2)
    
    % gain down to apply joels idea
    second_data_scaled = bitsra(second_data, (gain_cic_bits-gain_ideal) );
    
    
    % now we can shift and pull out our 5 channels
    % This is the first channel:
    chan_shift = int32(tone_gen(decimation_samples, decimation_fs, -1*(pre_adc_shift + applied_shift) - channels(4) ) * float_scale32);
    channel_data_shifted = complex_mult32(second_data_scaled,chan_shift);
    
    fplot(double(channel_data_shifted), fs/decimation_rate);
    title('Spectrum shifted');
    
    
    % now that channel is centered, low pass filter it
    channel_low_pass_fir = [1074124;1254245;1436570;1621068;1807710;1996464;2187299;2380183;2575081;2771961;2970787;3171523;3374133;3578581;3784829;3992838;4202569;4413983;4627039;4841696;5057912;5275645;5494852;5715489;5937512;6160877;6385537;6611447;6838560;7066830;7296208;7526647;7758097;7990511;8223837;8458027;8693029;8928793;9165267;9402399;9640138;9878430;10117224;10356464;10596099;10836074;11076335;11316828;11557497;11798287;12039144;12280012;12520836;12761558;13002125;13242478;13482563;13722322;13961699;14200638;14439081;14676973;14914255;15150873;15386768;15621884;15856165;16089553;16321993;16553427;16783800;17013054;17241135;17467985;17693550;17917773;18140600;18361975;18581843;18800149;19016840;19231861;19445159;19656680;19866371;20074179;20280053;20483940;20685788;20885547;21083167;21278596;21471785;21662686;21851249;22037427;22221172;22402436;22581174;22757339;22930887;23101772;23269951;23435380;23598017;23757819;23914746;24068756;24219810;24367869;24512894;24654847;24793692;24929392;25061912;25191217;25317275;25440050;25559513;25675631;25788374;25897712;26003617;26106062;26205018;26300460;26392364;26480704;26565458;26646604;26724119;26797984;26868179;26934686;26997486;27056564;27111904;27163492;27211312;27255354;27295605;27332055;27364694;27393514;27418506;27439665;27456984;27470459;27480087;27485865;27487791;27485865;27480087;27470459;27456984;27439665;27418506;27393514;27364694;27332055;27295605;27255354;27211312;27163492;27111904;27056564;26997486;26934686;26868179;26797984;26724119;26646604;26565458;26480704;26392364;26300460;26205018;26106062;26003617;25897712;25788374;25675631;25559513;25440050;25317275;25191217;25061912;24929392;24793692;24654847;24512894;24367869;24219810;24068756;23914746;23757819;23598017;23435380;23269951;23101772;22930887;22757339;22581174;22402436;22221172;22037427;21851249;21662686;21471785;21278596;21083167;20885547;20685788;20483940;20280053;20074179;19866371;19656680;19445159;19231861;19016840;18800149;18581843;18361975;18140600;17917773;17693550;17467985;17241135;17013054;16783800;16553427;16321993;16089553;15856165;15621884;15386768;15150873;14914255;14676973;14439081;14200638;13961699;13722322;13482563;13242478;13002125;12761558;12520836;12280012;12039144;11798287;11557497;11316828;11076335;10836074;10596099;10356464;10117224;9878430;9640138;9402399;9165267;8928793;8693029;8458027;8223837;7990511;7758097;7526647;7296208;7066830;6838560;6611447;6385537;6160877;5937512;5715489;5494852;5275645;5057912;4841696;4627039;4413983;4202569;3992838;3784829;3578581;3374133;3171523;2970787;2771961;2575081;2380183;2187299;1996464;1807710;1621068;1436570;1254245;1074124];
    
    channel_filtered = fir_fixed32(channel_data_shifted,channel_low_pass_fir);
    fplot(double(channel_filtered), fs/decimation_rate);
    title('Spectrum after FIR');
    
    
    % this decimates the channel to it's final sample rate (30518 at time of writing)
    
    channel_decimation_rate = 128;
    channelcic = dsp.CICDecimator(channel_decimation_rate);
    channelcic.NumSections = 2;
    pre_channel_decimation_samples = floor(decimation_samples/channel_decimation_rate)*channel_decimation_rate; % needs to be a multiple of filter rate, this does not apply to FPGA
    channel_decimation_fs = round(decimation_fs/channel_decimation_rate); % fs after decimation
    
    % the final channel bits
    critical_channel_data = step(channelcic, channel_filtered(1:pre_channel_decimation_samples));
    
    fplot(double(critical_channel_data), fs/decimation_rate/channel_decimation_rate);
    title('Spectrum after final CIC Filter');
    
    release(channelcic); % free memory
    
    
    
% Write out data for david

% csvwrite('input_250M.csv',data);
% csvwrite('after_final_recursive_sum_250M.csv',pre_filter3);
% dlmwrite('after_first_cic_3_9M.csv',int64(round(double(second_data))),'delimiter',',','precision',100);
% dlmwrite('after_fir_3_9M.csv',channel_filtered,'delimiter',',','precision',100);
% dlmwrite('output_after_cic_30k.csv',int64(round(double(critical_channel_data))),'delimiter',',','precision',100);


    
    