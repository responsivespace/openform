// Stereo Out

var streamOut = ~channelsOut;

~test1 = Routine {

	~stimmen. do({ |x|

		var inBus = ~modul.granulatoreffectBus[x];
		var time = 0;
		var outBus1 = ~channelsOut.rand;
		var outBus2 = ~channelsOut.rand;

		postf("Starte Granular-Schleife %:\n", x);

		~modul.repeatgranular[x] = 2.rrand(8);
		~modul.timegranular[x] = Array.fill(~modul.repeatgranular[x], ~tonlaenge[x].choose);
		~modul.durationgranular[x] = Array.fill(~modul.repeatgranular[x],
			{(~tonlaenge[x].choose)*2.rrand(4)});
		~modul.repeatgranular[x].do ({|i| time = time + ~modul.durationgranular[x][i]});

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatgranular[x], time);

		~modul.granulator[x].start;

		~modul.granulator1out[x] = Synth.head(~master, "out",
			[\inBus, inBus, \outBus, outBus1, \level, 1.5]);
		~modul.granulator2out[x] = Synth.head(~master, "out",
			[\inBus, inBus.index+1, \outBus, outBus2, \level, 1.5]);

		~modul.granulatormix[x] = Synth.head(~master, "out2",
			[\inBus, inBus, \outBus, streamOut, \level, 1.5]);

		(time/(x+2)).wait;
	});

};

~test1Stop = {
	~test1.stop; ~test1.reset;

	~stimmen. do({ |x|

		~modul.granulator[x].stop;
		~modul.granulator1out[x].free;
		~modul.granulator2out[x].free;
		~modul.granulatormix[x].free;
	})
};

// Stereo Out

~test2 = Routine {

	~stimmen. do({ |x|

		var inBus1 = ~modul.samplegraineffectBus1[x];
		//var inBus2 = ~modul.samplegraineffectBus2[x];
		var time = 0;
		var outBus1 = (~channelsOut-1).rand;
		//var outBus2 = (~channelsOut-1).rand;
		var variation = ~tonlaenge[x]/((x+1)/2);

		postf("Starte Granularsample-Schleife %:\n", x);


		~modul.repeatsamplegrain[x] = 2.rrand(8);
		~modul.timesamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x],~tonlaenge[x].choose);
		~modul.durationsamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x], {(variation.choose)*1.rrand(3)});
		~modul.repeatsamplegrain[x].do ({|i| time = time + ~modul.durationsamplegrain[x][i]});

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatsamplegrain[x], time);

		~modul.samplegrain[x].start;

		~modul.samplegrain1out[x] = Synth.head(~master, "out2", [\inBus, inBus1, \outBus, outBus1, \level, 0.8]);
		//~modul.samplegrain2out[x] = Synth.head(~master, "out2", [\inBus, inBus2, \outBus, outBus2, \level, 0.6]);

		~modul.samplegrainmix1[x] = Synth.head(~master, "out2", [\inBus, inBus1, \outBus, streamOut, \level, 0.8]);
		//~modul.samplegrainmix2[x] = Synth.head(~master, "out2", [\inBus, inBus1, \outBus, 0, \level, 0.6]);

		10.rand.wait;
	});

};

~test2Stop = {
	~test2.stop; ~test2.reset;

	~stimmen. do({ |x|

		~modul.samplegrain[x].stop;
		~modul.samplegrain1out[x].free;
		~modul.samplegrainmix1[x].free;
	})
};

//

~test3 = Routine {
	~stimmen. do({ |x|

		var inBus1 = ~modul.delaysyntheffectBus1[x];
		var inBus2 = ~modul.delaysyntheffectBus2[x];
		var time = 0;
		var variation = ~tonlaenge[x]/((x+1));
		var outBusses = ~dodecout1;
		var outBus1 = (~channelsOut-1).rand, outBus2 = (~channelsOut-1).rand;

		/*while ( {outBus1 == outBus2}, {outBus1 = outBusses.choose; outBus2 = outBusses.choose;});*/
		10.rand.wait;
		x.postln;

		time = 10.rand;

		~modul.repeatdelaysynth[x] = 4.rrand(10);
		~modul.timedelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x], {variation.choose});
		~modul.tonfolgedelaysynth[x]=Array.fill(~modul.repeatdelaysynth[x], {Rand(1,3)});
		~modul.durationdelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x],
			{variation.choose*2});
		~modul.repeatdelaysynth[x].do ({|i| time = time + ~modul.durationdelaysynth[x][i]});

/*		~modul.delaysynth1out[x] = Array.newClear(5);
		~modul.delaysynth2out[x] = Array.newClear(5);*/

		~modul.delaysynth1out[x] = Synth.head(~master, "out2", [\inBus, inBus1.index, \outBus, outBus1, \level, 1]);
		~modul.delaysynth2out[x] = Synth.head(~master, "out2", [\inBus, inBus2.index, \outBus, outBus2, \level, 1]);


		~modul.delaysynthmix[x] = Synth.head(~master, "out2", [\inBus1, inBus1, \inBus2, inBus2, \outBus, streamOut, \level, 1]);

		~modul.glockensynth[x].start;

		time.wait;
	});

};

~test3Stop = {
	~test3.stop; ~test3.reset;

	~stimmen. do({ |x|

		~modul.glockensynth[x].stop;
		~modul.delaysynth1out[x].free;
		~modul.delaysynth2out[x].free;
		~modul.delaysynthmix[x].free;
	})
};


~test4 = Routine {
	~stimmen.do({ |x|

		var inBus = ~modul.rauscheneffectBus[x];
		var time = 0;
		var variation = ~tonlaenge[x];
		var outBus1 = ~channelsOut.rand, outBus2 = ~channelsOut.rand;
		var randompath = 5.rand;
		var randomlayer = 5.rand;

		20.rand.wait;
		postf("Starte Windrauschen-Schleife %:\n", x);

		~modul.repeatrauschen[x] = 2.rrand(6);
		~modul.durationrauschen[x]=Array.fill(~modul.repeatrauschen[x], {~tonlaenge[x].choose});

		~modul.tonfolgerauschen[x]=Array.fill(~modul.repeatrauschen[x], {1.rrand(4)});

		~modul.timerauschen[x]= Array.fill(~modul.repeatrauschen[x], { |irepeat|
			Array.fill(~modul.tonfolgerauschen[x][irepeat], {variation.choose})});


		~modul.repeatrauschen[x].do ({|irepeat|
			time = time + ~modul.durationrauschen[x][
				irepeat];
			~modul.tonfolgerauschen[x][irepeat].do ({ |i|
				time = time + ~modul.timerauschen[x][irepeat][i];
			});
		});

		~modul.sequenzdauerrauschen[x] = time;

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatrauschen[x], time);
		~modul.repeatrauschen[x].do({ |irepeat|
			postf("%. Tonfolge: % mal\n", irepeat, ~modul.tonfolgerauschen[x][irepeat])});

		~modul.windrauschen[x].start;

		~modul.rauschen1out[x] = Synth.head(~master, "out",
			[\inBus, inBus.index, \outBus, outBus1, \level, 1]);
		~modul.rauschen2out[x] = Synth.head(~master, "out",
			[\inBus, (inBus.index)+1, \outBus, outBus2, \level, 1]);
		~modul.rauschenmix[x] = Synth.head(~master, "out2",
			[\inBus, inBus, \outBus, streamOut, \level, 1]);

	});

};

~test5Stop = {
	~test5.stop; ~test5.reset;

	~stimmen. do({ |x|

		~modul.glockensynth[x].stop;
		~modul.delaysynth1out[x].free;
		~modul.delaysynth2out[x].free;
		~modul.delaysynthmix[x].free;
	})
};


~test5 = Routine {

	~stimmen.do({ |x|

		var inBus = ~modul.sinusglissandieffectBus[x];
		var variation = ~tonlaenge[x]/2 * (x+1);
		var outBus1 = ~channelsOut.rand;
		var outBus2 = ~channelsOut.rand;
		var time = 0;

		x.postln;
		postf("Starte Sinusglissandi-Schleife %:\n", x);


		~modul.repeatsinusglissandi[x] = 2.rrand(6-x/2);
		~modul.durationsinusglissandi[x]=Array.fill(~modul.repeatsinusglissandi[x], {variation.choose});

		~modul.tonfolgesinusglissandi[x]=Array.fill(~modul.repeatsinusglissandi[x], {1.rrand(4)});

		~modul.timesinusglissandi[x]= Array.fill(~modul.repeatsinusglissandi[x], { |irepeat|
			Array.fill(~modul.tonfolgesinusglissandi[x][irepeat], {variation.choose})});


		~modul.repeatsinusglissandi[x].do ({|irepeat|
			time = time + ~modul.durationsinusglissandi[x][irepeat];
			~modul.tonfolgesinusglissandi[x][irepeat].do ({ |i|
				time = time + ~modul.timesinusglissandi[x][irepeat][i]
			});
		});
		~modul.sequenzdauersinusglissandi[x] = time;

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatsinusglissandi[x], time);

		~modul.sinusglissandi[x].start;
		~modul.sinusglissandi1out[x] = Synth.head(~master, "out", [\inBus, inBus, \outBus, outBus1, \level, 1]);
		~modul.sinusglissandi2out[x] = Synth.head(~master, "out", [\inBus, inBus.index+1, \outBus, outBus2, \level, 1]);
		~modul.sinusmix = Synth.head(~master, "out2", [\inBus, inBus, \outBus, streamOut, \level, 1]);

		(time/((x+1)*1.2)).wait;

	});

};