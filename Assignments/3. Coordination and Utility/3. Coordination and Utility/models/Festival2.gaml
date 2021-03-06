/***
* Name: Festival 2
* Author: Emil Ståhl, Peyman Peirovifar
* Description: 
* Author: Emil Ståhl, Peyman Peirovifar
***/

model Festival

/* Insert your model definition here */

global {
	geometry shape <- square(100#m);
	
	init {
		create MerchantDutchAuction {
			location <- {20, 80};
			type <- "cloths";
		}
		create MerchantEnglishAuction2 {
			location <- {20, 20};
			type <- "sweets";
		}
		//create MerchantSealedBidAuction {
		//	location <- {80, 50};
		//	type <- "cloths";
		//}
		/*
		create MerchantEnglishAuction {
			location <- {50, 80};
			type <- "cloths";
		}
		create MerchantSealedBidAuction {
			location <- {80, 50};
			type <- "cloths";
		}*/
		create Guest number: 15 {
			location <- rnd({0, 0}, {100, 100});
		}
		//create Guest2 number: 20 {
		//	location <- rnd({0, 0}, {100, 100});
		//}
	}

	aspect default {
		draw square(100#m) at: {50, 50} color: #black;
	}
}

species Merchant skills: [fipa] {
	
	int totalMoney <-0;
	
	float size <- 10#m;
	string type <- "cloths" among: ["cloths", "sweets"];
	int itemPrice <- 0;
	bool auctionInProgress <- false;
	list<Participant> participants <- nil;
	int countdown <- 0 min:0 max:100 update: countdown - 1;
	
	
	int highestBid <--1.0;
	message winner <-nil;
	int currentBid <- 0;
	bool announced <- false;
	list<Guest2> pGuests;
	
	
	aspect default {
		if (self.type = "cloths") {
			draw square(size) at: location color: #yellow;
			draw "Cloths" at: location + {-2.5#m, 0} color: #white font: font('Default', 12, #bold) ;
		} else {
			draw square(size) at: location color: #orange;
			draw "Sweets" at: location + {-2.5#m, 0} color: #black font: font('Default', 12, #bold) ;
		}
	}
	
	action auction_start {
		// Virtual function. See corresponding specialized classes.
	}
	
	action auction_round {
		// Virtual function. See corresponding specialized classes.
	}
	
	action auction_bid(message p) {
		// Virtual function. See corresponding specialized classes.
	}
	
	action auction_pass(message p) {
		// Virtual function. See corresponding specialized classes.
	}
	
	action auction_end {
		// Virtual function. See corresponding specialized classes.
	}
}

species MerchantBase parent: Merchant {

	list<message> messages <- nil;
	action participate (Participant participant) {
		participants <- participants + participant;
	}
	
	reflex start_auction when: !auctionInProgress and countdown = 0 {
		auctionInProgress <- true;
		participants <- nil;
		countdown <- 200;
		self.itemPrice <- rnd(10, 150);
		
		write name + ': Informing the start of a new auction (item price = $' + self.itemPrice + ')';
		loop p over: Guest {
			do start_conversation (to ::[p], protocol:: 'fipa-request',
				performative:: 'request', contents::[self.name, self.type, 'start-auction', self.location]
			);
		}
		
		// Sub-class specific.
		do auction_start;
		
	}
	
	reflex read_agree_message when: !(empty(agrees)) {
		loop a over: agrees {
			write name + ': Participant joining: ' + (string(a.contents));
		}
	}

	// Bids are submitted in these proposals!
	reflex read_propose_message when: !(empty(proposes)) {
		loop p over: proposes {
			do auction_bid(p);
		}
	}
	
	// Bids are passed in these refuses!
	reflex read_refuse_message when: !(empty(refuses)) {
		loop p over: refuses {
			do auction_pass(p);
		}
	}
	
	reflex auction_cfp when: auctionInProgress = true and countdown = 0 and !(empty(participants)) {
		countdown <- 20; // Wait time for bids collection to complete.
		
		write (name + ': Beginning an auction round ...');
		do auction_round;
	}
	
	reflex auction_cancel when: auctionInProgress = true and countdown = 0 and (empty(participants)) {
		write (name + ': No participants. Auction is canceled.');
		auctionInProgress <- false;
		countdown <- 100;
	}
	
	action auction_end {
		// End auction and ask all guests to leave.
		loop p over: participants {
			do start_conversation (to ::[p.hostGuest], protocol:: 'fipa-request',
				performative:: 'request', contents::[self.name, self.type, "end-auction", self.location]
			);
		}
		auctionInProgress <- false;
		participants <- nil;
		countdown <- 200; // Delay until next auction.
	}
}

species MerchantDutchAuction parent: MerchantBase {	
	
	int askPrice <- 0;
	
	action auction_start {
		self.askPrice <- 0;
	}
		
	// Start a new auction after 100th cycle of informing of auction.
	action auction_round {
		if askPrice = 0 {
			askPrice <- itemPrice * rnd(2, 4); // Start with very high ask price.
		} else {
			// Reduce the ask price until a buyer accepts
			askPrice <- askPrice - itemPrice * rnd(0.2, 0.3);
		}
		write name + ': [Dutch] Auction round of ' + self.type + ', at ask price $' + askPrice;
		loop p over: participants {
			do start_conversation (to:: [p], protocol:: 'fipa-contract-net',
				performative:: 'cfp', contents::[self.type, askPrice]);
		}
	}
	
	action auction_bid (message p) {
		write name + ': Winner -> ' + p.contents[0] + ' at bid = $' + p.contents[1];

		totalMoney <- totalMoney + int( p.contents[1]);
		do accept_proposal with: (message: p, contents: [name, p.contents[1]]);
		//do end_conversation with: (message: p, contents: [name]);
		do auction_end;
	}
}

species MerchantEnglishAuction2 parent: MerchantBase {	
	
	int lastBid;
	string winnerGuest <- nil;
	message winnerMsg <- nil;
	bool bidSubmitted <- false;
	bool auctionRoundInProgress <- false;
	int responses <- 0;
	
	action auction_start {
		lastBid <- 0;
	}
	
	action auction_round {
		write name + ': [English] Auction round of ' + self.type + ', at current bid $' + lastBid;
		auctionRoundInProgress <- true;
		responses <- length(participants);
		loop p over: participants {
			do start_conversation (to:: [p], protocol:: 'fipa-contract-net',
				performative:: 'cfp', contents::[self.type, lastBid]);
		}
		bidSubmitted <- false;
	}
	
	action auction_bid (message p) {
		responses <- responses - 1;
		int bid <- p.contents[1];
		write name + ': Received bid from ' + p.contents[0] + ' with bid = $' + p.contents[1];
		if bid > self.lastBid {
			write name + ': Current winner is ' + p.contents[0] + ' with bid = $' + p.contents[1];
			winnerGuest <- p.contents[0];
			winnerMsg <- p;
			self.lastBid <- bid;
			bidSubmitted <- true;
		}
	}
	
	action auction_pass (message p) {
		responses <- responses - 1;
		write name + ': Received pass from ' + p.contents[0];
	}
	
	reflex round_end when: auctionInProgress and auctionRoundInProgress and responses <= 0 {
		write name + ': Round ended';
		auctionRoundInProgress <- false;
		if bidSubmitted {
			// Start the round again
		} else {
			// End auction
			write name + ': Winner -> ' + winnerGuest + ' at bid = $' + lastBid;
			do accept_proposal with: (message: winnerMsg, contents: [name, lastBid]);
			do auction_end;
			bidSubmitted <- false;
		}
	}
}

species MerchantEnglishAuction  parent: Merchant {
	
	
	reflex announceAuction when: !auctionInProgress and countdown = 0 and !announced{		
		do start_conversation (to: list(Guest2), protocol: 'fipa-propose', performative: 'cfp', contents: ['Start', 'sweets',self.location]);		
		announced <- true;
	}
	
	reflex startAuction when: !auctionInProgress and !empty(pGuests) and (pGuests max_of (location distance_to(each.location))) <= 10
	{
		write name + " auctions "+ type;
		currentBid<-0;
		auctionInProgress <- true;
		
	}
	
	reflex getProposes when: (!empty(proposes)){
		
		loop p over: proposes {
				write name + ': offer from ' + p.sender + ' of $' + p.contents[1];
				if(currentBid < int(p.contents[1]))
				{
					currentBid <- int(p.contents[1]);
					winner <- p;
				}
			}
			

	}
	
	reflex getRejectMessages when: auctionInProgress and !empty(reject_proposals)
	{
		loop r over: reject_proposals 
			{
				pGuests >- r.sender;
			}
			if(length(pGuests) < 2)
			{

				if(currentBid > 1){
					write 'Winner is: ' + winner + ' with a bid of ' + currentBid;	
					totalMoney <- totalMoney +  currentBid;
					do start_conversation (to: winner.sender, protocol: 'fipa-propose', performative: 'cfp', contents: ['Winner']);
				}
				if(!empty(pGuests))
				{
					do start_conversation (to: pGuests, protocol: 'fipa-propose', performative: 'cfp', contents: ["End"]);
					
				}
				countdown<-200;
				pGuests <- [];
				auctionInProgress <- false;
				announced <- false;
				winner <-nil;
				currentBid<-0;	
			}
		
	}
	reflex sendInfo when: auctionInProgress and !empty(pGuests){
		
		write  name + ': Current bid: ' + currentBid ;
		do start_conversation (to: pGuests, protocol: 'fipa-propose', performative: 'cfp', contents: ["English", currentBid]);
	}
	
	
	
	
}

species MerchantSealedBidAuction  parent: Merchant {

	
	
	
	reflex announceAuction when: !auctionInProgress and countdown = 0 and !announced
	{
		
		do start_conversation (to: list(Guest2), protocol: 'fipa-propose', performative: 'cfp', contents: ['Start', 'cloths',self.location]);
		announced <- true;
	}
	
	reflex startAuction when: !auctionInProgress and !empty(pGuests) and (pGuests max_of (location distance_to(each.location))) <= 10
	{
		write name + " auctions "+type;
		auctionInProgress <- true;
		announced <- false;
	}
	
	reflex getProposes when: (!empty(proposes)){
		
		loop p over: proposes {
				write name + ': offer from ' + p.sender + ' of $' + p.contents[1];
				if(currentBid < int(p.contents[1]))
				{
					currentBid <- int(p.contents[1]);
					winner <- p;
				}
			}
			do start_conversation (to: winner.sender, protocol: 'fipa-propose', performative: 'cfp', contents: ['Winner']);
			do accept_proposal with: (message: winner, contents: ['You won!']);
			write name + ' bid ended. Sold to ' + winner.sender + ' for: ' + currentBid;
			do start_conversation (to: pGuests, protocol: 'fipa-propose', performative: 'cfp', contents: ["End"]);
			totalMoney <- totalMoney +  currentBid;
			pGuests <- [];
			countdown<-200;
			auctionInProgress <- false;
			announced <- false;
			winner <-nil;
			currentBid<-0;	

	}
	
	
	
	reflex sendInfo when: auctionInProgress and !empty(pGuests){
		write name + ': Sealed bid info';
			do start_conversation (to: pGuests, protocol: 'fipa-propose', performative: 'cfp', contents: ['Sealed']);
	}
	
	

	
}

species Guest skills: [moving, fipa] {
	point targetPoint <- nil;
	Participant myBidder <- nil;
	int totalWins <- 0;

	init {
		// Place the guest randomly
		location <- rnd({0, 0}, {100, 100});
	}

	reflex beIdle when: myBidder = nil and targetPoint = nil {
		do wander amplitude: 90.0;
	}
	
	reflex moveToTarget when: myBidder = nil and targetPoint != nil {
		do goto target: targetPoint;
	}
	
	reflex approachTarget when: myBidder = nil and targetPoint != nil and location distance_to(targetPoint) < 2 {

		write name + ': Merchant reached. Starting to participate.';
		
		// If merchant is dutch auction
		ask MerchantDutchAuction at_distance 10 {
			write name + ": Merchant is dutch auction. Assigning a bidder participant.";
			Guest ptrGuest <- myself;
			create ParticipantDutch returns: participant {
				guestName <- ptrGuest.name;
				maxPrice <- rnd(10.0, 100.0);
				increment <- 10.0;
				hostGuest <- ptrGuest;
			}
			myself.myBidder <- participant at 0;
			do participate participant: myself.myBidder;
		}
		
		// If merchant is english auction
		ask MerchantEnglishAuction2 at_distance 10 {
			write name + ": Merchant is english auction. Assigning a bidder participant.";
			Guest ptrGuest <- myself;
			create ParticipantEnglish returns: participant {
				guestName <- ptrGuest.name;
				maxPrice <- rnd(10.0, 100.0);
				increment <- 10.0;
				hostGuest <- ptrGuest;
			}
			myself.myBidder <- participant at 0;
			do participate participant: myself.myBidder;
		}
		/*
		// If merchant is sealed bit auction
		ask MerchantSealedBidAuction at_distance 10 {
			write 'Guest #' + id + ": Merchant is sealed bid auction. Assigning a bidder participant.";
			Guest ptrGuest <- myself;
			create ParticipantEnglish returns: participant {
				id <- ptrGuest.id;
				maxPrice <- rnd(10.0, 100.0);
				increment <- 10.0;
				askPrice <- 1.0;
				hostGuest <- ptrGuest;
			}
			myself.myBidder <- participant at 0;
			do participate participant: myself.myBidder;
		}
		*/
	}
	
	reflex reply_message when: (!empty(requests)) {
		
		message r <- (requests at 0);
		if myBidder = nil and r.contents[2] = 'start-auction' {
			write (name + ": Auction announcement from " + r.contents[0]);
					
			if flip(0.3) {
				write name + ': Participating in an auction by ' + r.contents[0]
					 + ' of type "' + r.contents[1] + '" at location' + r.contents[3] + '!';
				do agree with: (message: r, contents: [name]);
				targetPoint <- r.contents[3];
				targetPoint <- targetPoint + rnd({-5, -5}, {5, 5});
			} else {
				do cancel with: (message: r, contents: [name]); // Not interested
			}
		} else if myBidder != nil and r.contents[2] = 'end-auction' {
			do end_auction;
		}
		
	}
	
	//reflex auction_ended when: myBidder != nil and empty(conversations) {
	//	do end_auction;
	//}

	action end_auction {
		write name + ': Auction ended. Leaving auction. Total win so far: $' + totalWins;
		if myBidder = nil {
			return;
		}
		targetPoint <- nil;
		ask myBidder {
			do die;
		}
		myBidder <- nil;
	}
	
	action won_auction(int bid) {
		write name + ": Auction won with $" + bid + "!";
		totalWins <- totalWins + bid;
	}
	
	aspect default {
		color <- myBidder != nil? #green : #red;
    	draw pyramid(2) color:color;
    }
    
}

species Participant skills: [fipa] {
	string guestName <- nil;
	float maxPrice <- 0.0;
	float increment <- 0.0;
	Guest hostGuest <- nil;
	
	reflex bid_auction when: (!empty(cfps)) {
		loop cfp over: cfps {
			do real_bid_auction (cfp);
		}
	}
	
	reflex won_auction when: (!empty(accept_proposals)) {
		loop a over: accept_proposals {
			write name + ": Auction won! $" + a.contents[1];
			ask hostGuest {
				do won_auction(int(a.contents[1]));
			}
		}
	}
	
	reflex lost_auction when: (!empty(reject_proposals)) {
	}
	
	action real_bid_auction (message cfp) {
		// Virtual function. See corresponding specialization.
	}
}

species ParticipantDutch parent: Participant {
	action real_bid_auction (message cfp) {
		int cfpPrice <- cfp.contents[1];
		if (cfpPrice < maxPrice) {
			write guestName + ': Accepts bid at price $' + cfpPrice;
			do propose with: (message: cfp, contents: [guestName, cfpPrice]);
		} else {
			write guestName + ': Rejects bid at price $' + cfpPrice;
			do refuse with: (message: cfp, contents: [guestName, cfpPrice]);
		}
	}
}

species ParticipantEnglish parent: Participant {
	action real_bid_auction (message cfp) {
		int cfpPrice <- cfp.contents[1];
		
		// Increase bid until we reach max afordable.
		cfpPrice <- cfpPrice + rnd(5, 15);
		
		if (cfpPrice <= maxPrice) {
			write guestName + ': Proposes bid at price $' + cfpPrice;
			do propose with: (message: cfp, contents: [guestName, cfpPrice]);
		} else {
			write guestName + ': Refuses bid at price $' + cfp.contents[1];
			do refuse with: (message: cfp, contents: [guestName, cfp.contents[1]]);
		}
	}
}

species Guest2 skills:[moving, fipa]{
	
	Merchant targetMerch;
	string itemType;
	int askPrice <- rnd(10,100);
	bool wonAuction <- false;
	point target <-nil;
	
	init {
		location <- rnd({0, 0}, {100, 100});
		itemType <- flip(0.5)? 'cloths' : 'sweets';
	}

	reflex beIdle when: targetMerch = nil {
		do wander amplitude: 90.0;
	}
	
	reflex moveToTarget when: targetMerch != nil
	{
		do goto target:target + rnd({-5, -5}, {5, 5});
	}
	
	reflex listen when: (!empty(cfps)){
		
		message msg <- (cfps at 0);


		if(msg.contents[0] = 'Start' and msg.contents[1] = itemType)//Preferable item type
		{
			targetMerch  <- msg.sender;
			target <- msg.contents[2] ;

			write name + " wants " + itemType  + " from " + msg.sender;
			targetMerch.pGuests <+ self;
		}
		else if(msg.contents[0] = 'English')//English
		{
			int currentBid <- int(msg.contents[1]);
			if (askPrice > currentBid) //raise
			{
				int newOffer <-  rnd(currentBid, askPrice-1);
				do start_conversation (to: msg.sender, protocol: 'fipa-propose', performative: 'propose', contents: ['New offer: ', newOffer]);
			}
			else
			{
				write name + ": is out";
				do reject_proposal (message: msg, contents: ["Out"]);
				targetMerch <- nil;
				target <- nil;
			}
		}
		else if(msg.contents[0] = 'Sealed')//Sealed
		{
			do start_conversation (to: msg.sender, protocol: 'fipa-propose', performative: 'propose', contents: ['Offer:', askPrice]);
			targetMerch <- nil;
			target <- nil;
		}
		else if(msg.contents[0] = 'Winner')//Win
		{
			wonAuction <- true;
			write name + ' won ' + itemType;
			targetMerch <- nil;
			target <- nil;
		}
		else if(msg.contents[0] = 'End')//End
		{
			write name + ' left';
			targetMerch <- nil;
			target <- nil;
		}
		
		
	}
	
		
	
	aspect default {
		color <- targetMerch != nil? #green : #red;
    	draw pyramid(2) color:color;
    }
	
}

experiment main type:gui autorun:true {
	float minimum_cycle_duration <- 0.03#seconds;
	output {
		display my_display type:opengl background:#black
			camera_pos:{100, 100, 70} {
			species Guest;
			species Guest2;
			species MerchantSealedBidAuction;
			species MerchantEnglishAuction2;
			species MerchantEnglishAuction;
			species MerchantDutchAuction;
		}
	}
}
