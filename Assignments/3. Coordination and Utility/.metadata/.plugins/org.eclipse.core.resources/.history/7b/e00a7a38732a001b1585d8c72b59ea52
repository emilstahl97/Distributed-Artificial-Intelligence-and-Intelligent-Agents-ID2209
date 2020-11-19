/***
* Name: Festival
* Author: Emil Ståhl, Peyman Peirovifar
* Description: 
***/

model Festival

/* Insert your model definition here */

global {
	
	geometry shape <- square(100#m);
	point info_;
	point danceFloor_;
	
	init {
		create DanceFloor returns: danceFloors {location <- {70#m, 20#m};}
		create Info returns: infos {location <- {50#m, 50#m};}
		create SecurityGuard returns: guard;
		info_ <- infos[0].location;
		danceFloor_ <- danceFloors[0].location;
	}

	reflex replishGuests {
		int ns <- length(agents where (species(each) = sGuest));
		int nm <- length(agents where (species(each) = mGuest));
		if (ns < 10) {
			create sGuest number: 10 - ns {
				info <- info_;
				danceFloor <- danceFloor_;
			}
		}
		if (nm < 10) {
			create mGuest number: 10 - nm {
				info <- info_;
				danceFloor <- danceFloor_;
			}
		}
	}
	aspect default {
		draw square(100#m) at: {50, 50} color: #black;
	}
	
	reflex reportStats when: mod(cycle, 300) = 0 {

		float distTraveledsGuests <- 0.0;
		ask sGuest {
			distTraveledsGuests <- distTraveledsGuests + self.distanceTraveled;
		}

		float distTraveledmGuests <- 0.0;
		ask mGuest {
			distTraveledmGuests <- distTraveledmGuests + self.distanceTraveled;
		}
		write "Dist. traveled - sGuests: " + round(distTraveledsGuests)
			 + " m, mGuests: " + round(distTraveledmGuests) + " m";
	}
}

species Info {
	
	list<Shop> shops;
	
	init {
		create Shop returns: shop {
			location <- {20, 80};
			type <- "food";
		}
		shops <- shops + shop;

		create Shop returns: shop {
			location <- {50, 80};
			type <- "water";
		}
		shops <- shops + shop;

		create Shop returns: shop {
			location <- {80, 50};
			type <- "food";
		}
		shops <- shops + shop;

		create Shop returns: shop {
			location <- {20, 40};
			type <- "water";
		}
		shops <- shops + shop;

		//create Shop number: 4 returns: newShops {
		//	location <- rnd({10#m, 10#m}, {90#m, 90#m}, 10#m);
		//	type <- flip(0.5)? "food" : "water";
		//}
		//shops <- newShops;
	}
	
	point shopLocation(string shopType) {
		loop shop over: shuffle(shops) {
			if (shop.type = shopType) {
				return shop.location;
			}
		}
	}
	
	aspect default {
		draw sphere(3#m) at: location color: #blue;
		draw "Info" at: location + {-1.5#m, 0.5#m}  color: #white font: font('Default', 12, #bold) ;
	}
}

species Shop {
	
	float size <- 6#m;
	string type <- "food" among: ["food", "water"];
	
	aspect default {
		if (self.type = "food") {
			draw cube(size) at: location color: #red;
			draw "Food" at: location + {-2.5#m, 0} color: #white font: font('Default', 12, #bold) ;
		} else {
			draw cube(size) at: location color: #orange;
			draw "Water" at: location + {-2.5#m, 0} color: #black font: font('Default', 12, #bold) ;
		}
	}
}

species DanceFloor {
	float width <- 30#m;
	float height <- 10#m;
	aspect default {
		color <- flip(0.5)? #purple : #yellow;
		draw rectangle(width, height) at: location color: color;
		draw "Dance Floor" at: location + {-10#m, 0}  color: #black font: font('Default', 18, #bold) ;
	}
}

species Guest skills: [moving] {
	
	point info <- nil;
	point danceFloor <- nil;
	point targetPoint <- nil;
	point troublePoint <- nil;
	bool isMad <- false;
	bool hasTrouble <- false;
	bool foundCopLoc <- false;
	bool foundCop <-false;
	bool hasStolen <- false;
	int hunger <- rnd(100, 1000) min:0 max:rnd(700, 1000) update: hunger - 1;
	int thirsty <- rnd(50, 300) min:0 max:rnd(200, 300) update:thirsty - 1;
	float distanceTraveled <- 0.0;

	init {
		// Place the guest randomly
		location <- rnd({0, 0}, {100, 100});
	}

	reflex updateDistanceTraveled {
		
		// Only count the distance traveled looking for food/water
		if hunger <= 0 or thirsty <= 0 {
			distanceTraveled <- distanceTraveled + self.real_speed;
		}
	}
	
	reflex beIdle when: targetPoint = nil and !hasStolen and location distance_to(danceFloor) > 3#m{
		// do goto target: danceFloor;
		if flip(0.0005) {
			isMad <-true;
		}
		
		ask sGuest at_distance 3#m {
			if self.isMad{
				myself.hasTrouble <-true;
				self.targetPoint <- self.location;
				myself.troublePoint <- myself.location;
				self.hasStolen <- true;
				}
		}
		ask mGuest at_distance 3#m {
			if self.isMad{
				myself.hasTrouble <-true;
				self.targetPoint <- self.location;
				myself.troublePoint <- myself.location;
				self.hasStolen <- true;
				}
		}
		
		
		do wander amplitude: 90.0;
	}
	
	reflex getCop when: hasTrouble and !foundCopLoc{
		targetPoint <- info;
	}
	
	reflex getCopLoc when: hasTrouble and location distance_to(info) < 3#m {
		ask SecurityGuard {
			myself.targetPoint <- self.location;
			myself.foundCopLoc <- true;
		}
	}
	
	reflex getCopBack when: hasTrouble {
		ask SecurityGuard at_distance 2#m {
			self.targetPoint <- myself.troublePoint;
			myself.targetPoint <- myself.troublePoint;
			myself.hasTrouble <- false;
			myself.foundCopLoc <- false;
		}
	}
	
	reflex toDance when: targetPoint = nil and !hasStolen and flip(0.01) {
		targetPoint <- danceFloor + rnd({-5, -5}, {5, 5});
	}

	reflex dance when: targetPoint = nil and !hasStolen and location distance_to(danceFloor) <= 5#m{
		// do goto target: danceFloor;
		do wander amplitude: 360.0;
	}
}
///

species sGuest parent: Guest{
	
    reflex getTired when: targetPoint = nil and (hunger <= 0 or thirsty <= 0) {
		// Find Info
		// write "I am tired, going to Info";
		targetPoint <- info;
	}
	
	reflex approachTarget when: targetPoint != nil and !hasStolen and location distance_to(targetPoint) < 2#m {

		// write "Reached destination";
		self.targetPoint <- nil;
		
		ask Shop at_distance 3#m {
			if (self.type = "food") {
				myself.hunger <- 1000000;
			} else if (self.type = "water") {
				myself.thirsty <- 1000000;
			}
		}
		
		ask Info at_distance 3#m {
			// write "Asking Info";
			if (myself.hunger <= 0) {
				myself.targetPoint <- self.shopLocation("food");
			} else if (myself.thirsty <= 0) {
				myself.targetPoint <- self.shopLocation("water");
			}
		}
	}
	
	reflex moveToTarget when: targetPoint != nil and !hasStolen {
		do goto target: targetPoint;
	}
	
	aspect default {
		if hasTrouble{
			color <- #pink;
		}else if isMad{
			color <- #green;
		}else if targetPoint = info {
			color <- #blue;
		}else{
		color <- hunger <= 0? #red : (thirsty <= 0? #orange : #white);
		}
    	draw pyramid(2) color:color;
    }	
	
	
}


species mGuest parent: Guest{
	
	point recentWater <- nil;//
	point recentFood <- nil;//
	
	
	reflex getTired when: targetPoint = nil and (hunger <= 0 or thirsty <= 0) {
		
		if (hunger <= 0) and flip(0.5) and recentFood != nil{
				targetPoint <- recentFood;
			} else if (thirsty <= 0) and flip(0.5) and recentWater != nil {
				targetPoint <- recentWater;
			}else{
				targetPoint <- info;
			}
	}
	
	reflex approachTarget when: targetPoint != nil and !hasTrouble and location distance_to(targetPoint) < 2#m {

		// write "Reached destination";
		self.targetPoint <- nil;
		
		ask Shop at_distance 3#m {
			if (self.type = "food") {
				myself.hunger <- 1000000;
			} else if (self.type = "water") {
				myself.thirsty <- 1000000;
			}
		}
		
		ask Info at_distance 3#m {
			// write "Asking Info";
			if (myself.hunger <= 0) {
				myself.recentFood <- self.shopLocation("food");//
				myself.targetPoint <- self.shopLocation("food");
			} else if (myself.thirsty <= 0) {
				myself.recentWater <- self.shopLocation("water");//
				myself.targetPoint <- self.shopLocation("water");
			}
		}
	}
	
	reflex moveToTarget when: targetPoint != nil  and !hasStolen {
		
		if targetPoint != info {
			do goto target: targetPoint;
		} else {
			ask mGuest at_distance 2#m {
				// write "Asking Info";
				if (myself.hunger <= 0) {
					if self.recentFood != nil{
						myself.recentFood <- self.recentFood;//
						myself.targetPoint <- self.recentFood;
					}
				} else if (myself.thirsty <= 0) {
					if self.recentWater != nil{
						myself.recentWater <- self.recentWater;//
						myself.targetPoint <- self.recentWater;
					}
				}				
			}
			do goto target: targetPoint;		
		}
	}
	
	aspect default {
		
		if hasTrouble{
			color <- #pink;
		}else if isMad{
			color <- #green;
		}else if targetPoint = info{
			color <- #blue;
		}else{
			color <-  hunger <= 0? #red : (thirsty <= 0? #orange :  #white);
    	}
    	draw sphere(1) color:color;
    }
}

species SecurityGuard skills: [moving]{
	
	
	point targetPoint <-nil;
	
	init {
		location <- rnd({0, 0}, {100, 100});
	}
	
	reflex catchBad when: targetPoint = nil {
		ask  Guest at_distance 2#m {
			if self.hasTrouble{
				myself.targetPoint<- self.troublePoint;
				self.targetPoint <- self.troublePoint;
				self.troublePoint <- nil;
			}
		}
	}
	
	reflex moveToTarget when: targetPoint != nil {
		do goto target: targetPoint;
	}
	
	reflex kill {
		ask  sGuest at_distance 3#m {
			if self.isMad{
				ask self{
					do die;
				}
				myself.targetPoint <- nil;		
			}
		}
		ask  mGuest at_distance 3#m {
			if self.isMad{
				ask self{
					do die;
				}
				myself.targetPoint <- nil;		
			}
		}		
	}
	
	aspect default {
		draw cube(1) at: location color: #yellow;
	}
}

experiment main type:gui autorun:true {
	float minimum_cycle_duration <- 0.03#seconds;
	output {
		display my_display type:opengl background:#black
			camera_pos:{100, 100, 70} {
			species Info;
			species Shop;
			species DanceFloor;
			species Guest;
			species sGuest;
			species mGuest;
			species SecurityGuard;
		}
	}
}
