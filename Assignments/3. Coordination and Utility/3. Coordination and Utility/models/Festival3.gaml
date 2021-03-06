/***
* Name: Festival
* Author: Emil Ståhl, Peyman Peirovifar
* Description: 
***/

model Festival3

/* Insert your model definition here */

global {
	
	geometry shape <- square(120#m);
	point info_;
	list<DanceFloor> danceAll;
	list<point> danceFloor_;
	int totalGuests;
	
	list<Guest> guestsAll;
	
	init {
		create DanceFloor returns: d1 {location <- {100#m, 20#m};}
		danceFloor_ <+ d1[0].location;
		
		create DanceFloor returns: d2 {location <- {20#m, 100#m};}
		danceFloor_ <+ d2[0].location;
		create DanceFloor returns: d3 {location <- {100#m, 100#m};}
		danceFloor_ <+ d3[0].location;
		create DanceFloor returns: d4 {location <- {20#m, 20#m};}
		danceFloor_ <+ d4[0].location;
		
		danceAll <+d1[0];
		danceAll <+d2[0];
		danceAll <+d3[0];
		danceAll <+d4[0];
		
		totalGuests <- 10;
		create Guest number: totalGuests-2 {
			location <- rnd({0, 0}, {120, 120});
			crowdW <- rnd(0.0,1.0,0.1);			
		}
		create Guest number: 2 {
			location <- rnd({0, 0}, {120, 120});
			crowdW <- -2.5;			
		}
		
		
		
	}

	
	aspect default {
		draw square(100#m) at: {50, 50} color: #black;
	}
	
	
}



species DanceFloor skills: [fipa] {
	float width <- 30#m;
	float height <- 30#m;
	bool eventOn <- false;
	int countdown <- 100 * rnd(1,12,1) update: countdown - 1;
	
	float band<- 0.0;
	float lights<- 0.0;
	float sound<- 0.0;
	float djset<-0.0;
	float vibe <- 0.0;
	
	float crowdmass<-0.0;
	
	
	list<Guest> guestsIn <- [];
	
	int red <- 0;
	int green <-0;	
	
	init{
		band<- rnd(0.0,1.0,0.1);
		lights<- rnd(0.0,1.0,0.1);
		sound<- rnd(0.0,1.0,0.1);
		djset<-rnd(0.0,1.0,0.1);
		vibe <- rnd(0.0,1.0,0.1);
	}
	
	aspect default {
		
		if eventOn{
			color <- flip(0.5)? #purple : rgb(red,green,0);
			
			
		}else{
			color <-#white;
		}
		
		draw rectangle(width, height) at: location color: color;
		draw "Sound: "+string(sound) at: location + {-10#m, 0}  color: #white font: font('Default', 18, #bold) ;
		draw "Lights: "+string(lights) at: location + {-10#m, 3}  color: #white font: font('Default', 18, #bold) ;
		draw "DjSet: "+string(djset) at: location + {-10#m, 6}  color: #white font: font('Default', 18, #bold) ;
		draw "Vibe: "+string(vibe) at: location + {-10#m, 9}  color: #white font: font('Default', 18, #bold) ;
	}
	
	
	reflex crowdmassUpdate{
		if empty(guestsIn) {
			crowdmass <- 0.0;
		}else{
			crowdmass <-  length(guestsIn)/totalGuests;
		}
		
		red <- int((crowdmass > 0.5 ? 1 - 2 * (crowdmass - 0.50) : 1.0) * 255);
		green <- int((crowdmass > 0.5 ? 1.0 : 2 * crowdmass ) * 255);
	}
	
	
	
	
	
	//fipa
	
	reflex announceEvent when: !eventOn and countdown = 0 {	
		
		
			
		do start_conversation (to: guestsAll, protocol: 'fipa-propose', performative: 'cfp', contents: ['Start', band, lights,sound,djset,vibe,crowdmass,self,self.location]);
		write name + ' starts event';
		eventOn <- true;
		countdown <- int(1000 * rnd(0.7,1.0,0.1));
	}
	
	
	
	reflex listen when: eventOn and (!empty(cfps)){
		
		message msg <- (cfps at 0);
		
		if(msg.contents[0] = 'Query' ){
			
			do start_conversation (to: msg.sender, protocol: 'fipa-propose', performative: 'cfp', contents: ['Start', band, lights,sound,djset,vibe,crowdmass,self,self.location]);
			
			//write name + ': '+ msg.sender +' asked info';
			
		}else if(msg.contents[0] = 'Remove' ){
			
			//guestsIn >- msg.sender;
			//write name +" removed "+msg.sender;
		}
		
		
		
		
	}
	
	reflex end_event when: eventOn and countdown = 1{  
		
		if !empty(guestsIn){
			do start_conversation (to: guestsIn, protocol: 'fipa-propose', performative: 'cfp', contents: ['End']);	
			
		}
		
		
		eventOn <- false;
		guestsIn <-[];
		countdown <- 500;
		
	}
	
	
	
}

species Guest skills: [moving , fipa]{
	
	point targetPoint <- nil;
	
	float bandW<- 0.0;
	float lightsW<- 0.0;
	float soundW<- 0.0;
	float djsetW<-0.0;
	float vibeW <- 0.0;
	float currentUtil;
	
	float crowdW<-0.0;
	
	
	DanceFloor currentDancefloor <- nil;
	
	bool isIdle <- true;


	init {
		// Place the guest randomly
		guestsAll <+ self;
		currentUtil<-0.0;
		bandW<- rnd(0.0,1.0,0.1);
		lightsW<- rnd(0.0,1.0,0.1);
		soundW<- rnd(0.0,1.0,0.1);
		djsetW<-rnd(0.0,1.0,0.1);
		vibeW <- rnd(0.0,1.0,0.1);
		//crowdW <- flip(0.7)? 0.5:-1.5;
		
	}

	
	reflex beIdle when: currentDancefloor = nil {		
		
		do wander amplitude: 90.0;
	}
	
	
	reflex toDance when: currentDancefloor != nil  {
		targetPoint <- currentDancefloor.location + rnd({-25, -25}, {25, 25});
		
		if(time mod 100 = 0) and flip(0.5){
			
					do send_query_message;
					write "Mod for "+name;
		}
		
		do goto target: targetPoint;
		
	}

	//reflex dance when: targetPoint = nil and currentDancefloor != nil{
	//	 do goto target: currentDancefloor.location;
	//	do wander amplitude: 360.0;
	//}
	
	
	action calcUtility(DanceFloor d){
		
		
		
		return (d.band * self.bandW + d.lights * self.lightsW + d.sound * self.soundW + d.djset * self.djsetW + d.vibe * self.vibeW + d.crowdmass * self.crowdW );
		
	}
	
	
	//fipa
	
	reflex listen when: (!empty(cfps)){
		
		message msg <- (cfps at 0);


		if(msg.contents[0] = 'Start' )//Event start
		{			
			
			float util <- float( calcUtility(msg.contents[7]));
			
			//write " Event from "+ msg.sender;
			if (util > currentUtil){
					write name+": Proposed util: "+ util + "for "+msg.contents[7]+" is better than "+currentUtil;
					currentUtil <- util;
					
					if currentDancefloor!=nil{
						
						do start_conversation (to: [currentDancefloor], protocol: 'fipa-propose', performative: 'cfp', contents: ['Remove']);						
						currentDancefloor.guestsIn >- self;
					}
					
					do accept_proposal ( message : msg, contents : [] );
					currentDancefloor<- msg.contents[7];
					isIdle <- false;
					currentDancefloor.guestsIn <+self;
					
					
			}else{
					do reject_proposal ( message : msg, contents : [] );
			}
			
			
		}else if(msg.contents[0] = 'End' ){
					write " Event from "+ msg.sender+" ended";
					currentDancefloor.guestsIn >-self;
					currentDancefloor<-nil;
					targetPoint <- nil;
					isIdle<-true;
					currentUtil <-0.0;
					
					do send_query_message;
		}
		
				
		
	}

	
	action send_query_message  {
		//write name + ' sends a query message';
		loop d over: danceAll{
			if d.eventOn{
				do start_conversation (to :: [d], protocol :: 'fipa-propose', performative :: 'cfp', contents :: ['Query']);
				//write name + ' sends a query message to '+ d;
				}
		}
		
	}
	
	
	
	aspect default {
		color <- #blue;
    	draw sphere(1) color:color;
    }
	
	
}
///

species Leader parent:Guest{
	
	
	
}


experiment main type:gui autorun:true {
	float minimum_cycle_duration <- 0.03#seconds;
	output {
		display my_display type:opengl background:#black
			camera_pos:{100, 100, 70} {
			species DanceFloor;
			species Guest;
		}
	}
}
