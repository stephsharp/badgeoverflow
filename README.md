# Badge Overflow

An exceptionally handsome way to track your Stack Overflow badges.

Created by [Adam](https://github.com/sharplet) & [Stephanie Sharp](https://github.com/stephsharp).

## Overview

A [Dashing](http://shopify.github.com/dashing) dashboard that 
displays a range of stats about a [Stack Overflow](http://stackoverflow.com) user’s badges.

## Widgets

### Since Last Badge
Displays the name of the user's last awarded badge, and the time since the badge was awarded in days and hours.

### Rarest Badge
Displays the rarest badge the user has been awarded, and the number of times this badge has been awarded. The widget's background colour dynamically changes depending on the badge's rank (bronze, silver, or gold).

### Recent Badges
Displays a list of the user's 5 most recently awarded badges and their rank (bronze, siler, or gold).

### Unearned Badges
This widget tracks the progress toward unearned badges. It randomly selects a badge you haven't earned and shows your progress, or suggests things you could try in order to earn the badge. The widget's background colour dynamically changes depending on the badge's rank (bronze, silver, or gold). For badges where we aren't (yet) calculating progress, we display the badge's description.

### User
This widget displays the Stack Overflow users's avatar, name, reputation and number of badges the user has been awarded. The avatar image and user's name are linked to the user's Stack Overflow profile webpage.


## Demo

You can view the demo dashboard at [http://badgeoverflow.heroku.com/](http://badgeoverflow.heroku.com/).

![Steph's dashboard](https://raw.github.com/stephsharp/badgeoverflow/master/public/screenshots/badgeoverflow/steph_sharp.png)

![Adam's dashboard](https://raw.github.com/stephsharp/badgeoverflow/master/public/screenshots/badgeoverflow/adam_sharp.png)

## Setup

1. Edit the file `config/badgeoverflow.yml` and set the user ID you want to track progress for:

    ```yaml
    user_id: YOUR_USER_ID
    ```

## How it works

The dashboard talks to the Stack Exchange API via the
[`badgeoverflow-core` gem](https://github.com/sharplet/badgeoverflow-core),
which we wrote while developing the dashboard. The most significant
part of this gem is the logic for calculating a user's progress toward
a badge for the Unearned Badges widget. We've implemented progress calculation for a large number of
badges, and tried to [make it as easy as possible to add more](https://github.com/sharplet/badgeoverflow-core/blob/master/CONTRIBUTING.md).
