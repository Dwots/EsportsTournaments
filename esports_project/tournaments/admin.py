from django.contrib import admin
from .models import (
    Country, GamesList, Map, Hero,
    Team, Player,
    Tournament, TournamentStage,
    Match, Game,
    PlayerGameStats,
    PlayersHistory, TeamsHistory, MatchesHistory,
)


class ReadOnlyAdmin(admin.ModelAdmin):
    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


# === Обычные таблицы (можно редактировать через админ) ===

@admin.register(Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ("id", "country_name")
    search_fields = ("country_name",)
    ordering = ("id",)


@admin.register(GamesList)
class GamesListAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "has_heroes", "has_towers")
    search_fields = ("name",)
    ordering = ("id",)


@admin.register(Team)
class TeamAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "game", "coach", "manager", "total_earnings")
    list_filter = ("game",)
    search_fields = ("name", "coach", "manager")
    ordering = ("id",)


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ("id", "nickname", "full_name", "country", "role", "total_winnings", "status")
    list_filter = ("status", "country")
    search_fields = ("nickname", "full_name")
    ordering = ("id",)


@admin.register(Tournament)
class TournamentAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "game", "tier", "prize_pool", "start_date", "end_date", "winner_team")
    list_filter = ("game", "tier")
    search_fields = ("name",)
    ordering = ("id",)


@admin.register(TournamentStage)
class TournamentStageAdmin(admin.ModelAdmin):
    list_display = ("id", "tournament", "name", "stage_type", "bracket_type", "stage_order")
    list_filter = ("tournament", "stage_type", "bracket_type")
    search_fields = ("name",)
    ordering = ("tournament", "stage_order")


@admin.register(Match)
class MatchAdmin(admin.ModelAdmin):
    list_display = ("id", "stage", "match_date", "team1", "team2", "winner_team")
    list_filter = ("stage__tournament", "stage", "match_date")
    search_fields = ("team1__name", "team2__name")
    ordering = ("id",)


@admin.register(Game)
class GameAdmin(admin.ModelAdmin):
    list_display = ("id", "match", "game_number", "map", "team1_score", "team2_score", "winner_team")
    list_filter = ("match__stage__tournament", "map")
    ordering = ("match", "game_number")


@admin.register(PlayerGameStats)
class PlayerGameStatsAdmin(admin.ModelAdmin):
    list_display = ("id", "game", "player", "hero", "kills", "deaths", "assists")
    list_filter = ("hero",)
    search_fields = ("player__nickname",)
    ordering = ("id",)


# === HISTORY-ТАБЛИЦЫ: ТОЛЬКО ПРОСМОТР (read-only) ===

@admin.register(PlayersHistory)
class PlayersHistoryAdmin(ReadOnlyAdmin):
    list_display = (
        "history_id",
        "operation_type",
        "operation_timestamp",
        "operation_user",
        "old_id",
        "old_nickname",
        "new_id",
        "new_nickname",
    )
    list_filter = ("operation_type", "operation_user")
    search_fields = ("old_nickname", "new_nickname", "operation_user")
    ordering = ("-history_id",)


@admin.register(TeamsHistory)
class TeamsHistoryAdmin(ReadOnlyAdmin):
    list_display = (
        "history_id",
        "operation_type",
        "operation_timestamp",
        "operation_user",
    )
    list_filter = ("operation_type", "operation_user")
    ordering = ("-history_id",)


@admin.register(MatchesHistory)
class MatchesHistoryAdmin(ReadOnlyAdmin):
    list_display = (
        "history_id",
        "operation_type",
        "operation_timestamp",
        "operation_user",
    )
    list_filter = ("operation_type", "operation_user")
    ordering = ("-history_id",)