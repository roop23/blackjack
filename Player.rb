#!/usr/bin/env ruby

# This file is a part of the codebase for implementation of Blackjack. Developed by Sai Roop Tetali as part of the interview process with LiveRamp.

require 'Hand'

# The class Player is used to represent a single player at the table.
# An object of this class represents a real world person who is at a Blackjack table.

class Player
  
  ## Start of attributes

  # Represents the total money available to the player at the start of the round.
  # This attribute is updated at the end of each round with respect to the result of the round.
  # This attribute is also used to validate whether a player can use doubling down or splitting options, if available.
  attr_reader :total_money
  
  # Represents the position of the player across the table. This attribute is used to address players by their position.
  attr_reader :position
  
  ## End of attributes
  
  ## Start of methods
  
  # Creates an object of Person. The default values of hands is an empty array as the player hasn't been dealt cards yet.
  # This method is called when a player has to be added to the table.
  # current_hand is a variable that keeps track of the current hand that is being played by the player.
  # current_hand starts/resets at 0. This variable increases when the player has finished playing the current hand.
  # When current_hand reaches hands.length + 1, it indicates that all hands of the player have been completed dealing with.
  # Params:
  # +total_money+:: initial sum of money made available to the player for bets
  # +position+:: the position of the player on the table
  
  def initialize(total_money, position)
    @total_money = total_money
    @position = position
    @hands = Array.new
    @current_hand = 0
  end

  # Creates the first hand of the new round and reduces the bet amount from the player's total_money value.
  # This method is called when a player places a valid bet and receives cards for the first time in each new round of gameplay.
  # Params:
  # +cards+:: the array of two cards which form the hand
  # +bet+:: the bet amount which is associated with this hand
  
  def start_round(cards, bet)
    new_hand = Hand.new(cards, bet)
    place_bet(bet)
    @hands.push(new_hand)
    @current_hand = 0
    check_blackjack()
  end
  
  # This method clears the hands that were present in the previous round. It resets the hands to an empty array.
  # Params: +None+

  def clear()
    @hands = Array.new
  end

  # This method returns a boolean value indicating if the player has a positive balance of money left.
  # Params: +None+
  
  def out_of_money()
    @total_money <= 0
  end

  # This method returns a boolean value indicating if the amount received is a valid bet.
  # A bet amount if valid if it is positive and if the player has total_money of at least the amount passed as the bet amount.
  # Params:
  # +amount+:: the value of bet which is given as user input
  
  def can_bet(amount)
    amount > 0 && amount <= @total_money
  end
  
  # This method returns a boolean value indicating if the player has enough money left to perform a double down.
  # Params: +None+
  
  def can_double()
    hand = @hands[@current_hand]
    @total_money > 0
  end
  
  # This method returns a boolean value indicating if the amount received is a valid bet for a double down.
  # A bet amount if valid if it is positive and if the player has total_money of at least the amount passed as the bet amount.
  # The additional condition is that the new bet value must be <= original bet of this hand for a double down.
  # Params:
  # +amount+:: the value of double down bet which is given as user input  
  
  def can_double_down(amount)
    hand = @hands[@current_hand]
    amount > 0 && amount <= hand.bet && amount <= @total_money
  end

  # This method places the user bet on the table. The bet amount is reduced from the player's money.
  # Params:
  # +amount+:: the bet value
  
  def place_bet(amount)
    @total_money -= amount
  end

  # This method places the double down bet on the table. The bet amount is reduced from the player's money.
  # The bet of the hand is increased by the double down bet amount.
  # Params:
  # +amount+:: the value of double down bet which has already been validated
  
  def place_double_bet(amount)
    hand = @hands[@current_hand]
    hand.bet += amount
    @total_money -= amount
  end
  
  # This method is used to settle the bets of all hands of the player which are active at the end of the current round.
  # For each hand which is not bust or not a blackjack,
  # the hand value is compared with that of the dealer and a respective action is taken based on the comparison.
  # Params:
  # +dealer_value+:: the hand value of the dealer's cards
  # +dealer_has_blackjack+:: boolean flag indicating if the dealer has a blackjack or not

  def settle_round(dealer_value, dealer_has_blackjack)
    @hands.each do |hand|
      if !hand.is_bust()                                                      # Only deal with hands that are still active
        if !(hand == @hands[0] && hand.is_blackjack())                        # Blackjack hands are already considered inside start_round
          if dealer_value > 21 || (hand.hand_value() > dealer_value)          # Player won! Add winnings of the hand to the player
            puts "Player #{@position} wins against the dealer"
            add_winnings(hand, blackjack=false, push=false)
          elsif dealer_has_blackjack || hand.hand_value() < dealer_value      # If dealer has a blackjack or has higher hand value
            puts "Player #{@position} loses to the dealer"                    # User loses the bet he played
          elsif hand.hand_value() == dealer_value                             # Player drew. He gets back the bet he placed for the hand
            puts "Player #{@position} gets a push"
            add_winnings(hand, blackjack=false, push=true)
          end
        end
      end
    end   
  end
  
  # This method prints the information of each hand that the player has.
  # The method calls the hand.to_s method to get a string that contains the hand information and prints it on the console.
  # Params: +None+

  def print_player_hands()
    puts "--- Player #{@position} --- "
    @hands.each do |hand|                               # The player might have multiple hands, if splitting was used
      puts hand.to_s()                                  # Print the details of the hand
    end
  end

  # This method adds the winnings of the hand to the player.
  # Params:
  # +hand+:: the hand under consideration
  # +blackjack+:: boolean value indicating if the player got a blackjack or not
  # +false+:: boolean value indicating if the player drew against the dealer

  def add_winnings(hand, blackjack=false, push=false)
    if push                                   # The user drew with the dealer, only gets back the bet placed
      @total_money += hand.bet
    else                                      # The user won against the dealer
      if blackjack
        @total_money += (hand.bet * 2.5)      # If the player got a blackjack, he wins 3:2. So, the total is 2.5 times the bet placed
      else
        @total_money += (hand.bet * 2)        # Else the player wins the 1:1. So, the total is 2 times the bet placed
      end
    end
  end
  
  # This method checks if the original hand received by the player during the beginning of the round is a blackjack or not.
  # If the hand is a blackjack, it calls add_winnings to credit the player with the winnings for the particular hand.
  # Params: +None+
  
  def check_blackjack()
    hand = @hands[0]
    if hand.is_blackjack()
      print_player_hands()
      puts "Player #{@position} has a blackjack. You win 3:2!"
      add_winnings(hand, blackjack=true)                # Add the winnings of the bet to the player
      @current_hand += 1
    end
  end
  
  # This method returns a boolean variable indicating if the user still has at least one hand which he has to play.
  # Params: +None+

  def has_unplayed_hands()
    @current_hand < @hands.length
  end
  
  # This method is called when the player chooses to hit on the curernt hand. The method first identifies the current hand on which the player
  # is playing. Then it pushes the new card to the the hand. If the resulting hand is a bust, it reports to the user. A bust results
  # in the hand being completed w.r.t the user action and also w.r.t the dealer.
  # +card+:: the new card picked out of the shoe
  
  def hit(card)
    hand = @hands[@current_hand]
    hand.cards.push(card)
    puts "New card received - #{card}"
    if hand.is_bust()
      print_player_hands()
      puts "Player #{@position} busts!"
      @current_hand += 1
    end
  end
  
  # This method is called when the player chooses to hit on a hand. When a user decides to stand, he has completed acting on the hand.
  # Params: +None+
  
  def stand()
    @current_hand += 1
  end
  
  # This method is called when the player chooses to double down on the current hand. First, this method places the additional bet of the user.
  # Then it calls hit with the new card to accept the new card from the shoe. Then the player's hands are printed. This results in end of
  # the user action on the current hand.
  # +amount+:: the additional bet placed due to doubling down
  # +next_card+:: the new card picked out of the shoe

  def double_down(amount, next_card)
    hand = @hands[@current_hand]
    place_double_bet(amount)
    hit(next_card)                                # Add this card to the current hand of the player
    print_player_hands()                          # Display the state of the table to show the player the card that was received
    @current_hand += 1
  end
  
  # This method checks if a player can split on the current hand. First the hand is checked for a length of 2 and the 2 cards being the same.
  # Then it checks if the player has enough money to double the bet. It also checks the number of hands of the player. A player can utmost have
  # 4 hands. Any value more than that is not permitted.
  # Params: +None+

  def can_split()
    hand = @hands[@current_hand]
    if hand.can_be_split() && @hands.length < 4
      if @total_money - hand.bet >= 0
        return true
      end
    end
    return false
  end
  
  # This method is called when the player chooses to double down on the current hand. Two new hands are created with cards from the current hand.
  # These new hands are placed just on right of the current hand. An additional bet is placed of the same value as the original bet.
  # At the end, the current hand, which was the parent of the split operation is deleted from the list of hands. Current_hand is not modified
  # as deleting the current hand ensures that current_hand points to the first of the two hands that were created during the split operation.
  # Params:
  # +next_cards+:: the array of two cards. one card each for the two hands being created as a result of split

  def split(next_cards)
    hand = @hands[@current_hand]
    hand_cards = hand.cards                               # Get the two cards of the hand
    2.times do |index|                                    # One split results in creation of two hands
      new_hand = Hand.new([hand_cards[index]], hand.bet)  # Create new hands with one card each of the original hand cards
      new_card = next_cards[index]                        # Obtain a new card from the shoe
      new_hand.cards.push(new_card)                       # Add this card to the newly created hand
      @hands.insert(@current_hand + 1, new_hand)          # The newly created hands are pushed to the immediate right of the hand
    end
    place_bet(hand.bet)                                   # Double the original bet
    @hands.delete_at(@current_hand)                       # Remove the hand that was split
  end
    
  ## End of methods
end