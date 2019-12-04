%실제로 내가 만든 4QAM DSP와 이론에서의 4QAM DSP의 차이를 확인하기위한 function이다.

function QPSKser = QPSKser
N = 10^5; % number of symbols
Es_N0_dB = [-3:20]; % multiple Eb/N0 values
ipHat = zeros(1,N);
for ii = 1:length(Es_N0_dB)
ip = (2*(rand(1,N)>0.5)-1) + j*(2*(rand(1,N)>0.5)-1); %
s = (1/sqrt(2))*ip; % normalization of energy to 1
n = 1/sqrt(2)*[randn(1,N) + j*randn(1,N)]; % white guassian noise, 0dB variance

y = s + 10^(-Es_N0_dB(ii)/20)*n; % additive white gaussian noise

% demodulation
y_re = real(y); % real
y_im = imag(y); % imaginary
ipHat(find(y_re < 0 & y_im < 0)) = -1 + -1*j;
ipHat(find(y_re >= 0 & y_im > 0)) = 1 + 1*j;
ipHat(find(y_re < 0 & y_im >= 0)) = -1 + 1*j;
ipHat(find(y_re >= 0 & y_im < 0)) = 1 - 1*j;

nErr(ii) = size(find([ip- ipHat]),2); % couting the number of errors
end

simSer_QPSK = nErr/N;
theorySer_QPSK = erfc(sqrt(0.5*(10.^(Es_N0_dB/10)))) - (1/4)*(erfc(sqrt(0.5*(10.^(Es_N0_dB/10))))).^2;
pract_QPSK = [ 124/500    88/500    58/500    40/500    30/500    22/500    17/500    7/500   0.002   0    0    0    0    0   0     0    0    0    0   0   0    0   0  0];
close all
figure
semilogy(Es_N0_dB,theorySer_QPSK,'b.-');
hold on
semilogy(Es_N0_dB,simSer_QPSK,'mx-');
hold on
semilogy(Es_N0_dB,pract_QPSK,'r.-');
axis([-3 10 0.002 1])
grid on
legend('theory-QPSK', 'simulation-QPSK');
xlabel('Es/No, dB')
ylabel('Symbol Error Rate')
title('Symbol error probability curve for QPSK(4-QAM)')