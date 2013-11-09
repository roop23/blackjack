DESCRIPTION
-----------

This codebase is developed by Sai Roop Tetali as part of the interview process with LiveRamp.
This directory contains the ruby programs and classes required for BlackJack. All the required files are present in a single directory.
The doc folder contains the RDoc generated HTML documentation for this project.

PROGRAMS (assuming ruby is located in /usr/bin/ruby)
--------

Hand.rb: Contains the class Hand
Player.rb: Contains the class Player
Blackjack.rb: Contains the class Blackjack and the instantitation of the game

All the files above are required for the program to execute.

TO RUN THE GAME
---------------

Please enter the following command from the directory in which the programs are present in the terminal.

ruby Blackjack.rb

SPECIFICATIONS
--------------

Implement a simple game of blackjack. It should employ a basic command-line interface. The program should begin by asking how many players are at the table, start each player with $1000, and allow the players to make any integer bet for each deal.

The program must implement the core blackjack rules, i.e. players can choose to hit until they go over 21, the dealer must hit on 16 and stay on 17, etc. It must also support doubling-down and splitting. You are welcome but not required to add functionality on top of these basics. We are most interested in seeing a clean codebase that we can readily understand.

Please make sure that your implementation works with Ruby 1.8.7 and avoid unnecessary dependencies. Don't hesitate to write with any questions. If your Blackjack contains more than one file, please submit all files together in either a .tar.gz or .zip archive.