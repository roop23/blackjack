#!/usr/bin/env ruby

# This file is a part of the codebase for implementation of Blackjack. Developed by Sai Roop Tetali as part of the interview process with LiveRamp.
# Since the suite of cards is of no importance to Blackjack, I am not considering them. Just the values of the cards are considered.

require 'Hand'
require 'Player'

# Assuming the number of decks with which we are playing is 8.
# This variable can be modified here, or can be asked as a user input if required.
Num_Decks = 8

# This constant variable decides the number of times the shoe has to be shuffled before the cards are dealt.
# This value should be >= 1. 
# This is because the deck has to be shuffled at least once to ensure that cards are dealt randomly to the players from the shoe.
Num_Shuffle = 8

# This constant variable is used as the initial amount of money made available to each player
Initial_Money = 1000

# A constant variable to hold the face values of the cards contained in a deck.
Cards = [2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"]

# The class Blackjack is used to represent a single blackjack table.
# An object of this class represents a real world blackjack game table.

class Blackjack  
  
  ## Start of methods
  
  # This method creates an object of the class. This method is called when a player has to be added to the table.
  # Shoe and players are set as empty arrays. The dealer's hand object is initialized only when a new round is started.
  # An object of Blackjack class represents a real world blackjack table.
  # Params: +None+
  
  def initialize()
    @shoe = Array.new
    @players = Array.new
    @num_players = 0
    @can_continue = true
    # @dealer_hand will be initialized during start_new_round when the dealer gets cards
  end
  
  # This method calls the run_game method which starts the game of blackjack on the table.
  # Params: +None+

  def start_blackjack()
    run_game()
  end

  # This method populates the shoe and then shuffles the shoe to ensure cards are obtained randomly from the shoe.
  # This method uses the global variables Num_Decks (which holds the number of decks used for the game) and
  # Cards (which is an array that holds the possible cards that a deck can be comprised of).
  # Params: +None+
  
  def init_cards()
    @shoe = Array.new
    Num_Decks.times { @shoe += Cards }
    Num_Shuffle.times { @shoe.shuffle! }
  end
  
  # This method adds a player to the players array of the table.
  # Params:
  # +money+:: the starting money of the player
  # +position+:: the position of the player on the table
  
  def add_player(money, position)
    p_entry = Player.new(money, position)
    @players.push(p_entry)
  end

  # This method gets the a valid user input for the number of players on the table and initializes the players and adds them to the table.
  # Each player gets Initial_Money ($1000) to play the game. The position of placing the users is recorded for addressing players later on.
  # Params: +None+

  def init_table()
    puts "Please enter the number of players"
    valid_value = false
    while !valid_value
      value = gets.to_i
      if value > 0
        valid_value = true
      else
        puts "Please enter a valid number"
      end
    end
    @num_players = value
    @num_players.times do |index|
      add_player(Initial_Money, index)
    end
  end

  # This starts initializes the game and starts the game loop that loops for every round of gameplay. This sets the game in action.
  # This method first calls init_cards to initialize the shoe, then init_table to initialize the players on the table.
  # Then the function goes into a loop. As long as at least one player has money to play and wants to play, 
  # the game continues. The calls inside the loop are to init_round (creates a new round) and play_round (enables one round of game play)
  # Params: +None+

  def run_game()
    init_cards()
    init_table()
    while @can_continue
      puts "\n***Get ready for a new round***\n\n"
      init_round()
      play_round()
      if @can_continue                              # Can be modified by clean_up_table method when all players run out of money
        print "\nEnter quit to end the game. Press enter to play next round : "
        if gets.chomp.eql? "quit"
          puts "\nExiting the game\n\n"
          @can_continue = false                     # end the game loop if the user wants to quit
        end
      end
    end
    puts "The game has finished. Thanks for playing!"
  end

  # This method initiates one round of gameplay. Player hands pertaining to the previous round of gameplay are cleared.
  # Params: +None+

  def init_round()
    @players.each { |player| player.clear() }     # Clear previous round information of player hands
    start_new_round()                             # Start a new round of gameplay
  end
  
  # This method is used to remove players who have run out of money on the table. Such users are informed of the action.
  # If all the players on the table are removed as a result of this, then the can_continue flag is set to false to end the game loop.
  # Params: +None+
  
  def clean_up_table()
    @players.each { |player|
      if player.out_of_money()
        puts "**** Player #{player.position} has run out of money and hence being removed from the table. ****"
      end
    }
    @players.reject! { |player| player.out_of_money() }                     # Remove players who don't have money to continue
    if @players.length == 0
      puts "**** All players on the table are out of money. ****"   # If no players remain on the table, we need to end the game
      @can_continue = false                                                 # This variable controls the game loop inside run_game()
    end
  end
  
  # This method prompts each player for their initial bet at the start of each round. The method stays in a loop asking for user input
  # until a valid bet is received. The method then returns this bet value back to the caller method.
  # Params:
  # +player+:: the object to the player that needs to place the bet

  def get_initial_bet(player)
    valid_bet = false
    while (!valid_bet)
      print "Player #{player.position}. You have money = #{player.total_money.to_s}. Please enter your bet for this round : "
      bet = gets.to_i
      if player.can_bet(bet)
        valid_bet = true                                # Bet is valid as the player has enough money to bet
      else                                              # Keep prompting for valid bet
        puts "Please enter a valid bet"
      end
    end
    return bet
  end
  
  # This method gets the user input for the initial bets of each round of gameplay.
  # Then, cards are dealt to each player and their hands are created. After all players are dealt cards, the dealer is dealt cards.
  # dealer_hand corresponds to the hand of the dealer. This object is initialized here.
  # Params: +None+

  def start_new_round()
    @players.each do |player|
      amount = get_initial_bet(player)                # Get valid user input for the initial bet
      cards = [@shoe.pop(), @shoe.pop()]              # Two cards dealt to each player
      player.start_round(cards, amount)               # Create a hand for the player for the new round
    end
    dealer_cards = [@shoe.pop(), @shoe.pop()]         # Once all players are dealt 2 cards each, the dealer gets 2 cards
    @dealer_hand = Hand.new(dealer_cards, 0)          # Dealer hand is created with a 0 (bet value is insignificanct to the dealer's)
  end

  # This method prompts each player for their double down bet at the start of each round.
  # The method stays in a loop asking for user input until a valid bet is received.
  # The method then returns this bet value back to the caller method.
  # Params:
  # +player+:: the object to the player that needs to place the bet
    
  def get_double_bet(player)
    valid_bet = false                             # Flag to keep prompting user input till valid bet is received
    while (!valid_bet)
      print "Player #{player.position} : Please enter your additional bet : "
      amount = gets.to_i
      if player.can_double_down(amount)           # Additional bet can't be > original bet
        valid_bet = true
      else
        puts "Please enter a valid bet"           # Keep prompting until user gives valid bet
      end
    end
    return amount
  end
  
  # This method is the main body of the game loop. This method runs one complete round of blackjack with the players availale on the table.
  # For each hand of each player, a loop is run which gets user action for every hand which the player has not yet played and acts accordingly.
  # Params: +None+
  
  def play_round()
    @players.each do |player|      

      while player.has_unplayed_hands()   # While the player has any more hands which he hasn't played
        player.print_player_hands()       # Print the state of the board
        print "Player #{player.position}, please enter your option - hit, stand, split or double : "   # Prompt for user input
        option = gets.chomp

        case option                               # Check for user input matching to functionaltity provided and call the respective methods
        when "hit"
          player.hit(@shoe.pop())                 # Player receives one card for the hand
        when "stand"
          player.stand()
        when "double"
          if !player.can_double()                 # Check if user has any money left as bet for double down
            puts "You don't have money to double down!"
          else
            amount = get_double_bet(player)       # Obtain the bet for doubling down
            player.double_down(amount, @shoe.pop())
          end
        when "split"
          if !player.can_split()                  # If split is not possible either due to cards not being same or lack of money
            puts "Split is not possible! Check cards and/or money available"
          else
            cards = [@shoe.pop(), @shoe.pop()]    # One card each for the hand being created as a result of split
            player.split(cards)
          end
        else                                      # If the user input was invalid, prompt for a valid input
          puts "Please enter a valid option."
        end
      end
      
    end
    end_round()                                   # Call to finalize the bettings of the round
  end
  
  # This method wraps up the round that has been played during play_round method. First the dealer's cards are shown.
  # Then the bets on the table for this round are settled. Then a clean up function is called to remove players who run out of money.
  # Params: +None+

  def end_round()
    table_settle_round()                            # The bets of the rounds are settled
    clean_up_table()                                # Remove players who run out of money
  end
  
  # This method is used to represent the play of the dealer when the players have completed playing.
  # If the dealer got a blackjack, no further action needs to be taken by the dealer.
  # Else, the dealer has to hit on hand value <= 16 and stay on hand value >= 17.
  # Params: +None+
  
  def show_dealer_cards()
    puts "Dealer original cards are #{@dealer_hand.cards.join(',')}"
    if @dealer_hand.is_blackjack()                                        # If dealer has a blackjack, no further play is required
      puts "Dealer has a blackjack!"
      return
    else
      dealer_hand_value = @dealer_hand.hand_value()                       # Compute current dealer hand value
      while dealer_hand_value < 17                                        # Hit if the hand value <= 16
        puts "Dealer hits"
        @dealer_hand.cards.push(@shoe.pop())                              # Receives one card from the shoe
        puts "Dealer current cards are #{@dealer_hand.cards.join(',')}"   # Dealer cards are displayed
        dealer_hand_value = @dealer_hand.hand_value()                     # Dealer hand value is recomputed
      end
    end
  end

  # This method is used to settle the active bets of the current round of gameplay. First the dealer cards are shown along with hand value.
  # Then this method calls the settle_round method of each player in order to settle bets according to the hand value of the dealer.
  # Params: +None+

  def table_settle_round()
    puts "\n**** Everyone in this round has completed playing ****"
    show_dealer_cards()                                                              # Dealer plays his part and then reveals the cards
    puts "Dealer final hand value = #{@dealer_hand.hand_value()}"
    @players.each do |player|                                                        # For each player
      player.settle_round(@dealer_hand.hand_value(), @dealer_hand.is_blackjack())    # Call the player's settle_round function to settle bets
    end
  end

  ## End of methods
    
end

if __FILE__ == $0
  game = Blackjack.new()      # Create an object of the Blackjack class
  game.start_blackjack()      # Start a game of blackjack
end
