# 🏆 Esports Tournaments

Веб-приложение для управления киберспортивными турнирами.
База данных PostgreSQL + веб-интерфейс на Django.

## Стек
- Python 3.x
- Django
- PostgreSQL

## Возможности
- CRUD для турниров, команд, игроков, матчей
- Авторизация пользователей
- Детальная статистика

## Установка

1. Клонируй репозиторий:
```bash
git clone https://github.com/Dwots/EsportsTournaments.git
cd EsportsTournaments
```

2. Создай виртуальное окружение:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
```

3. Создай базу данных PostgreSQL:
```bash
createdb esports_tournaments
psql -d esports_tournaments -f sql/01_schema.sql
psql -d esports_tournaments -f sql/02_seed_data.sql  # опционально
```

4. Настрой переменные окружения:
```bash
cp .env.example .env
# отредактируй .env — укажи свои данные
```

5. Примени миграции и запусти:
```bash
cd esports_project
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

6. Открой http://127.0.0.1:8000
