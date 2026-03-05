# esports_project/tournaments/models.py

from django.db import models


class Country(models.Model):
    country_name = models.TextField(unique=True)

    class Meta:
        managed = False
        db_table = 'countries'

    def __str__(self):
        return self.country_name


class GameGenre(models.Model):
    genre_name = models.TextField(unique=True)

    class Meta:
        managed = False
        db_table = 'game_genres'

    def __str__(self):
        return self.genre_name


class GamesList(models.Model):
    name = models.TextField(unique=True)
    has_heroes = models.BooleanField(default=False)
    has_towers = models.BooleanField(default=False)

    class Meta:
        managed = False
        db_table = 'games_list'

    def __str__(self):
        return self.name


class Map(models.Model):
    name = models.TextField()
    game = models.ForeignKey(
        GamesList, on_delete=models.CASCADE, null=True,
        db_column='game_id', related_name='maps'
    )

    class Meta:
        managed = False
        db_table = 'maps'

    def __str__(self):
        return f"{self.name} ({self.game.name if self.game else 'Unknown'})"


class Hero(models.Model):
    name = models.TextField()
    game = models.ForeignKey(
        GamesList, on_delete=models.CASCADE, null=True,
        db_column='game_id', related_name='heroes'
    )

    class Meta:
        managed = False
        db_table = 'heroes'

    def __str__(self):
        return self.name


class Team(models.Model):
    name = models.TextField()
    created_at = models.DateField(null=True, blank=True)
    disbanded_at = models.DateField(null=True, blank=True)
    coach = models.TextField(null=True, blank=True)
    manager = models.TextField(null=True, blank=True)
    total_earnings = models.IntegerField(default=0)
    game = models.ForeignKey(
        GamesList, on_delete=models.SET_NULL, null=True,
        db_column='game_id', related_name='teams'
    )
    # captain добавим после Player

    class Meta:
        managed = False
        db_table = 'teams'

    def __str__(self):
        return f"{self.name} ({self.game.name if self.game else 'Unknown'})"

    def get_players(self):
        """Получить всех игроков команды через raw SQL"""
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT p.id, p.nickname, p.role, p.total_winnings
                FROM players p
                JOIN player_teams pt ON pt.player_id = p.id
                WHERE pt.team_id = %s
            """, [self.id])
            columns = [col[0] for col in cursor.description]
            return [dict(zip(columns, row)) for row in cursor.fetchall()]


class Player(models.Model):
    nickname = models.TextField(unique=True)
    full_name = models.TextField(null=True, blank=True)
    birthdate = models.DateField(null=True, blank=True)
    role = models.TextField(null=True, blank=True)
    total_winnings = models.IntegerField(default=0)
    country = models.ForeignKey(
        Country, on_delete=models.SET_NULL, null=True,
        db_column='country_id', related_name='players'
    )
    status = models.TextField(default='active')

    class Meta:
        managed = False
        db_table = 'players'

    def __str__(self):
        return self.nickname

    def get_current_team(self):
        """Получить текущую команду через raw SQL"""
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT t.id, t.name
                FROM teams t
                JOIN player_teams pt ON pt.team_id = t.id
                WHERE pt.player_id = %s
                LIMIT 1
            """, [self.id])
            row = cursor.fetchone()
            if row:
                return Team.objects.get(id=row[0])
            return None


# Добавляем captain к Team после определения Player
Team.add_to_class('captain', models.ForeignKey(
    Player, on_delete=models.SET_NULL, null=True, blank=True,
    db_column='captain_id', related_name='captain_of'
))


class Tournament(models.Model):
    name = models.TextField()
    tier = models.TextField(null=True, blank=True)
    prize_pool = models.IntegerField(null=True, blank=True)
    location = models.TextField(null=True, blank=True)
    max_number_of_teams = models.IntegerField(null=True, blank=True)
    start_date = models.DateField(null=True, blank=True)
    end_date = models.DateField(null=True, blank=True)
    winner_team = models.ForeignKey(
        Team, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='winner_team_id', related_name='won_tournaments'
    )
    game = models.ForeignKey(
        GamesList, on_delete=models.SET_NULL, null=True,
        db_column='game_id', related_name='tournaments'
    )

    class Meta:
        managed = False
        db_table = 'tournaments'

    def __str__(self):
        return self.name


class TournamentParticipant(models.Model):
    tournament = models.ForeignKey(
        Tournament, on_delete=models.CASCADE,
        db_column='tournament_id', related_name='participants'
    )
    team = models.ForeignKey(
        Team, on_delete=models.CASCADE,
        db_column='team_id', related_name='tournament_participations'
    )
    place = models.IntegerField(null=True, blank=True)
    earnings = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'tournament_participants'
        unique_together = (('tournament', 'team'),)


class TournamentStage(models.Model):
    """Этапы турнира (group + playoff)"""
    tournament = models.ForeignKey(
        Tournament, on_delete=models.CASCADE,
        db_column='tournament_id', related_name='stages'
    )
    name = models.TextField()
    stage_type = models.TextField()  # 'group' или 'playoff'
    bracket_type = models.TextField(default='no_type')
    stage_order = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'tournament_stages'

    def __str__(self):
        if self.bracket_type and self.bracket_type != 'no_type':
            return f'{self.tournament.name}: {self.name} ({self.bracket_type})'
        return f'{self.tournament.name}: {self.name}'


class Match(models.Model):
    stage = models.ForeignKey(
        TournamentStage, on_delete=models.CASCADE,
        db_column='stage_id', related_name='matches'
    )
    team1 = models.ForeignKey(
        Team, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='team1_id', related_name='matches_as_team1'
    )
    team2 = models.ForeignKey(
        Team, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='team2_id', related_name='matches_as_team2'
    )
    winner_team = models.ForeignKey(
        Team, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='winner_team_id', related_name='won_matches'
    )
    match_date = models.DateField(null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'matches'

    def __str__(self):
        t1 = self.team1.name if self.team1 else 'TBD'
        t2 = self.team2.name if self.team2 else 'TBD'
        return f"{t1} vs {t2}"

    @property
    def score(self):
        """Возвращает счёт матча"""
        games = self.games.all()
        score1 = sum(1 for g in games if g.winner_team_id == self.team1_id)
        score2 = sum(1 for g in games if g.winner_team_id == self.team2_id)
        return f"{score1}:{score2}"


class Game(models.Model):
    """Отдельная игра (карта) в матче"""
    match = models.ForeignKey(
        Match, on_delete=models.CASCADE,
        db_column='match_id', related_name='games'
    )
    game_number = models.IntegerField()
    map = models.ForeignKey(
        Map, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='map_id', related_name='games_played'
    )
    winner_team = models.ForeignKey(
        Team, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='winner_team_id', related_name='games_won'
    )
    team1_score = models.IntegerField(default=0)
    team2_score = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'games'
        unique_together = (('match', 'game_number'),)

    def __str__(self):
        map_name = self.map.name if self.map else 'Unknown'
        return f"Game {self.game_number}: {map_name} ({self.team1_score}-{self.team2_score})"


class PlayerGameStats(models.Model):
    """Статистика игрока в игре"""
    game = models.ForeignKey(
        Game, on_delete=models.CASCADE,
        db_column='game_id', related_name='player_stats'
    )
    player = models.ForeignKey(
        Player, on_delete=models.CASCADE,
        db_column='player_id', related_name='game_stats'
    )
    hero = models.ForeignKey(
        Hero, on_delete=models.SET_NULL, null=True, blank=True,
        db_column='hero_id', related_name='player_stats'
    )
    kills = models.IntegerField(default=0)
    deaths = models.IntegerField(default=0)
    assists = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'player_game_stats'
        unique_together = (('game', 'player'),)

    @property
    def kda(self):
        if self.deaths == 0:
            return self.kills + self.assists
        return round((self.kills + self.assists) / self.deaths, 2)

    def __str__(self):
        return f"{self.player.nickname}: {self.kills}/{self.deaths}/{self.assists}"


# === ТАБЛИЦЫ ИСТОРИИ ===

class PlayersHistory(models.Model):
    history_id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=10)
    operation_timestamp = models.DateTimeField(null=True)
    operation_user = models.TextField(null=True)
    old_id = models.IntegerField(null=True)
    old_nickname = models.TextField(null=True)
    new_id = models.IntegerField(null=True)
    new_nickname = models.TextField(null=True)

    class Meta:
        managed = False
        db_table = 'players_history'


class TeamsHistory(models.Model):
    history_id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=10)
    operation_timestamp = models.DateTimeField(null=True)
    operation_user = models.TextField(null=True)

    class Meta:
        managed = False
        db_table = 'teams_history'


class MatchesHistory(models.Model):
    history_id = models.AutoField(primary_key=True)
    operation_type = models.CharField(max_length=10)
    operation_timestamp = models.DateTimeField(null=True)
    operation_user = models.TextField(null=True)

    class Meta:
        managed = False
        db_table = 'matches_history'