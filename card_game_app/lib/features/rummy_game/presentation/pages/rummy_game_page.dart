import 'package:flutter/material.dart';
import 'package:card_game_app/l10n/app_localizations.dart';
import 'package:card_game_app/core/models/deck.dart';
import 'package:card_game_app/core/models/playing_card.dart';
import 'package:card_game_app/core/widgets/playing_card_widget.dart';

import 'dart:math'; // For Random

// Removed AnimatedCardData class

enum Player { user, opponent }
enum TurnPhase { draw, play, discard } // Added TurnPhase Enum

class RummyGamePage extends StatefulWidget {
  const RummyGamePage({super.key});

  @override
  State<RummyGamePage> createState() => _RummyGamePageState();
}

class _RummyGamePageState extends State<RummyGamePage> with TickerProviderStateMixin { // Changed to TickerProviderStateMixin
  late Deck _deck;
  List<PlayingCard> _playerHandCards = []; // Stores all 10 cards for player
  List<PlayingCard> _opponentHandCards = []; // Stores all 10 cards for opponent
  List<PlayingCard> _discardPile = [];

  late AnimationController _dealingAnimationController;
  late Animation<int> _currentCardDealingAnimation;

  Player? _currentPlayer;
  late AnimationController _turnIndicatorAnimationController;
  late Animation<double> _turnIndicatorAnimation;
  int? _dragHoverTargetIndex;
  PlayingCard? _selectedCardForDiscard; // Added for discard selection

  TurnPhase _currentTurnPhase = TurnPhase.draw;
  final Map<Player, List<List<PlayingCard>>> _meldedCards = {
    Player.user: [],
    Player.opponent: [],
  };

  @override
  void initState() {
    super.initState();
    _deck = Deck();
    _deck.shuffle();

    _playerHandCards = _deck.deal(10);
    _opponentHandCards = _deck.deal(10);

    _dealingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _turnIndicatorAnimationController = AnimationController( // Initialized
      duration: const Duration(milliseconds: 750),
      vsync: this,
    )..repeat(reverse: true);

    _turnIndicatorAnimation = Tween<double>(begin: 0.0, end: 6.0).animate( // Initialized
      CurvedAnimation(parent: _turnIndicatorAnimationController, curve: Curves.easeInOut),
    )..addListener(() { setState(() {}); }); // Added listener for turn indicator

    _currentCardDealingAnimation = IntTween(begin: 0, end: 19).animate(_dealingAnimationController)
      ..addListener(() {
        setState(() {
          // This will trigger build
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!_deck.isEmpty) {
             // Temporarily remove setState from discard pile for clarity, will be covered by currentPlayer setState
            _discardPile.add(_deck.dealOne()!);
          }
          // Determine first player
          final random = Random();
          _currentPlayer = random.nextBool() ? Player.user : Player.opponent;
          setState(() {}); // This will trigger rebuild with currentPlayer and discardPile
        }
      });

    _dealingAnimationController.forward();
  }

  @override
  void dispose() {
    _dealingAnimationController.dispose();
    _turnIndicatorAnimationController.dispose(); // Disposed
    super.dispose();
  }

  Widget _buildHandUI(List<PlayingCard> handCards, int cardsToShow, Player handOwner, bool isPlayerHandType) {
    List<PlayingCard> visibleCards = [];
    if (cardsToShow > 0 && cardsToShow <= handCards.length) {
      visibleCards = handCards.sublist(0, cardsToShow);
    } else if (cardsToShow > handCards.length) {
      visibleCards = handCards;
    }

    bool isCurrentPlayerTurnPhasePlay = _currentPlayer == handOwner && _currentTurnPhase == TurnPhase.play;
    bool isCurrentPlayer = _currentPlayer == handOwner; // For turn indicator
    const double baseHorizontalPadding = 4.0;
    const double shiftAmount = PlayingCardWidget.defaultWidth / 2; // How much cards shift

    List<Widget> handWidgets = visibleCards.asMap().entries.map((entry) {
      int index = entry.key;
      PlayingCard card = entry.value;

      double currentLeftPadding = baseHorizontalPadding;
      if (isPlayerHandType && _dragHoverTargetIndex != null && index >= _dragHoverTargetIndex!) {
        currentLeftPadding += shiftAmount;
      }

      Widget playingCardWidget = PlayingCardWidget(
        card: card,
        isFaceUp: isPlayerHandType,
      );

      Widget cardDisplayWidget;
      if (isPlayerHandType) {
        bool isSelectedToDiscard = _selectedCardForDiscard == card;
        cardDisplayWidget = GestureDetector(
          onTap: () {
            if (isCurrentPlayerTurnPhasePlay) {
              setState(() {
                if (_selectedCardForDiscard == card) {
                  _selectedCardForDiscard = null; // Toggle off
                } else {
                  _selectedCardForDiscard = card; // Select
                }
              });
            }
          },
          child: Container(
            decoration: isSelectedToDiscard ? BoxDecoration(
              border: Border.all(color: Colors.blue.shade300, width: 3),
              borderRadius: BorderRadius.circular(PlayingCardWidget.defaultWidth / 10 + 3),
            ) : null,
            child: playingCardWidget,
          ),
        );
      } else {
        cardDisplayWidget = playingCardWidget;
      }

      Widget cardWithPadding = AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(left: currentLeftPadding, right: baseHorizontalPadding),
        child: cardDisplayWidget, // Use the potentially wrapped widget
      );

      if (isPlayerHandType) {
        return DragTarget<PlayingCard>(
          builder: (context, candidateData, rejectedData) {
            return Draggable<PlayingCard>(
              data: card,
                feedback: PlayingCardWidget( // Feedback should be the plain card
                  card: card,
                  isFaceUp: true,
                  height: PlayingCardWidget.defaultHeight * 1.1,
                  width: PlayingCardWidget.defaultWidth * 1.1,
                ),
                childWhenDragging: SizedBox(
                  width: PlayingCardWidget.defaultWidth + 8,
                  height: PlayingCardWidget.defaultHeight,
                ),
                    child: cardWithPadding, // Child of Draggable is the padded card (which includes selection highlight)
              );
            },
            onWillAcceptWithDetails: (details) {
              if (details.data != card) { // Can't drop on itself without effect
                setState(() { _dragHoverTargetIndex = index; });
                return true;
              }
              return false;
            },
            onLeave: (data) { setState(() { _dragHoverTargetIndex = null; }); },
            onAcceptWithDetails: (details) {
              final draggedCard = details.data;
              final targetCard = card;
              final oldIndex = _playerHandCards.indexOf(draggedCard);
              final newIndex = _playerHandCards.indexOf(targetCard);

              if (oldIndex != -1 && newIndex != -1) {
                setState(() {
                  _playerHandCards.removeAt(oldIndex);
                  if (oldIndex < newIndex) {
                    _playerHandCards.insert(newIndex - 1, draggedCard);
                  } else {
                    _playerHandCards.insert(newIndex, draggedCard);
                  }
                  _dragHoverTargetIndex = null;
                  _dealingAnimationController.forward(from: _dealingAnimationController.upperBound);
                });
              }
            },
          );
        } else {
          return cardWithPadding; // Opponent's cards are not draggable but still need padding
        }
      }).toList();

    if (isPlayerHandType) {
      double endTargetLeftPadding = baseHorizontalPadding;
      if (_dragHoverTargetIndex != null && _dragHoverTargetIndex == visibleCards.length) {
         endTargetLeftPadding += shiftAmount;
      }
      handWidgets.add(
        DragTarget<PlayingCard>(
          key: const Key('end_of_hand_drag_target'), // Added Key
          builder: (context, candidateData, rejectedData) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(left: endTargetLeftPadding, right: baseHorizontalPadding),
              child: Container(
                width: PlayingCardWidget.defaultWidth / 2,
                height: PlayingCardWidget.defaultHeight,
                decoration: BoxDecoration(
                  border: candidateData.isNotEmpty ? Border.all(color: Colors.yellow.withOpacity(0.5), width: 2) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
          onWillAcceptWithDetails: (details) {
            setState(() {
              _dragHoverTargetIndex = visibleCards.length; // Target is end of the list
            });
            return true;
          },
          onLeave: (data) {
            setState(() {
              _dragHoverTargetIndex = null;
            });
          },
          onAcceptWithDetails: (details) {
            final draggedCard = details.data;
            setState(() {
              if (_playerHandCards.contains(draggedCard)) {
                 _playerHandCards.remove(draggedCard);
              }
              _playerHandCards.add(draggedCard);
              _dragHoverTargetIndex = null; // Reset hover index
              _dealingAnimationController.forward(from: _dealingAnimationController.upperBound);
            });
          },
        )
      );
    }

    Widget handRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: handWidgets, // Use the generated list of widgets
    );

    Widget handContainer = Container(
      key: (handOwner == Player.user) ? const Key('player_hand_container') : const Key('opponent_hand_container'),
      padding: const EdgeInsets.all(8.0),
      height: PlayingCardWidget.defaultHeight + 16 + (isPlayerHandType ? 20 : 0),
      decoration: isCurrentPlayer ? BoxDecoration( // Animated shadow for current player
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(_turnIndicatorAnimation.value / 12.0), // Max opacity 0.5 (6.0 / 12.0 = 0.5)
            blurRadius: _turnIndicatorAnimation.value * 1.5, // Max blurRadius 9 (6.0 * 1.5 = 9.0)
            spreadRadius: _turnIndicatorAnimation.value / 3.0, // Max spreadRadius 2 (6.0 / 3.0 = 2.0)
          ),
        ],
        borderRadius: BorderRadius.circular(12), // Optional: to make shadow look nice around the hand
      ) : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: handRow,
      ),
    );

    if (isCurrentPlayer) {
      return Transform.translate(
        offset: Offset(0, -_turnIndicatorAnimation.value / 1.5), // Lift effect
        child: handContainer,
      );
    }
    return handContainer;
  }

  // Player Action Function Signatures
  void _playerDrawsFromStock() {
    if (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.draw && !_deck.isEmpty) {
      setState(() {
        final drawnCard = _deck.dealOne();
        if (drawnCard != null) {
          _playerHandCards.add(drawnCard);
          _currentTurnPhase = TurnPhase.play; // Or play/discard if that's a combined phase
        }
      });
    } else {
      // Optional: Show a message or log if draw is not allowed
      print("Cannot draw from stock: Not user's turn ($_currentPlayer), wrong phase ($_currentTurnPhase), or deck empty (${_deck.isEmpty}).");
    }
  }

  void _playerDrawsFromDiscard() {
    if (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.draw && _discardPile.isNotEmpty) {
      setState(() {
        final drawnCard = _discardPile.removeLast();
        _playerHandCards.add(drawnCard);
        _currentTurnPhase = TurnPhase.play; // Or play/discard
      });
    } else {
      // Optional: Show a message or log
      print("Cannot draw from discard: Not user's turn ($_currentPlayer), wrong phase ($_currentTurnPhase), or discard empty (${_discardPile.isEmpty}).");
    }
  }

  void _playerDiscardsCard(PlayingCard cardToDiscard) {
    if (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.play) {
      if (_playerHandCards.contains(cardToDiscard)) {
        setState(() {
          _playerHandCards.remove(cardToDiscard);
          _discardPile.add(cardToDiscard);
          _switchToNextPlayer();
        });
      } else {
        print("Error: Card to discard not in player's hand.");
      }
    } else {
      print("Cannot discard: Not user's turn or not in play phase.");
    }
  }

  void _playerMeldsCards(List<PlayingCard> cardsToMeld) {
    // Logic to be implemented (primarily for human player)
  }

  void _executeAITurn() async {
    if (_currentPlayer != Player.opponent || !mounted) return;

    // AI Draw Phase
    await Future.delayed(const Duration(seconds: 1)); // Simulate thinking
    if (!mounted) return;

    final random = Random();
    bool drawFromDiscardAI = false;
    if (_discardPile.isNotEmpty) {
      drawFromDiscardAI = random.nextBool();
    }

    PlayingCard? drawnCardAI;
    if (drawFromDiscardAI) {
      drawnCardAI = _discardPile.removeLast();
      print("AI drew from discard: ${drawnCardAI.toString()}");
    } else {
      if (!_deck.isEmpty) {
        drawnCardAI = _deck.dealOne();
        print("AI drew from stock: ${drawnCardAI.toString()}");
      } else {
        print("AI: Stock empty, cannot draw from discard or chose not to.");
      }
    }

    if (drawnCardAI != null) {
      _opponentHandCards.add(drawnCardAI);
    }

    // Update UI after AI draw & set phase
    // No immediate setState here, will be covered by discard or if no actions possible
    _currentTurnPhase = TurnPhase.play;
    // If AI has complex play logic, it would go here, potentially with more setStates
    // For now, AI immediately moves to discard after drawing.

    // AI Discard Phase
    await Future.delayed(const Duration(seconds: 1)); // Simulate thinking
    if (!mounted) return;

    if (_opponentHandCards.isNotEmpty) {
      final discardIndexAI = random.nextInt(_opponentHandCards.length);
      final PlayingCard cardToDiscardAI = _opponentHandCards.removeAt(discardIndexAI);
      _discardPile.add(cardToDiscardAI);
      print("AI discarded: ${cardToDiscardAI.toString()}");

      // Now switch turn (this will call setState)
      _switchToNextPlayer();
    } else {
      print("AI has no cards to discard.");
      // Switch turn even if AI had no cards (e.g. drew its last card and melded everything)
      _switchToNextPlayer();
    }
  }

  void _switchToNextPlayer() {
    setState(() {
      if (_currentPlayer == Player.user) {
        _currentPlayer = Player.opponent;
        _currentTurnPhase = TurnPhase.draw; // AI starts its turn in draw phase
        _selectedCardForDiscard = null;
        _executeAITurn(); // Trigger AI turn
      } else {
        _currentPlayer = Player.user;
        _currentTurnPhase = TurnPhase.draw;
        _selectedCardForDiscard = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int animationValue = _currentCardDealingAnimation.value;
    bool dealingComplete = !_dealingAnimationController.isAnimating || _dealingAnimationController.value == _dealingAnimationController.upperBound;

    int numPlayerCardsToShow = dealingComplete ? _playerHandCards.length : (animationValue >= 0 ? (animationValue / 2).floor() + 1 : 0);
    if (numPlayerCardsToShow > _playerHandCards.length) numPlayerCardsToShow = _playerHandCards.length;

    int numOpponentCardsToShow = dealingComplete ? _opponentHandCards.length : (animationValue >= 1 ? ((animationValue - 1) / 2).floor() + 1 : 0);
    if (numOpponentCardsToShow > _opponentHandCards.length) numOpponentCardsToShow = _opponentHandCards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rummyGameTitle),
      ),
      backgroundColor: const Color(0xFF35654d),
      body: Column(
        children: <Widget>[
          // Opponent's Hand (Top)
          _buildHandUI(_opponentHandCards, numOpponentCardsToShow, Player.opponent, false),

          Expanded(
            child: Padding( // Added Padding for some spacing from screen edges
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Changed to start
                children: <Widget>[
                  // Deck (now first)
                  GestureDetector(
                    onTap: (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.draw && !_deck.isEmpty)
                           ? _playerDrawsFromStock
                           : null,
                    child: Container( // Wrap in container for potential visual cues
                      decoration: BoxDecoration(
                        border: (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.draw && !_deck.isEmpty)
                                 ? Border.all(color: Colors.yellow.withOpacity(0.7), width: 2)
                                 : null,
                        borderRadius: BorderRadius.circular(PlayingCardWidget.defaultWidth / 10), // Consistent with card
                      ),
                      child: (_deck.isEmpty)
                          ? Container(
                              key: const Key('deck_area'),
                              width: PlayingCardWidget.defaultWidth,
                              height: PlayingCardWidget.defaultHeight,
                      decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8.0),
                            )
                          : SizedBox(
                              key: const Key('deck_area'),
                              child: PlayingCardWidget(
                                isFaceUp: false,
                              ),
                            ),
                      ),
                    ),

                  const SizedBox(width: 16), // Spacing

                  // Discard Pile (now second)
                  GestureDetector(
                     onTap: (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.draw && _discardPile.isNotEmpty)
                            ? _playerDrawsFromDiscard
                            : null,
                    child: Container( // Wrap for visual cues
                       decoration: BoxDecoration(
                        border: (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.draw && _discardPile.isNotEmpty)
                                 ? Border.all(color: Colors.yellow.withOpacity(0.7), width: 2)
                                 : null,
                        borderRadius: BorderRadius.circular(PlayingCardWidget.defaultWidth / 10),
                      ),
                      child: (_discardPile.isEmpty)
                          ? Container(
                              key: const Key('discard_pile_area'),
                              width: PlayingCardWidget.defaultWidth,
                              height: PlayingCardWidget.defaultHeight,
                      decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                              borderRadius: BorderRadius.circular(8.0),
                            )
                          : SizedBox(
                              key: const Key('discard_pile_area'),
                              child: PlayingCardWidget(
                                card: _discardPile.last,
                                isFaceUp: true,
                              ),
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Player's Hand (Bottom)
          _buildHandUI(_playerHandCards, numPlayerCardsToShow, Player.user, true),

          // Discard Button
          if (_currentPlayer == Player.user && _currentTurnPhase == TurnPhase.play && _selectedCardForDiscard != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _playerDiscardsCard(_selectedCardForDiscard!);
                },
                child: Text(AppLocalizations.of(context)!.discardButtonText), // Assuming key is added
              ),
            ),
        ],
      ),
    );
  }
}
