# 2 Players Six Card Golf
_First love2d game mostly used to learn more on Lua, hence why it might feel a bit rough on the edge (especially the opponents turns)_

- [How to play](#How-to-play)
- [Technical Details](#Technical-details)

## How to play

_As this version of Six card golf is slightly different from the ones I found online I'll put the rules here._

### Goal
Have the lowest score after 9 rounds

### Board setup
Each player receives 6 cards face down, all cards left are put in a draw pile. One card from the draw pile is put in a discard pile, face up.

### Turn actions
The players have 2 choices of action each turn
- Turning up a face-down card on their side
- Drawing a card: from the discard pile (the one on top) or the draw pile.

    If they chose to draw a card, they can replace any card on their side with the one drawn. They can also choose not to use it, and can simply discard it.

The turn now ends, and the next player can start.

The game ends the turn after a player turned face up all their cards. (The other player can do one last turn, and then needs to turn all their cards face up, in this game, this will be done automatically)

### Scoring
- Jokers are worth -5
- Any pairs of cards are worth 0 points
- Kings are worth 0 points
- Every other card is worth their rank

# Technical details

## How to run

### From source code

If you cloned the repo, you'll need to download [LÖVE](https://www.love2d.org/) first then you can simply run the game with:

```
love six-card-golf/six-card-golf
```

### From executable

You can find those in the [latest release](https://github.com/CGagnier/six-card-golf/releases)

### From the web

Available on [itch.io]()