/***
* Name: FinalProject
* Author: Peyman Peirovifar, Emil Ståhl
* Description: Behavior of different agents
* Tags: Tag1, Tag2, TagN
***/

model BasicModel

global {
	int number_of_places <- 9;
	int number_of_guests <- 50;
	
	int acceptance_count <- 0;
	int rejection_count <- 0;
	
	list<point> place_location <- [{10,10},{10,50},{10,90},{50,10},{50,50},{50,90},{90,10},{90,50},{90,90}];
	list<string> guest_type <- ['Extrovert', 'Introvert', 'Juicehead', 'Journalist', 'Salesman'];
	list<string> place_type <- ['Dancefloor', 'Store', 'Pub'];
	int type_assigned <- 0;
	list<place> placeList <- [];
	list<place> placeListDancefloor <- [];
	list<place> placeListStore <- [];
	list<place> placeListPub <- [];
	
	init {
		create guest number: number_of_guests;
		create place number: number_of_places;
	}
}

species place {

	string type;
	rgb color;
	bool initialized <- false;
	
	aspect base {
		if !self.initialized{
			self.initialized <- true;
			add self to: placeList;
			// Assign type
			self.type <- place_type[rnd(0, length(place_type)-1)];
			self.location <- place_location[type_assigned];
			type_assigned <- type_assigned + 1;
			if self.type = 'Dancefloor'{
				add self to: placeListDancefloor;
				self.color <- #lawngreen;
			} else if self.type = 'Store'{
				add self to: placeListStore;
				self.color <- #cyan;
			} else if self.type = 'Pub'{
				add self to: placeListPub;
				self.color <- #orange;
			}
		}
		draw rectangle(5,2) at: self.location color: #gray;
		draw string(self.type) at: self.location + {-3, 3} color: self.color font: font('Default', 12, #bold);
	}
}

species guest skills: [moving, fipa] {
	
	// Personal traits
	int kindness <- rnd(0,10);
	int sympathetic <- rnd(0,10);
	int charitable <- rnd(0,10);
	
	// Traits depending on type
	float interact_Extrovert;
	float interact_Introvert;
	float interact_Juicehead;
	float interact_Journalist;
	float interact_Salesman;
	
	int time <- 0 update: time + 1;
	int autonomy <- rnd(200,400);
	bool limit_interactions <- false;
	
	string type <- guest_type[rnd(0, length(guest_type)-1)];
	rgb color;
	point targetPoint;
	bool initialized <- false;
	bool decider;
	//added by Peyman
//	guest neighbor <- nil;
	list<guest> guestList<- [];
	bool initiater <- false;
	bool participant <- false;
	bool dialoge <- false;
	guest participant_name <- nil;
	list<guest> initiater_name <- nil;
	
	
	aspect base {
		if self.initialized = false {
			if self.type = 'Extrovert' {
				self.color <- #lawngreen;
				self.interact_Extrovert <- 1.0;
				self.interact_Introvert <- 0.5;
				self.interact_Juicehead <- with_precision(rnd(0.0,1.0),1);
				self.interact_Journalist <- 0.2;
				self.interact_Salesman <- with_precision(rnd(0.0,1.0),1);
			} else if self.type = 'Introvert' {
				self.color <- #cyan;
				self.interact_Extrovert <- 0.0;
				self.interact_Introvert <- 1.0;
				self.interact_Juicehead <- 0.0;
				self.interact_Journalist <- 0.5;
				self.interact_Salesman <- 0.0;
			} else if self.type = 'Juicehead' {
				self.color <- #orange;
				self.interact_Extrovert <- 0.4;
				self.interact_Introvert <- 0.6;
				self.interact_Juicehead <- 1.0;
				self.interact_Journalist <- 0.2;
				self.interact_Salesman <- 0.8;
			} else if self.type = 'Journalist' {
				self.color <- #magenta;
				self.interact_Extrovert <- 0.8;
				self.interact_Introvert <- 0.4;
				self.interact_Juicehead <- 0.6;
				self.interact_Journalist <- 1.0;
				self.interact_Salesman <- 0.2;
			} else if self.type = 'Salesman' {
				self.color <- #black;
				self.interact_Extrovert <- 1.0;
				self.interact_Introvert <- 0.6;
				self.interact_Juicehead <- 0.2;
				self.interact_Journalist <- 0.4;
				self.interact_Salesman <- 0.0;
			}
		}
		draw circle(0.5) color: self.color;
	}
	
	reflex move when: self.targetPoint != nil {
		if (distance_to(self.location, self.targetPoint) > 5#m) {
			do goto target: self.targetPoint;
		}
		do wander;
	}
	
	reflex choosePlace when: (self.time=self.autonomy) or (!self.initialized) {
		self.time <- 0;
		self.autonomy <- rnd(200,400);
		self.initialized <- true;
		self.limit_interactions <- false;
		self.participant <- false;
		self.initiater <- false;
		self.initiater_name<- nil;
		self.guestList<- nil;
		self.dialoge <- false;
		
		if self.type = 'Extrovert' {
			self.targetPoint <- placeListDancefloor[rnd(0, length(placeListDancefloor)-1)].location;
		} else if self.type = 'Introvert' {
			self.targetPoint <- placeListStore[rnd(0, length(placeListStore)-1)].location;
		} else if self.type = 'Juicehead' {
			self.targetPoint <- placeListPub[rnd(0, length(placeListPub)-1)].location;
		} else if self.type = 'Journalist' {
			self.targetPoint <- placeList[rnd(0, length(placeList)-1)].location;
		} else if self.type = 'Salesman' {
			self.targetPoint <- placeList[rnd(0, length(placeList)-1)].location;
		}
	}
	reflex startconversation when: (self.limit_interactions=false) and !self.participant  {
		guestList <- guest at_distance 5;
		
		if !empty(guestList) and !self.participant{
			write  name + ' I would like to know your character';
			write guestList;
			self.limit_interactions <- true;
			

			//do start_conversation (to:guestList, protocol: 'fipa-request', performative: 'inform', contents:[self.name,self.type,'I want to know about you']);
			do start_conversation with: [to :: guestList, protocol :: 'fipa-contract-net', performative :: 'inform', contents ::  [self.name,self.type] ];
			initiater <- true;
			list guestList2 <- guestList;
			int M <- length(guestList2);
			//loop while: guestList2 != nil {
			loop i from:0 to:M-1 {
				participant_name<- guestList[i];

				//write participant_name;
				participant_name.participant<- true;
				participant_name.limit_interactions<- true;
				add self to: participant_name.initiater_name;

				
				
			}
			self.initiater <- true;
			self.participant <- false;
		}
		if !empty(guestList) and self.participant{
			self.dialoge <-true;
			
		}
		 
	}

	
	
	reflex interact when:  !empty(informs) {
    	message m <- informs[0];
		//message r <- (requests at 0);
		list<unknown> c <- m.contents;
		//write c[1];
			

			if (c[1] = 'Extrovert') {
				write string(c[0]) + 'asks: Hello, ' + string(self.name) + '. I am ' + string(c[1]) + ' and I want to dance with you.';
				//message m <- (informs at 0);
				//do propose with: [ message :: m, contents :: ['Dance with me!'] ];
				if self.sympathetic>=5 {
					decider <- flip(self.interact_Extrovert);
					if decider=true {
						acceptance_count <- acceptance_count + 1;
						do agree with: [ message :: m, contents :: ['interested'] ];
						write string(self.name) + 'says: Yes, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I accept to dance with you.';
					} else if decider=false {
						rejection_count <- rejection_count + 1;
						do refuse with: [ message :: m, contents :: ['not-interested'] ];
						write string(self.name) + 'says: No, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I do not like ' + string(c[1]) + ' people.';
					}
				} else if self.sympathetic<5 {
					decider <- false;
					rejection_count <- rejection_count + 1;
					write string(self.name) + 'says: No, ' + string(c[0]) + '. I am sorry, but I am not sympathetic enough to dance with you.';
					do refuse with: [ message :: m, contents :: ['not-interested'] ];
				}
			} else if (c[1] = 'Introvert') {
				//write string(myself.name) + 'asks: Hello, ' + string(self.name) + '. I am ' + string(myself.type) + ' and I want to chill with you.';
				if self.sympathetic>=5 {
					decider <- flip(self.interact_Introvert);
					if decider=true {
						acceptance_count <- acceptance_count + 1;
						do agree with: [ message :: m, contents :: ['interested'] ];
						write string(self.name) + 'says: Yes, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I accept to chill with you.';
					} else if decider=false {
						rejection_count <- rejection_count + 1;
						do refuse with: [ message :: m, contents :: ['not-interested'] ];
						write string(self.name) + 'says: No, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I do not like ' + string(c[1]) + ' people.';
					}
				} else if self.sympathetic<5 {
					decider <- false;
					rejection_count <- rejection_count + 1;
					write string(self.name) + 'says: No, ' + string(c[0]) + '. I am sorry, but I am not sympathetic enough to chill with you.';
					do refuse with: [ message :: m, contents :: ['not-interested'] ];
				}
			} else if (c[1] = 'Juicehead') {
				//write string(myself.name) + 'asks: Hello, ' + string(self.name) + '. I am ' + string(myself.type) + ' and I want to drink with you.';
				if self.kindness>=5 {
					decider <- flip(self.interact_Juicehead);
					if decider=true {
						acceptance_count <- acceptance_count + 1;
						do agree with: [ message :: m, contents :: ['interested'] ];
						write string(self.name) + 'says: Yes, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I am inviting you for a drink.';
					} else if decider=false {
						rejection_count <- rejection_count + 1;
						do refuse with: [ message :: m, contents :: ['not-interested'] ];
						write string(self.name) + 'says: No, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I do not like ' + string(c[1]) + ' people.';
						do refuse with: [ message :: m, contents :: ['not-interested'] ];
					}
				} else if self.kindness<5 {
					decider <- false;
					rejection_count <- rejection_count + 1;
					write string(self.name) + 'says: No, ' + string(c[0]) + '. I am sorry, but I am not generous enough to invite you for a drink.';
					do refuse with: [ message :: m, contents :: ['not-interested'] ];
				}
			} else if (c[1] = 'Journalist') {
				//write string(myself.name) + 'asks: Hello, ' + string(self.name) + '. I am ' + string(myself.type) + ' and I want a picture with you.';
				if self.sympathetic>=5 {
					decider <- flip(self.interact_Journalist);
					if decider=true {
						acceptance_count <- acceptance_count + 1;
						do agree with: [ message :: m, contents :: ['interested'] ];
						write string(self.name) + 'says: Yes, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I am taking a picture with you.';
					} else if decider=false {
						rejection_count <- rejection_count + 1;
						do refuse with: [ message :: m, contents :: ['not-interested'] ];
						write string(self.name) + 'says: No, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I do not like ' + string(c[1]) + ' people.';
					}
				} else if self.sympathetic<5 {
					decider <- false;
					rejection_count <- rejection_count + 1;
					write string(self.name) + 'says: No, ' + string(c[0]) + '. I am sorry, but I am not sympathetic enough to take a picture with you.';
					do refuse with: [ message :: m, contents :: ['not-interested'] ];
				}
			} else if (c[1] = 'Salesman') {
				//write string(myself.name) + 'asks: Hello, ' + string(self.name) + '. I am ' + string(myself.type) + ' and I want to sell drugs to you.';
				if self.charitable>=5 {
					decider <- flip(self.interact_Salesman);
					if decider=true {
						acceptance_count <- acceptance_count + 1;
						do agree with: [ message :: m, contents :: ['interested'] ];
						write string(self.name) + 'says: Yes, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I am buying drugs to you.';
					} else if decider=false {
						rejection_count <- rejection_count + 1;
						do refuse with: [ message :: m, contents :: ['not-interested'] ];
						write string(self.name) + 'says: No, ' + string(c[0]) + '. I am ' + string(self.type) + ' and I do not like ' + string(c[1]) + ' people.';
					}
				} else if self.charitable<5 {
					decider <- false;
					rejection_count <- rejection_count + 1;
					write string(self.name) + 'says: No, ' + string(c[0]) + '. I am sorry, but I am not charitable enough to buy drugs to you.';
					do refuse with: [ message :: m, contents :: ['not-interested'] ];
				}
			}
		
		self.limit_interactions <- true;
	}
}

experiment BasicModel type: gui {
	output {
		display Festival {
			species place aspect: base;
			species guest aspect: base;
		}
		display Chart refresh: every(500#cycles) {
			chart "Acceptance and rejection" type: pie { 
				data "Acceptance" value: acceptance_count color: #green;
				data "Rejection" value: rejection_count color: #red;
			}
		}
	}
}