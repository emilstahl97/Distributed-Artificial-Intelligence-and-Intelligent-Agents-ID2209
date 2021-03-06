///***
//* Name: Festival
//* Athours: Emil Stahl & Peyman Peirovifar

model Festival

global {
	
	init {
		
		seed <- 10.0;
		bool alternateFlag;
		
		create Guest number: rnd(15,25)	{
			location <- {rnd(100), rnd(100)};
		}
		
		create Store number: rnd(5,10) {
			location <- {rnd(100), rnd(100)};
			// blue: bar, red: restaurant
			if(alternateFlag) {
				color <- #blue;
				bar <- true;
				restaurant <- false;
				alternateFlag <- false;
			} else {
				color <- #red; 
				bar <- false;
				restaurant <- true;
				alternateFlag <- true;
			}
		}
		
		create InformationCenter number: 1 {
			location <- {50, 50};
		}
				
	}

}


species Store {
	
	bool bar <- false;
	bool restaurant <- false;
	rgb color <- #white;
	point loc <- {50, 50};
	
	aspect default {
		draw cube(8) at: location color: color; 
	}
}
species Guest skills: [moving] {
	
	int thirsty <- rnd(1000);
	int hungry <- rnd(1000);
	point informationCenterLocation <- {50, 50};
	rgb color <- nil;
	point targetPoint <- nil;
	Store targetStore <- nil;
	bool alternateFlag;
	
	aspect default {
		draw sphere(2) at: location color: color;
	}
	
}

species InformationCenter {

	aspect default {
		draw pyramid(15) at: location color: #black;
	}	
}

	



experiment main type: gui {
	output {
		display map type: opengl 
		{
			species Guest;
			species Store;
			species InformationCenter;
		}
	}
}
