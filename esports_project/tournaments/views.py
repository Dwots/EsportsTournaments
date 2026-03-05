# esports_project/tournaments/views.py

from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django.db import connections, connection
from django.db.utils import OperationalError
from functools import wraps

from .models import (
    Player, Team, Tournament, Match, TournamentStage,
    Game, PlayerGameStats
)

from .forms import PlayerForm, TeamForm, TournamentForm, LoginForm, MatchForm, AddPlayerToTeamForm

def role_required(*allowed_roles):
    """Декоратор для проверки роли пользователя"""
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):
            user_role = request.session.get('user_role', 'guest')
            if user_role not in allowed_roles:
                messages.error(request, f'Недостаточно прав. Требуется роль: {", ".join(allowed_roles)}')
                return redirect('home')
            return view_func(request, *args, **kwargs)
        return wrapper
    return decorator


def operator_required(view_func):
    return role_required('operator', 'administrator')(view_func)


def admin_required(view_func):
    return role_required('administrator')(view_func)


# === АУТЕНТИФИКАЦИЯ ===

def login_view(request):
    if request.method == 'POST':
        form = LoginForm(request.POST)
        if form.is_valid():
            role = form.cleaned_data['role']
            password = form.cleaned_data['password']

            passwords = {
                'client': 'esports_client_pass',
                'operator': 'esports_operator_pass',
                'administrator': 'esports_admin_pass',
            }

            if password == passwords.get(role):
                db_mapping = {
                    'client': 'client',
                    'operator': 'operator',
                    'administrator': 'default',
                }

                try:
                    conn = connections[db_mapping[role]]
                    conn.ensure_connection()

                    request.session['user_role'] = role
                    request.session['is_authenticated'] = True

                    role_names = {
                        'client': 'Клиент',
                        'operator': 'Оператор',
                        'administrator': 'Администратор'
                    }
                    messages.success(request, f'Вы вошли как {role_names[role]}')
                    return redirect('home')

                except OperationalError as e:
                    messages.error(request, f'Ошибка подключения к БД: {e}')
            else:
                messages.error(request, 'Неверный пароль')
    else:
        form = LoginForm()

    return render(request, 'auth/login.html', {'form': form})


def logout_view(request):
    request.session.flush()
    messages.success(request, 'Вы вышли из системы')
    return redirect('login')


# === ГЛАВНАЯ ===

def home(request):
    context = {
        'players_count': Player.objects.count(),
        'teams_count': Team.objects.count(),
        'tournaments_count': Tournament.objects.count(),
        'tournaments': Tournament.objects.select_related('game', 'winner_team').all()[:5],
    }
    return render(request, 'home.html', context)


# === ИГРОКИ ===

def player_list(request):
    search = request.GET.get('search', '')
    players = Player.objects.select_related('country').all()

    if search:
        players = players.filter(nickname__icontains=search)

    # Получаем команды для игроков через raw SQL
    players_with_teams = []
    for player in players[:100]:
        team = player.get_current_team()
        players_with_teams.append({
            'player': player,
            'team': team,
        })

    return render(request, 'players/player_list.html', {
        'players_with_teams': players_with_teams,
        'search': search,
    })


def player_detail(request, pk):
    player = get_object_or_404(Player, pk=pk)
    team = player.get_current_team()
    stats = PlayerGameStats.objects.filter(player=player).select_related('game', 'hero')[:20]

    return render(request, 'players/player_detail.html', {
        'player': player,
        'team': team,
        'stats': stats,
    })


@operator_required
def player_create(request):
    if request.method == 'POST':
        form = PlayerForm(request.POST)
        if form.is_valid():
            try:
                player = form.save()
                messages.success(request, f'Игрок {player.nickname} создан!')
                return redirect('player_detail', pk=player.pk)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = PlayerForm()

    return render(request, 'players/player_form.html', {
        'form': form,
        'title': 'Создать игрока',
    })


@operator_required
def player_edit(request, pk):
    player = get_object_or_404(Player, pk=pk)

    if request.method == 'POST':
        form = PlayerForm(request.POST, instance=player)
        if form.is_valid():
            try:
                form.save()
                messages.success(request, f'Игрок {player.nickname} обновлён!')
                return redirect('player_detail', pk=pk)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = PlayerForm(instance=player)

    return render(request, 'players/player_form.html', {
        'form': form,
        'player': player,
        'title': f'Редактировать {player.nickname}',
    })


@admin_required
def player_delete(request, pk):
    player = get_object_or_404(Player, pk=pk)

    if request.method == 'POST':
        try:
            nickname = player.nickname
            # Удаляем связи с командами через raw SQL
            with connection.cursor() as cursor:
                cursor.execute("DELETE FROM player_teams WHERE player_id = %s", [pk])
            player.delete()
            messages.success(request, f'Игрок {nickname} удалён!')
            return redirect('player_list')
        except Exception as e:
            messages.error(request, f'Ошибка БД: {e}')

    return render(request, 'players/player_confirm_delete.html', {'player': player})


# === КОМАНДЫ ===

def team_list(request):
    teams = Team.objects.select_related('game').all().order_by('-total_earnings')
    return render(request, 'teams/team_list.html', {'teams': teams})


def team_detail(request, pk):
    team = get_object_or_404(Team, pk=pk)
    players = team.get_players()  # list of dicts: id, nickname, role, total_winnings

    user_role = request.session.get('user_role', 'guest')
    can_edit = user_role in ('operator', 'administrator')

    add_player_form = None

    if can_edit:
        if request.method == 'POST':
            form = AddPlayerToTeamForm(request.POST, team=team)
            if form.is_valid():
                player = form.cleaned_data['player']
                role = form.cleaned_data['role'] or None

                try:
                    # Вставляем связь в player_teams, избегая дубликатов
                    with connection.cursor() as cursor:
                        cursor.execute(
                            """
                            INSERT INTO player_teams (player_id, team_id, role)
                            VALUES (%s, %s, %s)
                            ON CONFLICT (player_id, team_id) DO NOTHING
                            """,
                            [player.id, team.id, role],
                        )
                    messages.success(
                        request,
                        f'Игрок {player.nickname} добавлен в команду {team.name}',
                    )
                    return redirect('team_detail', pk=team.id)
                except Exception as e:
                    messages.error(request, f'Ошибка БД: {e}')
            add_player_form = form
        else:
            add_player_form = AddPlayerToTeamForm(team=team)

    return render(request, 'teams/team_detail.html', {
        'team': team,
        'players': players,               # список dict'ов
        'add_player_form': add_player_form,
    })

@operator_required
def team_create(request):
    if request.method == 'POST':
        form = TeamForm(request.POST)
        if form.is_valid():
            try:
                team = form.save()
                messages.success(request, f'Команда {team.name} создана!')
                return redirect('team_detail', pk=team.pk)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = TeamForm()

    return render(request, 'teams/team_form.html', {
        'form': form,
        'title': 'Создать команду',
    })


@operator_required
def team_edit(request, pk):
    team = get_object_or_404(Team, pk=pk)

    if request.method == 'POST':
        form = TeamForm(request.POST, instance=team)
        if form.is_valid():
            try:
                form.save()
                messages.success(request, f'Команда {team.name} обновлена!')
                return redirect('team_detail', pk=pk)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = TeamForm(instance=team)

    return render(request, 'teams/team_form.html', {
        'form': form,
        'team': team,
        'title': f'Редактировать {team.name}',
    })


@admin_required
def team_delete(request, pk):
    team = get_object_or_404(Team, pk=pk)

    if request.method == 'POST':
        team_name = team.name
        # Удаляем связи игроков с командой через raw SQL
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM player_teams WHERE team_id = %s", [pk])
        team.delete()
        messages.success(request, f'Команда "{team_name}" удалена!')
        return redirect('team_list')

    # Считаем игроков через raw SQL
    with connection.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) FROM player_teams WHERE team_id = %s", [pk])
        players_count = cursor.fetchone()[0]

    return render(request, 'teams/team_confirm_delete.html', {
        'team': team,
        'players_count': players_count,
    })


# === ТУРНИРЫ ===

def tournament_list(request):
    tournaments = Tournament.objects.select_related('game', 'winner_team').all()
    return render(request, 'tournaments/tournament_list.html', {'tournaments': tournaments})


def tournament_detail(request, pk):
    tournament = get_object_or_404(Tournament, pk=pk)

    stages = TournamentStage.objects.filter(
        tournament=tournament
    ).order_by('stage_order')

    stages_with_matches = []
    for stage in stages:
        matches = Match.objects.filter(
            stage=stage
        ).select_related('team1', 'team2', 'winner_team').order_by('match_date', 'id')

        matches_with_score = []
        for match in matches:
            games = Game.objects.filter(match=match)
            score1 = sum(1 for g in games if g.winner_team_id == match.team1_id)
            score2 = sum(1 for g in games if g.winner_team_id == match.team2_id)
            matches_with_score.append({
                'match': match,
                'score1': score1,
                'score2': score2,
                'games': games,
            })

        stages_with_matches.append({
            'stage': stage,
            'matches': matches_with_score,
        })

    return render(request, 'tournaments/tournament_detail.html', {
        'tournament': tournament,
        'stages_with_matches': stages_with_matches,
    })


@operator_required
def tournament_create(request):
    if request.method == 'POST':
        form = TournamentForm(request.POST)
        if form.is_valid():
            try:
                tournament = form.save()
                messages.success(request, f'Турнир "{tournament.name}" создан!')
                return redirect('tournament_detail', pk=tournament.pk)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = TournamentForm()

    return render(request, 'tournaments/tournament_form.html', {
        'form': form,
        'title': 'Создать турнир',
    })


@operator_required
def tournament_edit(request, pk):
    tournament = get_object_or_404(Tournament, pk=pk)

    if request.method == 'POST':
        form = TournamentForm(request.POST, instance=tournament)
        if form.is_valid():
            try:
                form.save()
                messages.success(request, f'Турнир "{tournament.name}" обновлён!')
                return redirect('tournament_detail', pk=pk)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = TournamentForm(instance=tournament)

    return render(request, 'tournaments/tournament_form.html', {
        'form': form,
        'tournament': tournament,
        'title': f'Редактировать "{tournament.name}"',
    })


@admin_required
def tournament_delete(request, pk):
    tournament = get_object_or_404(Tournament, pk=pk)

    if request.method == 'POST':
        try:
            tournament_name = tournament.name
            tournament.delete()
            messages.success(request, f'Турнир "{tournament_name}" удалён!')
            return redirect('tournament_list')
        except Exception as e:
            messages.error(request, f'Ошибка БД: {e}')

    return render(request, 'tournaments/tournament_confirm_delete.html', {'tournament': tournament})


# === МАТЧИ ===

@operator_required
def match_create(request):
    stage_id = request.GET.get('stage')
    initial = {}
    if stage_id:
        initial['stage'] = stage_id

    if request.method == 'POST':
        form = MatchForm(request.POST)
        if form.is_valid():
            try:
                match = form.save()
                messages.success(request, 'Матч создан!')
                return redirect('tournament_detail', pk=match.stage.tournament_id)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = MatchForm(initial=initial)

    return render(request, 'matches/match_form.html', {
        'form': form,
        'title': 'Создать матч',
    })


@operator_required
def match_edit(request, pk):
    match = get_object_or_404(Match, pk=pk)

    if request.method == 'POST':
        form = MatchForm(request.POST, instance=match)
        if form.is_valid():
            try:
                match = form.save()
                messages.success(request, 'Матч обновлён!')
                return redirect('tournament_detail', pk=match.stage.tournament_id)
            except Exception as e:
                messages.error(request, f'Ошибка БД: {e}')
    else:
        form = MatchForm(instance=match)

    return render(request, 'matches/match_form.html', {
        'form': form,
        'match': match,
        'title': 'Редактировать матч',
    })


@admin_required
def match_delete(request, pk):
    match = get_object_or_404(Match, pk=pk)
    tournament_id = match.stage.tournament_id if match.stage else None

    if request.method == 'POST':
        try:
            match.delete()
            messages.success(request, 'Матч удалён!')
            if tournament_id:
                return redirect('tournament_detail', pk=tournament_id)
            return redirect('tournament_list')
        except Exception as e:
            messages.error(request, f'Ошибка БД: {e}')

    return render(request, 'matches/match_confirm_delete.html', {'match': match})


# === ДЕТАЛИ МАТЧА ===

def match_detail(request, pk):
    """Просмотр игр матча"""
    match = get_object_or_404(Match, pk=pk)
    games = Game.objects.filter(match=match).select_related('map', 'winner_team').order_by('game_number')

    games_with_stats = []
    for game in games:
        stats = PlayerGameStats.objects.filter(game=game).select_related('player', 'hero')

        # Разделяем статистику по командам через raw SQL
        team1_stats = []
        team2_stats = []

        if match.team1_id and match.team2_id:
            with connection.cursor() as cursor:
                # Игроки team1
                cursor.execute("""
                    SELECT pt.player_id FROM player_teams pt WHERE pt.team_id = %s
                """, [match.team1_id])
                team1_player_ids = {row[0] for row in cursor.fetchall()}

                # Игроки team2
                cursor.execute("""
                    SELECT pt.player_id FROM player_teams pt WHERE pt.team_id = %s
                """, [match.team2_id])
                team2_player_ids = {row[0] for row in cursor.fetchall()}

            for s in stats:
                if s.player_id in team1_player_ids:
                    team1_stats.append(s)
                elif s.player_id in team2_player_ids:
                    team2_stats.append(s)

        games_with_stats.append({
            'game': game,
            'team1_stats': team1_stats,
            'team2_stats': team2_stats,
        })

    return render(request, 'matches/match_detail.html', {
        'match': match,
        'games_with_stats': games_with_stats,
    })