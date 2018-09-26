## Copyright (C) 2018 -*- octave -*-

## usage: [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav(wav_filename, max_last_gpsfix)
##
## input: wav_filename - filename of .wav file generated by kiwirecorder.py with options '-m iq --kiwi-wav'
##        (optional) 2nd argument - maximal age of the GNSS position solution
## output: x - array of structs containing the information in the WAV chunks, i.e. IQ samples and GNSS timestamps
##         xx - array of structs containting IQ samples and for each IQ samples a GNSS timestamp
##         fs - sampling rate
##         last_gpsfix - oldest GNSS position solution
##
## note: last_gps_fix = 255 means there was no GNSS position solution at all on the KiwiSDR

function [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav(varargin)
  if length(varargin) == 0
    print_usage;
  end
  if length(varargin) >=1
    fn = varargin(1);
  end
  max_last_gpsfix = 255;
  if length(varargin) >=2
    max_last_gpsfix = varargin(2){1,1};
  end

  [x,fs]      = read_kiwi_iq_wav(fn);
  last_gpsfix =  max(cat(1,x.gpslast));
  idx         = find(cat(1,x.gpslast) < max_last_gpsfix);
  xx          = {};
  if isempty(idx)
    return
  endif
  n = length(idx);
  xx(n).t = [];
  xx(n).z = [];
  for i=1:n
    j       = idx(i);
    xx(i).t = x(j).gpssec + 1e-9*x(j).gpsnsec + [0:length(x(j).z)-1]'/fs;
    xx(i).z = x(j).z;
  end

#  if length(xx) != 0
#    subplot(2,2,1:2); plot(mod(cat(1,xx.t), 1), abs(cat(1,xx.z)));                                  xlabel("GPS seconds mod 1 (sec)");
#    subplot(2,2,3);   plot(mod(cat(1,xx.t), 1), abs(cat(1,xx.z)), '.'); xlim([0.0285 0.0294]) ;     xlabel("GPS seconds mod 1 (sec)");
#    subplot(2,2,4);   plot(mod(cat(1,xx.t), 1), abs(cat(1,xx.z)), '.'); xlim(0.1+[0.0285 0.0294]) ; xlabel("GPS seconds mod 1 (sec)");
#  end
endfunction
