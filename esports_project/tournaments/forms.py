# esports_project/tournaments/forms.py

from django import forms
from .models import Player, Team, Tournament, Match, TournamentStage, Game, Country, GamesList
from django.db import connection

STATUS_CHOICES = [
    ('active', 'Active'),
    ('inactive', 'Inactive'),
]


class PlayerForm(forms.ModelForm):
    status = forms.ChoiceField(choices=STATUS_CHOICES)

    class Meta:
        model = Player
        fields = ['nickname', 'full_name', 'birthdate', 'country', 'role',
                  'total_winnings', 'status']
        widgets = {
            'birthdate': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'


class TeamForm(forms.ModelForm):
    class Meta:
        model = Team
        fields = ['name', 'coach', 'manager', 'game', 'total_earnings', 'created_at', 'captain']
        widgets = {
            'created_at': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'
        # Ограничиваем капитанов только игроками этой команды (если редактируем)
        if self.instance and self.instance.pk:
            self.fields['captain'].queryset = Player.objects.filter(
                playerteam__team=self.instance
            )


class TournamentForm(forms.ModelForm):
    class Meta:
        model = Tournament
        fields = ['name', 'tier', 'prize_pool', 'location', 'max_number_of_teams',
                  'start_date', 'end_date', 'game', 'winner_team']
        widgets = {
            'start_date': forms.DateInput(attrs={'type': 'date'}),
            'end_date': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'


class TournamentStageForm(forms.ModelForm):
    """Форма для создания/редактирования этапа турнира"""
    class Meta:
        model = TournamentStage
        fields = ['tournament', 'name', 'stage_type', 'bracket_type', 'stage_order']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'


class MatchForm(forms.ModelForm):
    class Meta:
        model = Match
        fields = ['stage', 'team1', 'team2', 'winner_team', 'match_date']
        widgets = {
            'match_date': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'

    def clean(self):
        cleaned = super().clean()
        team1 = cleaned.get('team1')
        team2 = cleaned.get('team2')
        winner = cleaned.get('winner_team')

        if team1 and team2 and team1 == team2:
            self.add_error('team2', 'Команда 1 и команда 2 не могут совпадать.')

        if winner and winner not in (team1, team2):
            self.add_error('winner_team', 'Победитель должен быть одной из команд матча.')

        return cleaned


class GameForm(forms.ModelForm):
    """Форма для создания/редактирования игры в матче"""
    class Meta:
        model = Game
        fields = ['match', 'game_number', 'map', 'team1_score', 'team2_score', 'winner_team']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'


class LoginForm(forms.Form):
    """Форма входа"""
    ROLE_CHOICES = [
        ('client', '👁️ Клиент (только просмотр)'),
        ('operator', '⚙️ Оператор (управление турнирами)'),
        ('administrator', '🔐 Администратор (полный доступ)'),
    ]

    role = forms.ChoiceField(
        choices=ROLE_CHOICES,
        widget=forms.RadioSelect(attrs={'class': 'role-radio'}),
        label='Выберите роль'
    )
    password = forms.CharField(
        widget=forms.PasswordInput(attrs={
            'class': 'form-input',
            'placeholder': 'Введите пароль'
        }),
        label='Пароль'
    )


class AddPlayerToTeamForm(forms.Form):
    """Форма для добавления игрока в команду"""
    player = forms.ModelChoiceField(
        queryset=Player.objects.none(),
        label='Игрок'
    )
    role = forms.CharField(
        max_length=100,
        required=False,
        label='Роль в команде (опционально)'
    )

    def __init__(self, *args, **kwargs):
        team: Team | None = kwargs.pop('team', None)
        super().__init__(*args, **kwargs)

        # Стили
        for field in self.fields.values():
            field.widget.attrs['class'] = 'form-input'

        # Базовый список игроков
        qs = Player.objects.all().order_by('nickname')

        # Если команда задана — исключаем уже привязанных к ней игроков
        if team is not None:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT player_id FROM player_teams WHERE team_id = %s",
                    [team.id],
                )
                existing_ids = [row[0] for row in cursor.fetchall()]
            if existing_ids:
                qs = qs.exclude(id__in=existing_ids)

        self.fields['player'].queryset = qs