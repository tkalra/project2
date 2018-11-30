person(mustard).
person(scarlett).
person(plum).
person(peacock).
person(green).
person(white).

weapon(candlestick).
weapon(dagger).
weapon(poison).
weapon(revolver).
weapon(rope).
weapon(spanner).

room(kitchen).
room(ballroom).
room(conservatory).
room(dining).
room(billiard).
room(library).
room(lounge).
room(hall).
room(study).


killer(X) :- person(X), has_not(player(1), X), has_not(player(2), X), has_not(player(3), X), has_not(player(4), X), has_not(player(5), X), has_not(player(6), X).
killer(X) :- person(X), aggregate_all(count, \+ has(_, X), 1).

murder_weapon(X) :- weapon(X), has_not(player(1), X), has_not(player(2), X), has_not(player(3), X), has_not(player(4), X), has_not(player(5), X), has_not(player(6), X).
murder_weapon(X) :- weapon(X), aggregate_all(count, \+ has(_, X), 1).

murder_location(X) :- room(X), has_not(player(1), X), has_not(player(2), X), has_not(player(3), X), has_not(player(4), X), has_not(player(5), X), has_not(player(6), X).
murder_location(X) :- room(X), aggregate_all(count, \+ has(_, X), 1).


bet(player(X), player(Y), player(Z)) :- X<Y, Y<Z.
bet(player(X), player(Y), player(Z)) :- Z<X, X<Y.
bet(player(X), player(Y), player(Z)) :- Y<Z, Z<X.


has(player(P), Person) :- show(_, player(P), Person, Weapon, Room), has_not(player(P), Weapon), has_not(player(P), Room).
has(player(P), Weapon) :- show(_, player(P), Person, Weapon, Room), has_not(player(P), Person), has_not(player(P), Room).
has(player(P), Room) :- show(_, player(P), Person, Weapon, Room), has_not(player(P), Person), has_not(player(P), Weapon).


show(player(7), player(8), cpsc, 312, prolog).

has_not(player(P), Person) :- show(player(P1), player(P2), Person, _, _), bet(player(P1), player(P), player(P2)).
has_not(player(P), Weapon) :- show(player(P1), player(P2), _, Weapon, _), bet(player(P1), player(P), player(P2)).
has_not(player(P), Room) :- show(player(P1), player(P2), _, _, Room), bet(player(P1), player(P), player(P2)).


exists(Card) :- person(Card).
exists(Card) :- weapon(Card).
exists(Card) :- room(Card).

play :- card_reader,
		play_turn.


play_turn :- 	write("Is this your turn (1) or someone else's (2) ?"), nl,
				read(N1),
				(N1 = 1 ->
					write('Did you make a suggestion?'), nl,
					read(N2),
					(N2 = yes ->
						write('What was the person?'), nl, read(Person),
						write('What was the murder weapon?'), nl, read(Weapon),
						write('What was the room?'), nl, read(Room),
						write('Did somebody show a card?'), nl,
						read(N3),
						(N3 = yes ->
							write('What was the card?'), nl,
							read(Card),
							write('Which player showed the card?'), nl,
							read(P),
							assertz(has_shown(player(P), Card)),
							assertz(has(player(P), Card)),
							assertz(show(player(1), player(P), Person, Weapon, Room)),
							write('Do you want to make an accusation?'), nl,
							read(N10),
							(N10 = yes ->
								write('Do you want help?'), nl,
								read(N11),
								(N11 = yes ->
									(killer(X), murder_weapon(W), murder_location(R) ->
										write(X), write(' is the killer'), nl,
										write(W), write(' is the murder weapon'), nl,
										write(R), write(' is the murder location')
									;
										write('Not enough information yet!'), nl,
										play_turn
									)
								;
									write('End of game. Hope you won haha'), nl,
									true
								)
							;
								play_turn
							)
						;
							assertz(has_not(player(P), Person) :- dif(P, 1)),
							assertz(has_not(player(P), Weapon) :- dif(P, 1)),
							assertz(has_not(player(P), Room) :- dif(P, 1)),
							play_turn
						)
					;
						write('Do you want to make an accusation?'), nl,
						read(N10),
						(N10 = yes ->
							write('Do you want help?'), nl,
							read(N11),
							(N11 = yes ->
								(killer(X), murder_weapon(W), murder_location(R) ->
									write(X), write(' is the killer'), nl,
									write(W), write(' is the murder weapon'), nl,
									write(R), write(' is the murder location')
								;
									write('Not enough information yet!'), nl,
									play_turn
								)
							;
								write('End of game. Hope you won haha'), nl,
								true
							)
						;
							play_turn
						)
					)
				;
					write('Was there a suggestion?'), nl,
					read(N4),
					(N4 = yes ->
						write('Who made the suggestion?'), nl,
						read(P),
						write('What was the suggestion:'), nl,
						write('Person?'),
						read(Person),
						write('Weapon?'),
						read(Weapon),
						write('Room?'),
						read(Room),
						write('Did somebody show a card?'), nl,
						read(N5),
						(N5 = yes ->
							write('Who showed a card?'), nl,
							read(P_showed),
							assertz(show(player(P), player(P_showed), Person, Weapon, Room)),
							write('Did somebody make an accusation and was it true?'), nl,
							read(N101),
							(N101 = yes ->
								true
							;
								play_turn
							)
						;
							assertz(has_not(player(P2), Person) :- dif(P, P2)),
							play_turn
						)
					;
						write('Did somebody make an accusation and was it true?'), nl,
						read(N101),
						(N101 = yes ->
							true
						;
							play_turn
						)
					)
				).


card_reader :-	 write('What cards are you holding? Or enter "finished"'), nl,
				read(Card),
				( Card \= finished ->
					(exists(Card) ->
						assertz(has(player(1), Card)), assertz(has_not(player(P), Card) :- dif(P, 1)), card_reader
						; card_reader
					)
				; true
				).
