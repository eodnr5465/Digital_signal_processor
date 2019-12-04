# Digital_signal_processor
DSP의 모든 과정을 matlab code로 구현하였다.

1.	Bit Generation

 1000개의 bit 0과 1을 uniform random하게 생성함.
 
Constellation mapping 단계에서 짝수 개씩 묶이기 때문에 홀수의 n이 들어오게 되면 마지막 bit 무시하도록 함.





2.	Constellation mapping

 평균이 0이고 Energy가 1인 4QAM 방식으로 symbol mapping을 함.
00  s1
01  s2
11  s3
10  s4
 
각 signal의 real part와 imaginary part를 구분하여 따로 구분하여 해석하기 위해 sr과 si로 나누었고 signal의 개수를 snum으로 정의했다. 또한 data가 전달되는 속도 즉, data rate(=data frequency)를 1로 가정하고 단위를 1MHz라고 할 수 있다. 따라서 data는 1us 마다 전달된다. 그리고 총 data가 전달되는데 걸리는 시간은 total_t라고 정의한다.
다음 그림은 constellation mapping 결과 plot이다.
 
<constellation mapping>
S1 s2 s3 s4 순서대로 generate된 signal 개수 (합500개)
 








3.	Transmit Filter

Discrete signal에 gtx(t)의 function으로 convolution연산을 하게 되면 다음과 같은 식으로 표현이 가능하다.
 
위 상황에서 n을 0에서 snum(signal 개수)까지 놓고 discrete를 continuous ‘t’에 대한 식으로 표현하기 위해 500개의 signal이 각 1us의 주기로 만들어 지는 것을 감안하여 0.01us의 주기로 continuous time ‘t’를 sampling 하였다.
 
위의 code에서 gtx(t)의 경우 다음 square root raised cosine 식에서 alpha = 1을 적용하였다.
 
이 때 연산과정에서 infinity term이 한번씩 발생했는데 이러한 term이 생길 시 바로 이전 0.01us의 값과 같은 값으로 두었다.


다음은 0~500us 동안 transmit filter를 거친 continuous time signal을 time domain에서 plotting한 결과이다. (파란색이 real term이고 빨간색이 imaginary term이다.)
 

다음은 continuous time signal을 Fourier transform을 한 결과를 plotting 한 것이다. (파란색)
 
약 0~1MHz사이의 frequency를 가진 signal이 존재하고 있음을 알 수 있다. 

4.	Channel

 

Channel의 다음 부분을 Block을 각 Block의 특성을 고려하여 다음과 같은 모델을 생각할 수 있고 이러한 모델로 receive signal을 구하도록 할 것이다.


 



4.1 up-conversion
 Transmit filter를 통해 생긴 continuous time signal을 carrier frequency에 실어 passband영역에서 signal을 보내기 위해 up-conversion과정을 거친다. 이 때 실제로 보내는 up conversion된 signal의 real term 이기 때문에 Euler’s rule에 의해 cosine, sine function을 continuous time signal에 다음과 같이 곱하게 되면 원하는 passband signal을 얻을 수 있다.
 
 

다음은 10MHz의 band pass 주파수로 up-conversion 한 signal을 time domain에서 plotting한 결과이다.
 

다음은 frequency영역에서 확인한 up-conversion 이후의 signal의 Fourier transform을 취한 값에 절댓값을 분석한 결과이다.
 
 
예상과 같이 power는 절반이 되었고 bandpass frequency 만큼 shift되었다.







4.2 AWGN

Additive White Gaussian Distribution Noise의 특성상 다음 과정에서 아무 곳에 들어가도 상관이 없다. 따라서 up-conversion 이후 AWGN을 인가하게 되면 time domain 분석 시 다음과 같다. 또한 다음은 SNR을 10이 되도록 Noise power를 조절하여 인가하였다.
 
 
 


4.3 Down-conversion

AWGN이 섞여 있는 signal에 대해 원래의 signal을 복구하기 위해 down-conversion을 하면서 in-phase signal과 quadrature signal을 만들어야 한다.
이 때 다음의 structure를 따라 signal을 in-phase term과 quadrature term으로 분리하였고 여전히 2배의 carrier frequency에 의한 term은 존재하고 있으며 power는 절반인 상태이다.
 
 









4.4 Equivalent Channel
마지막으로 Equivalent Channel Block을 지나야 하는데 이 block에서는 현재 2배의 carrier frequency를 제거하기 위한 filtering과 2배의 증폭을 같이 수행할 것이다. 따라서 Equivalent Channel의 time domain model은 ideal한 filter라고 가정할 시 다음과 같을 것이다.
 
 

위의 코드에서 bpf라는 equivalent channel time domain model을 만들었고 이를 기존의 signal 과convolution을 취한다. 이 때 matlab의 conv 연산은 matrix 연산이기 때문에 convolution 과정에서 time 축이 500us에서 1ms로 늘어나게 되고 그 중 time이 0에서부터 convolution을 취했기 때문에 0~500us에 의미 있는 값들이 존재할 것이므로 for문을 활용하여 500us size의 signal을 따로 정의했다.
 
5.	Receiver Filter

 Receiver Filter의 경우 SINR을 최대로 만족시키기 위해 grx(t) = gtx(-t)가 되도록 설계해야 한다. 따라서 다음과 같이 grx filter를 만들었다.
 
그리고 received signal과 convolution을 취해야 하므로 이전의 경우와 마찬가지로 0~500us의 값만 취한다. 다음은 receiver filter를 지난 후의 time domain graph이다.
 






6.	Sampling

 이젠 원래의 discrete signal을 얻기 위해 time domain received signal을 다시 Sampling을 한다. 이때 Sampling frequency는 최초 transmit의 Data rate와 같아야 한다. 따라서 continuous time ‘t’(sampling period: 0.01us)를 다음과 같이 1us의 주기로 sampling 하였다.
 
그 결과 receive_sr에는 500개의 in-phase signal, receive_si에는 500개의 quadrature signal이 순서대로 담겨 있다.

7.	Detection

현재의 signal의 값은 2dimesion real/imaginary axis에서 plotting 해보면 다음과 같다. 
 
다음의 여러 data를 4개의 symbol로 mapping하기에 가장 적합한 방법은 원래의 4개의 symbol의 위치와 떨어진 거리가 가장 가까운 쪽으로 mapping하는 방법이다. 이때 data가 들어온 순서에 따라서 transmit와 receiver가 일치하는지도 판별해야 된다. 따라서 다음의 logic을 code로 표현하면 다음과 같다. 
 



 

그 결과는 다음과 같다. Error detection이 0퍼센트인 것을 확인할 수 있다.
 



8.	Summary
 다음 project는 bit generate 부터 detection까지의 모든 Digital Signal Processing의 모의 과정을 matlab으로 구현했다. 위의 1000개의 bit으로부터는 SNR이 10인 상황에서는 Error가 한 개도 없는 것을 알 수 있다. 따라서 SNR을 1dB씩 줄여가면서 Error의 비율이 어떻게 되는지 각 과정을 나열했다.



X축은 SNR(dB) 이고 Y 축은 SER이다.

이론상의 값과 어느정도 크게 차이가 나는데 그 이유는 먼저 simulation하는데 너무 오래 걸려 많은 표본을 가질 수 없었던 것과 bit의 개수 자체도 크게 많지 않아 resolution이 매우 좋지 않기 때문에 log scale의 SER 축에서 큰 차이가 있어 보인다. 
마지막으로 크게 차이나는 이유 중에 하나는 continuous time sample rate 때문이라고 생각한다. 실제로는 0.01us보다 훨씬 더 조밀한 간격에서 continuous time을 표현해야 되지만 아까도 언급했듯이 simulation time이 너무 길어지는 것을 방지하여 선택하였기 때문에 완벽한 표현은 어려울 것으로 예상된다. 
