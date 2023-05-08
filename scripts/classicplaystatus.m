//Attempts to emulate to the best of it's abilities, the play symbol
//aka the green and red LED's found in the Classic Skins.
//Handles empty kbps and khz and streaming related things.

#include "..\..\..\lib\std.mi"
#include "songinfo_new.m"

Global PopUpMenu pMenu;
Global layer playstatus, POptions;
Global timer setPlaysymbol;

Global Boolean WA5MODE, playLED, currentState;

Function setState();
Function setState2();
Function loadSettingsAndDefaults();
Function ProcessMenuResult (int a);
Function UpdatePlayingStatus(String sit);

System.onScriptLoaded(){

    initSongInfoGrabber();

    Group player = getScriptGroup();
    playstatus = player.findObject("playbackstatus");
    POptions = player.findObject("playledmenu");

    setPlaysymbol = new Timer;
	setPlaysymbol.setDelay(250);
	
	currentState = true;

    setState2();

	int curstatus = getStatus();
    if(curstatus == 1){
        playstatus.setXmlParam("alpha", "255");
    }else if(curstatus <= 0/*-1*/){
        playstatus.setXmlParam("alpha", "0");
    }/*else if(curstatus == 0){
        playstatus.setXmlParam("alpha", "0");
        //playstatus.setXmlParam("image", "wa.play.green");	// not needed as we default to this on loading per the xml
    }*/
	
    loadSettingsAndDefaults();
}

loadSettingsAndDefaults(){
    WA5MODE = getPrivateInt(getSkinName(), "Winamp 5.x LED Behavior", 1);
    playLED = getPrivateInt(getSkinName(), "Winamp 5.x LED Visibility", 1);
}

POptions.onRightButtonDown (int x, int y)
{
    pMenu = new PopUpMenu;
    pMenu.addCommand("Classic Play Status", 999, 0, 1);
    pMenu.addSeparator();
	pMenu.addCommand("Winamp 5.x mode", 101, WA5MODE == 1, 0);
    pMenu.addCommand("Show LED", 102, playLED == 1, 0);
    ProcessMenuResult (PMenu.popAtMouse());
}

ProcessMenuResult (int a)
{
	if (a < 1) return;

	else if (a == 101)
	{
		WA5MODE = (WA5MODE - 1) * (-1);
		setPrivateInt(getSkinName(), "Winamp 5.x LED Behavior", WA5MODE);
	}
    else if (a == 102)
	{
		playLED = (playLED - 1) * (-1);
        playstatus.setXmlParam("visible", integerToString(playLED));
		setPrivateInt(getSkinName(), "Winamp 5.x LED Visibility", playLED);
	}
}

UpdatePlayingStatus(String sit){
	if (sit == ""){
		getSonginfo(sit);
		if(getStatus() == 1){
			bitrateint == 0;
			freqint == 0;
		}
	}
	if(sit != ""){
        getSonginfo(sit);
    }
	setState2();
}

System.onScriptUnloading(){
    deleteSongInfoGrabber();
}

System.onPause(){
    //songInfoTimer.stop();

    playstatus.setXmlParam("alpha", "0");
}

System.onResume()
{
	UpdatePlayingStatus(getSongInfoText());

    //setPlaysymbol.start();
    playstatus.setXmlParam("alpha", "255");
}

System.onPlay()
{
    String sit = getSongInfoText();
		getSonginfo(sit);
    
	UpdatePlayingStatus(sit);

    //setPlaysymbol.start();
    playstatus.setXmlParam("alpha", "255");
}

System.onTitleChange(string newtitle)
{
    UpdatePlayingStatus(getSongInfoText());

	int curstatus = getStatus();
    if(curstatus == 1){
        playstatus.setXmlParam("alpha", "255");
    }else if(curstatus == -1){
        playstatus.setXmlParam("alpha", "0");
        setPlaysymbol.stop();
    }else if(curstatus == 0){
        setPlaysymbol.stop();
        playstatus.setXmlParam("alpha", "0");
		if (!currentState){
			currentState = true;
        playstatus.setXmlParam("image", "wa.play.green");
    }
}
}

System.onStop(){
    //songInfoTimer.stop();

    playstatus.setXmlParam("alpha", "0");
	if (!currentState){
		currentState = true;
    playstatus.setXmlParam("image", "wa.play.green");
}
}

System.onInfoChange(String info){
	UpdatePlayingStatus(getSongInfoText());
}

setPlaysymbol.onTimer(){
    UpdatePlayingStatus(getSongInfoText());
}

setState(){
    String currenttitle = System.strlower(System.getPlayItemDisplayTitle());
    
    if(System.strsearch(currenttitle, "[connecting") != -1){
		if (currentState){
			currentState = false;
		playstatus.setXmlParam("image", "wa.play.red");
	}
	}
    if(System.strsearch(currenttitle, "[resolving hostname") != -1){
		if (currentState){
			currentState = false;
		playstatus.setXmlParam("image", "wa.play.red");
	}
	}
    if(System.strsearch(currenttitle, "[http/1.1") != -1){
		if (currentState){
			currentState = false;
		playstatus.setXmlParam("image", "wa.play.red");
	}
	}
    if(System.strsearch(currenttitle, "[buffer") != -1){
		if (currentState){
			currentState = false;	
		playstatus.setXmlParam("image", "wa.play.red");
		}
	}else{
        if(bitrateint == 0 || bitrateint == -1 && freqint == 0 || freqint == -1){
			if (currentState){
				currentState = false;
            playstatus.setXmlParam("image", "wa.play.red"); 
			}
            setPlaysymbol.start();
        }
        if(bitrateint > 0 && freqint > 0){setPlaysymbol.start(); 
			if (!currentState){
				currentState = true;
            playstatus.setXmlParam("image", "wa.play.green");
        }
    }
}
}

setState2(){
    if(!WA5MODE){
		int length = getPlayItemLength();
        if(getPosition() < length-1093){ //1093 was eyeballed
			if (!currentState){
				currentState = true;
            playstatus.setXmlParam("image", "wa.play.green");
			}
            setState();
        }else if(length <= 0){
			if (!currentState){
				currentState = true;
            playstatus.setXmlParam("image", "wa.play.green");
			}
            setState();
        }else{
			if (currentState){
				currentState = false;
            playstatus.setXmlParam("image", "wa.play.red"); //only ever occurs if the above conditions passed
        }
        }
    }else{
        if(getPlayItemLength() <= 0 && bitrateint == 0 || bitrateint == -1 && freqint == 0 || freqint == -1){
			if (currentState){
				currentState = false;
            playstatus.setXmlParam("image", "wa.play.red"); //has to appear first, i think i'm getting the logic wrong...
			}
        }else{
			if (!currentState){
				currentState = true;
            playstatus.setXmlParam("image", "wa.play.green");
			}
            setState();
        }
    }
}
