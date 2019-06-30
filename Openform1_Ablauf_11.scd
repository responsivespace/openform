// -------------------------------------------------------------------------------------
//                                  Steuerung der Routinen
// -------------------------------------------------------------------------------------


~stimmen.do { |x|

	~modul.ablauf[x] = Task {

		//~ablauf.do { |index|

		var wahl = ~wahl[x];//(~wahl[index].sputter((1/~wahl[index].size), ~ablauf-x)).scramble; //
		var variation, time, einsatz;
		var repeat = (8-(x/2)).rrand(12-(x/2));
		var gleichzeitig;

		var channels = Array.fill(~channelsOut, {|i| i});
		var granulator1out, granulator2out, samplegrain1out, samplegrain2out;
		var delaysynth1out, delaysynth2out, rauschen1out, rauschen2out;
		var sinusglissandi1out, sinusglissandi2out;
		var granulatormix, samplegrainmix1, samplegrainmix2, delaysynthmix, rauschenmix, sinusmix;
		var start2, spielen;
		var streamOut = ~channelsOut;

		einsatz = (20*x).rrand(30*x);
		postf("START PROZEDURE % in % Sekunden, Repeat: %\n", x, einsatz.round(1e-1), repeat);

		einsatz.wait;

		// Granulator Synth 1

		~modul.granulator1out[x] = Synth.head(~master, "out",
			[\outBus, 2, \inBus, ~modul.granulatoreffectBus[x].index, \ctrincomp, 150+(100*x), \level, 0]);
		~modul.granulator2out[x] = Synth.head(~master, "out",
			[\outBus, 3, \inBus, (~modul.granulatoreffectBus[x].index)+1, \ctrincomp, 150+(100*x), \level, 0]);
		~modul.granulatormix[x] = Synth.head(~master, "out2",
			[\outBus, streamOut, \inBus, ~modul.granulatoreffectBus[x]]);

		// // Granulator Sample 2

		~modul.samplegrain1out[x] = Synth.head(~master, "out2",
			[\outBus, 2, \inBus, ~modul.samplegraineffectBus1[x], \level, 0]);
		/*samplegrain2out = Synth.head(~master, "out2",
			[\outBus, 4, \inBus, ~modul.samplegraineffectBus2[x], \level, 0]);*/

		~modul.samplegrainmix1[x] = Synth.head(~master, "out2",
			[\outBus, 0, \inBus, ~modul.samplegraineffectBus1[x]]);
		/*samplegrainmix2 = Synth.head(~master, "out2",
			[\outBus, 0, \inBus, ~modul.samplegraineffectBus2[x]]);*/

		// Delay Additiv Glockensynth

		~modul.delaysynth1out[x] = Synth.head(~master, "out2",
			[\outBus, 2, \inBus, ~modul.delaysyntheffectBus1[x], /*\ctrincomp, 160+(100*x),*/ \level, 1]);
		~modul.delaysynth2out[x] = Synth.head(~master, "out2",
			[\outBus, 4, \inBus, ~modul.delaysyntheffectBus2[x], /*\ctrincomp, 160+(100*x),*/ \level, 1]);

		~modul.delaysynthmix[x] = Synth.head(~master, "out2",
			[\outBus, streamOut, \inBus, ~modul.delaysyntheffectBus1[x], \level, 1.5]);

		// Synth Rauschen 1

		~modul.rauschen1out[x] = Synth.head(~master, "out",
			[\outBus, 2, \inBus, ~modul.rauscheneffectBus[x].index, \smooth, 1.0, \level, 0]);
		~modul.rauschen2out[x] = Synth.head(~master, "out",
			[\outBus, 3, \inBus, (~modul.rauscheneffectBus[x].index)+1, \smooth, 1.0, \level, 0]);

		~modul.rauschenmix[x] = Synth.head(~master, "out2",
			[\outBus, streamOut, \inBus, ~modul.rauscheneffectBus[x], \smooth, 1.0, \level, 1.0]);

		// Synth Sinus - Glissandi

		~modul.sinusglissandi1out[x] = Synth.head(~master, "out",
			[\outBus, 2, \inBus, ~modul.sinusglissandieffectBus[x].index, \smooth, 1.0, \level, 0]);
		~modul.sinusglissandi2out[x] = Synth.head(~master, "out",
			[\outBus, 3, \inBus, (~modul.sinusglissandieffectBus[x].index)+1, \smooth, 1.0, \level, 0]);

		~modul.sinusmix[x] = Synth.head(~master, "out2",
			[\outBus, streamOut, \inBus, ~modul.sinusglissandieffectBus[x],  \smooth, 1.0, \level, 0.8]);

		repeat.do {

			wahl.do { |auswahl|

				switch(auswahl,

					1, {
						//var outputBus = [0, 1, 2, 3, 4].choose;


						if (~modul.setgranulator[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut);
									outBus2 = rand(~channelsOut) });

								//outBus1 = (~modul.granulatorBus.index)+outBus1;
								//outBus2 = (~modul.granulatorBus.index)+outBus2;

								variation = ~tonlaenge[x]*1.rrand(4)/(x+1);
								time = 0;

								~modul.repeatgranular[x] = 1.rrand(3);
								~modul.durationgranular[x] = Array.fill(~modul.repeatgranular[x], {variation.choose});
								~modul.timegranular[x] = Array.fill(~modul.repeatgranular[x], {(~tonlaenge[x].choose)/2});
								~modul.repeatgranular[x].do ({|i|
									time = time + ~modul.durationgranular[x][i] + ~tonlaenge[x][i]});


								~modul.granulator1out[x].set(\outBus, outBus1+2, \level, 1.5);
								~modul.granulator2out[x].set(\outBus, outBus2+2, \level, 1.5);

								~modul.setgranulator[x] = 1;
								~modul.granulator[x].start;

								postf("GROUP % - Output % % – Granulartextur - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));


							},

							{spielen = 3}
						);


					},


					2, {
						//var outputBus = [0, 1, 2, 3, 4].choose;

						if (~modul.setsamplegrain[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut-1);
									outBus2 = rand(~channelsOut-1) });

								//outBus1 = ~modul.samplegrainBus+outBus1;
								//outBus2 = ~modul.samplegrainBus+outBus2;

								variation = ~tonlaenge[x]*1.rrand(4)/(x+1);
								time = 0;

								~modul.repeatsamplegrain[x] = 2.rrand(4);
								~modul.durationsamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x],
									{variation.choose});
								~modul.timesamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x],
									{(~tonlaenge[x].choose)/2});
								~modul.repeatsamplegrain[x].do ({|i|
									time = time + ~modul.durationsamplegrain[x][i] + ~modul.timesamplegrain[x][i]});
								~modul.samplegrain1out[x].set(\outBus, outBus1+2, \level, 1);
								//~modul.samplegrain2out[x].set(\outBus, outBus2+2, \level, 1);

								~modul.setsamplegrain[x] = 1;
								~modul.samplegrain[x].start;

								postf("GROUP % - Output % % – Granularsample - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));


							},

							{spielen = 3}
						);


					},

					3, {
						//var outputBus= [0, 1, 2, 3, 4].choose;



						if (~modul.setdelaysynth[x] == 0,

							{
								var outBusses = ~dodecout1;
								var outBus1, outBus2;

								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut-1);
									outBus2 = rand(~channelsOut-1)});

								/*outBus1 = outBusses.take(outBusses.choose);
								outBus2 = outBusses.take(outBusses.choose);*/

								/*outBus1 = (~modul.delaysynthBus.index)+outBus1;
								outBus2 = (~modul.delaysynthBus.index)+outBus2;*/

								variation = ~tonlaenge[x]*0.2.rrand(3);
								time = 0;

								~modul.repeatdelaysynth[x] = 3.rrand(6);
								//~tonfolgedelaysynth[x]=Array.fill(~repeatdelaysynth, {Rand(1,3)});

								~modul.durationdelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x],
									{(variation).choose});

								~modul.timedelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x],
									{(~tonlaenge[x].choose)/2});

								~modul.repeatdelaysynth[x].do ({|i|
									time = time + ~modul.durationdelaysynth[x][i] + ~modul.timedelaysynth[x][i]});


								~modul.delaysynth1out[x].set(\outBus, outBus1+2, \level, 1);
								~modul.delaysynth2out[x].set(\outBus, outBus2+2, \level, 1);


								~modul.setdelaysynth[x] = 1;
								~modul.glockensynth[x].start;


								postf("GROUP % - Output % % – Glockensynth - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));

							},

							{spielen = 3}
						);

					},


					4, {

						//var outputBus = [0, 1, 2, 3, 4].choose;

						if (~modul.setrauschen[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut);
									outBus2 = rand(~channelsOut)});

								//outBus1 = outBus1;
								//outBus2 = outBus2;

								variation = ~tonlaenge[x]/(x+1);
								time = 0;

								~modul.repeatrauschen[x] = 1.rrand(5);

								~modul.tonfolgerauschen[x]=Array.fill(~modul.repeatrauschen[x], {2.rrand(5)});

								~modul.durationrauschen[x]=Array.fill(~modul.repeatrauschen[x],
									(~tonlaenge[x].choose)/2);

								~modul.timerauschen[x]= Array.fill(~modul.repeatrauschen[x], { |irepeat|
									Array.fill(~modul.tonfolgerauschen[x][irepeat],
										{variation.choose})});


								~modul.repeatrauschen[x].do ({|irepeat|

									time = time + ~modul.durationrauschen[x][irepeat];
									~modul.tonfolgerauschen[x][irepeat].do ({ |i|
										time = time + ~modul.timerauschen[x][irepeat][i];
									});
								});

								~modul.rauschen1out[x].set(\outBus, outBus1+2, \level, 0.5);
								~modul.rauschen2out[x].set(\outBus, outBus2+2, \level, 0.5);

								~modul.sequenzdauerrauschen[x] = time;
								~modul.setrauschen[x] = 1;
								~modul.windrauschen[x].start;

								postf("GROUP % - Output % % – Rauschen - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));

							},

							{
								spielen = 3;
							}
						);


					},


					5, {
						//var outputBus= [0, 1, 2, 3, 4, 5].choose;

						if (~modul.setsinusglissandi[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut);
									outBus2 = rand(~channelsOut)});

								//outBus1 = (~modul.sinusglissandiBus.index) + outBus1;
								//outBus2 = (~modul.sinusglissandiBus.index) + outBus2;

								variation = ~tonlaenge[x] * (1+((x+1)/20));
								time = 0;

								~modul.repeatsinusglissandi[x] = 2.rrand(8-(x/2));
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

								~modul.sinusglissandi1out[x].set(\outBus, outBus1+2, \level, 0.8);
								~modul.sinusglissandi2out[x].set(\outBus, outBus2+2, \level, 0.8);


								~modul.setsinusglissandi[x] = 1;
								~modul.sinusglissandi[x].start;

								postf("GROUP % - Output % % - Sinusglissandi - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));
							},

							{spielen = 3}
						);
						// ~sinusglissandi1.value(variation);


					}

				);

				spielen = ~modul.setsinusglissandi[x] + ~modul.setrauschen[x] + ~modul.setdelaysynth[x] +
				~modul.setsamplegrain[x] + ~modul.setgranulator[x];

				if (spielen < wahl.size,

					{
						gleichzeitig = rand(3);

						if (gleichzeitig > 0,
							{
								postf("Gleichzeitiger Start, Routine %\n", x);

							},{
								(time+2.0).wait;
							}
						);

					},

					{(time+2.0).wait}
				);




		}};

		~modul.granulator1out[x].set(\level, 0);
		~modul.granulator2out[x].set(\level, 0);

		~modul.samplegrain1out[x].set(\level, 0);
		//~modul.samplegrain2out[x].set(\level, 0);

		~modul.delaysynth1out[x].set(\level, 0);
		~modul.delaysynth2out[x].set(\level, 0);

		~modul.rauschen1out[x].set(\level, 0);
		~modul.rauschen2out[x].set(\level, 0);

		~modul.sinusglissandi1out[x].set(\level, 0);
		~modul.sinusglissandi2out[x].set(\level, 0);

		2.2.wait;

		~modul.granulator1out[x].free;
		~modul.granulator2out[x].free;

		~modul.samplegrain1out[x].free;
		//~modul.samplegrain2out[x].free;

		~modul.delaysynth1out[x].free;
		~modul.delaysynth2out[x].free;

		~modul.rauschen1out[x].free;
		~modul.rauschen2out[x].free;

		~modul.sinusglissandi1out[x].free;
		~modul.sinusglissandi2out[x].free;
		//granulatormix.free; samplegrainmix.free; delaysynthmix.free; rauschenmix.free; sinusmix.free;

		postf("END OF PROZEDURE: %\n\n",x);

	};

	//};
};