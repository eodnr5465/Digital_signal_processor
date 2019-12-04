function AWGNadd = AWGNadd(sig,SNR)

Esig = norm(sig(:)).^2;
Eno = Esig./(10^(SNR/10));
Vno = Eno./(length(sig(:) - 1));
NoiseStd = sqrt(Vno);
Noise = NoiseStd .* randn(size(sig));

AWGNadd = sig + Noise;

