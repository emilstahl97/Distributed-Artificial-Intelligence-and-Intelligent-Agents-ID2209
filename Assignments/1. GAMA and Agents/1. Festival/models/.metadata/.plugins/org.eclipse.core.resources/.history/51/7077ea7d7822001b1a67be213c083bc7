///***
//* Name: Festival
//* Athours: Emil Stahl & Peyman Peirovifar



model Festival15

/* Model definition */
global {
	

	init {
		create Guest number: 50 
		{
		informed <- false;
		WCPoint <- {0,0};
		PubPoint <-{0,0};
		RestaurantPoint <-{0,0};
		wc <- rnd(200)+50;
		thirst <- rnd(200)+100;
		hunger <- rnd(200)+100;
		wait <- 20;
		pubiter <- rnd(3);
		}
		create Pub with: (location: point(80, 80));
		create Pub with: (location: point(80, 50));
		create Pub with: (location: point(80, 25));
		create Restaurant with: (location: point(25, 80));

		create WC number:1 
		{
		location <- {25,25};
		}
		create InformationCenter number: 1
		{
			WCaddress <-{25,25};
			location <- {10,50};
			pubaddress <- {80,80};
			pub2address <- {80,50};
			pub3address <- {80,25};
			restaurantadd <- {25,80};
		}
		
		
		
	}
	
}
species InformationCenter{
	point WCaddress;
	point pubaddress;
	point pub2address;
	point pub3address;
	point restaurantadd;
	aspect default{
    	draw cylinder(8,8) at: location color: #red lighted: bool(1) ;
    }
}
species WC{
	aspect default{
    	draw box(10,5,2) at: location color: #blue lighted: bool(1) ;
    }
}
species Pub{
	aspect default{
    	draw box(10,5,2) at: location color: #green lighted: bool(1) ;
    }
}
species Restaurant{
	aspect default{
    	draw box(10,5,2) at: location color: #purple lighted: bool(1) ;
    }
}

species Guest skills:[moving, fipa] {
	//point WCaddress;
	point targetPoint;
	point WCPoint;
	point PubPoint;
	point RestaurantPoint;
	rgb myColor <- #blue;
	int wc;
	int hunger;
	int pubiter;
	int thirst;
	int wait;
	bool informed;

	

	
	aspect default{
		draw sphere(1.5) at: location color: myColor;
	}
	
	reflex gotoInfo when: ((wc <= 0 or thirst <= 0 or hunger <= 0 ) and informed = false)
	{

		targetPoint <- {10,50}; // 

		if(location = {10,50})
		{
			if wait <= 0
			{

				if wc <= 0
				{
					ask InformationCenter{
						myself.targetPoint <- WCaddress;
						myself.WCPoint<- WCaddress;				
					}						
					write name + "says: I need to go bathroom.";
				}
				if hunger <= 0
				{
					ask InformationCenter{
						myself.targetPoint <- restaurantadd;
						myself.RestaurantPoint<- restaurantadd;				
					}						
					write name + "says: I need to go bathroom.";
				}
				if thirst <= 0
				{
					if pubiter = 3
					{
						ask InformationCenter{
							myself.targetPoint <- pubaddress;
							myself.PubPoint<- pubaddress;				
						}							
					}
					else if pubiter = 1
					{
						ask InformationCenter{
							myself.targetPoint <- pub2address;
							myself.PubPoint<- pub2address;				
						}							
					}
					else if pubiter = 2
					{
						ask InformationCenter{
							myself.targetPoint <- pub3address;
							myself.PubPoint<- pub3address;				
						}							
					}
					
					
					write name + "says: I am thirsty.";
				}
				
				write name + "says: Thanks, I got it!";
				informed <- true;
				wait <- 10;
			}
			wait <- wait - 1;
		}
	}
	reflex fromInformationCentre when: informed = true
	{

		if wc <= 0
		{
			
			targetPoint <- self.WCPoint;
		
		}
		if thirst <= 0
		{
			
			targetPoint <- self.PubPoint;
		
		}
		if hunger <= 0
		{
			
			targetPoint <- self.RestaurantPoint;
		
		}
		do goto target:targetPoint;

		if(location = targetPoint)
		{
				if wait <= 0
				{
					if wc <=0
					{
						write self.name + "says:I am relieved!";
						self.wc <- rnd(200)+100;
					}
					if thirst <=0
					{
						write self.name + "says:Nice Let's go back to dancing!";
						self.thirst <- rnd(200)+100;
						pubiter <- rnd(3);						
					}
					
					self.informed <- false;
					self.wait <- 20;
					targetPoint <- {rnd(100),rnd(100)};		
					if hunger <=0
					{
						write self.name + "says:I am relieved!";
						self.hunger <- rnd(200)+100;
					}			
				}
				wait <- wait - 1;	
		}
	
	}
	reflex fromCheckpoint when: (targetPoint != nil and informed=false and wc != 0 and thirst !=0 and hunger !=0)
	{
		if (location distance_to(self.targetPoint) < 3)
		{
		myColor <- #blue;
		targetPoint <- nil;
		do wander;
		wc <- wc-1;
		thirst <- thirst-1;
		hunger <-hunger-1;
		

		}	
	}

	reflex beIdle when: (targetPoint = nil and (wc != 0 and thirst !=0 and hunger !=0)) 
	{
		myColor <- #blue;
		do wander;
		wc <- wc-1;
		thirst <- thirst-1;
		hunger <- hunger-1;
		if informed =true
		{
			self.WCPoint <- {25,25};
			if ((location distance_to(self.WCPoint) < 3) or (location distance_to(self.PubPoint) < 3) or (location distance_to(self.RestaurantPoint) < 3) )
			{
					self.RestaurantPoint<- {0,0};
					self.WCPoint <- {0,0};
					self.PubPoint <- {0,0};
					informed <- false;
			}	
		}
	}
	
	
	reflex moveToTarget when: targetPoint != nil {
		myColor <- #purple;
		do goto target:targetPoint;
	}
	

	
}


experiment main type: gui {
	output {
		display map type: opengl {
			species Guest;
			species InformationCenter;
			species Restaurant;
			species WC;
			species Pub;
		
		}
	}
}