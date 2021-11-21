function coefficients(N,nb)

close all;

f_cut_off = 2000; % 2kHz
f_sampling = 10000; % 10kHz

f_nyq = f_sampling/2; %% Nyquist frequency
f0 = f_cut_off/f_nyq; %% normalized cut-off frequency

b=fir1(N, f0); %% get filter coefficients

bi=floor(b*2^(nb-1)); %% convert coefficients into nb-bit integers

%% coefficient
fp=fopen('C:\Users\hugob\Desktop\Bureau\Dossier_Polito\deuxieme_annee\TP\ISA\LAB_1\coefficients.txt','w');
fprintf(fp,'%d\n', bi);
fclose(fp);
