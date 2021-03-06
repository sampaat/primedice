##Origin of the raw dataset

The origin of the primedice dataset is the on-line gambling site primedice.com. This site uses bitcoin for betting, and runs a game of percentage-based dice-roll. As part of the homepage there is a constantly updating “all bets” section, where one can see information about recently played bets. Using the mechanism of the scripts that refresh the data on the homepage, we were able to make a watcher script, that is able to ping the game server for data on recent bets. Using this script on separate servers, we were able to catch some times over 90% of all the placed bets, with information about the time, user, outcome, and game type.

The script (*pd_listener.sh*) works as follows:

- It pings the [primedice.com/api/get_bets.php] and in catch the response, that is a JSON table of the last 10 bets

- It pings the primedice.com/api/get_bets.php and in catch the response, that is a JSON table of the last 10 bets

- The script transforms the JSON file to csv-type lines, compare the new lines to the last 10 lines, and concatenates the new ones to the data file of the given day (*pd_transform.py*)
- Then repeats the process immediately

##Properties of dataset

The script was used on varying number of servers, from 2014-02-04 to 2014-05-13. The daily files of raw data, that was created by the listener script was processed to an SQL database. The usernames were dropped because of ethical reasons. The datasets from the servers were loaded into a common table, then made distinct, to evade duplications. (*pd_datamaker.sh*, *pd_datarunner.awk*, *scripts.sql*)

##Accessibility of the dataset

The PrimeDice dataset is publicly accessible on [CasJobs](http://nm.vo.elte.hu/casjobs/default.aspx) server of Eötvös Loránd University

##Tables of the SQL dataset

1. __Game__

	contains the recorded bets, each with the following properties:

  - _game_id_			ID of bet
  - _user_id_			ID of player
  - _game_time_		time of bet (minute precision)
  - _game_pwin_		type of the game / probability of winning in percent (0.01% - 98%)
  - _game_multip_		prize multiplier in case of winning (1.01202 - 9900)
  - _game_roll_		rolled random number for the game (0-100)
  - _game_outcome_	outcome of the game (0 if lose - 1 if win)
  - _game_bet_		bet placed in the game in BTC (0 - inf)
  - _game_pay_		change in account after the game in BTC

2. __Users__

	contains the following information/statistics about users:

  - _user_id_		ID of player
  - _user_num_	number of bets recorded by the player
  - _user_betsum_	sum of recorded bet amounts by the player in BTC
  - _user_betawg_	average of recorded bet amounts of the player in BTC 
  - _user_betmin_	minimum of recorded bet amounts of the player in BTC
  - _user_betmax_	maximum of recorded bet amounts of the player in BTC
  - _user_fake_	is 1 if player is presumably a fake user

3. __Daystat__

	contains the following statistics of daily data:

  - _daystat_day_		date of the day
  - _daystat_num_		number of recorded bets on the given day
  - _daystat_min_		game_id of the first recorded bet of the given day
  - _daystat_max_		game_id of the last recorded bet of the given day
  - _daystat_betsum_	sum of bets placed on the given day in BTC
  - _daystat_perc_	estimated rate of bets recorded at the given day (0 - 1)


4. __Subseq__

	contains information about subsequent bets of the players
	data created from the days where Daystat.daystat_perc > 0.7 using the *subseq_calc.awk* script
	(2014-02-13 00:00:00 - 2014-03-09 23:59:59)

  - _game_id_				ID of bet
  - _user_id_				ID of player
  - _return_time_			time elapsed since last bet in minutes
  - _return_betchange_	change in bet amount compared to last bet in BTC
  - _last_outcome_		outcome of last bet
  - _last_pay_			change in account after the game in BTC

5. __Balance__

	contains approximate information of the account balance of the players
	data based on the game_pay ammounts of captured subsequent plays of users using the *pd_account.awk* script
	(2014-02-13 00:00:00 - 2014-03-09 23:59:59)

  - _game_id_			ID of bet
  - _user_balance_	account balance of the user of game_id before playing the given bet
