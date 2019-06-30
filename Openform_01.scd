({
	/****************************************************
	-----------------------------------------------------
	-----------------    Openform 1 ---------------------
	© Raimund Vogtenhuber - 14.4.2013
	-----------------------------------------------------

	Set Channels: --- >  ~channelsOut = ?;

	Write Path of Folder in which the files are: ----->
	~folder = "/Users/????/Desktop/Openform1_final";

	Start with command+Return (cursor within the brackets)


	****************************************************/

	~channelsOut = 4; // 26 Kanäle?? - 24 Outputs + 2 Subwoofer?

	//s.quit;
	//s.reboot;
	o = Server.local.options;

	o.device = "JackRouter";
	//ServerOptions.devices; // get list of audio devices
	//o.device = "Fireface 800 (1EA)";

	o.numOutputBusChannels = ~channelsOut+2;
	o.memSize = 2.pow(20);
	o.numAudioBusChannels = 2048;
	o.sampleRate = 44100;
	o.maxNodes = 1024*12;
	//s.volume = -12;


	s.bootSync();
	o.blockSize;
	o.memSize;
	o.numAudioBusChannels;

	~folder = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "samples/").pathOnly;
	~files = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "samples/").files;

	~filename = Array.newClear(~files.size);
	~filename = Array.fill(~files.size,
		{ |index| ~folder +/+ ~files[index].fileName});

	~file = Array.newClear(~files.size);
	~files.size. do { |i|
		~file[i] = Buffer.readChannel(s, ~filename[i], channels: [0, 1]);
	};//
	~setfile = ~files.size;

	thisProcess.openUDPPort(9002);
	~oscsend1 = NetAddr("localhost", 12001);
	//~oscsend1 = NetAddr("localhost", 12001);

	~oscsend2 = NetAddr("localhost", 12002);
	//~oscsend2 = NetAddr("localhost", 12002);

	~oscsend3 = NetAddr("localhost", 12003);
	//~oscsend3 = NetAddr("localhost", 12003);

	~oscsend4 = NetAddr("localhost", 9000);


	//~oscsend4 = NetAddr("vitlab.ch", 64463);


	//"169.254.4.168" "169.254.123.93" "http://95.143.172.134:62147/""localhost" "224.0.0.1",

	// ---------------------------------------------------------------------------------
	//                                Globale Setting
	// ---------------------------------------------------------------------------------

	~stimmen = 5;
	~ablauf = 5;
	~polygon1 = [[1, 2, 3, 4, 5],
		[3, 4, 9, 14, 8], [2, 3, 8, 13, 7], [1, 6, 12, 7, 2], [5, 10, 11, 6, 1], [4, 9, 15, 10, 5],
		[8, 13, 18, 19, 14], [7, 12, 17, 18, 13], [6, 11, 16, 17, 12], [10, 15, 20, 16, 11], [9, 14, 19, 20, 15],
		[16, 17, 18, 19, 20]];
	~polygon2 = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15], [16, 17, 18, 19, 20]];
	~dodecout1 = ~polygon1-1;
	~dodecout2 = ~polygon2-1;

	"----------- START SEQUENZ  ----------------\n\n".postln;

	// -------------------------------------------------------------------------------------
	//                          Frequenzen und Zeitdauern bestimmen
	// -------------------------------------------------------------------------------------

	~modus = Array.newClear(~stimmen);
	~tonlaenge = Array.newClear(~stimmen);
	~basistime = Array.newClear(~stimmen);


	~ausgangsfreq = 22.rrand(40);
	~ausgangszeit = 40.rrand(45);
	postf("Ausgangsfreqenz: % \nAusgangszeit = %\n", ~ausgangsfreq, ~ausgangszeit);

	~stimmen.do ({ |x|

		var modusanzahl = 2.rrand(6);
		var tonlaengeanzahl = 2.rrand(6);
		var basefreq, teilton, ausgangfreq;
		var basistime, timedivisor;

		~modus[x] = Array.newClear(modusanzahl);
		~tonlaenge[x] = Array.newClear(tonlaengeanzahl);


		basefreq = ~ausgangsfreq * [2, 3].choose;
		teilton = [1, 2, 3, 4, 5, 6].choose;
		postf("Basisfreqenz %: %\n", x, basefreq);
		~basistime[x] = ~ausgangszeit / [2, 3, 4].choose;
		timedivisor = 2.rrand(4);

		postf("Basistime %: %, Divisor: %\n", x, ~basistime[x].round(1e-3), timedivisor);

		~modus[x] = basefreq*(Array.series(modusanzahl,teilton,1));
		~tonlaenge[x] =    ~basistime[x]/(Array.series(tonlaengeanzahl,timedivisor,timedivisor));

		~modus[x].postln;
		~tonlaenge[x].round(1e-2).postln;

	});


	// -------------------------------------------------------------------------------------
	//                                    Synthdefs
	// -------------------------------------------------------------------------------------


	"Openform1_Synthdefs_11.scd".loadRelative;

	// -------------------------------------------------------------------------------------
	//                                   Soundmodule
	// -------------------------------------------------------------------------------------

	"Openform1_Soundmoduls_11.scd".loadRelative;

	// Sync for Synth Definition and boot server

	s.sync;

	// ------------------------------------------------------------------------------------

	// ~oscsend2.sendMsg("/dodec", 4, -0.0257588904351, 271.91271972656, 0.0099999997764826, 0 );

	// -------------------------------------------------------------------------------------
	//                                Send OSC - Datas
	// -------------------------------------------------------------------------------------

	~oscOut1 = OSCFunc({
		arg msg, time, cmdname;
		var object, vol, freq, pos, copy;

		//msg.postln; //- to see the full message

		cmdname = msg[0].value.asString;
		object = msg[2].value.asInt;
		vol = msg[3].value;
		freq = msg[4].value;
		pos = msg[5].value;
		copy = msg[6].value.asInt;

		~oscsend1.sendMsg("/noisy", object, vol, freq, pos, copy);
		~oscsend2.sendMsg("/noisy", object, vol, freq, pos, copy);
		~oscsend3.sendMsg("/noisy", object, vol, freq, pos, copy);
		~oscsend4.sendMsg("/noisy", object, vol, freq, pos, copy);
		// postf("Message: %, %, %, %, %, %\n", cmdname, object, vol, freq, pos, copy);
	},'/noisy', s.addr);

	~oscOut2 = OSCFunc({
		arg msg, time, cmdname;
		var object, vol, freq, pos, copy;

		//msg.postln; //- to see the full message

		cmdname = msg[0].value.asString;
		object = msg[2].value.asInt;
		vol = msg[3].value;
		freq = msg[4].value;
		pos = msg[5].value;
		copy = msg[6].value.asInt;

		~oscsend1.sendMsg("/sinus", object, vol, freq, pos, copy);
		~oscsend2.sendMsg("/sinus", object, vol, freq, pos, copy);
		~oscsend3.sendMsg("/sinus", object, vol, freq, pos, copy);
		~oscsend4.sendMsg("/sinus", object, vol, freq, pos, copy);
		// postf("Message: %, %, %, %, %, %\n", cmdname, object, vol, freq, pos, copy);
	},'/sinus', s.addr);

	~oscOut3 = OSCFunc({
		arg msg, time, cmdname;
		var object, vol, freq, pos, copy;

		//msg.postln; //- to see the full message

		cmdname = msg[0].value.asString;
		object = msg[2].value.asInt;
		vol = msg[3].value;
		freq = msg[4].value;
		pos = msg[5].value;
		copy = msg[6].value.asInt;

		~oscsend1.sendMsg("/klank", object, vol, freq, pos, copy);
		~oscsend2.sendMsg("/klank", object, vol, freq, pos, copy);
		~oscsend3.sendMsg("/klank", object, vol, freq, pos, copy);
		~oscsend4.sendMsg("/klank", object, vol, freq, pos, copy);
		// postf("Message: %, %, %, %, %, %\n", cmdname, object, vol, freq, pos, copy);
	},'/klank', s.addr);


	// -------------------------------------------------------------------------------------
	//                                 5 Soundmodelle
	// -------------------------------------------------------------------------------------


	~testwahl = {

		~wahl = Array.newClear(~ablauf);


		~wahl[0] = [1, 2];
		~wahl[1] = [1, 2];
		~wahl[2] = [1, 2, 5];
		~wahl[3] = [2, 3, 5];
		~wahl[4] = [2, 3, 4];
		/*~wahl[5] = [2, 3];
		~wahl[6] = [1, 4];
		~wahl[7] = [1, 2];*/

		postf("Auwahl = %\n", ~wahl);


	};

	// -------------------------------------------------------------------------------------
	//                                  Ablauf bestimmen
	// -------------------------------------------------------------------------------------

	~prowahl =
	{

		var oldwahl, zaehler = 0;
		var task = [1, 2, 3, 4, 5];
		~wahl = Array.newClear(~ablauf);


		oldwahl = task.take(task.wchoose([0.3, 0.3, 0.3, 0.05, 0.05]));

		~ablauf.do ({ |x|

			var auswahl1, auswahl2, auswahl3;

			if (task.size < 1, {task =  [1, 2, 3, 4, 5]; task.remove(oldwahl)});

			auswahl1 = oldwahl;
			auswahl2 = task.take(task.choose);
			oldwahl = auswahl2;
			zaehler = zaehler + 1;

			if (zaehler > 2,
				{
					if (task.size < 1, {
						task =  [1, 2, 3, 4, 5];
						task.remove(auswahl1); task.remove(auswahl2)
					});
					auswahl3 = task.take(task.choose);
					~wahl[x] = [auswahl1, auswahl2, auswahl3];
					zaehler = 0;

				},{
					~wahl[x] = [auswahl1, auswahl2];

			});

			postf("Auwahl[%] = %, task = %\n", x, ~wahl[x], task);
		});

	};

	// -------------------------------------------------------------------------------------
	//                                  Steuerung der Routinen
	// -------------------------------------------------------------------------------------

	~masterout = Synth.tail(~master, "limiter", [\level, 1]);

	//	~startRecordingToDisk.value("Version6¨_");

	//~testwahl.value;
	~prowahl.value;

	"Openform1_Ablauf_11.scd".loadRelative;

	~openformStart = {

		~stimmen.do ({ |x|
			~modul.ablauf[x].play;
		});

	};

	~openformStop = {

		~osclogAll.close;


		~stimmen.do ({ |x|
			~modul.ablauf[x].stop;
			~modul.ablauf[x].reset;
		});

	};

	"Openform1_Test_11.scd".loadRelative;

    //~test1.play;
	//~test2.play;
	//~test3.play;
	//~test4.play;
	//~test5.play;

	//~test1.reset;
	//~test2.reset;
	//~test3.reset;
	//~test4.reset;
	//~test5.reset;
	// ~stopRecordingToDisk.value;
	//~nowstart.value;

	// Routine
	~nowstart = {

		~openformStart.value();
		~oscsend2.sendMsg("/command", 0);
		~oscsend3.sendMsg("/command", 0);
	};

	~oscsend2.sendMsg("/command", 1);

	~oscsend3.sendMsg("/command", 1);

	//~nowstart.value;


}.fork;

~nowstart.value;

)


/*________________________________________________________________________________________
________________________________________________________________________________________

----------------------------- End of Program -------------------------------------------*/

