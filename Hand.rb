#!/usr/bin/env ruby

# This file is a part of the codebase for implementation of Blackjack. Developed by Sai Roop Tetali as part of the interview process with LiveRamp.

# The class Hand is used to represent one hand of a player at the table.
# An object of this class represents one game hand of a real world person who is at a Blackjack table.

class Hand

  ## Start of attributes

  # Represents the bet associated with the hand.
  # This attribute effects the earnings of the player at the end of each round.
  # This attribute is updated when the player is dealt cards initially. This attribute is also updated when the player chooses to double down.
  attr_accessor :bet

  # Represents the set of cards associated with the hand. It is an array that maps to the cards associated with the hand.
  # This attribute is updated when the player is dealt cards initially.
  # This attribute is also updated when the player chooses to hit or double down.
  attr_accessor :cards
  
  ## End of attributes
  
  ## Start of methods
  
  # Creates an object of Person. The default values of is_alive is true when the hand is created.
  # This method is called when a player is dealt cards for the first time in the round or when a player chooses to split cards.
  # Params:
  # +cards+:: the set of cards (passed as an array) that is associated with the hand
  # +bet+:: the bet associated with the hand
  
  def initialize(cards, bet)
    @cards = cards
    @bet = bet
  end

  # Returns if the hand is a blackjack or not.
  # This method checks if the hand contains two cards and if the sum of the cards is 21 and returns a boolean value.
  # Params: +None+
  
  def is_blackjack()
    hand_value() == 21 && @cards.length == 2
  end

  # Returns if the hand is a bust or not.
  # This method checks the hand value of the hand and compared it with 21. If the hand value exceeds 21, it is a bust hand.
  # Params: +None+

  def is_bust()
    hand_value() > 21
  end

  # Returns the value of the hand as an integer. The method first sorts the cards such that Aces are present at the end of the array.
  # Then face values of 2 - 10 are considered as such. J, Q and K are considered as 10. Aces are considered as 1 only if the sum of the
  # cards exceeds 21. Therefore, soft hands are handled to maximize the hand value by returning the maximum hand value possible.
  # Params: +None+
  
  def hand_value()
    # First rearrange the cards such that Aces appear at the end of the array
    @cards.sort_by { |card| card.to_i != 0 ? card : card[0] - 81 }.reverse().inject(0) do |total,current|
      if current.to_i != 0
        total + current                     # Cards 2, 3, 4 ... 10 are treated by their face value
      elsif ["J","Q","K"].include? current
        total + 10                          # Cards J, Q and K are treated as 10
      elsif current == "A"
        if (total+11) > 21
          total + 1                         # If the sum exceeds 21, consider the Ace as 1
        else
          total+11                          # Else consider the Ace as 11 to maximize the hand value
        end
      end
    end
  end
  
  # Returns the details of the hand - cards, hand value, bet value and status concatinated as a string.
  # This method is used when printing the current state of the table during the game. This method is called by player's print_player_hands method.
  # Params: +None+
  
  def to_s()    
    return "Hand -> #{@cards.join(',')}. Hand value -> #{hand_value().to_s}. Bet value -> #{@bet.to_s}. Status -> #{is_bust()? "Lost." : "Active."}"
  end

  # Returns a boolean value indicating if the hand can be split or not.
  # This method checks if there are two cards and if the two cards are the same and accordingly returns the boolean value.
  # This method is used to validate player action when split is received as user input for the hand in consideration.
  # Params: +None+

  def can_be_split()
    @cards.length == 2 && (cards[0] == cards[1])
  end
  
  ## End of methods
  
end