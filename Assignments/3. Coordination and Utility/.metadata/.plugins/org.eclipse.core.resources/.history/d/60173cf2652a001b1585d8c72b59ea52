/***
* Name: Queens
* Author: Emil Ståhl, Peyman Peirovifar
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Queens

/* Insert your model definition here */

global {
	
	int N <- 6;
	int width <- 10 * N;
	geometry shape <- square(width);
	Queen headQueen <- nil;
	
	init {
		Queen lastQueen <- nil;
		int nQueens <- N;
		loop row from: 0 to: N - 1 {
			create Queen returns: q {
				N <- nQueens;
				location <- {5, 5 + row * 10};
				parent <- lastQueen;
				do moveTo(0);
			}
			lastQueen <- q[0];
			if row = 0 {
				headQueen <- lastQueen;
			}
		}
		
		// Set child
		Queen q <- lastQueen;
		loop while: q.parent != nil {
			q.parent.child <- q;
			q <- q.parent;
		}
		
		write 'Done initialization';
		
		// Begin the placement. Head queen is always ready.
		headQueen.isReady <- true;
	}

	aspect default {
		draw square(width) at: {width/2, width/2} color: #lightgreen;
	}
}

grid board cell_width: 10 cell_height: 10 {
}


species Queen skills: [moving, fipa] {
	Queen parent <- nil;
	Queen child <-nil;
	int N <- nil;
	int position <- 0;
	point targetPoint <- nil;
	bool isReady <- false;
	bool canMove <- true;
	map visited;
	
	reflex moveToTarget when: targetPoint != nil {
		do goto target: targetPoint;
	}
	
	action moveTo(int pos) {
		position <- pos;
		visited[pos] <- true;
		targetPoint <- {5 + 10 * pos, location.y};
	}
	
	// Evaluate board configuration.
	// Returns true if the given position is safe from previous parents.
	bool safeAt(int pos) {
		int generation <- 1;
		Queen q <- parent;
		loop while: q != nil {

			if pos = q.position
				or (pos - generation) = q.position
				or (pos + generation) = q.position {
				return false;
			}
			q <- q.parent;
			generation <- generation + 1;
		}
		return true;
	}
	
	bool moveToNextSafePosition
	{
		loop i from:0 to:N-2 {
			int newPos <- mod(position + i + 1, N);
			write name + ': Checking new position = ' + newPos;
			if visited[newPos] = true {
				write name + ": Already visited.";
			} else if safeAt(newPos) {
				do moveTo(newPos);
				write name + ": Placed at " + position;
				return true;
			}
		}
		return false;
	}
	
	// When all parents are placed, try to place myself
	reflex placeMe when: (parent != nil and parent.isReady and !isReady and canMove) {
		write name + ': Finding a place';
		if !moveToNextSafePosition() {
			canMove <- false;
		} else {
			isReady <- true;
		}
	}

	reflex requestParent when: !canMove {
		write name + ': Can not move, requesting parent';
		if parent = nil {
			// Asking the parent of top queen means no solution.
			write "No solution available";
		}
		do start_conversation (to ::[parent], protocol:: 'fipa-request',
			performative:: 'request', contents::[self.name, "move-next"]
		);
		canMove <- true;
	}
	
	reflex read_request_message when: !(empty(requests)) {
		write name + ': Received move-next request';
		message r <- (requests at 0);
		list<unknown> c <- r.contents;
		string x <- string(c[1]);
		if x = 'move-next' {
			if !moveToNextSafePosition() {
				canMove <- false;
				isReady <- false;
			} else {
				do start_conversation (to ::[child], protocol:: 'fipa-request',
					performative:: 'request', contents::[self.name, "reset-child"]
				);
			}
		} else if x = 'reset-child' {
			loop i from:0 to:N {
				visited[i] <- false;
			}
			if child != nil {
				do start_conversation (to ::[child], protocol:: 'fipa-request',
					performative:: 'request', contents::[self.name, "reset-child"]
				);
			}
		}
	}

	aspect default {
		color <- #red;
    	draw pyramid(2) color:color;
    }
}

experiment main type:gui autorun:true {
	float minimum_cycle_duration <- 0.03#seconds;
	output {
		display my_display type:opengl background:#white
			camera_pos:{100, 100, 70} {
			species Queen;
			grid board lines: #black ;
		}
	}
}
