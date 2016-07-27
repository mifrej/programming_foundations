require 'pry'
HIT = "Hit".freeze
STAY = "Stay".freeze
SUITS = { "S" => "Spades",
          "H" => "Hearts",
          "D" => "Diamonds",
          "C" => "Clubs" }.freeze
RANKS = %w(A 2 3 4 5 6 7 8 9 10 J Q K).freeze
PLAYER_NAME = "Player".freeze
DEALER_NAME = "Dealer".freeze
def prompt(msg)
  puts "=> #{msg}"
end

def clean_screen
  system('clear') || system('cls')
end

def total(cards)
  values = cards.map { |card| card[1] }
  sum = 0

  values.each do |value|
    sum +=
      if value == "A"
        11
      elsif value.to_i == 0 # J, Q, K
        10
      else
        value.to_i
      end
  end

  values.select { |value| value == "A" }.count.times do
    sum -= 10 if sum > 21
  end

  sum
end

def initialize_deck
  stack = []
  SUITS.each_key do |suit|
    RANKS.each { |rank| stack << [suit, rank] }
  end
  stack.shuffle
end

def deal_cards(deck, current_player_cards)
  2.times do
    current_player_cards << deck.delete(deck.sample)
  end
end

def hit(deck, current_player_cards)
  current_player_cards << deck.delete(deck.sample)
end

def busted?(cards)
  total(cards) > 21
end

def display_cards(cards, player_name)
  prompt "#{player_name} has corresponding cards:"
  cards.each do |card|
    prompt "\t - #{SUITS[card[0]]} of value #{card[1]}"
  end
  prompt "Total value of #{player_name} cards is: #{total(cards)}"
  prompt "================================="
  prompt ""
end

def display_winner(user_cards, dealer_cards)
  puts ""
  puts "*********************************"
  if busted?(dealer_cards)
    puts "!!!! Dealer Busted ! User has won !!!!"
  elsif busted?(user_cards)
    puts "!!! User Busted ! Dealer has won !!!"
  elsif total(dealer_cards) < total(user_cards)
    puts "!!!! User has won !!!!"
  elsif total(dealer_cards) == total(user_cards)
    puts "!!!! It's a tie !!!!"
  else
    puts "!!!! Dealer has won !!!!"
  end
  puts "*********************************"
  puts ""
end

def another_game?
  loop do
    answer = gets.chomp.downcase
    if %w(y yes).include?(answer)
      clean_screen
      return true
    end
    return false if %w(n no).include?(answer)
    prompt("Please enter 'y or 'n'.")
  end
end

loop do
  clean_screen
  deck = initialize_deck
  user_cards = []
  dealer_cards = []
  deal_cards(deck, user_cards)
  deal_cards(deck, dealer_cards)

  sample_dealer_card = dealer_cards.sample
  prompt ""
  prompt "One of the dealer card is:"
  prompt "\t - #{SUITS[sample_dealer_card[0]]} of value #{sample_dealer_card[1]}"
  prompt ""

  # player turn
  answer = nil
  loop do
    display_cards(user_cards, PLAYER_NAME)
    loop do
      prompt "Are you #{HIT} or #{STAY}? Choose (h) or (s) letter."
      answer = gets.chomp.downcase
      break if ['h', 's'].include?(answer)
      prompt "You must choose only either letter 'h' or 's'."
    end
    hit(deck, user_cards) unless answer == 's'
    break if answer == 's' || busted?(user_cards)
  end

  unless busted?(user_cards)
    # dealer turn
    loop do
      hit(deck, dealer_cards)
      break if total(dealer_cards) >= 17 || busted?(dealer_cards)
    end
  end

  display_cards(user_cards, PLAYER_NAME)
  display_cards(dealer_cards, DEALER_NAME)
  display_winner(user_cards, dealer_cards)
  prompt "Do you want to play again? (y/yes or n/no)"
  break unless another_game?
end
prompt "Thank You for playing 21!"
