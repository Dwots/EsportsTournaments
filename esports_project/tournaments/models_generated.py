# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Countries(models.Model):
    country_name = models.TextField(unique=True)

    class Meta:
        managed = False
        db_table = 'countries'


class GameGenres(models.Model):
    genre_name = models.TextField(unique=True)

    class Meta:
        managed = False
        db_table = 'game_genres'


class GameGenresLink(models.Model):
    pk = models.CompositePrimaryKey('game_id', 'genre_id')
    game = models.ForeignKey('GamesList', models.DO_NOTHING)
    genre = models.ForeignKey(GameGenres, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'game_genres_link'


class Games(models.Model):
    match = models.ForeignKey('Matches', models.DO_NOTHING, blank=True, null=True)
    game_number = models.IntegerField()
    map = models.ForeignKey('Maps', models.DO_NOTHING, blank=True, null=True)
    team1_score = models.IntegerField(blank=True, null=True)
    team2_score = models.IntegerField(blank=True, null=True)
    winner_team = models.ForeignKey('Teams', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'games'
        unique_together = (('match', 'game_number'),)


class GamesList(models.Model):
    name = models.TextField(unique=True)
    genre = models.ForeignKey(GameGenres, models.DO_NOTHING, blank=True, null=True)
    has_heroes = models.BooleanField(blank=True, null=True)
    has_towers = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'games_list'


class GroupStageMain(models.Model):
    group_stage = models.ForeignKey('GroupStages', models.DO_NOTHING)
    team = models.ForeignKey('Teams', models.DO_NOTHING)
    wins = models.IntegerField(blank=True, null=True)
    losses = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'group_stage_main'
        unique_together = (('group_stage', 'team'),)


class GroupStageMatches(models.Model):
    group_stage = models.ForeignKey('GroupStages', models.DO_NOTHING)
    round_number = models.IntegerField(blank=True, null=True)
    team_a = models.ForeignKey('Teams', models.DO_NOTHING)
    team_b = models.ForeignKey('Teams', models.DO_NOTHING, related_name='groupstagematches_team_b_set')
    team_a_score = models.IntegerField(blank=True, null=True)
    team_b_score = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'group_stage_matches'
        unique_together = (('group_stage', 'round_number', 'team_a', 'team_b'),)


class GroupStages(models.Model):
    tournament = models.ForeignKey('Tournaments', models.DO_NOTHING, blank=True, null=True)
    name = models.TextField()
    stage_order = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'group_stages'
        unique_together = (('tournament', 'stage_order'), ('tournament', 'name'),)


class Heroes(models.Model):
    name = models.TextField()
    game = models.ForeignKey(GamesList, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'heroes'
        unique_together = (('name', 'game'),)


class Maps(models.Model):
    name = models.TextField(unique=True)
    game = models.ForeignKey(GamesList, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'maps'


class Matches(models.Model):
    stage = models.ForeignKey('Playoff', models.DO_NOTHING, blank=True, null=True)
    team1 = models.ForeignKey('Teams', models.DO_NOTHING, blank=True, null=True)
    team2 = models.ForeignKey('Teams', models.DO_NOTHING, related_name='matches_team2_set', blank=True, null=True)
    winner_team = models.ForeignKey('Teams', models.DO_NOTHING, related_name='matches_winner_team_set', blank=True, null=True)
    match_date = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'matches'
        unique_together = (('stage', 'match_date', 'team1', 'team2'),)


class MatchesHistory(models.Model):
    history_id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=10)
    operation_timestamp = models.DateTimeField(blank=True, null=True)
    operation_user = models.TextField(blank=True, null=True)
    old_id = models.IntegerField(blank=True, null=True)
    old_stage_id = models.IntegerField(blank=True, null=True)
    old_team1_id = models.IntegerField(blank=True, null=True)
    old_team2_id = models.IntegerField(blank=True, null=True)
    old_winner_team_id = models.IntegerField(blank=True, null=True)
    old_match_date = models.DateField(blank=True, null=True)
    new_id = models.IntegerField(blank=True, null=True)
    new_stage_id = models.IntegerField(blank=True, null=True)
    new_team1_id = models.IntegerField(blank=True, null=True)
    new_team2_id = models.IntegerField(blank=True, null=True)
    new_winner_team_id = models.IntegerField(blank=True, null=True)
    new_match_date = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'matches_history'


class PlayerGameStats(models.Model):
    game = models.ForeignKey(Games, models.DO_NOTHING, blank=True, null=True)
    player = models.ForeignKey('Players', models.DO_NOTHING, blank=True, null=True)
    hero = models.ForeignKey(Heroes, models.DO_NOTHING, blank=True, null=True)
    kills = models.IntegerField(blank=True, null=True)
    deaths = models.IntegerField(blank=True, null=True)
    assists = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'player_game_stats'
        unique_together = (('game', 'player'),)


class Players(models.Model):
    nickname = models.TextField(unique=True)
    full_name = models.TextField(blank=True, null=True)
    birthdate = models.DateField(blank=True, null=True)
    country = models.ForeignKey(Countries, models.DO_NOTHING, blank=True, null=True)
    role = models.TextField(blank=True, null=True)
    total_winnings = models.IntegerField(blank=True, null=True)
    team = models.ForeignKey('Teams', models.DO_NOTHING, blank=True, null=True)
    status = models.TextField()

    class Meta:
        managed = False
        db_table = 'players'


class PlayersHistory(models.Model):
    history_id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=10)
    operation_timestamp = models.DateTimeField(blank=True, null=True)
    operation_user = models.TextField(blank=True, null=True)
    old_id = models.IntegerField(blank=True, null=True)
    old_nickname = models.TextField(blank=True, null=True)
    old_full_name = models.TextField(blank=True, null=True)
    old_birthdate = models.DateField(blank=True, null=True)
    old_country_id = models.IntegerField(blank=True, null=True)
    old_role = models.TextField(blank=True, null=True)
    old_total_winnings = models.IntegerField(blank=True, null=True)
    old_team_id = models.IntegerField(blank=True, null=True)
    old_status = models.TextField(blank=True, null=True)
    new_id = models.IntegerField(blank=True, null=True)
    new_nickname = models.TextField(blank=True, null=True)
    new_full_name = models.TextField(blank=True, null=True)
    new_birthdate = models.DateField(blank=True, null=True)
    new_country_id = models.IntegerField(blank=True, null=True)
    new_role = models.TextField(blank=True, null=True)
    new_total_winnings = models.IntegerField(blank=True, null=True)
    new_team_id = models.IntegerField(blank=True, null=True)
    new_status = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'players_history'


class Playoff(models.Model):
    tournament = models.ForeignKey('Tournaments', models.DO_NOTHING, blank=True, null=True)
    name = models.TextField()
    bracket_type = models.TextField(blank=True, null=True)
    stage_order = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'playoff'
        unique_together = (('tournament', 'stage_order'), ('tournament', 'name', 'bracket_type'),)


class TeamCountries(models.Model):
    pk = models.CompositePrimaryKey('team_id', 'country_id')
    team = models.ForeignKey('Teams', models.DO_NOTHING)
    country = models.ForeignKey(Countries, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'team_countries'


class Teams(models.Model):
    name = models.TextField()
    created_at = models.DateField(blank=True, null=True)
    disbanded_at = models.DateField(blank=True, null=True)
    coach = models.TextField()
    total_earnings = models.IntegerField(blank=True, null=True)
    game = models.ForeignKey(GamesList, models.DO_NOTHING, blank=True, null=True)
    manager = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'teams'
        unique_together = (('name', 'game'),)


class TeamsCaptains(models.Model):
    team = models.OneToOneField(Teams, models.DO_NOTHING, primary_key=True)
    player = models.OneToOneField(Players, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'teams_captains'


class TeamsHistory(models.Model):
    history_id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=10)
    operation_timestamp = models.DateTimeField(blank=True, null=True)
    operation_user = models.TextField(blank=True, null=True)
    old_id = models.IntegerField(blank=True, null=True)
    old_name = models.TextField(blank=True, null=True)
    old_created_at = models.DateField(blank=True, null=True)
    old_disbanded_at = models.DateField(blank=True, null=True)
    old_coach = models.TextField(blank=True, null=True)
    old_total_earnings = models.IntegerField(blank=True, null=True)
    old_game_id = models.IntegerField(blank=True, null=True)
    old_manager = models.TextField(blank=True, null=True)
    new_id = models.IntegerField(blank=True, null=True)
    new_name = models.TextField(blank=True, null=True)
    new_created_at = models.DateField(blank=True, null=True)
    new_disbanded_at = models.DateField(blank=True, null=True)
    new_coach = models.TextField(blank=True, null=True)
    new_total_earnings = models.IntegerField(blank=True, null=True)
    new_game_id = models.IntegerField(blank=True, null=True)
    new_manager = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'teams_history'


class TournamentParticipants(models.Model):
    tournament = models.ForeignKey('Tournaments', models.DO_NOTHING, blank=True, null=True)
    team = models.ForeignKey(Teams, models.DO_NOTHING, blank=True, null=True)
    place = models.IntegerField(blank=True, null=True)
    earnings = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tournament_participants'
        unique_together = (('tournament', 'team'),)


class Tournaments(models.Model):
    name = models.TextField()
    tier = models.TextField(blank=True, null=True)
    prize_pool = models.IntegerField(blank=True, null=True)
    location = models.TextField(blank=True, null=True)
    max_number_of_teams = models.IntegerField(blank=True, null=True)
    start_date = models.DateField(blank=True, null=True)
    end_date = models.DateField(blank=True, null=True)
    winner_team = models.ForeignKey(Teams, models.DO_NOTHING, blank=True, null=True)
    game = models.ForeignKey(GamesList, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tournaments'
        unique_together = (('name', 'game', 'start_date'),)
