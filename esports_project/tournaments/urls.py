# esports_project/tournaments/urls.py

from django.urls import path
from . import views

urlpatterns = [
    # Аутентификация
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),

    # Главная
    path('', views.home, name='home'),

    # Игроки
    path('players/', views.player_list, name='player_list'),
    path('players/create/', views.player_create, name='player_create'),
    path('players/<int:pk>/', views.player_detail, name='player_detail'),
    path('players/<int:pk>/edit/', views.player_edit, name='player_edit'),
    path('players/<int:pk>/delete/', views.player_delete, name='player_delete'),

    # Команды
    path('teams/', views.team_list, name='team_list'),
    path('teams/create/', views.team_create, name='team_create'),
    path('teams/<int:pk>/', views.team_detail, name='team_detail'),
    path('teams/<int:pk>/edit/', views.team_edit, name='team_edit'),
    path('teams/<int:pk>/delete/', views.team_delete, name='team_delete'),

    # Турниры
    path('tournaments/', views.tournament_list, name='tournament_list'),
    path('tournaments/create/', views.tournament_create, name='tournament_create'),
    path('tournaments/<int:pk>/', views.tournament_detail, name='tournament_detail'),
    path('tournaments/<int:pk>/edit/', views.tournament_edit, name='tournament_edit'),
    path('tournaments/<int:pk>/delete/', views.tournament_delete, name='tournament_delete'),

    # Матчи
    path('matches/create/', views.match_create, name='match_create'),
    path('matches/<int:pk>/', views.match_detail, name='match_detail'),
    path('matches/<int:pk>/edit/', views.match_edit, name='match_edit'),
    path('matches/<int:pk>/delete/', views.match_delete, name='match_delete'),
]